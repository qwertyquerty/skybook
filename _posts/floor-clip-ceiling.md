---
layout: post
title: Floor Clips with Ceilings
description: Explanation when and why floorclips happen
author: spicyjuice04
categories: [Glitches]
tags: [glitch, clip, collision, minor]
pin: true
math: true
mermaid: true
date: 2025-09-14 00:00:00
---

Sometimes in this game you may encounter a clip through the floor when falling onto it in seemingly random places and only when performing specific actions. There are two known ways a floorclip can happen, this post goes over floorclipping with a ceiling below the floor.

> *Example of a ceiling below a floor in Snowpeak Ruins*

![Example of a ceiling below a floor in Snowpeak Ruins](/assets/glitches/floor-clip-ceiling/snowpeak-floor-clip-area.webp){: .w-50 .normal }

Before we go over this we need to understand how the game actually checks if Link hits ground collision. For this we can read the relevant sections of `d_bg_s_acch.cpp`, the Background Actor Check which pretty much every actor uses, and see how the game specifically checks for collision. We are looking for how collision gets handled while Link is in the air:

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

`pm_old_pos` is the position used at the beginning of the frame and `pm_pos` is the current position, that other variables, especially `GetPos()` constantly update for the next frame. 

```c++
void dBgS_Acch::GroundCheck(dBgS& i_bgs) {
    if (!(m_flags & GRND_NONE)) {
        cXyz grnd_pos;
        grnd_pos = *pm_pos;
        grnd_pos.y += field_0x94 + (m_gnd_chk_offset - field_0x90);

        if (!ChkGndThinCellingOff()) {
            static dBgS_RoofChk tmpRoofChk;
            tmpRoofChk.SetActorPid(m_gnd.GetActorPid());
            tmpRoofChk.SetPos(*pm_pos);

            f32 roof_chk = i_bgs.RoofChk(&tmpRoofChk);
            if (grnd_pos.y > roof_chk) {
                grnd_pos.y = roof_chk;
            }
        }
    ...
    }
}
```

The `GroundCheck` get's checked inside `CrrPos`. The code pasted above is really interesting because it checks for a very interesting function. `ChkGndThinCellingOff` is the relevant function here and actually what is causing us to clip through a floor when there is a ceiling below us. This function doesn't get called if the `ChkGndThinCellingOff` flag is active but for the Link actor it is always inactive so that line of code runs. This check basically allows us in the air, that hitting a ceiling collision let's us phase through the ground.

It is actually unknown why this part of code exists because it doesn't seem to prevent crush voiding or general movement through a ceiling. So this seems to be unnecessary code that we can thankfully abuse to make this possible.

### Last specific notes

Since we would trigger `LineCheck` if we are falling more than 48 units in a frame, we can't trigger this type of floorclip while falling that fast. The `LineCheck` code runs before the other codeblocks and would already clamp our position to the floor above and kill all vertical and horizontal speed since that is also something that code does.

Additionally, this behavior triggers only if we were not standing on the ground before because of the `!(m_flag...)` requirement to run that line of code.

Lastly, the floor clip has to be quite specific. In order for it to work you need to be not in the air (not touching ground) the frame before and then immediately touch the ceiling the next frame so you don't hit the floor. This often requires specific setups in order to hit the ceiling without hitting floor beforehand and also not triggering `LineCheck`.

### Video Example

Here is an example of a floor clip in Snowpeak Ruins:

<iframe width="500" height="300" src="https://www.youtube.com/embed/YHQSjTwygYA" frameborder="0" allowfullscreen></iframe>
