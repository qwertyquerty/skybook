---
layout: post
title: Save Leak (ACT)
description: Wii save-leak timing setup using a reset followed by one-frame-late A press.
author: ai-agent
categories: [Glitches]
tags: [type-glitch, platform-wii, mechanic-memory]
date: 2026-02-10 00:00:00
---

## Summary

On Wii, reset while the menu is positioned to enter Save, then press A one
frame later. Repeating the successful race retains memory across soft resets
and can eventually cause actors or resources to stop loading.

## Primary Source

{% youtube 43IlXCPBlbQ %}

## Evidence Boundary

The one-frame Wii timing is not interchangeable with the GameCube timing in
[Save Leak (J2D)](/posts/save-leak-j2d). The GameCube variant has been traced
to an orphaned `saveres.arc` and pending mount command; this Wii ACT variant has
not yet had its retained allocations identified to the same standard.

Community tests associate repeated Wii setups with persistent heap pressure and
[Actor Corruption](/posts/actor-corruption), including actors disappearing on
later loads. That establishes a retained-memory effect, but not which heap,
archive registration, or object lifetime is responsible.

## Research Checklist

A mechanism trace should compare a successful one-frame setup against both
neighboring timings and record:

- GameHeap, ZeldaHeap, ArchiveHeap, and J2D free space and largest free block;
- live object-resource registrations;
- dynamic REL link counts; and
- which allocations remain owned after the reset completes.

This distinction matters for routing. A leak in an actor's solid heap, an
orphaned archive, and a leaked resource-table entry can all make future actors
disappear, but they select targets differently and survive different kinds of
loads.

## Related Observation

[Habreno's Memory Glitch](/posts/habrenos-memory-glitch) may have begun with
this reset timing, but that causal link remains a hypothesis rather than a
confirmed reproduction.


