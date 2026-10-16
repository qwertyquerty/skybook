---
layout: post
title: Actor Corruption
description: Memory leak state from Rod Duping or Save Leak setups that enables further corruption-driven glitches.
author: zcanann
categories: [Glitches]
tags: [type-glitch, mechanic-memory, mechanic-actor-corruption, meta-major-glitch]
date: 2026-02-10 00:00:00
---

## Summary

Actor corruption is the broad name for making an actor or one of its resources
fail to load by exhausting or fragmenting the heaps it needs. The useful result
is usually not corrupted save data: it is a missing actor, a partially created
actor, or a failed event resource that changes what the current scene does.

The common setup is [Fishing Rod Duping](/posts/fishing-rod-duping). Each
duplicate retains allocations which would ordinarily be destroyed when Link
puts the rod away. Save Leak variants can produce different persistent heap
pressure and allocator layouts.

{% youtube uXepgqiXDdc %}

## What Is Being Exhausted

Actor creation uses more than one heap, so "free memory" is not a single
number:

- **ZeldaHeap** contains the process object and other actor-management data.
- **GameHeap** supplies an actor's solid heap, which commonly contains models,
  animation objects, and other runtime resources.
- **ArchiveHeap** and object-resource registrations own shared archive data.
- Room-specific heaps can retain stage resources independently of those global
  heaps.

A rod duplicate costs roughly 50 KiB in GameHeap and another 5-6 KiB in
ZeldaHeap on the investigated GameCube build. Consequently, an allocation can
fail even when another heap still has plenty of space.

Fragmentation matters as much as total free space. A request fails when no
single free block is large enough, even if the sum of several smaller holes is
greater than the request. This is why two setups with similar reported free
space can corrupt different actors.

## Failure Points

A simplified actor load looks like this:

1. Link the actor's dynamic REL module if it is not already present.
2. Allocate the process object.
3. Register and load any object archives requested by the actor.
4. Allocate the actor's solid heap and construct its models and animations.
5. Finish `create()` and begin executing the actor.

Failure at different steps produces different behavior. Some actors detect a
failed allocation and disappear cleanly. Others remain in creation for several
frames, return an error after changing shared state, or assume that a resource
pointer is valid and crash. A missing actor therefore does not imply that its
REL or archive was corrupted, and an actor that appears normally can still
have lost an optional resource.

Simple process-allocation failure is also not a general REL leak: the process
loader releases the REL reference when that allocation fails. Persistent
future-instance corruption requires a longer-lived shared resource or
registration imbalance, not merely one rejected process allocation.

## Choosing a Useful Target

The strongest targets have all of the following properties:

- They can be requested on demand by a room transition. An actor used only on
  a full stage load is difficult to isolate because later essential actors,
  including Link or Midna dependencies, may fail as well.
- Their absence or partial creation changes progression, collision, a loading
  zone, or an event flag. Removing a combat encounter rarely repays the setup
  time.
- The allocation being attacked is unusually large, or fragmentation can deny
  that allocation while leaving smaller essential requests available.
- The scene remains playable after the failure. Many attractive targets simply
  dereference the missing resource on the next frame.

Repeated actors can also be valuable when their creation updates a shared
counter or table before checking capacity. In that case, failed duplicates may
alter the surviving leader. This must be verified per actor; it is not a
general property of actor corruption.

## Known Applications

- [City in the Sky - Gate Unload](/posts/city-in-the-sky-gate-unload)
  removes a gate after building pressure with rod duplicates.
- [Castle Town - Squidna Cutscene Skip](/posts/castle-town-squidna-cutscene-skip)
  prevents a large cutscene resource from loading.
- [Castle Town Wrong Warp](/posts/castle-town-wrong-warp) and
  [Lake Hylia Wrong Warp](/posts/lake-hylia-wrong-warp) preserve an earlier
  save-warp destination when the event that should replace it fails.
- [Permanent Desert State 8 Cinematic](/posts/permanent-desert-state-8-cinematic)
  records another event-load failure state.

## Research Guidance

When testing a new target, record more than whether the actor is visible:

1. Measure total free space and largest free block in each relevant heap.
2. Record the actor's REL link count and object-resource registration before
   and after failure.
3. Distinguish process allocation, archive synchronization, solid-heap
   creation, and the actor's own `create()` result.
4. Leave and re-enter the room to determine whether the failure belongs to one
   instance or to shared resource state.
5. Verify that later required actors still load before treating the setup as a
   route candidate.

For progression research, selective failure is the goal. Filling every heap
until the game happens to omit something generally produces crashes and does
not establish a repeatable actor-corruption setup.


