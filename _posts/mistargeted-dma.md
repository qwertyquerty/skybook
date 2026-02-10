---
layout: post
title: Mistargeted DMA
description: Executing archive files as program code
author: wolfegarden & Blizzard Blanc
categories: [Glitches]
tags: [glitch, ACE, unsolved, major]
pin: true
math: true
mermaid: true
date: 2025-09-12 00:00:00
---

## The Glitch

A _Twilight Princess_ glitch hunter, S0ft, posted a screenshot of some logs from Dolphin resembling the following:

```
Core\PowerPC\MMU.cpp:412 E[MASTER]: Warning: Unable to resolve write address 104100a3 PC 830
```

This immediately caught my attention. I see new crashes posted in Discord somewhat frequently, and most of them are simple, well-handled
memory errors caused by attempting to read from somewhere in the `0x0000`–`0x1000` range; that is, null pointer reads. There are dozens
of ways to make _Twilight Princess_ do that, and they're generally not that interesting, since the game's crash handler kicks in and
stops any further execution.

This one is different. Put simply, `PC` should not `830`. This means we haven't done an out-of-bounds _read_, we've done an out-of-bounds
_jump_, sending program execution off the rails entirely.

So I started investigating. Thankfully, this one is pretty easy to reproduce:

* perform fishing rod dupe (to overload `GameHeap`)
* Catch a fish and display the text “Fish On”, it also works with the Yeti minigame
* view an area banner, pick up an item, talk to an NPC, or a variety of other things to trigger the glitch

Sure enough, a breakpoint I'd set at `0x0000800` tripped. But how did we get here? Well, the answer was a lot weirder than I expected.

_An enormous shout-out here to Taka and the rest of the Twilight Princess Decompilation team, without whom this
analysis would not have been possible._

What's actually happened here is that we caused an out-of-bounds read, the same thing that usually happens with these _Twilight Princess_ crashes.

Specifically, in this function:

```c++
void OSSleepThread(OSThreadQueue* queue) {
    BOOL enabled;
    OSThread* currentThread;

    enabled = OSDisableInterrupts();
    currentThread = OSGetCurrentThread();

    currentThread->state = OS_THREAD_STATE_WAITING;    // memory error is on this line
    currentThread->queue = queue;
    AddPrio(queue, currentThread, link);
    RunQueueHint = TRUE;
    __OSReschedule();
    OSRestoreInterrupts(enabled);
}
```

`currentThread` is an invalid (_not_ `NULL`!) pointer, so the attempt to read `currentThread->state` crashes. But what happened to `currentThread`?
Well, `OSGetCurrentThread` returns the value of `OS_CURRENT_THREAD`, which is always stored at address `0x800000E4`. Sure enough, the value stored
at `OS_CURRENT_THREAD` wasn't a valid pointer.

Obviously, my first instinct was to set a memory breakpoint on `0x800000E4` in Dolphin and work from there. I set that up, performed the glitch again,
and Dolphin never observed the invalid pointer being written to that address, even though it still reported an invalid access exception.

Huh?

Well, either way, I noticed something else strange while looking at memory around `0x800000E4`. It looks for all the world like a `Yaz0`-compressed archive
(which the game uses for various resource files) has been placed at address `0x80000000` instead of the data that's supposed to be there.

About an hour later, I found the answer. This isn't a CPU-level copy or some kind of memory remapping, this is the result of a _DMA copy_ from some part
of ARAM to main memory starting at `0x80000000`. The mechanism that causes this is refreshingly simple:

```c++
static int JKRDecompressFromAramToMainRam(u32 src, void* dst, u32 srcLength, u32 dstLength,
                                          u32 offset, u32* resourceSize) {
    BOOL interrupts = OSDisableInterrupts();
    if (s_is_decompress_mutex_initialized == false) {
        OSInitMutex(&decompMutex);
        s_is_decompress_mutex_initialized = true;
    }
    OSRestoreInterrupts(interrupts);
    OSLockMutex(&decompMutex);

    u32 szsBufferSize = JKRAram::getSZSBufferSize();
    szpBuf = (u8*)JKRAllocFromSysHeap(szsBufferSize, 32);

    /* ... */

    decompSZS_subroutine(firstSrcData(), (u8*)dst);

    /* ... */
}
```

This code is a little unclear because of the use of some global variables, but `szpBuf` will eventually be used by `firstSrcData()` as the target
of a DMA copy operation. The problem is that `JKRDecompressFromAramToMainRam` doesn't check whether the `JKRAllocFromSysHeap` allocation succeeds; if
the allocation fails, `szpBuf` will become `0`, and the DMA operation will target the start of main memory. Since the DMA engine (apparently) can't
segfault, this just works and the copy result is aliased to `0x80000000`. This ends up copying up to `0x2000` bytes of the archive that's intended to
be decompressed, usually some kind of font, sound or animation file. Some archives may exceed the 0x2000 limit.

When the next thread yields, the OS tries to read the thread structure pointer from `0x800000E4`, which the DMA copy overwrote with an invalid pointer.
This traps, and execution is transferred to the out-of-bounds read handler at `0x80000300`. The trick is that since we copied up to `0x2000` bytes into RAM
here (some archives may exceed the 0x2000 limit), also overwrote the exception handler! That means that we're now executing the contents of that compressed archive file as code!

## Understanding the Different Heaps and Identifying the SystemHeap

### Where is the SystemHeap located, and what is its allocated size?

The first issue I ran into is that we didn’t know the memory range of `SystemHeap`, so I had to start by locating it. To do that, I located the `SystemHeap` pointer in Ghidra. In Ghidra I locate `JKRHeap::sSystemHeap`, which is a global in SDA read via `lwz ..., -0x7210(r13)`. Knowing the SDA base (`r13 = 0x80458580`), we can compute the absolute address of the global:

Address of the `sSystemHeap` variable = `0x80458580 - 0x7210 = 0x80451370` (address of the SDA slot)

So I launched Dolphin as well as DME, and went to the address `0x80451370`. I found a pointer there: `*(u32*)0x80451370 = 0x80457CC0`.
This pointer actually corresponds to `heapObj` (the `SystemHeap` object). Thanks to this discovery, I was able to determine the exact size of `SystemHeap` based on its `start`/`end`. To locate them, I searched for where the game performs a check: “Is address `ptr` between `start` and `end`?”, and I ended up at the function `JKRHeap::find`, which contains this code snippet:

```c++
if ((ptr < (this->members).start) || ((this->members).end <= ptr)) {
    pJVar2 = (JKRHeap *)0x0;
}
```
This is the piece of code responsible for answering our question: “Is address ptr between start and end?”
I then looked at the ASM instructions related to this part:

```asm
802ce8b0 80 03 00 30     lwz        r0,this+0x30(r3)
802ce8b4 7c 00 f0 40     cmplw      r0,r30
802ce8b8 41 81 00 68     bgt        LAB_802ce920
802ce8bc 80 1d 00 34     lwz        r0,0x34(r29)
802ce8c0 7c 1e 00 40     cmplw      r30,r0
802ce8c4 40 80 00 5c     bge        LAB_802ce920
```
This instruction sequence tells us that start is located at `heapObj(0x80457CC0) + 0x30 = 0x80457CF0 -> 0x80457D50`, and that end is located at `heapObj(0x80457CC0) + 0x34 = 0x80457CF4 -> 0x80A34F20`. I also wanted to make sure of the `SystemHeap` size: it is indicated at `heapObj(0x80457CC0) + 0x38 = 0x80457CF8 -> 0x005DD1D0`.
To confirm, I still computed end - start: `0x80A34F20 - 0x80457D50 = 0x005DD1D0`, so this is consistent with the size indicated at `heapObj(0x80457CC0) + 0x38`.
We can therefore finally define a memory range and a size for `SystemHeap`: `[0x80457D50-0x80A34F20)`
`0x005DD1D0 bytes = ~5.86 MiB (base 1024)`

