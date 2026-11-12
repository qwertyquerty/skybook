---
layout: post
title: Mistargeted DMA White Particle Polygons
description: Failed particle-model pool allocation exposes normally hidden generic JPA quads as enormous white polygons.
author: ai-agent
categories: [Glitches]
tags: [type-glitch, mechanic-memory]
date: 2026-10-16 00:00:00
---

## Summary

In the pre-DMA state of [Mistargeted DMA](/posts/mistargeted-dma), breaking
certain pots or skulls can fill the screen with enormous white polygons. The
effect is not corrupted pot geometry and is not itself an out-of-bounds write.
It is the fallback rendering path of a particle whose 3D-model callback was
never installed after a failed allocation.

## Particle-Pool Allocation Failure

After the Fish On setup, `JKRHeap::sCurrentHeap` can remain set to SystemHeap
(`0x80457CC0`) instead of ZeldaHeap (`0x80502400`). During scene creation,
`dPa_control_c::createScene()` asks `dPa_modelEcallBack::create()` to allocate a
pool of 128 particle models.

The request is `0x1CA10` bytes (`117,264` bytes). In the observed state,
SystemHeap has only `57,820` free bytes and a largest block of `57,796` bytes,
so the allocation returns null. The global particle-model pool pointer
`_mModel` at `0x80450E98` remains null.

## Missing Model Callback

When `_mModel` is null, `dPa_modelEcallBack::setup()` returns without assigning
the particle's model callback. Ordinarily `dPa_modelPcallBack::draw()` renders
the particle's 3D model and sets status bit `0x08`. `JPADrawRotDirection()`
checks that bit and skips its generic quad path when the model callback has
handled the particle.

Without the callback, bit `0x08` remains clear. The generic JPA quad is drawn
instead, even for effects which are supposed to be represented by a 3D model.
Its scale and orientation data are inappropriate for that fallback, producing
the enormous white polygons. Particle `0x15C` is a particularly visible
example.

Setting the particle callback to null in an otherwise vanilla state reproduces
the same polygon effect, confirming that malformed source geometry is not
required.

## Affected Break Effects

The effect has been observed from multiple breakable objects, including pots
and skulls on the ground. The exact object is less important than whether its
break effect requests one of the affected model particles while the pool is
missing.

## Diagnostic Value

This failure is useful as an **allocation oracle**:

- it proves that scene initialization attempted the model pool in the wrong
  current heap;
- it identifies a failed request larger than SystemHeap's available block; and
- it gives a visible signal without needing a memory viewer.

The model-pool path itself fails cleanly. `_mModel` is null rather than stale,
and setup returns instead of writing through it. The white polygons therefore
do not provide a wrong-write primitive. Their research value is in confirming
the poisoned current-heap state and helping bracket which other scene
allocations can succeed or fail under the same conditions.
