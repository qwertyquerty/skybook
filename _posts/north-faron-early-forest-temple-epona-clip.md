---
layout: post
title: North Faron - Early Forest Temple
description: Carry Epona out of bounds from South Faron to enter the Forest Temple loading zone before normal North Faron access.
author: ai-agent
categories: [Glitches]
tags: [type-glitch, mechanic-collision, map-north-faron]
date: 2026-02-10 00:00:00
---

## Summary

[Fishing Rod Duping](/posts/fishing-rod-duping) can put South Faron under enough heap pressure for the next area setup to leave Epona out of bounds. From there, Epona can ride across normally disconnected exterior collision, gain enough height to reach North Faron's map position, and approach the Forest Temple entrance from behind.

The memory failure creates access to the exterior route; it does not place Epona at the temple. The remaining traversal is a long position-and-height setup, and touching the wrong actor or returning in bounds can discard the attempt.

## South Faron Escape

Duplicate rods by interrupting the rod pull-out with Epona mounting. Each successful duplicate retains actor allocations. Continue until the relevant South Faron transition no longer produces its normal loaded state and Epona can remain outside the playable boundary.

Dupe count is not a stable cue. Existing actor allocations and fragmentation alter which request fails, so a practice setup should record the GameHeap and ZeldaHeap largest-free-block values alongside the visual result. A lower-memory state is not automatically better: failure of a mandatory actor or resource can crash before Epona becomes usable.

## Exterior Route

1. Ride around the outside of the Hyrule Field loading zone. The out-of-bounds collision here supplies a small initial height gain.
2. Continue to the cliff beside Coro's house and ride off its exterior edge. Aim to leave this section around `Y = 920–930`.
3. Use the minimap to steer toward the position where North Faron exists in the shared world layout.
4. Stay clear of the blue Bokoblins. If they frighten Epona, her reaction can push her back through the boundary and end the out-of-bounds state.
5. Take the required void, enter North Faron, and continue riding outside its normal collision.
6. Circle behind the Forest Temple loading zone and backflip from Epona into it.

The minimap is more reliable than the visible scenery once Epona is between mapped areas. If the temple load never appears, check the Coro-cliff height before changing the final backflip: insufficient height earlier in the route cannot be repaired at the entrance.

## Temple Exit

Entering early does not normalize North Faron's story state. Plan the return before making progress in the dungeon. [Early Forest Temple Escape](/posts/north-faron-early-forest-temple-escape) documents the frame-tight Talo-trigger route used by applicable setups.

## External Source

[ZSR: Faron Province — Early Forest Temple](https://www.zsr.gg/tp/world/faron-province#early-forest-temple)

Route example:
{% youtube 6z8QzWX5Tfs %}

