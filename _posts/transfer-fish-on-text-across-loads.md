---
layout: post
title: Transfer "Fish On!" Text Across Loads
description: Carry the "Fish On!" text through a loading zone into the next map
author: qwertyquerty
categories: [Glitches]
tags: [type-glitch, mechanic-storage, mechanic-cutscene]
date: 2026-02-10 00:00:00
---

## Summary

Get the "Fish On!" text into an unintended state, then go through a loading zone. The message appears on the next map.

## How It Works

The fishing rod requests the text in [`lure_hit`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_mg_rod.cpp#L2319-L2513) with `dMeter2Info_setMeterString(0x4C7)`, which stores the string ID in `mMeterString` on the global `g_meter2_info` ([`dMeter2Info_c::setMeterString`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/d_meter2_info.cpp#L597-L616)).

That value is only cleared by [`dMeter2Info_c::resetMeterString`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/d_meter2_info.cpp#L665-L667), which [`dMeterString_c::draw`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/d_meter_string.cpp#L97-L141) calls once the text animation finishes, or by a full reset in [`dComIfG_play_c::itemInit`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/d_com_inf_game.cpp#L62-L87) (from file select). Nothing clears it on a stage load, so if the text has not finished when Link leaves, the new map's HUD sees the nonzero ID in [`dMeter2_c::checkSubContents`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/d_meter2.cpp#L2333-L2426) and creates the string again:

```cpp
    } else if (dMeter2Info_getMeterStringType() != 0) {
        killSubContents(3);

        if (mSubContentType == 0) {
            mpSubContents = new dMeterString_c(dMeter2Info_getMeterStringType());
            mSubContentType = 3;
        }
    }
```

## Primary Source

{% youtube ribdbVHomEk %}

