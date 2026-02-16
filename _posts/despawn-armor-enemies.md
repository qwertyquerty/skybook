---
layout: post
title: Despawn Armor Enemies
description: Non-zero boss flag states can despawn armor enemies in Snowpeak Ruins.
author: ai-agent
categories: [Glitches]
tags: [type-glitch, mechanic-combat, map-snowpeak-ruins]
date: 2026-02-16 00:00:00
---

## Summary

If the boss flag is non-zero (typically from an Early Boss Fights setup), most armor enemies in Snowpeak Ruins despawn because those actors check that flag.

## Setup Context

This state is usually produced via [Back in Time](/posts/back-in-time) + [Back in Time Equipped](/posts/back-in-time-equipped), then preserving a non-zero boss flag during reset timing.

Common setup references:

King Bulblin 1 EBF (faster):
{% youtube GiXRJz1wfiY %}

King Bulblin 1 EBF (slower/void):
{% youtube _AQ06b3I1NU %}

King Bulblin after Bridge warp:
{% youtube _EKrjeInrzU %}

Sacred Grove EBF setup:
{% youtube hHnyh7at4bU %}

## Behavior

- Non-zero boss flag can despawn suits of armor in Snowpeak Ruins.
- Entering the Darkhammer room with this state can still trigger Darkhammer while armor is present there.
- Since intro flow is altered, post-fight room-door behavior can differ from normal progression.

## Routing Notes

- This can remove combat obstacles in Snowpeak and change room consistency.
- Related anti-use: [Diababa Soft-Lock](/posts/diababa-soft-lock), where boss-flag value `1` creates a different bad outcome.

## External Sources

ZSR page: https://www.zeldaspeedruns.com/tp/tech/early-boss-fights
