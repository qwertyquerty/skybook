---
layout: post
title: Death Through Load Zones
description: Dying can override many cutscenes, enabling sequence-break setups.
author: ai-agent
categories: [Glitches]
tags: [type-glitch, mechanic-cutscene]
date: 2026-02-16 00:00:00
---

## Summary

Death Through Load Zones triggers a map transition on the same frame Link dies. On load, Game Over/death handling can take priority over cutscene start, which can bypass intended cutscene flow or create unusual map states.

## Core Rule

- The load trigger and lethal hit must occur on the same frame.
- For ground triggers specifically, Link must be grounded on that frame (some damage sources can pop Link airborne and fail the setup).

## How To

### Bomb method

1. Lower health to lethal range (typically half-heart).
2. Place a bomb near a load trigger.
3. Time movement so bomb damage and load trigger contact happen on the same frame.

For ground triggers, riding into the trigger with [Epona Slide](/posts/epona-slide) keeps Link grounded on the lethal frame.

{% youtube CFjDz9fogBc %}

### Enemy-hit method

1. Bring an enemy near a load trigger at lethal health.
2. Walk into trigger as the enemy hit connects.
3. If timed correctly, death state carries through the transition.

{% youtube uC7Xx-VMPBI %}

## Documented Outcomes

- Cutscene suppression where death handling interrupts normal cutscene startup.
- Setups that produce [Ooccoo Stuck to Link's Arm](/posts/ooccoo-stuck-to-links-arm) and [Ooccoo Slide](/posts/ooccoo-slide) behavior after fairy revival.
- Theorycraft for barrier-cutscene bypass in Castle Town if a lethal bomb setup were available there.

{% youtube Ng2-4efhoKM %}

## Notes

- This is a timing-heavy utility tech rather than a single destination skip.
- Fairy revival can be part of follow-up setups after transitioning in death state.
- Related pages: [Cutscene Boomerang Item Dropping](/posts/cutscene-boomerang-item-dropping), [Map Glitch Warp Method](/posts/map-glitch-warp-method).

## External Sources

ZSR page: https://www.zeldaspeedruns.com/tp/tech/death-through-load-zones
