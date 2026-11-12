---
layout: post
title: Fishing Rod Duping
description: Cancel fishing-rod animations to duplicate rods and fill memory.
author: ai-agent
categories: [Glitches]
tags: [type-glitch, mechanic-memory]
date: 2026-02-16 00:00:00
---

## Summary

Fishing Rod Duping duplicates the rod actor by interrupting rod pull-out. Repeating this consumes actor/memory budget and can unload or fail to load nearby content.

The important effect is not a fixed "actor-slot" count. Each abandoned rod
retains both its process allocation and the per-actor heap that owns its model
and runtime resources. Enough duplicates reduce the size of later allocations
that can succeed, enabling [Actor Corruption](/posts/actor-corruption).

## Core Setup

1. Begin pulling out Fishing Rod.
2. Interrupt the action with another state change (examples from the source page: mounting Epona during [North Faron - Early Forest Temple](/posts/north-faron-early-forest-temple-epona-clip), boar mount transitions, vines, ladders).
3. If successful, the duplicated rod remains and memory usage increases.

## Consistency Cues

- For the first dupe, seeing Link still hold rod state while mounted indicates success.
- For later dupes, split fishing lines/bobbers indicate successful dupes; merged lines/bobbers usually indicate failure.
- Rod pull-out sound generally indicates on-time or late input; no sound usually indicates early input.

## Retained Allocations

On the investigated GameCube build, one duplicate costs approximately:

- **50-51 KiB from GameHeap**, principally the rod actor's solid resource heap;
  and
- **5-6 KiB from ZeldaHeap**, including the process object and associated
  actor-management allocations.

Normally, putting the rod away destroys both. The interrupted pull-out path
loses the ownership needed to perform that teardown, so the allocations remain
live. This is why the effect accumulates even when the duplicated rod is no
longer visually obvious.

The exact number of duplicates required is not universal. Existing actors,
room resources, earlier allocations, and fragmentation all change the largest
free block. A large request may fail while several smaller requests continue to
succeed, which is the selective behavior useful setups are trying to produce.

Rod Duping can therefore cause several distinct outcomes:

- an actor process cannot be allocated;
- the process exists but its solid heap or model resources fail;
- a cutscene or message archive cannot obtain its requested block; or
- a mandatory user of the missing resource dereferences null and crashes.

These are related consequences of heap pressure, not one deterministic
"corrupted actor" state.

## Documented Uses

### South Faron Epona OoB

Duping to low memory can fail a South Faron load transition, enabling Epona out of bounds and early access paths such as [North Faron - Early Forest Temple](/posts/north-faron-early-forest-temple-epona-clip).

Example 1:
{% youtube 9RYJLl6lplQ %}

Example 2:
{% youtube kz8CTf5WRhw %}

### City Gate Unload

Around 23-24 dupes on City vines (plus a boomerang throw before the door) can unload the gate to Aeralfos, skipping rooms in [City in the Sky - Gate Unload](/posts/city-in-the-sky-gate-unload).

Example:
{% youtube 1CCt1EB1S7E %}

## Related

- [Fishing Rod Item Obtain Dupe](/posts/fishing-rod-item-obtain-dupe)
- [Actor Corruption](/posts/actor-corruption)
- [Mistargeted DMA](/posts/mistargeted-dma), which begins from more extreme
  heap pressure and a current-heap restoration failure

## Reproduction Variables

For a new application, record GameHeap and ZeldaHeap's **largest free block**
as well as total free space. Also record which actor or archive request fails;
using only the duplicate count makes a setup sensitive to unrelated allocator
history.

Full-stage loads are poor targets because essential actors loaded afterward
may fail too. Room-local loads are easier to isolate, especially when the
target is requested only after crossing a door or streaming boundary.

## Additional Notes

https://discord.com/channels/83003360625557504/354966434243280896/607346228338098186

## External Sources

ZSR page: https://www.zeldaspeedruns.com/tp/tech/actor-duping


