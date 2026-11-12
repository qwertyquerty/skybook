---
layout: post
title: Castle Town - Squidna Cutscene Skip
description: Using actor corruption, waste enough memory that the large cutscene arc files cannot load. This skips the cutscene entirely.
author: ai-agent
categories: [Glitches]
tags: [type-glitch, mechanic-actor-corruption, mechanic-cutscene, map-castle-town]
date: 2026-02-10 00:00:00
---

## Summary

Build enough heap pressure with [Actor Corruption](/posts/actor-corruption),
then enter the Squidna cutscene. If the cutscene's large resource request is
rejected while the surrounding room remains viable, the event can fail open
and return control without presenting the normal sequence.

## Primary Source

{% youtube LjVlufLlXHw %}

## Fail-Open Demo Archive

Room loading has a path for optional demo archives. The room layer selects a
`DemoXX_YY` archive, and the engine asks the object-resource controller to load
it. If that request fails, the demo-archive name is cleared. Room object setup
nevertheless continues: background creation, event-manager initialization, and
room actor loading are not all rejected with it.

That asymmetry is the useful part. The goal is not to run the entire game out
of memory; it is to deny the large cutscene allocation while preserving the
smaller allocations required to keep the map and player functional.

## Allocation Window

Duplicate count alone is not a stable measurement. Existing allocations and
fragmentation determine the largest block available when the event is
requested. Too little pressure loads the cutscene normally. Too much pressure
can reject later actors or other mandatory state and crash instead of skipping.

For repeatable testing, record:

- GameHeap and ZeldaHeap total free space and largest free block immediately
  before entering the trigger;
- the failed allocation size and caller;
- the selected demo-archive name; and
- the event and save-location state after control returns.

The related [Squidna Heap Allocation Failure](/posts/castle-town-squidna-heap-alloc-failure)
page documents visible allocation warnings. Warnings alone do not prove that
the useful cutscene failure occurred; the post-event state must also be checked.

## Failure Mode

This is a selective resource-load failure, not a wrong write. Its usefulness
comes from event sequencing: the room survives without the cutscene resource,
so the game can advance or return control in a state normally reached only
after the sequence.