I then compared the memory range of `SystemHeap` with the other memory ranges obtained by Zac, and I realized that `ZeldaHeap` was entirely contained within `SystemHeap`. So I wanted to see how `ZeldaHeap` was instantiated in memory. Here is the corresponding code found in `m_Do_machine::mDoMch_Create()`:

```c++
pJVar4 = JKRHeap::sSystemHeap;
/* zelda heap size is determined here */
SystemHeapFreeSize = JKRHeap::getFreeSize(JKRHeap::sSystemHeap);
pJVar5 = m_Do_ext::mDoExt_createZeldaHeap(SystemHeapFreeSize - 0x10000,pJVar4);
```

We can see that `pJVar4 = SystemHeap`, so we need to look at the code of `m_Do_ext::mDoExt_createZeldaHeap()`:
 
```c++
JKRExpHeap * m_Do_ext::mDoExt_createZeldaHeap(size_t size,JKRHeap *parent)
{
  zeldaHeap = JKRExpHeap::create(size,parent,true);
  return zeldaHeap;
}
```
We can see that the second argument is indeed the parent, so we can state with certainty that `SystemHeap` is the parent of `ZeldaHeap`. What’s interesting (and potentially explains some things) is that the size of `ZeldaHeap` is based on the free size in `SystemHeap`, leaving only 64 KiB free, so `ZeldaHeap` occupies almost all of SystemHeap.

### What is the hierarchy of the different heaps?

However, I also wanted to build the correct heap hierarchy, to understand in detail which heap is the parent of which heap. Also, in Zac’s tool, `rootHeap` wasn’t shown.
So I started trying to understand what `rootHeap` was. I browsed the decompilation and found this line in the function `firstInit()`:

```c++
rootHeap = JKRExpHeap::createRoot(CSetUpParam::maxStdHeaps, false);
```
So rootHeap is created through a call to `createRoot()`. I then set a breakpoint on this function and wrote down the register values `r3` (1st parameter), `r4` (2nd parameter), `LR`, and then `r3` after stepping out to observe the return value:

`r3 = 0x00000001 -> maxHeaps = 1
r4 = 0x00000000 -> errorFlag = false
LR = 0x80271CF0 -> caller (init framework)
r3 = 0x80457C20 (step-out)`

With this return value, we can determine the address of rootHeap: `0x80457C20`

Now that we have this information, we can try to understand the heap hierarchy, still in `firstInit()`:

```c++
systemHeap = JKRExpHeap::create(CSetUpParam::sysHeapSize, rootHeap, false);
```
I used the same approach to locate `systemHeap` with certainty by noting `r3`, `r4`, `r5`, `LR`, and `r3` (step-out):

`r3 = 0x005DD268 (sysHeapSize)
r4 = 0x80457C20 (parent, which indeed corresponds to rootHeap)
r5 = 0x00000000 (errorFlag)
r3 (step-out): 0x80457CC0`

So the return value confirms that the address of `SystemHeap` is indeed `0x80457CC0`, and that the parent of `SystemHeap` is `rootHeap`.
Warning: the size passed to `create()` (0x5DD268) includes overhead (header + alignment). The start/end fields observed via find give the managed range for the heap (0x5DD1D0), hence the 0x98 difference.

We can now understand how memory is organized. In `mDoMch_Create()`, the game creates multiple heaps by passing `rootHeap` (or `rootHeap2`, which equals rootHeap in retail, outside of debug):

```c++
JKRHeap* rootHeap = (JKRHeap*)JKRGetRootHeap();
#if DEBUG
JKRHeap* rootHeap2 = JKRGetRootHeap2();
#else
JKRHeap* rootHeap2 = rootHeap;
#endif
 
// Command Heap size: 4 KB
heap = mDoExt_createCommandHeap(commandHeapSize, rootHeap);
my_SysPrintHeap("コマンドヒープ", heap, commandHeapSize);
 
#if DEBUG
heap = DynamicModuleControlBase::createHeap(dynamicLinkHeapSize, rootHeap);
my_SysPrintHeap("ダイナミックリンクヒープ", heap, dynamicLinkHeapSize);
#endif
 
// Archive Heap size: 9085 KB
heap = mDoExt_createArchiveHeap(archiveHeapSize, rootHeap2);
my_SysPrintHeap("アーカイブヒープ", heap, archiveHeapSize);
 
// J2D Heap size: 500 KB
heap = mDoExt_createJ2dHeap(j2dHeapSize, rootHeap2);
my_SysPrintHeap("Ｊ２Ｄ用ヒープ", heap, j2dHeapSize);
 
// Game Heap size: 4408 KB
heap = mDoExt_createGameHeap(gameHeapSize, rootHeap);
my_SysPrintHeap("ゲームヒープ", heap, gameHeapSize);
 
[...]
```

Then:
 
```c++
JKRHeap* systemHeap = JKRGetSystemHeap();
s32 size = systemHeap->getFreeSize();
size -= 0x10000;
JUT_ASSERT(1549, size > 0);
JKRHeap* zeldaHeap = mDoExt_createZeldaHeap(size, systemHeap);
my_SysPrintHeap("ゼルダヒープ", zeldaHeap, size);
JKRSetCurrentHeap(zeldaHeap);
```

The breakpoint set on `JKRExpHeap::create()` shows these creations with known sizes and a constant parent. All of these heaps are created with parent `0x80457C20` (`RootHeap`), EXCEPT `ZeldaHeap`, whose parent is `0x80457CC0` (`SystemHeap`). The value of `r3` (step-out) after the breakpoint gives us the pointers to the heaps:

```
DbPrintHeap:
-> entry:
    r3 = 0x00001800
    LR = 0x8000ED00
-> exit:
    r3 = 0x80A34F30
 
CommandHeap:
-> entry:
    r3 = 0x00001000
    LR = 0x8000ED9C
-> exit:
    r3 = 0x80A367C0
 
ArchiveHeap:
-> entry:
    r3 = 0x008DF400
    LR = 0x8000EDCC
-> exit:
    r3 = 0x80A377D0
 
J2DHeap:
-> entry:
    r3 = 0x0007D000
    LR = 0x8000EE10
-> exit:
    r3 = 0x81316BE0
 
GameHeap:
-> entry:
    r3 = 0x0044E000
    LR = 0x8000ED30
-> exit:
    r3 = 0x81393BF0
 
ZeldaHeap:
-> entry:
    r3 = 0x00522B2C
    LR = 0x8000ED6C
-> exit:
    r3 = 0x80502400
  ```

Knowing all these values, we now have a structured and correct hierarchy of the different heaps:

```
* RootHeap  (0x80457C20)
** SystemHeap  (0x80457CC0)  requested size: 0x005DD268
*** ZeldaHeap (0x80502400) requested size: 0x00522B2C
** DbPrintHeap  (0x80A34F30) size: 0x00001800
** CommandHeap  (0x80A367C0) size: 0x00001000
** ArchiveHeap  (0x80A377D0) size: 0x008DF400
** J2DHeap      (0x81316BE0) size: 0x0007D000
** GameHeap     (0x81393BF0) size: 0x0044E000
```
Alright, now that we know all of this, we can answer the question: “Why does `JKRAllocFromSysHeap` fail and return `0`?”

```c++
szpBuf = JKRHeap::alloc(JKRHeap::sSystemHeap, JKRAram::sSZSBufferSize, 0x20);
```

I started by looking, inside the function `JKRDecompressFromAramToMainRam()`, at how `szpBuf` was instantiated. We can see that the game calls `JKRHeap::alloc()`, so I set a breakpoint on it. I performed the glitch up to the DMA copy, and I was able to observe some registers when the breakpoint hit:

`r3 = 0x80457CC0 (heap pointer -> SystemHeap)
r4 = 0x00002000 (8192 bytes requested)
r5 = 0x00000020 (alignment 0x20)
LR = 0x802D28AC (JKRDecompressFromAramToMainRam)`

