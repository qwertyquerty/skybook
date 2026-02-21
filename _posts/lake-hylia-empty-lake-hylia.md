---
layout: post
title: Lake Hylia - Empty Lake Hylia
description: Under specific setup conditions, Lake Hylia can load in an unexpectedly empty state.
author: ai-agent
categories: [Glitches]
tags: [type-glitch, map-lake-hylia]
date: 2026-02-16 00:00:00
---

## Summary

Empty Lake Hylia is a temporary out-of-progression state where Lake Hylia loads without water and without many state-dependent actors. In speedrun routing, this is used to enter [Lake Hylia - Early Lakebed Temple](/posts/lake-hylia-early-lakebed-temple-various-methods) without normal [Zora Armor](/posts/lakebed-temple-morpheel-without-zora-armor) requirements.

## Requirements

- Story window between finishing Lanayru Twilight and beating Lakebed Temple.
- Iza river rocks must still be unbombed (Iza minigame not started).
- A death during Plumm's minigame.

## Setup

1. Enter Plumm's minigame during the valid story window.
2. Force a death during the minigame.
3. Respawn in Lake Hylia with state carryover, resulting in an empty lake state.

## Practical Death Options

- Fastest: clip out of bounds to take void damage, then chain additional voids if needed.
- Backup: bonk from high wooden scaffolding to void.
- Easier but slower: stay in bounds and bonk the kargarok on the right side of the high wooden scaffolding to take heavy damage.

## Why It Works

This is attributed to global temporary-state respawn handling. On void/game over under specific conditions, the game can reapply a previous area state value instead of Lake Hylia's default story state.

- During this story window, Lake Hylia defaults to state `0`.
- Dying in Plumm's minigame can carry over a prior temporary state (`4`) on respawn.
- State `4` is undefined for Lake Hylia, so state-bound actors (including water) fail to load.

## Routing Use

- Enables early Lakebed entry paths that avoid standard water traversal requirements.
- Commonly paired with [Lake Hylia - Early Lakebed Temple](/posts/lake-hylia-early-lakebed-temple-various-methods) methods.
- Also synergizes with [Air Replenish (Swim with Water Bombs)](/posts/air-replenish-swim-with-water-bombs) in low-air routes.

## Video References

The source page describes a demonstration video on the page, but no directly linked YouTube URL/ID is currently exposed in page source.

## External Sources

ZSR page: https://www.zeldaspeedruns.com/tp/misc/empty-lake-hylia


