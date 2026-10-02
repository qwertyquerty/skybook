---
layout: post
title: 21/20 Goats
author: qwertyquerty
description: Letting a counted goat escape the pen and come back in counts it twice, so the goat herding minigame never ends.
categories: [Glitches]
tags: [type-glitch, map-goats, type-softlock]
date: 2026-10-01 00:00:00
---

## Summary

If a goat that has already been counted gets back out of the pen (for example an angry goat) and then re-enters, it is counted a second time. The counter goes past the total (e.g. 21/20) and the minigame never ends.

## How It Works

Each goat ([`daCow_c`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/include/d/actor/d_a_cow.h#L19), [`d_a_cow.cpp`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_cow.cpp)) adds to the herding counter in [`daCow_c::setEnterCount`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_cow.cpp#L1384-L1395) whenever it enters the pen, by incrementing [`dMeter2Info_getNowCount()`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/include/d/d_meter2_info.h#L671-L673). Nothing records that a particular goat was already counted, so a goat that enters twice is counted twice:

```c++
void daCow_c::setEnterCount() {
    dTimer_createGetIn2D(2, current.pos);
    dMeter2Info_setNowCount(dMeter2Info_getNowCount() + 1); // no per-goat check

    mTimer1 = 50;
    mCrazy = daCow_c::Crazy_Dash;
    mEnterTimerDone = false;

    if (dMeter2Info_getNowCount() == (u8)dMeter2Info_getMaxCount()) {
        mEnterTimerDone = true;
    }
}
```

The game only finishes when a goat completes its entry while the count is exactly equal to the total: [`daCow_c::action_enter`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_cow.cpp#L1397-L1536) checks `dMeter2Info_getNowCount() == dMeter2Info_getMaxCount()` before calling [`daNpc_Aru_c::setLastIn`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/include/d/actor/d_a_npc_aru.h#L173) (Fado):

```c++
if (dMeter2Info_getNowCount() == (u8)dMeter2Info_getMaxCount() &&
    mEnterTimerDone)
{
    daNpc_Aru_c* aru;
    fopAcM_SearchByName(fpcNm_NPC_ARU_e, (fopAc_ac_c**)&aru);
    if (aru) {
        aru->setLastIn();
    }
}
```

Once the count overshoots the total, that equality can never be true again, so the minigame keeps running.

## Primary Source

{% youtube J8Q50kn_hn8 %}
