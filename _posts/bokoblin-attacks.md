---
layout: post
title: Bokoblin Attacks
description: How does the Bokoblin decide to attack?
author: spicyjuice04
categories: [Reference]
tags: [type-reference, mechanic-rng]
pin: true
math: true
mermaid: true
date: 2025-11-11 00:00:00
---

## Initializing Attack

code snippets are from `d_a_e_oc.cpp`

```c++

void daE_OC_c::executeFind() {
    s16 pl_ang = fopAcM_searchPlayerAngleY(this);
    f32 pl_dist = fopAcM_searchPlayerDistance(this);
    if (mOcState < 3 || (setWatchMode() & 0xff) == 0) {
        ...
        switch (mOcState) {
            ...
            case 4:
            if (checkBeforeFloorBg(200.0f) & 0xff) {
                if (field_0x6e3)
                    setActionMode(0x10, 0);
                else
                    setActionMode(0xf, 0);
            } else { 
                ...
                if (my_status == 0) {
                    if (field_0x6c2 == 0) {
                        if (pl_dist < 300.0f)
                            cLib_chaseF(&speedF, -3.0f, 1.0f);
                        else
                            cLib_chaseF(&speedF, 20.0f, 1.0f);
                        if (pl_dist < 400.0f && pl_dist > 200.0f) {
                            if (abs(shape_angle.y - fopAcM_searchPlayerAngleY(this)) >= 0x1000)
                                return;
                            if (my_status == 0) {
                                setActionMode(4, 0);
                            }
                            return;
                        }
                    }
                    ...
                }
                ...
            }
        }
    }
}
```

In this part of the code we can find when exactly the Bokoblin starts to attack. The attack state is set using `setActionMode` with the value 4. This part of the code is the only time the Bokoblin is set to attack mode so it needs to be in the find mode for that to be possible.

Additionally there are other restrictions. Because of the line `ìf (pl_dist < 400.0f && pl_dist > 200.0f)` the next part of the code only gets executed when Link is between 200 and 400 units away from the Bokoblin. Other parts I left out handle what state the Bokoblin should go in for other values. The only example I have put in is `if (pl_dist < 300.0f) cLib_chaseF(&speedF, -3.0f, 1.0f);` which makes the Bokoblin move slightly backwards if Link is closer than 300 units to the Bokoblin. 

If we are closer than 200 units to the Bokoblin then it won't attack which is also what makes Bokoblin Pushing flawlessly possible.

## Decision Vertical or Horizontal Slash

The `setActionMode` set to 4 executes the code block of `executeAttack`

```c++

void daE_OC_c::executeAttack() {
    ...
    switch(mOcState) {
        case 0:
            if (cLib_chaseF(&speedF, 0.0f, 1.0f)) {
                if (cM_rndF(1.0f) < 0.5f) {
                    setBck(5, 0, 5.0f, 1.0f);
                    mSound.startCreatureVoice(Z2SE_EN_OC_V_ATTACK_B, -1);
                    mOcState = 1;
                } else {
                    setBck(6, 0, 5.0f, 1.0f);
                    mSound.startCreatureVoice(Z2SE_EN_OC_V_ATTACK_C, -1);
                    mOcState = 2;
                }
                field_0x6a0 = 0.0f;
            }
            break;
        ...
    }
}
```

`mOcState` set to 1 is the horizontal attack and set to 2 is the vertical attack. `cM_rndF` is an rng value. This specific rng concludes that it is a pure 50/50 if the slash is vertical or horizontal. Other factors like position do not have an influence on how the Bokoblin attacks.

    





    

