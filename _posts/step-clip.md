---
layout: post
title: Step Clip
description: The animation that disables Link's wall collision
author: qwertyquerty
categories: [Glitches]
tags: [type-glitch, mechanic-collision]
pin: true
math: true
mermaid: true
date: 2025-09-17 00:00:00
---

## About

When Link steps up onto a short ledge thats tall enough to enter a stepping animation, during that action state, line checks for walls are disabled. This allows Link to be pushed through walls and out of bounds by a push collider such as a pot, skull, or enemy. It's possible to drop a held item by pulling sword during the step animation, making step clips rather trivial to perform manually.

> Example video of using a skull to step clip out of bounds in triple stalfos room

{% youtube z1FwzSQpg1s %}

## How it works

Excerpt from `d_a_alink.cpp`:

```c++
void daAlink_c::commonProcInit(daAlink_c::daAlink_PROC i_procID) {
    ...

    if (checkModeFlg(MODE_NO_COLLISION) || mProcID == PROC_STEP_MOVE || mProcID == PROC_WOLF_TAG_JUMP) {
        mLinkAcch.OffLineCheck();
        mLinkAcch.OnLineCheckNone();
    } else {
        mLinkAcch.OnLineCheck();
        mLinkAcch.OffLineCheckNone();
        ...
    }

    ...
}
```

When Link enters the stepping proc (or a midna jump, though this hasn't been found to be useful yet), `LineCheck` is turned off and `LineCheckNone` is turned on. They remain that way until a different proc is entered. The effects of those flags can be seen below:

```c++
void dBgS_Acch::CrrPos(dBgS& i_bgs) {
    ...
    
    if (!(m_flags & 1)) {
        ...

        bool bvar2 = false;

        OffLineCheckHit();
        if (!ChkLineCheckNone() && !cM3d_IsZero(tmp) &&
            (dvar10 > (tmp * tmp) || fvar12 > fvar1 || dvar11 > m_gnd_chk_offset || ChkLineCheck()))
        {
            bvar2 = true;
            LineCheck(i_bgs);
        }

        if (!(m_flags & WALL_NONE)) {
            if (ChkWallSort()) {
                i_bgs.WallCorrectSort(this);
            } else {
                i_bgs.WallCorrect(this);
            }
        }

        if (ChkWallHit() && bvar2) {
            LineCheck(i_bgs);
        }
    }
}
```

It can be seen that if `ChkLineCheckNone` is true, `LineCheck` will never be called, and `ChkLineCheckNone` is true during the step action.

Additionally, if all of these are false `dvar10 > (tmp * tmp) || fvar12 > fvar1 || dvar11 > m_gnd_chk_offset || ChkLineCheck()`, `LineCheck` will also be skipped.

> TODO: It's not clear yet what `dvar10 > (tmp * tmp) || fvar12 > fvar1 || dvar11 > m_gnd_chk_offset` is checking and this should be researched further

Additionally, `bvar2` will remain false in these cases so the second opportunity for `LineCheck` to run will also be skipped.

`LineCheck` is a function responsible for checking if Link's movement in a frame intersects a background collision polygon.

> TODO: It's not clear yet why skipping `LineCheck` causes WallCorrect to not have effect, and this should be researched further

