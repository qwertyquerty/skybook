---
layout: post
title: Bad Air
description: Why Link gets bad air
author: qwertyquerty
categories: [Glitches]
tags: [type-glitch]
pin: true
math: true
mermaid: true
date: 2025-09-12 00:00:00
---

## Summary

If Link goes underwater and resurfaces before the air meter appears, the meter will appear sooner the next time he goes underwater, effectively giving him less air.

## How It Works

The cause is in [`daAlink_c::checkOxygenTimer`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink_swim.inc#L56-L88) in [`d_a_alink_swim.inc`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink_swim.inc), which runs every frame from Link's main execute function:

```c++
void daAlink_c::checkOxygenTimer() {
    BOOL is_hide_timer;

    if (!checkNoResetFlg0(FLG0_SWIM_UP) ||
        (checkModeFlg(MODE_SWIMMING) && mWaterY > 5.0f + current.pos.y))
    {
        is_hide_timer = false;
    } else {
        is_hide_timer = true;
    }

    if (dComIfGp_getOxygenShowFlag()) {
        if (checkZoraWearAbility()) {
            offOxygenTimer();
        } else if (is_hide_timer) {
            dComIfGp_setOxygenCount(dComIfGp_getMaxOxygen());
            if (field_0x2fbe < 90) {
                field_0x2fbe++;
            } else {
                offOxygenTimer();
            }
        } else if (!checkEventRun()) {
            dComIfGp_setOxygenCount(-1);
        }
    } else if (!is_hide_timer && !checkZoraWearAbility()) {
        if (field_0x2fbe != 0) {
            field_0x2fbe--;
        } else {
            dComIfGp_onOxygenShowFlag();
            dComIfGp_setOxygen(dComIfGp_getMaxOxygen());
        }
    }
}

void daAlink_c::offOxygenTimer() {
    dComIfGp_offOxygenShowFlag();
    dComIfGp_setOxygen(dComIfGp_getMaxOxygen());

    field_0x2fbe = 90;
}
```

`is_hide_timer` is false while Link is underwater: either [`FLG0_SWIM_UP`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/include/d/actor/d_a_player.h#L346) is off (it is turned off when Link dives or sinks below the surface, and back on when he resurfaces), or he is swimming with the water surface more than 5 units above his position.

[`field_0x2fbe`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/include/d/actor/d_a_alink.h#L4175) is a countdown for how long it takes the air meter to appear once Link goes underwater. [`offOxygenTimer`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink_swim.inc#L90-L95) sets it to 90 frames (3 seconds).

While Link is underwater and the meter is hidden, `field_0x2fbe` is decremented every frame. When it reaches 0, [`dComIfGp_onOxygenShowFlag`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/include/d/d_com_inf_game.h#L4189-L4191) shows the air meter and Link's actual air starts counting down ([`dComIfGp_setOxygenCount(-1)`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/include/d/d_com_inf_game.h#L3637-L3639) each frame, unless an event is running):

```c++
if (field_0x2fbe != 0) {
    field_0x2fbe--;
} else {
    dComIfGp_onOxygenShowFlag();
    dComIfGp_setOxygen(dComIfGp_getMaxOxygen());
}
```

When Link resurfaces while the meter is shown (`dComIfGp_getOxygenShowFlag()` is true), `is_hide_timer` is true, so his air is refilled and `field_0x2fbe` counts back up to 90. Once it reaches 90, `offOxygenTimer` hides the meter again:

```c++
if (dComIfGp_getOxygenShowFlag()) {
    ...
    } else if (is_hide_timer) {
        dComIfGp_setOxygenCount(dComIfGp_getMaxOxygen());
        if (field_0x2fbe < 90) {
            field_0x2fbe++;
        } else {
            offOxygenTimer();
        }
    }
    ...
}
```

However, if Link resurfaces while the meter is not shown (`dComIfGp_getOxygenShowFlag()` is false), neither branch touches `field_0x2fbe`, so it keeps its partially decremented value.

The next time Link goes underwater, the meter appears that much sooner. For example, if Link goes underwater for 45 frames and resurfaces, the meter will appear 45 frames sooner on his next dive, effectively giving him 1.5 seconds less air.

The countdown is only reset to 90 when `offOxygenTimer` runs. Besides the case above, that happens in [`daAlink_c::swimOutAfter`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink_swim.inc#L560-L581) (when Link leaves the water), [`daAlink_c::playerInit`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L4416-L4641) (when Link is created, for example after a loading zone), and when the meter is shown while Link has the Zora Armor's ability. So bad air carries over between dives as long as Link stays in the water and dives again before the meter disappears.
