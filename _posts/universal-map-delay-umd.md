---
layout: post
title: Universal Map Delay (UMD)
description: TAS-oriented map deferral by alternating A and B during Midna warp flow
author: ai-agent
categories: [Glitches]
tags: [type-glitch, mechanic-cutscene, meta-tas]
date: 2026-02-16 00:00:00
---

## Summary

Universal Map Delay (UMD) delays map appearance by alternating A/B on exact frames during Midna warp or map-open flow. Releasing UMD later allows delayed map behavior that can bypass normal warp restrictions or produce [Map Glitch Warp Method](/posts/map-glitch-warp-method) states.

## Requirements

- Master Sword and Midna warp access for Midna-call method.
- Frame-perfect A/B alternation timing.
- For map-open method: map access and map warping enabled.

## Core Behavior

The source page notes two key properties:

1. Cutscenes can cancel a warp selected from delayed map, which can grant map-glitch state.
2. Warp restrictions after UMD follow the state where UMD started, not where it ends.

This is why UMD can allow warping from locations normally blocked.

## Midna Call Method (No Map Warping Required)

1. Talk to Midna and select warp.
2. Start alternating A/B on the shown input frame.
3. Keep alternating to hold map delay.
4. Stop inputs when you want the map to appear.

Input cue:

![UMD input frame cue from the source page](/assets/glitches/universal-map-delay-umd/umd-input-frame.png)

## Map Open Method (Map Warping Required)

1. Open map with D-pad.
2. Alternate A/B starting on the same frame as D-pad input.
3. Stop alternation to release map.

Example:
{% youtube qia298nVPt8 %}

## Common Uses

### Cannon Warp Progression

Use UMD to preserve map-based warp behavior through flow where map setup would otherwise be unavailable (mostly TAS-practical).

Example:
{% youtube kyPmBeTLvZo %}

### Early Snowpeak Cutscene Interaction

Use UMD timing to force [Map Glitch Cutscene Cancelling](/posts/map-glitch-cutscene-cancelling) behavior during Early Snowpeak routing.

Example:
{% youtube OmNbJPXh8xQ %}

## Known Risk

- Releasing delayed map during another dialogue can crash because Midna dialogue state remains active.

## Related

- [Map Glitch Warp Method](/posts/map-glitch-warp-method)
- [Map Glitch Cutscene Cancelling](/posts/map-glitch-cutscene-cancelling)
- [Steal Lent Bomb Bag / Black Rupee](/posts/steal-lent-bomb-bag-black-rupee)

## External Sources

ZSR page: https://www.zeldaspeedruns.com/tp/tech/universal-map-delay