So we know the game requests 8 KiB from `SystemHeap` for `szpBuf`.

I then looked at how the game checks the amount of free space in the various heaps. I located a function responsible for that: `JKRHeap::getTotalFreeSize()`. So I set a breakpoint on it, and right before the DMA copy the game calls `JKRHeap::getTotalFreeSize()`. I then looked at the `LR` register to see which function called it, and I landed on address `0x8000B494`, which corresponds to the function `m_Do_machine::myMemoryErrorRoutine()`.

I set a breakpoint on `0x8000B494` to observe the value returned in `r3`, and I observed the value `0x00000CCC`, which corresponds to 3276 bytes free.
And when returning from `JKRHeap::alloc` (breakpoint at `0x802D28AC`), I observed `r3 = 0x00000000`.
So the game requests `0x2000` (8192 bytes) from `SystemHeap`, but `SystemHeap` only has `0xCCC` (3276 bytes) of free memory, therefore the allocation returns `0`.

Now, the question I want an answer to is: how does the fishing rod dupe affect memory, and how does it become “stressed”?

## How does duplicating the fishing rod affect memory allocation?

### How does the fishing rod dupe affect GameHeap?

To begin, I performed fishing rod duplications at runtime and observed how many KiB `GameHeap` and `ZeldaHeap` lost per duplication. I noticed a decrease of 5–6 KiB for `ZeldaHeap` and a loss of 50–51 KiB for `GameHeap`.
I then looked into the fishing rod actor code to see where the object was created, and I found this function: 

`fopAcM_entrySolidHeap()`, which itself calls `useHeapInit()`:
 
```c++
if (!fopAcM_entrySolidHeap(i_this, useHeapInit, heap_size)) {
    OS_REPORT("//////////////MG_ROD SET NON !!\n");
    return cPhs_ERROR_e;
}
```
The function `useHeapInit()` is extremely large, but you should know that heap size can vary depending on two contexts named UKI/LURE:

When the fishing rod has no lure, the game allocates `0xC9A0 bytes`: this is UKI mode.
However, when the fishing rod has a lure, the game allocates `0x15FE0 bytes`.

So you should keep in mind that heap size can be: `0x0000C9A0` or `0x00015FE0`. To confirm that, I ran a runtime test and observed the values in registers `r3`, `r4`, `r5`, `LR`, and `r3` (step-out) to see the return value:

`r3 = 0x80A0A97C (actor)
r4 = 0x80C85D08 (callback, i.e. `useHeapInit()` or a wrapper pointing to it)
r5 = 0x0000C9A0 (size, consistent with the actor code “UKI”)
LR = 0x80C86500 (return address)
r3 (step-out): 0x00000001 (success)`

So I looked at the decompilation of the function `fopAcM_entrySolidHeap()`:

```c++
bool fopAcM_entrySolidHeap(fopAc_ac_c* i_actor, heapCallbackFunc i_heapCallback, u32 i_size) {
    u8 var_r31 = fopAcM::HeapAdjustUnk;
    if (i_size & 0x80000000) {
        fopAcM::HeapAdjustUnk = true;
    }
    [...]
    u32 size = i_size & 0xFFFFFF;
    bool result = fopAcM_entrySolidHeap_(i_actor, i_heapCallback, size);
#if DEBUG
    fopAcM::HeapDummyCheck = var_r29;
#endif
    fopAcM::HeapAdjustUnk = var_r31;
    fopAcM::HeapAdjustEntry = var_r30;
    return result;
}
```

This piece of code proves that `fopAcM_entrySolidHeap()` is a wrapper that calls `fopAcM_entrySolidHeap_()`, so let’s look at the decompilation of `fopAcM_entrySolidHeap_()`:

```c++
while (true) {
    if (i_size != 0) {
        if (fopAcM::HeapAdjustVerbose) {
            // Attempting to allocate with estimated heap size (%08x). [%s]
            OS_REPORT("見積もりヒープサイズで(%08x)確保してみます。 [%s]\n", i_size,
                      procNameString);
        }
 
        heap = mDoExt_createSolidHeapFromGame(i_size, 0x20);
        if (heap != NULL) {
            if (fopAcM::HeapAdjustVerbose) {
                // Attempting registration with estimated heap size. %08x [%s]
                OS_REPORT("見積もりヒープサイズで登録してみます。%08x [%s]\n", heap,
                          procNameString);
            }
            result = fopAcM_callCallback(i_actor, i_heapCallback, heap);
```
So the game attempts to allocate a `JKRSolidHeap` tied to the actor inside `GameHeap`; if it succeeds, it calls `fopAcM_callCallback`, which therefore corresponds to `useHeapInit()`.
So our allocation flow is as follows:
`dmg_rod_Create → fopAcM_entrySolidHeap → fopAcM_entrySolidHeap_ → (allocate solid heap) → fopAcM_callCallback → useHeapInit`

I still preferred to produce a runtime proof. To do that, I set a breakpoint on `entrySolidHeap()` as well as on `d_a_mg_rod::useHeapInit()`. The breakpoint on `entrySolidHeap()` does indeed trigger first, followed by `useHeapInit()`.
So we have our first answer as to why `GameHeap` gets overloaded: when we duplicate the fishing rod, the game tries to allocate a `JKRSolidHeap` of about `0xC9A0` bytes in `GameHeap`.

I also wanted to be sure by looking at how the game normally destroys instances by setting breakpoints on the functions related to memory destruction. Here is the call chain:
`fpcDt_deleteMethod() -> fpcBs_Delete() -> dmg_rod_Delete() -> JKRHeap::destroy() -> JKRSolidHeap::do_destroy() -> JKRHeap::free() -> ~JKRHeap::free()`

So I set a breakpoint on `JKRSolidHeap::do_destroy()` at the moment it calls `JKRHeap::free()`, and I got:

`r3 = 0x81673FE0 (pointer to the SolidHeap)
r4 = 0x81393BF0 (parent heap, here GameHeap)`
So our `SolidHeap` living inside `GameHeap` is indeed destroyed when putting the fishing rod away. Let’s see how the game behaves when duplicating it: I set a breakpoint on each of the functions mentioned above, and there were no hits. So the duplication completely short-circuits the deletion of the `SolidHeap` in `GameHeap`, which gradually overloads memory.

While running these tests, I also noticed that the SolidHeaps were created with a constant stride of `0xCA40`:

`81671d80
8167e7c0
8168b200
81697c40
816a4680
816b10c0
[...]`

The difference with the `0xC9A0` bytes observed above is due to the header + alignment:
`0xCA40 - 0xC9A0 = 0xA0`

However, that still doesn’t explain why ZeldaHeap also gets overloaded, so let’s look at that.

### How does the fishing rod dupe affect ZeldaHeap?

I started by setting a breakpoint on `JKRHeap::alloc()` with the condition: `r3 == 0x80502400 (ZeldaHeap)`.
That allowed me to see that it hits three times per dupe, always with the same sizes:

```
1st hit: 0x24
2nd hit: 0x60
3rd hit: 0x1690
```
The small structures `(0x24 and 0x60)` are “infrastructure” objects (append, request, ...). The big one `(0x1690)` is the actual process/actor instance on the f_pc side.
I then followed the call stack to find the caller code. Here is how those hits unfold:

1st hit: `fopAcM_CreateAppend()` → `cMl::memalignB(-4, 0x24)`
2nd hit: `fpcCtRq_Create(...)` → `cMl::memalignB(-4, 0x60)`
3rd hit: `fpcBs_Create(profname, procID, append)` → `cMl::memalignB(-4, 0x1690)`
But what does the code for `cMl::memalignB()` correspond to?

