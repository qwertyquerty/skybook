---
layout: post
title: Map Glitch (Warp Method)
description: Midna warp interaction that disables map triggers
author: ai-agent
categories: [Glitches]
tags: [type-glitch, mechanic-warp, mechanic-cutscene]
date: 2026-02-16 00:00:00
---

## Summary

Map Glitch disables most area-load and area-reload triggers after a warp-interrupt setup. In practice, this lets Link bypass many normal loading-zone behaviors until the glitch is canceled.

## Common Warp-Interrupt Methods

1. `GCN`: open map and call Midna on the same frame, then choose a warp destination.
2. `Wii`: use icon shortcuts plus same-frame Midna/map input timing, then choose a warp destination.
3. `GCN UMD`: use [Universal Map Delay (UMD)](/posts/universal-map-delay-umd) to defer map timing, then force an interrupt.
4. If successful, Midna or another action interrupts the warp and leaves Map Glitch active.

### GCN Methods

Map+Midna (unplug method):
{% youtube IuReOKB3qLs %}

Map+Midna (controller reset combo):
{% youtube ydxYu9v8lFE %}

Midna warp + fast action button cancel:
{% youtube S2TwgXTIY_A %}

Map warp + animation item cancel:
{% youtube MvkInMuZGLw %}

Map screen delay method:
{% youtube qSGknKi1MxM %}

Midna warp + dig spot method:
{% youtube Ow0ZU3zkwI0 %}

### Wii Methods

Icon shortcuts + Midna:
{% youtube MX1t6HAPres %}

Map warp + action button cancel:
{% youtube byE_troKbOo %}

### UMD Method

Universal Map Delay setup:
{% youtube qia298nVPt8 %}

## Constraints and Behavior

- The behavior is version-dependent and does not affect every trigger class (for example, many cutscene triggers still work).
- Most practical setups are 1-frame timings.
- Map Glitch is usually ended by area loads (including many warps/savewarps).
- Related pages: [Map Glitch (Cutscene Cancelling)](/posts/map-glitch-cutscene-cancelling), [Post-Warp Map Glitch](/posts/post-warp-map-glitch), [Snowpeak Ruins Early (Map Glitch)](/posts/snowpeak-ruins-early-map-glitch).

## External Sources

ZSR page: https://www.zeldaspeedruns.com/tp/tech/map-glitch
