---
layout: post
title: Bad Air
description: Why Link gets bad air
author: qwertyquerty
categories: [Glitches]
tags: [glitch]
pin: true
math: true
mermaid: true
---

Bad air is a glitch that *Twilight Princess* speedrunners often caution about. If Link goes underwater and resurfaces before the air meter appears, it'll appear much sooner the next time he goes underwater, effectively giving him less air. But why does this happen?

The underlying cause is found in this code snippet from `d_a_alink_swim.inc`:

```c++
void daAlink_c::checkOxygenTimer() {
    BOOL hide_timer;

    if (!i_checkNoResetFlg0(FLG0_UNK_100) ||
        (i_checkModeFlg(MODE_SWIMMING) && mWaterY > lit_7808 + current.pos.y))
    {
        hide_timer = false;
    } else {
        hide_timer = true;
    }

    if (dComIfGp_getOxygenShowFlag()) {
        if (checkZoraWearAbility()) {
            offOxygenTimer();
        } else if (hide_timer) {
            s32 max = dComIfGp_getMaxOxygen();
            dComIfGp_setOxygenCount(max);

            if (field_0x2fbe < 90) {
                field_0x2fbe++;
            } else {
                offOxygenTimer();
            }
        } else if (!checkEventRun()) {
            dComIfGp_setOxygenCount(-1);
        }
    } else if (!hide_timer && !checkZoraWearAbility()) {
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
    s32 max = dComIfGp_getMaxOxygen();
    dComIfGp_setOxygen(max);

    field_0x2fbe = 90;
}
```

The relevant field is `field_0x2fbe` which acts as a countdown timer for how long it takes the air meter to appear once link goes underwater. It is initialized to 90 frames (or 3 seconds) as seen in `offOxygenTimer`.

As soon as Link goes underwater, `checkOxygenTimer`, which is run every frame, starts decrementing `field_0x2fbe` until it reaches zero, at which point it calls `dComIfGp_onOxygenShowFlag` to make the air meter appear and start counting down links actual oxygen:

```c++
if (field_0x2fbe != 0) {
    field_0x2fbe--;
} else {
    dComIfGp_onOxygenShowFlag();
    dComIfGp_setOxygen(dComIfGp_getMaxOxygen());
}
```

When Link resurfaces while the air meter is shown (`dComIfGp_getOxygenShowFlag()` is true), `hide_timer` is true and `field_0x2fbe` is incremented back to 90. Once it reaches 90 `offOxygenTimer` is called to hide the air meter again.

```c++
if (dComIfGp_getOxygenShowFlag()) {
  ...
  else if (hide_timer) {
      s32 max = dComIfGp_getMaxOxygen();
      dComIfGp_setOxygenCount(max);

      if (field_0x2fbe < 90) {
          field_0x2fbe++;
      } else {
          offOxygenTimer();
      }
  }
  ...
}
```

However, you might notice that if Link resurfaces while the air meter is not shown (`dComIfGp_getOxygenShowFlag()` is false), `field_0x2fbe` will never be incremented back to 90. Since the air meter is not shown until `field_0x2fbe` reaches 0, any time Link goes underwater and quickly resurfaces again before it does reach 0 will cause it to retain its partially decremented value.

This will cause the delay for the air meter appearing to be less the next time Link goes underwater. For example if Link goes underwater for 45 frames and resurfaces, the air meter will appear 45 frames sooner the next time he goes underwater, effectively giving Link 1.5 seconds less air.
