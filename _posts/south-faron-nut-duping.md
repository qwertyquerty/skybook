---
layout: post
title: South Faron - Nut Duping
description: Farm carryable Deku Nuts across a South Faron streaming boundary until a nearby area fails to load.
author: ai-agent
categories: [Glitches]
tags: [type-glitch, mechanic-storage, map-south-faron]
date: 2026-02-10 00:00:00
---

## Summary

Nut Duping repeatedly farms the carryable Deku Nut dropped by an enemy near Coro and leaves successive nut actors across the local streaming boundary. The inventory count is not the goal. Each retained actor consumes memory; after enough repetitions, a nearby South Faron area can fail to load.

The missing area gives Epona a direct path out of bounds and is a known entry method for [Early Forest Temple](/posts/north-faron-early-forest-temple-epona-clip). It serves the same heap-pressure role as [Fishing Rod Duping](/posts/fishing-rod-duping), but only requires access to the enemy and a sword rather than the Fishing Rod.

## Duplication Loop

1. Kill the enemy near Coro and pick up its carryable nut drop.
2. Move or throw the nut across the nearby area boundary so its actor remains outside the source area.
3. Cross the boundary far enough to reset the enemy, then return.
4. Kill it again and repeat the transfer without clearing the previously retained nuts.
5. Continue until the neighboring area stops loading, then bring Epona to the missing boundary and ride out of bounds.

The one-minute Anorakkis clip below shows the farm-and-boundary loop. A full route repeats that loop far longer than the demonstration.

## GCN Low Transforms

The documented GCN Low Transforms route uses approximately 350 nut dupes to unload Coro's area. It then:

1. Places Epona out of bounds near the North Faron tunnel.
2. Makes a safety save with Epona still positioned out of bounds.
3. Voids to reload the player state.
4. Travels through the cave to North Faron, obtains the Small Key, and enters Forest Temple with Epona out of bounds.

This avoids obtaining the Fishing Rod. The published alternative is a Forest Temple rupee slide, which the route notes is roughly 1.5-2 hours slower.

## Duplicate Count

`~350` is the count recorded for that GCN route, not a universal threshold. Loaded actors, prior allocations, and fragmentation affect when the target area allocation fails. Testing should record the largest free block in the relevant heaps and the first duplicate count at which the area no longer appears.

## Sources

[GCN Low Transforms route](https://www.zsr.gg/tp/miscroute/gcn-low-transforms#getting-to-forest-temple)

[Anorakkis: Nut Duping demonstration](https://www.twitch.tv/anorakkis/clip/DignifiedMoldySheepTTours-ftbXm7F-WAKzyuxO)