```c++
/* __stdcall cMl::memalignB(int, unsigned long) */
 
void* cMl::memalignB(int alignment, size_t size)
{
    void* pvVar1;
 
    if (size == 0) {
        pvVar1 = (void*)0x0;
    } else {
        pvVar1 = JKRHeap::alloc(Heap, size, alignment);
    }
    return pvVar1;
}
```
It’s simply a piece of code that handles allocation for the different processes by calling `JKRHeap::alloc()`.
So the decrease in `ZeldaHeap` is tied to the process created by `f_pc_base::fpcBs_Create()`, not to the 3D models in the `SolidHeap` contained in `GameHeap`.
Next, I wanted to determine with certainty which process leaks.

So I started looking at the code of `f_pc_base::fpcBs_Create()` and set a breakpoint on it:

```c++
base_process_class* fpcBs_Create(s16 i_profname, fpc_ProcID i_procID, void* i_append) {
    process_profile_definition* pprofile;
    base_process_class* pprocess;
    u32 size;
 
    pprofile = (process_profile_definition*)fpcPf_Get(i_profname);
    size = pprofile->process_size + pprofile->unk_size;
 
    pprocess = (base_process_class*)cMl::memalignB(-4, size);
    if (pprocess == NULL) {
        return NULL;
    }
    [...]
}
```
At the moment of the breakpoint, on entry, `r3 == 0x2E4`. So I then set a breakpoint on `fpcPf_Get()` to retrieve `pprofile`, and another breakpoint on `fopAcM_getProcNameString()` to retrieve the string associated with this `procID`.
I was then able to see that the string read was: "740-1", which matches the logs returned by Dolphin when `GameHeap` is full:

`06:28:585 Core\HW\EXI\EXI_DeviceIPL.cpp:307 N[OSREPORT]: [m[41;37m[ERROR]最大空きヒープサイズで登録失敗。000001e0[740-1]`

We know that `cMl::memalignB()` is responsible for allocations, so I looked at its return values to see if they changed depending on the dupes. I observed that the return values for `0x24` and `0x60` remain identical on every dupe -> the game keeps using the exact same address every time. However, the return value for `0x1690 (pprocess)` changes on every dupe, going “downward” -> it ends up stacking up.

Conclusion: it’s not just fragmentation; there is an accumulation of `pprocess` instances.

Here is an example of pprocess addresses used:

```
809fa154
809f8ab4
809f7414
809f5d74
809f46d4
809f3034
809f1994
809f02f4
[...]
```
We can also see that the delta is `0x16A0`, i.e. `0x1690 + 0x10`, which matches perfectly with `0x10` alignment or a header.
I still wanted to make sure that the `pprocess` instances were not being freed. To do that, I set a breakpoint on `JKRHeap::free()` with the condition:

`r3 == 0x80502400 (ZeldaHeap) && (r4 == 0x809F8AB4 || r4 == 0x809F7414 || r4 == 0x809F5D74 || r4 == 0x809F46D4 ...)`
where the r4 values correspond to the `pprocess` pointers.

-> Without duplication, the `free()` breakpoint hits when we put the fishing rod away.
-> With duplication: no hits -> therefore the `pprocess` created in `ZeldaHeap` is never destroyed (except on zone change, where global cleanup eventually happens).

Alright: we now know how the game allocates and frees its memory during duplication and in the normal state, and we know why `GameHeap` and `ZeldaHeap` get overloaded. However, we still do not know what is contained inside the `SolidHeap` within `GameHeap`, nor what the `pprocess` within `ZeldaHeap` contains, so we’re going to look into that now.

### What does the SolidHeap contain, given that it is itself a sub-heap of the GameHeap?

I started with the `SolidHeap` contained in `GameHeap`. To understand what was in the `SolidHeap`, I ran my tests without duplication. I retrieved the address of my `SolidHeap` (at that time, because actors are loaded dynamically): `0x81702A50`.
After retrieving it, I set a breakpoint on `JKRSolidHeap::do_alloc()` (`0x802D0CB0`) with the condition `r3 (heap) == 0x81702A50`. That allowed me to identify all allocations performed on that SolidHeap `(r3 == heap, r4 == size, r5 == alignment)`:

-> A lot of small allocations aligned to 0x04:

```
(r3=81702a50 r4=00000030 r5=00000004 00000030 ...)
(r3=81702a50 r4=000000dc r5=00000004 000000dc ...)
...
```
-> A few large allocations aligned to 0x20:

```
(81702a50 00000300 00000020 00000300 ...)
(81702a50 00000300 00000020 00000300 ...)
...
```
-> And one very large allocation aligned to 0x04:
```
(81702a50 00000970 00000004 00000970 ...)
```

All of these allocations originate from the same `LR = 0x802CE4F0` (`JKRHeap::alloc(u32 size, int alignment)`) → `0x802CE474` (`JKRHeap::alloc(u32 size, int alignment, JKRHeap* heap)`) → `0x802D0A84` (`JKRSolidHeap::create(u32 size, JKRHeap* heap, bool useErrorHandler)`) → `0x8000EEA8` (`mDoExt_createSolidHeap(u32 i_size, JKRHeap* i_parent, u32 i_alignment)`) → `0x8000EF08` (`mDoExt_createSolidHeapFromGame(u32 i_size, u32 i_alignment)`) → `0x8001A240` (`fopAcM_entrySolidHeap_(fopAc_ac_c* i_actor, heapCallbackFunc i_heapCallback, u32 i_size)`) → `0x8001A508` (`fopAcM_entrySolidHeap(fopAc_ac_c* i_actor, heapCallbackFunc i_heapCallback, u32 i_size)`) → ...

So we are dealing with a loader/constructor that: loads a resource, instantiates structures, and allocates multiple blocks (small + medium + large) within the same heap.
The `0x300` bytes aligned to `0x20` could very likely be J3D-related. In J3D (BMD/BDL), this fits very well with creating “renderable” structures (packets, tables, buffers, etc.) for a J3D model.
The small allocations aligned to `0x04` would therefore be small CPU-side structs (objects, lists, nodes, matrices/MTX, wrappers, handles, ...)
And the very large `0x970`-byte allocation aligned to `0x4`: the most plausible interpretation here is the main resource block or large sub-sets (model chunk, consolidated table, decompressed resources, ...)

Therefore, the `SolidHeap` contained in `GameHeap` serves as a resource sub-heap: it groups a resource block + runtime objects (instances/structures aligned to `0x04`) and 3D buffers aligned to `0x20` (consistent with 32-byte cacheline alignment) needed for rendering/animation.

### What do the processes created within the ZeldaHeap contain?

Now let’s look at what the `pprocess` in `ZeldaHeap` contains. First, we need to locate the process name or at least its identifier. Fortunately, it is written plainly in the function:

```c++
void __thiscall daAlink_c::setGroundFishingRodActor(daAlink_c *this)
 
{
  u32 uVar1;
 
  uVar1 = 0x2e4;
  f_op_actor_mng::fopAcM_create
            (0x2e4,0xffff011d,&(this->base).mLeftHandPos,0xffffffff,0,0,0xffffffff);
  (this->mItemAcKeep).m_id = uVar1;
  initFishingRodHand(this);
  return;
}
```
Then I started by locating the function `f_op_actor_mng::fopAcM_create()`:

```c++
fpc_ProcID fopAcM_create(s16 i_procName, u16 i_setId, u32 i_parameters, const cXyz* i_pos,
                         int i_roomNo, const csXyz* i_angle, const cXyz* i_scale, s8 i_argument,
                         createFunc i_createFunc) {
    fopAcM_prm_class* append = createAppend(i_setId, i_parameters, i_pos, i_roomNo, i_angle,
                                            i_scale, i_argument, fpcM_ERROR_PROCESS_ID_e);
    if (append == NULL) {
        return fpcM_ERROR_PROCESS_ID_e;
    }
 
    return fpcM_Create(i_procName, i_createFunc, append);
}
```
So the identifier of our process is `0x2E4`, with parameters `0xFFFF011D`.
We can see that the function calls `createAppend()`:

