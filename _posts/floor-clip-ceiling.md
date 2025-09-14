---
layout: post
title: Floor Clips with Ceilings
description: Explanation when and why floorclips happen
author: spicyjuice04
categories: [Glitches]
tags: [glitch, collision, minor]
pin: true
math: true
mermaid: true
date: 2025-09-14 00:00:00
---

Sometimes in this game you may encounter clipping through the floor when falling onto it at seemingly random places and then only when performing specific actions. There are two known ways a floorclip can happen, this post goes over floorclipping with a ceiling below the floor. But before we go over this we need to understand how the game actually checks if Link hits ground collision. For this we go into the relevant sections of `d_bg_s_acch.cpp`, the Background Actor Check that pretty much all actors use and see how the game specifically checks for collision. We are looking for how this collision gets handled while Link is in the air.

```c++
void dBgS_Acch::CrrPos(dBgS& i_bgs) {
    bool bvar9;
    if (!(m_flags & 1)) {
        JUT_ASSERT(792, pm_pos != 0);
        JUT_ASSERT(793, pm_old_pos != 0);

        JUT_ASSERT(833, fpclassify(pm_pos->x) == 1);
        JUT_ASSERT(834, fpclassify(pm_pos->y) == 1);
        JUT_ASSERT(835, fpclassify(pm_pos->z) == 1);

        JUT_ASSERT(837, -1.0e32f < pm_pos->x && pm_pos->x < 1.0e32f);
        JUT_ASSERT(838, -1.0e32f < pm_pos->y);
        JUT_ASSERT(839, pm_pos->y < 1.0e32f);
        JUT_ASSERT(840, -1.0e32f < pm_pos->z && pm_pos->z < 1.0e32f);

        i_bgs.MoveBgCrrPos(m_gnd, ChkGroundHit(), pm_pos, pm_angle, pm_shape_angle, false, false);

        ...

        GroundCheckInit(i_bgs);
        Init();

        f32 tmp = GetWallAllLowH_R();
        f32 dvar10 = GetOldPos()->abs2XZ(*GetPos());
        f32 dvar11 = GetOldPos()->y - GetPos()->y;
        f32 tmp2 = GetWallAllLowH();

        field_0xb8 = GetPos()->y;
        field_0xc0 = 0;
        f32 fvar12 = tmp2 + GetOldPos()->y;
        f32 fvar1 = m_gnd_chk_offset + GetPos()->y;
        bool bvar2 = false;

        ...

        OffLineCheckHit();
        if (!ChkLineCheckNone() && !cM3d_IsZero(tmp) &&
            (dvar10 > (tmp * tmp) || fvar12 > fvar1 || dvar11 > m_gnd_chk_offset || ChkLineCheck()))
        {
            bvar2 = true;
            LineCheck(i_bgs);
        }

        ...

        if (!(m_flags & ROOF_NONE)) {
            m_roof.SetExtChk(*this);
            ClrRoofHit();
            cXyz roof_pos;
            roof_pos.x = pm_pos->x;
            roof_pos.y = pm_pos->y;
            roof_pos.z = pm_pos->z;

            m_roof.SetPos(roof_pos);
            m_roof_height = i_bgs.RoofChk(&m_roof);

            if (m_roof_height != 1000000000.0f) {
                f32 y = GetPos()->y;

                if (y + m_roof_crr_height > m_roof_height) {
                    field_0xcc = m_roof_height - m_roof_crr_height;
                    SetRoofHit();
                }
            }
        }

        if (!(m_flags & GRND_NONE)) {
            ClrGroundFind();
            GroundCheck(i_bgs);
            GroundRoofProc(i_bgs);
        } else {
            if (field_0xcc < GetPos()->y) {
                GetPos()->y = field_0xcc;
            }
        }
        ...
    }
}
```

### Floordetection for this scenario

This code block is usually bigger but because of the specific scenario, we can ignore functions that involve walls aswell as functions that assume you were already on the ground the previous frame, so functions using `ChkGroundHit` can be ignored. 

`pm_old_pos` is the position used at the beginning of the frame and `pm_pos` is the current position, that other variables, especially `GetPos()` constantly update for the next frame. First this game goes over the conditions to run the LineCheck 

```c++
OffLineCheckHit();
if (!ChkLineCheckNone() && !cM3d_IsZero(tmp) &&
    (dvar10 > (tmp * tmp) || fvar12 > fvar1 || dvar11 > m_gnd_chk_offset || ChkLineCheck()))
{
    bvar2 = true;
    LineCheck(i_bgs);
}
```

One of the following conditions has to be met in order to trigger `LineCheck`. Most of these conditions go over conditions with walls but `dvar11 > m_gnd_chk_offset` is a condition that means `LineCheck` will trigger if our vertical displacement is higher than the ground check offset (which is for Link 45 units).

This all pretty much makes sense so this doesn't have to run unnecessarily when all the groundchecks are running anyways to prevent the basic passing though the floor.

### Why Line Check is such an issue

```c++
if (i_bgs.LineCross(&lin_chk)) {
    *GetPos() = lin_chk.GetCross();
    OnLineCheckHit();

    if (pm_out_poly_info != NULL)
        *pm_out_poly_info = lin_chk;

    GetPos()->y -= 1.0f;
    GroundCheck(i_bgs);
}
```

Inside the `ChkLineDown` part of `LineCheck` we can find this part of the code. The problem is that the highest point the Line Check hits a floor our y position will be set to that floor -= 1.0f. This makes it impossible to clip past a floor even if there is a ceiling under it since we are then never under a ceiling unless it is inside the floor itself which is only the case on structures like rocks or doors that overlap with background collision.

### Order of Operations outside of LineCheck

If we are falling slower than 45 units, then we will never trigger `LineCheck`. So what happens now?

```c++
...

        if (!(m_flags & ROOF_NONE)) {
            m_roof.SetExtChk(*this);
            ClrRoofHit();
            cXyz roof_pos;
            roof_pos.x = pm_pos->x;
            roof_pos.y = pm_pos->y;
            roof_pos.z = pm_pos->z;

            m_roof.SetPos(roof_pos);
            m_roof_height = i_bgs.RoofChk(&m_roof);

            if (m_roof_height != 1000000000.0f) {
                f32 y = GetPos()->y;

                if (y + m_roof_crr_height > m_roof_height) {
                    field_0xcc = m_roof_height - m_roof_crr_height;
                    SetRoofHit();
                }
            }
        }

        if (!(m_flags & GRND_NONE)) {
            ClrGroundFind();
            GroundCheck(i_bgs);
            GroundRoofProc(i_bgs);
        } else {
            if (field_0xcc < GetPos()->y) {
                GetPos()->y = field_0xcc;
            }
        }
        ...
```

The game looks for Roof collision _first_ and looks for ground collision _after_. This is very important because this means as long as we don't trigger the LineChecks, are still in the air and are below a ceiling collision with our current position, the game updates our position to the ceiling first, snapping Link's entire model below the floor, the floor is not even seen after since the ceiling is below the floor. 

### Last specific notes

Since we would trigger `LineCheck` if we are falling more than 45 units, we can't trigger this type of floorclip while falling that fast. 

Additionally, this behavior triggers only if we were not standing on the ground before because on ground you got 0 vertical speed and can't fall to the ceiling. 

Lastly the floor clip has to be quite specific. In order for this to work you need to be not in the air (not touching ground) the frame before and then immediately touch the ceiling the next frame so you don't loose all your vertical speed from hitting the floor and not clipping. This sometimes requires specific setups in order to hit the ceiling without hitting floor before and also not triggering `LineCheck`.