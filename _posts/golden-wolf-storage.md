---
layout: post
title: Golden Wolf Storage
description: A wrong warp glitch to travel to the location of a golden wolf
author: zcanann
categories: [Glitches]
tags: [gws, glitches, EHC]
pin: true
math: true
mermaid: true
date: 2025-09-16 00:00:00
---

Golden Wolf Storage is a glitch discovered by Zachary Canann (zcanann) on March 9, 2022. This glitch allows for storing a golden wolf location to warp to it later. This glitch is only possible due to [Early Master Sword](/posts/early-master-sword).

By doing Early Master Sword, we are able to learn Ending Blow from a wolf other than the North Faron Woods wolf. For some reason, this causes a bug where the "return location" is not cleared after encountering the golden wolf. Then, by accessing another wolf, there are circumstances where the player is warped back to the original location.

This is the initial discovery video. This uses mods to warp around, but to clarify the events, the player:
- Gets storage from the Ordon Springs wolf by learning Ending Blow from it (or rather exiting before learning, the effect is teh same).
- Visits the wolf outside of Castle Town, but is returned to Ordon Springs upon leaving!
{% youtube lIqrX_CR75I %}

## Mechanics

When you enter Hero's Shade Realm, the game sets a flag indicating which wolf you arrived from. This flag is checked when leaving to decide the location to which Link returns. However, the game checks these flags in a specific order, notably:
```
80406FA2:
4 = Ordon Springs
2 = Castle Town (West exterior)
1 = Castle Town (South exterior)
80406FA3:
128 = Gerudo Desert
64 = Kakariko Grave Yard
32 = Hyrule Castle
If none are set:
0 = North Faron Woods
```

In other words, Ordon Springs is the highest priority warp location (checked first), and Hyrule Castle is the lowest priority warp location (checked last). Note that these are bit flags, so if the value was hacked to be 36 (from 32 + 4), the player would warp to Ordon Springs, even though the flag for HC is set, due to priority. If no flags are set, the player always returns to North Faron Woods.

## Potential Leads

If we could somehow set our Golden Wolf Storage without having visited that particular wolf, then this could potentially allow for either:
- Early Hyrule Castle by warping to the golden wolf on the other side of the guard door. Note this must be done in a pre-barrier raised state, and would require warping from the North Faron Woods wolf, as this is the only wolf with a lower priority than Hyrule Castle.
- Early desert by warping to the golden wolf in Gerudo Desert.
- Fast travel by warping to any of the other overworld wolves.

There is currently no conceivable way to accomplish this. While the golden wolf storage address is shared by some flags related to the early game Goats mini-game, the bits do not overlap.

Here is hacked proof that would show how EHC would be possible if we could set the right Golden Wolf Storage bit:
{% youtube T8zV6u5nx6w %}