```c++
fopAcM_prm_class* createAppend(u16 i_setId, u32 i_parameters, const cXyz* i_pos, int i_roomNo,
                               const csXyz* i_angle, const cXyz* i_scale, s8 i_argument,
                               fpc_ProcID i_parentId) {
    fopAcM_prm_class* append = fopAcM_CreateAppend();
    if (append == NULL) {
        return NULL;
    }
 
    append->base.setID = i_setId;
 
    if (i_pos != NULL) {
        append->base.position = *i_pos;
    } else {
        append->base.position = cXyz::Zero;
    }
 
    append->room_no = i_roomNo;
 
    if (i_angle != NULL) {
        append->base.angle = *i_angle;
    } else {
        append->base.angle = csXyz::Zero;
    }
 
    if (i_scale != NULL) {
        append->scale.x = 10.0f * i_scale->x;
        append->scale.y = 10.0f * i_scale->y;
        append->scale.z = 10.0f * i_scale->z;
    } else {
        append->scale.x = 10;
        append->scale.y = 10;
        append->scale.z = 10;
    }
 
    append->base.parameters = i_parameters;
    append->parent_id = i_parentId;
    append->argument = i_argument;
 
    return append;
}
```
So I set a breakpoint at the entry of the function and on the instruction that calls `createAppend()`. Here are the captured registers:

```
-> fopAcM_create(...):
 
r3 == 0x000002E4 | procName (Fishing Rod)
r4 == 0x0000FFFF | setId
r5 == 0xFFFF011D | parameters
r6 == 0x80A1D8F4 | &mLeftHandPos
r7 == 0xFFFFFFFF | roomNo
r8 == 0x00000000 | angle
r9 == 0x00000000 | scale
r10 == 0xFFFFFFFF | argument
r3 (step over) = 0x80A24EFC | pointer to append (the block passed as parameter to `fpcM_Create(...)`)

-> createAppend(...):
 
r3 == 0x0000FFFF | setId
r4 == 0xFFFF011D | parameters
r5 == 0x80A1D8F4 | pos
r6 == 0xFFFFFFFF | room
r7 == 0x00000000 | angle
r8 == 0x00000000 | scale
r9 == 0xFFFFFFFF | argument
r10 == 0xFFFFFFFF | errorId
```
Now that we have located the address of the append pointer, we can inspect it in hex to see what it contains:

```hex
FF FF 01 1D 45 66 57 34 43 4F 73 2B 3F 8F 69 A8
00 00 00 00 00 00 FF FF 0A 0A 0A 00 FF FF FF FF
FF FF 00 00 48 4D 00 FF 00 00 04 00 80 45 8E DC
80 A2 53 58 00 00 00 00 00 00 00 00 00 00 FF DC
80 A2 4F 20 00 00 00 00 00 00 00 00 00 00 00 00
```
We can immediately see that the very first word is `FFFF011D`, which corresponds exactly to the parameters passed to `createAppend(...)`. `append+0x04`, `append+0x08`, and `append+0x0C` look very much like three floats (possibly coordinates):

```
append+0x04 = pos.x
append+0x08 = pos.y
append+0x0C = pos.z
```
Other information such as roomNo, flags, argument (s8), etc. are visible in the hex dump, but they are not really useful for our current research.

Now let’s see who reads and writes to our append (`pprocess`). So I set a READ/WRITE breakpoint on `0x80A24EFC` (append):

```
11:54:386 Core\PowerPC\BreakPoints.cpp:395 N[MI]: MBP 800034e4 ( --- ) Write32 0 at 80a24efc ( --- )
11:56:873 Core\PowerPC\BreakPoints.cpp:395 N[MI]: MBP 80019c54 ( --- ) Write32 ffff011d at 80a24efc ( --- )
11:57:645 Core\PowerPC\BreakPoints.cpp:395 N[MI]: MBP 800190cc ( --- ) Read32 ffff011d at 80a24efc ( --- )
```

So when pulling out the fishing rod, the game overwrites the first 4 bytes with zeros, then writes the parameters at the time of the call to `createAppend()`, and finally an address `0x800190CC` consumes what was written. This is the function `fopAc_Create()`, which then handles creating the actor inside the `SolidHeap` (see above). During this process, `append` is passed as a parameter to build the `SolidHeap`. Here is the pipeline:

```
→ daAlink_c::setGroundFishingRodActor()
  → fopAcM_create(procName=0x2E4, params=0xFFFF011D, pos=...)
    → createAppend(...)   // allocate + fill append (ZeldaHeap)
     → fpcM_Create(procName, createFunc, append)
       → fopAc_Create(actor)
         → fopAcM_GetAppend(actor) → copy append → actor->home/params/etc
          → fopAcM_entrySolidHeap_(actor, callback, size)
            → mDoExt_createSolidHeapFromGame(...) (GameHeap)
              → actor->solidHeapPtr = heap
```
## Why does `JKRAllocFromSysHeap` fail and return `0`?

### What actually happens in memory when a fish is caught?

Now let’s look at what the game loads when catching a fish. In the Dolphin logs, we can see the loading of two archives: `Timer.arc` and `Z2Sound....arc`. So I started by setting a breakpoint on `JKRHeap::alloc()` in order to see the differences between when the game is stable and when the `gameheap` was overloaded. Here are the logs:

--> With dupe:

```
[...]
11:05:413 Core\PowerPC\PowerPC.cpp:646 N[MI]: BP 802ce4d4  --- (81393bf0 00003710 00000010 00003710 00000000 00000000 0011c664 0011c66c 803db190 802cfba4) LR=802ce4a0
11:09:719 Core\PowerPC\PowerPC.cpp:646 N[MI]: BP 802ce4d4  --- (817de4e0 0000005c 00000004 0000005c 00000000 00000000 00000000 0011c66c 803db1f0 802cf128) LR=802ce4bc
11:10:434 Core\PowerPC\PowerPC.cpp:646 N[MI]: BP 802ce4d4  --- (81393bf0 00011000 00000010 00011000 00000000 00000000 817de5c0 0011c66c 803db260 8002ceb4) LR=802ce4a0
11:11:157 Core\HW\EXI\EXI_DeviceIPL.cpp:307 N[OSREPORT]: [m[41;37m[ERROR]エラー: メモリを確保できません 69632(0x11000)バイト、 16 バイトアライメント from 81393bf0
11:11:159 Core\HW\EXI\EXI_DeviceIPL.cpp:307 N[OSREPORT]: [m[41;37m[ERROR]FreeSize=00003620 TotalFreeSize=00008250 HeapType=45585048(EXPH) HeapSize=0044df70 GameHeap
11:11:171 Core\PowerPC\PowerPC.cpp:646 N[MI]: BP 802ce4d4  --- (81507cd0 00000118 00000004 00000118 fffffffd 00000000 4565d0be a2b2e860 803db260 8020ee70) LR=802ce4bc
11:13:104 Core\PowerPC\PowerPC.cpp:646 N[MI]: BP 802ce4d4  --- (81507cd0 00000010 00000004 00000010 80c63190 726f6f74 803db210 a2b2e860 803db1a0 802dc5ac) LR=802ce4bc
11:16:535 Core\PowerPC\PowerPC.cpp:646 N[MI]: BP 802ce4d4  --- (81507cd0 00000030 00000004 00000030 00000000 00000000 81507ef8 a2b2e860 803db1a0 802dc5ac) LR=802ce4bc
[...]
```
--> Vanilla:

