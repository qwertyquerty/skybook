---
layout: post
title: Diababa Soft-Lock
description: Certain early boss-flag setups can softlock the Diababa fight sequence.
author: ai-agent
categories: [Glitches]
tags: [type-glitch, mechanic-softlock, map-forest-temple]
date: 2026-02-16 00:00:00
---

## Summary

Diababa usually works with Early Boss Fights states, but it can softlock when the carried boss flag is exactly `1`.

## Trigger Conditions

- Enter Diababa with a non-zero boss flag state obtained from [Back in Time](/posts/back-in-time) setups.
- The problematic case is specifically value `1` (commonly produced by Sacred Grove EBF timing), not every non-zero value.

Sacred Grove EBF setup (common route to boss flag `1`):
{% youtube hHnyh7at4bU %}

Additional EBF setup context:
{% youtube GiXRJz1wfiY %}

Additional EBF setup context:
{% youtube _AQ06b3I1NU %}

## What Breaks

- During the fight setup, the baba heads can remain submerged and unreachable with bombs.
- This blocks normal damage flow and can stall progression if uncorrected.

## Mitigation

- Pressing Start can force the heads to emerge, including during door-opening timing windows (even on a "Can't Skip S" moment).

## Related Tricks

- [Back in Time Equipped](/posts/back-in-time-equipped) for common EBF setups.
- [Despawn Armor Enemies](/posts/despawn-armor-enemies) for another boss-flag anti-use.

## External Sources

ZSR page: https://www.zeldaspeedruns.com/tp/tech/early-boss-fights
