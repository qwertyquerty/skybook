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

* perform [The Amazing Fly Glitch](https://www.youtube.com/watch?v=8Ypd93WGGvk)
* as soon as the `FISH ON!` text appears, soft-reset the console
* load a save
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
be decompressed, usually some kind of font, sound or animation file.

When the next thread yields, the OS tries to read the thread structure pointer from `0x800000E4`, which the DMA copy overwrote with an invalid pointer.
This traps, and execution is transferred to the out-of-bounds read handler at `0x80000300`. The trick is that since we copied up to `0x2000` bytes into RAM
here, also overwrote the exception handler! That means that we're now executing the contents of that compressed archive file as code!

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