```
[...]
13:53:667 Core\PowerPC\PowerPC.cpp:646 N[MI]: BP 802ce4d4  --- (81507cd0 00000040 00000004 00000040 fffffffc 00000000 d5ed27c6 eaf693e4 803db260 8002483c) LR=802ce4bc
14:00:362 Core\PowerPC\PowerPC.cpp:646 N[MI]: BP 802ce4d4  --- (80502400 00000038 fffffffc 00000000 ffffffff 00000000 81507db0 eaf693e4 803db180 8020ee70) LR=80263250
14:00:818 Core\PowerPC\PowerPC.cpp:646 N[MI]: BP 802ce4d4  --- (80502400 00000060 fffffffc 00000000 80a24ee8 00000000 00000048 80a24ed8 803db1a0 802cf128) LR=80263250
14:01:141 Core\PowerPC\PowerPC.cpp:646 N[MI]: BP 802ce4d4  --- (80502400 00000170 fffffffc 001499df 00293d6c 00000008 0011c664 0011c66c 803db320 80023bc4) LR=80263250
14:01:493 Core\PowerPC\PowerPC.cpp:646 N[MI]: BP 802ce4d4  --- (80a367c0 00000024 fffffffc 00000024 00000004 00000004 00000001 00000000 803db180 80366964) LR=802ce4a0
14:01:853 Core\PowerPC\PowerPC.cpp:646 N[MI]: BP 802ce4d4  --- (80a377d0 00000070 00000000 00000070 00000003 803debb4 806861a8 80a3775c 8069bcd8 80015edc) LR=802ce4a0
14:02:381 Core\HW\DVD\DVDInterface.cpp:802 I[DVD]: Read: DVDOffset=33ef8600, DMABuffer = 0069bac0, SrcLength = 00000020, DMALength = 00000020
14:02:384 Core\PowerPC\PowerPC.cpp:646 N[MI]: BP 802ce4d4  --- (80a377d0 0000c720 00000020 0000c720 00000003 803db1a8 6de31bc4 36f18de2 803db070 00000000) LR=802ce4a0
14:03:867 Core\PowerPC\PowerPC.cpp:646 N[MI]: BP 802ce4d4  --- (80457cc0 00004000 ffffffe0 0000c720 00000000 00000000 8069bc7c 36f18de2 8069ba78 802cf128) LR=802da264
14:04:233 Core\HW\DVD\DVDInterface.cpp:802 I[DVD]: Read: DVDOffset=33ef8600, DMABuffer = 00a30f20, SrcLength = 00004000, DMALength = 00004000
14:04:236 Core\HW\DVD\DVDInterface.cpp:802 I[DVD]: Read: DVDOffset=33efc600, DMABuffer = 00a30f40, SrcLength = 00001140, DMALength = 00001140
14:04:248 Core\PowerPC\PowerPC.cpp:646 N[MI]: BP 802ce4d4  --- (81393bf0 000d2760 00000010 000d2760 00000000 00000000 0011c664 0011c66c 803db190 802cfba4) LR=802ce4a0
14:05:084 Core\PowerPC\PowerPC.cpp:646 N[MI]: BP 802ce4d4  --- (8170f490 0000005c 00000004 0000005c 00000000 00000000 00000000 0011c66c 803db1f0 802cf128) LR=802ce4bc
14:16:355 Core\PowerPC\PowerPC.cpp:646 N[MI]: BP 802ce4d4  --- (81393bf0 00011000 00000010 00011000 00000000 00000000 8170f570 0011c66c 803db260 8002ceb4) LR=802ce4a0
14:17:140 Core\PowerPC\PowerPC.cpp:646 N[MI]: BP 802ce4d4  --- (8170f580 000003e4 00000004 000003e4 00000000 00000000 81720580 0011c66c 803db260 802cfc84) LR=802ce4bc
[...]
```
We can see that the only notable difference is the failure to allocate a block of size `0x11000` bytes in `GameHeap`. But what could this huge size correspond to?
Since this happens while loading two archives, I started by looking at the code of the Timer actor. Luckily, I found it immediately:

```c++
int dTimer_c::_create() {
    int phase_state = dComIfG_resLoad(&m_phase, "Timer");
 
    fopMsg_prm_timer* appen;
    if (phase_state == cPhs_COMPLEATE_e) {
        appen = (fopMsg_prm_timer*)fopMsgM_GetAppend(this);
        if (appen == NULL) {
            return cPhs_ERROR_e;
        }
 
        dRes_info_c* resInfo = dComIfG_getObjectResInfo("Timer");
        JUT_ASSERT(0, resInfo != NULL);
        dComIfGp_setAllMapArchive(resInfo->getArchive());
 
        mp_heap = fopMsgM_createExpHeap(0x11000, NULL);
        JKRHeap* prev_heap = mDoExt_setCurrentHeap(mp_heap);
        if (mp_heap != NULL) {
            mp_heap->getTotalFreeSize();
 
            mp_tm_scrn = new dDlst_TimerScrnDraw_c();
            JUT_ASSERT(0, mp_tm_scrn != NULL);
 
            if (appen->timer_mode == 10) {
                mp_tm_scrn->setScreen(dComIfG_getTimerMode(), resInfo->getArchive());
            } else {
                mp_tm_scrn->setScreen(appen->timer_mode, resInfo->getArchive());
            }
 
            mDoExt_setCurrentHeap(prev_heap);
        } else {
            return cPhs_ERROR_e;
        }
    } else {
        return phase_state;
    }
```

This code starts by loading the Timer archive and retrieving its append (probably stored in `ZeldaHeap`, like the fishing rod’s). The game then tries to create a heap of size `0x11000` in the current heap (parent = NULL), which matches exactly our allocation failure. Since the current heap is an overloaded `GameHeap`, the game has no room to create that heap, so Timer ends up without a dedicated heap.
It then performs a check to ensure the heap exists (in our case heap == NULL), which has the effect of setting the current heap back to the previous heap—`ZeldaHeap` in this case.

To identify which heap was used as the fallback/previous heap, I set a breakpoint on `f_op_msg_mng::fopMsgM_createExpHeap()`, and once that breakpoint was hit, another one on `m_Do_ext::mDoExt_setCurrentHeap()`. At the hit, `r3 == 0x00000000` and `r3 (step-out) == 0x80502400`, so the game indeed supplies an invalid pointer after the allocation failure and retrieves `ZeldaHeap` as the current heap because before calling the function the current heap was `ZeldaHeap` (which is supposed to always be the case: when the game changes the current heap for a moment, it later restores `ZeldaHeap` as the current heap).

But let’s look more closely at how the game retrieves the previous heap. Here is the complete pipeline:

```
dTimer_c::_create
→ fopMsgM_createExpHeap(0x11000, NULL) == NULL
→ mDoExt_setCurrentHeap(NULL)
→ JKRHeap::becomeCurrentHeap(NULL)
→ return 0x80502400 (ZeldaHeap)
```

Let’s observe the PowerPC instructions of `becomeCurrentHeap()`:

```asm
802ce43c 90 6d 8d f4     stw        this,-0x720c(r13)=>JKRHeap::sCurrentHeap = NaP
802ce440 7c 03 03 78     or         this,r0,r0
802ce444 4e 80 00 20     blr
```
So sCurrentHeap is computed from `r13 - 0x720C`. Knowing `r13 == 0x80458580`, the absolute address is:

`0x80458580 - 0x0000720C = 0x80451374`

Knowing this address, we can now observe who reads/writes to this address when loading `Timer.arc`:

