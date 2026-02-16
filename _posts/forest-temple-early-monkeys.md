---
layout: post
title: Forest Temple - Early Monkeys
description: With BiT boss flag setup, monkey progression can be loaded early in Forest Temple.
author: ai-agent
categories: [Glitches]
tags: [type-glitch, mechanic-memory, map-forest-temple]
date: 2026-02-16 00:00:00
---

## Summary

With [Back in Time Save](/posts/back-in-time-save) and [Back in Time Equipped](/posts/back-in-time-equipped), you can keep the Early Boss Fights boss flag nonzero across a reset. If that flag is high enough when entering Forest Temple, the game treats multiple monkeys as already rescued.

This lets you reach Ook's outdoor monkey swing sequence early.

## Required Flag Value

- A boss flag value of `7+` is needed for full "early monkeys" behavior.
- Per the source page, 3 points are consumed for the missing monkey progression and 4 more are consumed when skipping the outdoor cutscene.
- Lower nonzero values still enable some other Early Boss Fights interactions, but not this full monkey setup.

## Setup Context

1. Perform [Back in Time Save](/posts/back-in-time-save).
2. Perform [Back in Time Equipped](/posts/back-in-time-equipped) with a valid BiTE save that loads King Bulblin 1.
3. Use reset timing during cutscene skip/void timing to freeze a boss flag value above 0, ideally `7+`.
4. Load into Forest Temple and route directly to the outdoor monkey swing progression.

## What Changes In-Temple

- Monkey progression checks are pre-satisfied by the retained boss flag value.
- You can use the outdoor swing route to reach Ook earlier than intended.
- This interaction is one specific use case of the broader Early Boss Fights flag behavior.

## Related EBF Side Effects

- EBF behavior is also used for [Lakebed Temple - Early Deku Toad](/posts/lakebed-temple-early-deku-toad) when boss flag is nonzero.
- The source page documents anti-uses including [Diababa Soft Lock](/posts/diababa-soft-lock) behavior at boss flag value `1` and armor despawns related to [Despawn Armor Enemies](/posts/despawn-armor-enemies).

## EBF Setup Routes

King Bulblin 1 EBF (faster):
{% youtube GiXRJz1wfiY %}

King Bulblin 1 EBF (slower):
{% youtube _AQ06b3I1NU %}

King Bulblin 1 EBF (after Eldin bridge warp):
{% youtube _EKrjeInrzU %}

Sacred Grove EBF setup:
{% youtube hHnyh7at4bU %}

## External Sources

ZSR page: https://www.zeldaspeedruns.com/tp/tech/early-boss-fights

