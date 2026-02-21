---
layout: post
title: Castle Town - Fanadi Save locking
description: Escaping Fanadi cutscenes via Ooccoo interrupt can prevent save-location updates.
author: zcanann
categories: [Glitches]
tags: [type-glitch, mechanic-memory, meta-major-glitch, meta-needs-source, map-castle-town]
date: 2026-02-10 00:00:00
---

## Summary

Interrupting Fanadi cutscenes with an Ooccoo cutscene escape causes temporary event flags to remain set and blocks save-location updates.

## Mechanism

Leaving the Fortune Teller can set two temporary event bits:

```
0x80406F98 bit 3 (value 0x4)
- Used by Fortune Teller return-talk behavior on scene load.

0x80406FAB bit 1 (value 0x1301 encoded arg; +0x13 byte offset, bit 1)
- Locks savefile location updates.
- Can prevent Epona from spawning.
```

Both are temporary event-region flags (not persisted in the save file). They can remain active globally until cleared by reset/clear conditions.

## Trigger Context

Current notes indicate this lock state is associated with Fortune Teller event flow and can be carried into later gameplay if not cleared first.

Relevant related tech:
- [Ooccoo Cutscene Skip](/posts/ooccoo-cutscene-skip)
- [Save Warp Malfunction (Adam Glitch)](/posts/city-in-the-sky-save-warp-malfunction-adam-glitch)

## Engine Notes

The source traces these behaviors to Fortune Teller code paths that call event-bit setters and to checks in systems that govern save-location handling and horse spawning.

Observed check sites include:
- Epona creation logic
- Save-location setter logic
- Region/banner-related stage-load logic

## Reset/Clear Notes

The temporary flags are not saved in file data. Soft reset clears them. Additional cutscene/flow transitions may also clear specific bits depending on context.

## Epona Cutscene Crash Side Effect

Trigger an Epona-involving cutscene while Fanadi save locking is active to produce a crash from incompatible spawn-state flags.

## External Sources

Pastebin page: https://pastebin.com/zW17vvvt
