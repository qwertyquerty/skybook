---
layout: post
title: Text Displacement
description: Carry partial cutscene text state between interactions to alter later dialogue and event behavior.
author: ai-agent
categories: [Glitches]
tags: [type-glitch, mechanic-memory, mechanic-storage]
date: 2026-02-16 00:00:00
---

## Summary

Text Displacement (TD) is a memory-state glitch where cutscene/dialogue progress bits are left partially set, then reused by later NPC interactions. Depending on which bits are set, the game can skip, alter, or misroute event logic.

The source page notes this is central to several route breaks, especially [Early Master Sword](/posts/early-master-sword)-related progression.

## Technical Notes

The source page tracks relevant temporary flag bits at:

- `80406F98` (bits 1-3 in source-page numbering)
- `80406F99` (dialogue progression bits, less commonly used for setup)
- `80406F9D` (bits 6-9 in source-page numbering)

In normal flow, these bits are filled/cleared in expected order. TD happens when a broken text/cutscene state is exited before cleanup, then carried elsewhere.

## Route-Relevant Use

### Goron Mines entry in EMS state

By setting TD bit 2 or 3, then speaking to Gor Coron with Master Sword obtained, the game can treat the sumo progression as completed and open Goron Mines access logic early.

This is also documented in early-EMS progression context alongside [Goron Mines - Early Entry](/posts/goron-mines-early-entry) routing.

Example:
{% youtube 4ANDpgF_8Vw %}

## Clearing vs Keeping TD

The source page lists the following as common TD-clearing actions:

- Savewarping / title screen transitions
- Starting another file
- Some cutscene skips and event transitions

The source page lists the following as generally TD-safe:

- Voiding
- Game over
- Normal NPC talk that does not open a major cutscene
- Midna dialogue

## Common TD Sources (Tracked Here)

- [South Faron - Coro Text Displacement](/posts/south-faron-coro-text-displacement):
{% youtube z_2rkoc1MtY %}
- [Telma Dialog Skip (Grants Text Displacement)](/posts/telma-dialog-skip-grants-text-displacement), GCN:
{% youtube 9FOq6t-AE7A %}
- [Telma Dialog Skip (Grants Text Displacement)](/posts/telma-dialog-skip-grants-text-displacement), Wii:
{% youtube ZaBSlJxHDCw %}
- [Ooccoo Text-Displacement Corruption](/posts/ooccoo-text-displacement-corruption)
- [Squirrel Text Displacement Softlock](/posts/squirrel-text-displacement-softlock)
- Rusl TD context:
{% youtube mE_HWKNDvtc %}
- Yeta TD context:
{% youtube HfbAG4pweag %}
- Jovani bottle interaction context:
{% youtube MGBogH99iT4 %}
- TD via [Item Pickup Slide](/posts/item-pickup-slide) Void Out:
{% youtube CPAm2Vo_jIc %}

## External Sources

ZSR page: https://www.zeldaspeedruns.com/tp/tech/text-displacement

Jacquaid TD source sheet: https://tinyurl.com/mryasumm