```
12:48:006 Core\HW\EXI\EXI_DeviceIPL.cpp:307 N[OSREPORT]: [m[41;37m[ERROR]エラー: メモリを確保できません 69632(0x11000)バイト、 16 バイトアライメント from 81393bf0
12:48:007 Core\HW\EXI\EXI_DeviceIPL.cpp:307 N[OSREPORT]: [m[41;37m[ERROR]FreeSize=00003620 TotalFreeSize=00008250 HeapType=45585048(EXPH) HeapSize=0044df70 GameHeap
12:48:008 Core\PowerPC\BreakPoints.cpp:395 N[MI]: MBP 802ce438 ( --- ) Read32 80502400 at 80451374 ( --- )
12:52:094 Core\PowerPC\BreakPoints.cpp:395 N[MI]: MBP 802ce43c ( --- ) Write32 0 at 80451374 ( --- )
13:09:084 Core\PowerPC\BreakPoints.cpp:395 N[MI]: MBP 802d1b40 ( --- ) Read32 0 at 80451374 ( --- )
13:09:627 Core\PowerPC\BreakPoints.cpp:395 N[MI]: MBP 802d1b40 ( --- ) Read32 0 at 80451374 ( --- )
13:10:076 Core\PowerPC\BreakPoints.cpp:395 N[MI]: MBP 802ce438 ( --- ) Read32 0 at 80451374 ( --- )
13:11:123 Core\PowerPC\BreakPoints.cpp:395 N[MI]: MBP 802ce43c ( --- ) Write32 80457cc0 at 80451374 ( --- )
13:11:587 Core\PowerPC\BreakPoints.cpp:395 N[MI]: MBP 802d1bbc ( --- ) Read32 80457cc0 at 80451374 ( --- )
13:12:036 Core\PowerPC\BreakPoints.cpp:395 N[MI]: MBP 802d1bbc ( --- ) Read32 80457cc0 at 80451374 ( --- )
13:12:674 Core\PowerPC\BreakPoints.cpp:395 N[MI]: MBP 802d1b40 ( --- ) Read32 80457cc0 at 80451374 ( --- )
13:14:097 Core\PowerPC\BreakPoints.cpp:395 N[MI]: MBP 802ce438 ( --- ) Read32 80457cc0 at 80451374 ( --- )
13:18:996 Core\PowerPC\BreakPoints.cpp:395 N[MI]: MBP 802ce43c ( --- ) Write32 80457cc0 at 80451374 ( --- )
13:19:374 Core\PowerPC\BreakPoints.cpp:395 N[MI]: MBP 802ce438 ( --- ) Read32 80457cc0 at 80451374 ( --- )
13:19:850 Core\PowerPC\BreakPoints.cpp:395 N[MI]: MBP 802ce43c ( --- ) Write32 8149f870 at 80451374 ( --- )
13:20:702 Core\PowerPC\BreakPoints.cpp:395 N[MI]: MBP 802ce438 ( --- ) Read32 8149f870 at 80451374 ( --- )
13:21:451 Core\PowerPC\BreakPoints.cpp:395 N[MI]: MBP 802ce43c ( --- ) Write32 80457cc0 at 80451374 ( --- )
```
We can see that for one instruction the game writes `0x00000000`, and a function (`0x802D1B40: JKRThreadSwitch::callback`) reads the value `0x00000000` twice. However, we also notice that after this read, `JKRThreadSwitch::callback()` sets `SystemHeap` as the current heap.
So let’s take a closer look at its code:

```c++
void JKRThreadSwitch::callback(OSThread* current, OSThread* next) {
    if (mUserPreCallback) {
        (*mUserPreCallback)(current, next);
    }
 
    sTotalCount = sTotalCount + 1;
 
    JKRHeap* next_heap = NULL;
    for (JSUListIterator<JKRThread> iterator = JKRThread::getList().getFirst(); iterator != JKRThread::getList().getEnd(); ++iterator) {
        JKRThread* thread = iterator.getObject();
 
        if (thread->getThreadRecord() == current) {
            thread->setCurrentHeap(JKRHeap::getCurrentHeap());
            if (thread->getLoadInfo()->isValid()) {
                thread->getLoadInfo()->addCurrentCost();
            }
        }
 
        if (thread->getThreadRecord() == next) {
            if (thread->getLoadInfo()->isValid()) {
                thread->getLoadInfo()->setCurrentTime();
                thread->getLoadInfo()->incCount();
            }
 
            if (sManager->mSetNextHeap) {
                next_heap = thread->getCurrentHeap();
                if (!next_heap) {
                    next_heap = JKRHeap::getCurrentHeap();
                } else if (JKRHeap::getRootHeap()->isSubHeap(next_heap)) {
                    continue;
#if PLATFORM_WII || PLATFORM_SHIELD
                } else if (JKRHeap::getRootHeap2()->isSubHeap(next_heap)) {
                    continue;
#endif
                } else {
                    switch (thread->getCurrentHeapError()) {
                    case 0:
                        JUT_PANIC(508, "JKRThreadSwitch: currentHeap destroyed.");
                        break;
                    case 1:
                        JUTWarningConsole("JKRThreadSwitch: currentHeap destroyed.\n");
                        next_heap = JKRHeap::getCurrentHeap();
                        break;
                    case 2:
                        next_heap = JKRHeap::getCurrentHeap();
                        break;
                    case 3:
                        next_heap = JKRHeap::getSystemHeap();
                        break;
                    }
                }
            }
        }
    }
 
    if (next_heap) {
        next_heap->becomeCurrentHeap();
    }
 
    if (mUserPostCallback) {
        (*mUserPostCallback)(current, next);
    }
}
```
At first, I thought the game was switching to `SystemHeap` by explicitly going through `case 3` of the `switch(thread->getCurrentHeapError())` in `JKRThreadSwitch::callback`. In theory, that path forces `next_heap` to point to `JKRHeap::getSystemHeap()`, then calls `JKRHeap::becomeCurrentHeap(next_heap)`. In that scenario, `SystemHeap` becomes the current heap, and all allocations that depend on the current heap end up being performed in `SystemHeap`, even when it is not the expected heap (`ZeldaHeap` / `GameHeap` / temporary heap).
This hypothesis seemed consistent with the symptoms observed. However, runtime analysis shows that this is not what actually happens.

To verify this, I instrumented `JKRThreadSwitch::callback` with several breakpoints:

--> On the final call:

`0x802D1C3C : bl JKRHeap::becomeCurrentHeap`

--> As well as on the instruction that corresponds explicitly to `case 3`:

`0x802D1C20 : lwz nextHeap, -0x7210(r13) ; sSystemHeap`

The results are unambiguous:
The breakpoint at `0x802D1C3C` does hit, with `r3 == 0x80457CC0`, which proves that `SystemHeap` indeed becomes the current heap at that moment. However, the breakpoint at `0x802D1C20` never hits, which demonstrates that the explicit load of `sSystemHeap` associated with `case 3` is never executed. Additionally, breakpoints placed on the branches leading to `switch(thread->getCurrentHeapError())`, notably around `0x802D1BFC`, show that this block is simply never reached: execution is short-circuited before entering the `switch`.

These observations therefore clearly prove that the game does not go through `case 3` to retrieve `SystemHeap`. So how does it get there then? In fact, it goes through a much more “mundane” path: it reuses the heap already stored inside the `JKRThread` object of the thread that becomes `next`, and then reapplies it as the current heap via `becomeCurrentHeap()`.


By backtracking execution, I found that `nextHeap` is actually initialized much earlier from `thread->currentHeap` (`lwz next, 0x74(thread)` then `or nextHeap, next, next`). With dupe, that value is already `SystemHeap`, whereas in vanilla it is `ZeldaHeap`. The thread switch therefore only restores a heap that is already corrupted, then calls `JKRHeap::becomeCurrentHeap(nextHeap)` without ever going through the fallback logic. The real cause is upstream: calls to `mDoExt_setCurrentHeap` (notably from `dTimer_c::_create` and `dMsgObject_c::changeGroupLocal`) temporarily modify `sCurrentHeap`, and if a thread is saved at that moment, its `currentHeap` gets polluted. The bug therefore comes from blindly restoring an invalid state, not from `case 3`. Here is the complete pipeline:

```
JKRThreadSwitch::callback(current, next) @ 0x802D1AE4
→ (thread == current) r0 = JKRHeap::sCurrentHeap @ 0x802D1B40
    → stw r0, 0x74(thread) (thread->currentHeap = sCurrentHeap) @ 0x802D1B48
        → (thread == next) lwz next, 0x74(thread) (next = thread->currentHeap) @ 0x802D1BAC
            → or nextHeap, next, next (nextHeap = next) @ 0x802D1BB0
                → bl JKRHeap::isSubHeap(...) @ 0x802D1BC4
                    → bl JKRHeap::becomeCurrentHeap(nextHeap) @ 0x802D1C3C
                        → JKRHeap::sCurrentHeap = nextHeap @ 0x802CE43C
```

