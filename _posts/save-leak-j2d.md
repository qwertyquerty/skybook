---
layout: post
title: Save Leak (J2D)
description: GC save-screen reset timing that leaks J2D memory on Save and can crash on Options.
author: ai-agent
categories: [Glitches]
tags: [type-glitch, platform-gcn, mechanic-memory, mechanic-crash]
date: 2026-02-16 00:00:00
---

## Summary

Reset while the Collection menu is hovering over **Save**, wait 17 frames with
no input, then press A on frame 18. On the vulnerable frame, the Save screen's
archive finishes mounting after reset teardown has begun but before the menu
adopts it. The archive is left allocated in J2D heap across the soft reset.

The same timing over **Options** reaches a different partially initialized menu
and crashes instead of producing the confirmed Save leak.

## Primary Source

{% youtube 0yehcH0CGxs %}

## Additional Notes

Using this to alloc J2D objects into Zelda heap:
{% youtube sUazCj0PbiM %}

## Confirmed Memory Effect

Retail GameCube tests on both NTSC-U and Japanese builds found that one
successful setup orphans:

- a `JKRMemArchive` object;
- the decompressed `/res/Layout/saveres.arc`; and
- the completed asynchronous mount command.

The J2D allocations consume `0x44890` bytes including heap headers. The entire
J2D heap is `0x7CF70` bytes, so one leak occupies more than 55 percent of it.
The mount command costs another `0x34` bytes including its command-heap header.

This is retained allocation ownership, not merely stale archive bytes. Memory
from a normally freed archive can remain readable too, so finding a RARC header
in memory by itself is not proof of a leak.

## Why the Archive Is Orphaned

The Save menu starts an asynchronous mount into J2D heap and stores the command
in `mpMount`. Once the command completes, the normal `_open()` path transfers
the archive to `mpArchive`, builds the screen, and disposes of the command.

At the vulnerable reset timing, `_delete()` runs first. It only unmounts
`mpArchive`, which is still null; it does not destroy the completed `mpMount`.
The command, archive object, and decompressed archive body therefore have no
remaining owner but stay allocated.

The incomplete Save screen also removes font references it never acquired. In
the confirmed runs this destroys the global sub-font object. File select later
reconstructs it as a `0x70`-byte object with a `0x10`-byte heap header, shifting
the name-screen object and all following allocations by exactly `+0x80`.

That deterministic shift is visible to
[File Name Cursor Breakout](/posts/file-name-cursor-breakout), but it does not
change which cursor position reaches which field: the name object, array
cookie, and following J2D objects all move together.

## Timing Notes

The historical recipe counts the reset frame as the first frame: reset, 16
neutral frames, then A on frame 18. A controller soft-reset chord can add input
recognition delay, so a Dolphin input movie may not use the same raw frame
number as a direct emulated reset-line test.

Neighboring timings do not produce the same ownership leak. Some alter retained
font reference counts, but repeated testing made the message-font count grow
rather than approach an exploitable underflow.

## Limits

Opening Collection again after the confirmed leak wedges during construction
because the remaining J2D space is too small. This prevents the straightforward
plan of stacking the same `0x44890` leak repeatedly.

An event-style Save can make a second `saveres.arc` fall back into ZeldaHeap,
but normal adoption and teardown release that copy in the tested path. Resetting
that event Save produced a repeatable later file-select wedge, not a second
confirmed archive leak.

The useful result is therefore a reproducible persistent heap-layout change and
one very large orphan, not arbitrary memory corruption. A practical follow-up
needs a different menu/resource teardown race, or an allocation whose failure
has a valuable gameplay consequence.


