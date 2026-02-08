---
layout: post
title: Mistargeted DMA
description: Executing archive files as program code
author: wolfegarden
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

## Where is the SystemHeap located, and what is its allocated size?

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

* RootHeap  (0x80457C20)   [return value of createRoot]
** SystemHeap  (0x80457CC0)  requested size: 0x005DD268  [return value of create(..., RootHeap)]
*** ZeldaHeap (0x80502400) requested size: 0x00522B2C  [return value of create(..., SystemHeap)]
** DbPrintHeap  (0x80A34F30) size: 0x00001800
** CommandHeap  (0x80A367C0) size: 0x00001000
** ArchiveHeap  (0x80A377D0) size: 0x008DF400
** J2DHeap      (0x81316BE0) size: 0x0007D000
** GameHeap     (0x81393BF0) size: 0x0044E000

Alright, now that we know all of this, we can answer the question: “Why does `JKRAllocFromSysHeap` fail and return `0`?”

## Why does `JKRAllocFromSysHeap` fail and return `0`?

```c++
szpBuf = JKRHeap::alloc(JKRHeap::sSystemHeap, JKRAram::sSZSBufferSize, 0x20);`
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
}```

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

Currently W.I.P

## Observe the PPC instructions in the archives

The first step is to identify valid PPC instructions present in all of the game’s archives.

To achieve this, I wrote several Python scripts that:

1) decompress the archives from the Yaz0 format

2) scan the PPC instructions between 0x80000300 and 0x80000800 (corresponding to the different exception handlers)

3) verify that no instruction causes a crash or trap before execution reaches 0x80000300 (the first exception handler)

4) and log everything into a .txt file in the following format:

```
--- msgres03.arc --- <-- Archive name
0x80000300: sth r20, 0x2000(r11) <-- PPC instruction
0x80000304: bl 0x81020398
```

Fortunately, the game provides a large number of archives containing valid PPC instructions that does not cause crashes or traps. The most useful ones are typically the `st*` instructions or `branch` instructions, such as the one shown above.

## The Problems

So, to recap: Performing a simple sequence of actions in _Twilight Princess_ copies a chunk of data from ARAM to main memory starting at address `0x80000000`,
overwriting important system data and exception handlers, and usually causing execution to move into that data copied from ARAM.

In my opinion, this is the closest _Twilight Princess_ has ever come to arbitrary code execution. However, there are still several problems:

* The underlying mechanism that causes the `JKRAllocFromSysHeap` call to fail is not particularly well understood.
* Most pieces of data we can copy from ARAM don't do anything particularly interesting when executed, in part because:
* The FPU is disabled during this context-switch state, so any attempt to execute a floating-point instruction jumps to `0x80000800`.
* Even if we did get a jump to a player-controlled memory location, the amount of work that needs to be done to restore normal
  game operation from this state is non-trivial due to the critical global variables stored between `0x80000000` and `0x80000100` that are
  completely obliterated by this glitch.
