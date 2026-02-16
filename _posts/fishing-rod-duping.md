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

## Core Setup

1. Begin pulling out Fishing Rod.
2. Interrupt the action with another state change (examples from the source page: mounting Epona during [North Faron - Early Forest Temple](/posts/north-faron-early-forest-temple-epona-clip), boar mount transitions, vines, ladders).
3. If successful, the duplicated rod remains and memory usage increases.

## Consistency Cues

- For the first dupe, seeing Link still hold rod state while mounted indicates success.
- For later dupes, split fishing lines/bobbers indicate successful dupes; merged lines/bobbers usually indicate failure.
- Rod pull-out sound generally indicates on-time or late input; no sound usually indicates early input.

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

## Additional Notes

https://discord.com/channels/83003360625557504/354966434243280896/607346228338098186

## External Sources

ZSR page: https://www.zeldaspeedruns.com/tp/tech/actor-duping