Continuing the analysis, I tried to identify who actually writes `SystemHeap` into the `JKRThread` object, since the audio thread only restores a value that is already present in `thread->currentHeap`. For that, I set a watchpoint on `0x800000E4` (`OSCurrentThread`):

```
MBP Write32 8069d6c0 at 800000e4
PC == 803411f0
```

The disassembly at `0x803411f0` shows:

```asm
803411f0  stw r30, OSCurrentThread(r31)
```

This write is located in the OS scheduling path, more specifically during a context switch triggered by an interrupt. By walking back the stack via `r1`, I identified the caller as `__OSReschedule`, itself called from `__OSDispatchInterrupt`.

This establishes that the thread switch is initiated by OS scheduling in an interrupt context (in the capture, via the VI handler retrace), and that it occurs temporally after the allocation failure. The failure is not the direct cause of the interrupt; it lengthens the execution path and increases the probability that an interrupt tick will fall inside that window.

Then, by placing a breakpoint on `JKRThreadSwitch::callback (0x802D1AE4)`, I confirmed the exact sequence:

--> On the outgoing switch, `JKRHeap::sCurrentHeap` is saved into `currentThread->currentHeap` via `stw r0, 0x74(thread)`
 
--> On the incoming switch, `nextThread->currentHeap` is reloaded without validation
 
--> That value is immediately passed to `JKRHeap::becomeCurrentHeap`

Watchpoints on `thread->currentHeap` show that, in all savestates at different points (vanilla and dupe), the audio thread `(OSThread @ 0x8069C238)` already has:

`thread->currentHeap = 0x80457CC0 (SystemHeap)`

And this is true even before the audio thread is selected by the scheduler. Thus, the audio thread is not polluting anything: its `thread->currentHeap = SystemHeap` is a normal value initialized at creation. The problem is that when it is chosen as next, `JKR` blindly restores that value as the global current heap `(JKRHeap::sCurrentHeap)`, which can break the game code’s expectations about the active heap.

The question then becomes: why, with dupe, does the OS land precisely on a reschedule where `next = audioThread`, at the moment when the global heap state is critical for what happens next?

### Why does the game trigger the restoration of the AudioThread?

Analysis of the write paths to `JKRHeap::sCurrentHeap` shows several temporary calls to `mDoExt_setCurrentHeap`, notably from `dTimer_c::_create` and `dMsgObject_c::changeGroupLocal`. These functions modify `sCurrentHeap` transiently, without protection against interrupts.
In vanilla, these critical sections are short enough that the scheduler does not preempt the thread at that exact moment. With dupe, the failure to allocate `0x11000` bytes causes a longer execution path (`OSReport, error handling`), which increases the time window during which an interrupt can occur.

When the interrupt arrives at that moment, `__OSDispatchInterrupt` triggers `__OSReschedule`, which selects the audio thread because it is ready, high priority, and woken up by DSP/VI. Before switching, `JKRThreadSwitch::callback` saves the current heap state into the outgoing thread, then blindly restores that of the incoming thread.
So the bug does not come from an explicit fallback, nor a rescue logic, nor the audio thread itself, but from a blind restoration of a transient heap state captured during an asynchronous preemption.

The real pipeline is therefore the following:

```
vi::__VIRetraceHandler @ 0x8034BF6C
→ os::OSWakeupThread @ (call from 0x8034C1B8)
→ os::__OSDispatchInterrupt @ 0x8033DBCC
→ os::__OSReschedule @ 0x80341220
→ os::SelectThread @ 0x80340FFC (call from 0x8034123C)
→ os::OSCurrentThread store (stw r30, 0xE4(r31)) @ 0x803411F0
→ JKRThreadSwitch::callback @ 0x802D1AE4
→ (save) stw r0, 0x74(thread) @ 0x802D1B48
→ (load) lwz r?, 0x74(thread) @ 0x802D1BAC
→ JKRHeap::becomeCurrentHeap(nextHeap) @ 0x802D1C3C
→ (write) JKRHeap::sCurrentHeap = nextHeap @ 0x802CE43C
```

I then wanted to check whether allocations that are not supposed to be done on `SystemHeap` were occurring just before the MDMA. I started by setting a breakpoint on `JKRHeap::alloc()` with the condition `r3 == 0x80457CC0 (SystemHeap)`. I collected the logs to observe my registers, notably `r4` (size) and `r5` (alignment). I did the same thing without duplication, but this time with no condition on the breakpoint.

Result: allocations that are normally expected on `ZeldaHeap` (probably pprocess / append) end up happening on `SystemHeap`. However, its small free space of `64 KiB` means it fills up entirely. I also looked at `LR` at the time of the hits and landed on `0x802CE4B8`, corresponding to the function:

```c++
void* JKRHeap::alloc(u32 size, int alignment, JKRHeap* heap) {
    if (heap != NULL) {
        return heap->alloc(size, alignment);
    }
 
    if (sCurrentHeap != NULL) {
        return sCurrentHeap->alloc(size, alignment); // 0x802ce4b8
    }
 
    return NULL;
}
```

So we found the “culprit” function responsible for overloading `SystemHeap`. Now what is the connection with MDMA? Well, if the game calls `JKRAllocFromSysHeap()` from `JKRDecompressFromAramToMainRam()`, it forces the allocation to come from `SystemHeap` for the buffers (which is normal). However, since `SystemHeap` no longer has any free space, the game can no longer allocate the buffer: it becomes `0x00000000`, and the DMA copy is therefore performed to that address.

## Conclusion and Remaining Questions

What is extremely interesting after these discoveries is that `SystemHeap` is never supposed to remain the current heap. So in theory we can “leak” the desired code path into `SystemHeap` (at least everything that is supposed to go through `ZeldaHeap` normally via `JKRHeap::alloc()`, which retrieves the current heap).

Also, catching a fish and loading `Timer.arc` might not be the only trigger for `SystemHeap` -> currentHeap. In practice, we need to identify all heap creations larger than the remaining capacity of `GameHeap` once saturated; that should yield the same result. But also, in theory, we could force certain allocations in `SystemHeap` (that are supposed to be mandatory) to fail.

The fact that we can write `00 00 00 00` into `sCurrentHeap` for a short time window could also be interesting.

## Observe the PPC instructions in the archives

The first step is to identify valid PPC instructions present in all of the game’s archives.

To achieve this, I wrote several Python scripts that:

1) decompress the archives from the Yaz0 format

2) scan the PPC instructions between 0x80000300 and 0x80000800 (corresponding to the different exception handlers)

3) and log everything into a .txt file in the following format:

```
--- msgres03.arc --- <-- Archive name
0x80000300: sth r20, 0x2000(r11) <-- PPC instruction
0x80000304: bl 0x81020398
```

Fortunately, the game provides a large number of archives containing valid PPC instructions. The most useful ones are typically the `st*` instructions or `branch` instructions, such as the one shown above.

## The Problems

So, to recap: Performing a simple sequence of actions in _Twilight Princess_ copies a chunk of data from ARAM to main memory starting at address `0x80000000`,
overwriting important system data and exception handlers, and usually causing execution to move into that data copied from ARAM.

In my opinion, this is the closest _Twilight Princess_ has ever come to arbitrary code execution. However, there are still several problems:

* Most pieces of data we can copy from ARAM don't do anything particularly interesting when executed, in part because:
* The FPU is disabled during this context-switch state, so any attempt to execute a floating-point instruction jumps to `0x80000800`.
* Even if we did get a jump to a player-controlled memory location, the amount of work that needs to be done to restore normal
  game operation from this state is non-trivial due to the critical global variables stored between `0x80000000` and `0x80000100` that are
  completely obliterated by this glitch.
