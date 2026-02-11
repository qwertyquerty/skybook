---
layout: post
title: Door Storage
description: Explanation when and why floorclips happen
author: spicyjuice04
categories: [Glitches]
tags: [type-glitch, mechanic-collision]
pin: true
math: true
mermaid: true
date: 2025-09-19 00:00:00
---

### Initialization

Door Storage or Reverse Door Adventure (RDA) is an interesting glitch, that involves Map Glitch and keeping some properties of an event flag when entering a Door while holding a one handed item out. When performing the glitch, Link's hitbox changes in a strange way, he can walk into walls without loosing speed or even climb up steep walls as if they were slopes, or even clip through some walls.

> TODO: It is not understood why holding out a onehanded item is necessary for the initialization

```c++
int daAlink_c::procDoorOpenInit() {

    ...

    mLinkAcch.SetWallNone();
    mLinkAcch.OnLineCheckNone();

    ...

    return 1;
}
```
_`(d_a_alink_demo.inc)`_

In this part of the code, Door Storage gets set. Since this Door Opening Cutscene is normally a loading Zone, there is no reason for this part of the code to disable this function. Thankfully since we can activate Map Glitch this loading zone will never initialize and if we actually did hold out a one handed item we can keep this flag and play around with it.

Link's actor collision check can be seen in `CrrPos`. The `SetWallNone` flag that gets set from Door Storage does have an impact of the collision handling for Link by activating the `WALL_NONE` flag. `OnLineCheckNone` doesn't though since that only turns on `LINE_CHECK_NONE` but doesn't disable `LINE_CHECK`, so those still go through.

```c++
...
        if (!(m_flags & WALL_NONE)) {
            if (ChkWallSort()) {
                i_bgs.WallCorrectSort(this);
            } else {
                i_bgs.WallCorrect(this);
            }
        }
        ...
```

This is a snippet from `CrrPos`. This part of the code is crucial in handling wall intersections with the actor circle. Since `WALL_NONE` is set, this code will not get executed.

### How do you scale walls

Only because this part of the code now ignores for adjusting Link's wall correction with his actor circle doesn't mean that you can now just go through walls. `LineCheck` is still working and will prevent you from any crossing with the walls. There are other benefits this glitch state can provide us.

```c++
...
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

Checking for the ground still works perfectly fine, except that there is no `LineCheck`. Going through a floor with high speed though is still pretty much impossible because Link has 3 colliders that all can interact with the ground so going through a floor with that is not possible. Let's get a closer look at `GroundCheck``

```c++
void dBgS_Acch::GroundCheck(dBgS& i_bgs) {
    if (!(m_flags & GRND_NONE)) {
        cXyz grnd_pos;
        grnd_pos = *pm_pos;
        grnd_pos.y += field_0x94 + (m_gnd_chk_offset - field_0x90);
        
        ...

        field_0x94 = 0.0f;
        m_gnd.SetPos(&grnd_pos);
        m_ground_h = i_bgs.GroundCross(&m_gnd);

        if (m_ground_h != -1000000000.0f) {
            field_0xbc = m_ground_h + field_0x90;
            if (field_0xbc > field_0xb8) {
                pm_pos->y = field_0xbc;

                if (ChkClrSpeedY() && pm_speed != NULL) {
                    pm_speed->y = 0.0f;
                }

                i_bgs.GetTriPla(m_gnd, &field_0xa0);
                SetGroundFind();
                SetGroundHit();

                if (field_0xc0 == 0) {
                    field_0xc0 = 1;
                    i_bgs.RideCallBack(m_gnd, m_my_ac);
                }

                if (field_0xb4 == 0) {
                    SetGroundLanding();
                }
            }
        }

        if (field_0xb4 && !ChkGroundHit()) {
            SetGroundAway();
        }
    }
}
```

This is the normal check done to see if there is ground below Link. Most of the checks do not change our behavior with Door Storage active, the game finds ground in its usual way with `SetGroundFind`, `SetGroundHit` and `GroundCross`. `SetGroundFind` and `SetGroundHit` are not that interesting since they just check for the `GROUND_HIT` and `GROUND_FIND` flags but `GroundCross` has some meaningful code attached to it.

```c++
bool cBgW::GroundCrossRp(cBgS_GndChk* i_gndchk, int i_idx) {
    ...
    if ((tree->m_flag & 1)) {
        if (i_gndchk->GetWallPrecheck() && pm_blk[tree->m_id[0]].m_wall_idx != 0xFFFF &&
            RwgGroundCheckWall(pm_blk[tree->m_id[0]].m_wall_idx, i_gndchk))
        {
            chk = true;
        }
        return chk;
    }
    ...
}
```

The game does actually call `RwgGroundCheckWall` here.

```c++
bool cBgW::RwgGroundCheckWall(u16 i_poly_idx, cBgS_GndChk* i_gndchk) {
    bool chk = false;
    while (true) {
        cBgW_TriElm* tri = &pm_tri[i_poly_idx];
        cBgW_RwgElm* rwg = &pm_rwg[i_poly_idx];
        if (tri->m_plane.mNormal.y >= 0.014f) {
            f32 tri_y = tri->m_plane.getCrossY_NonIsZero(&i_gndchk->GetPointP());
            if (RwgGroundCheckCommon(tri_y, (u32)i_poly_idx, i_gndchk)) {
                chk = true;
            }
        }

        if (rwg->m_next == 0xFFFF)
            break;
        i_poly_idx = rwg->m_next;
    }

    return chk;
}
```

the line `if (tri->m_plane.mNormal.y >= 0.014f)` takes into account which walls to consider for this check. pretty much straight or nearly straight walls are not considered for this check. The function after this that gets passed checks for `RwgGroundCheckCommon`

```c++
bool cBgW::RwgGroundCheckCommon(f32 i_yPos, u16 i_poly_idx, cBgS_GndChk* i_gndchk) {
    if (i_yPos < i_gndchk->GetPointP().y && i_yPos > i_gndchk->GetNowY()) {
        cBgD_Tri_t* tri = &pm_bgd->m_t_tbl[i_poly_idx];
        if (cM3d_CrossY_Tri_Front(pm_vtx_tbl[tri->m_vtx_idx0], pm_vtx_tbl[tri->m_vtx_idx1],
                                  pm_vtx_tbl[tri->m_vtx_idx2], (const Vec*)&i_gndchk->GetPointP()))
        {
            if (!ChkPolyThrough(i_poly_idx, i_gndchk->GetPolyPassChk())) {
                i_gndchk->SetNowY(i_yPos);
                i_gndchk->SetPolyIndex(i_poly_idx);
                return true;
            }
        }
    }

    return false;
}
```

This generally code generally checks for your Y position, so if your new position has your Ground Offset intersecting with collision in general, it updates your position up or down to it. With this set, this does indeed include walls. Normally it is already possible to stand on walls like with _Humang Movement in AG_. Though unlike those cases, Storage should make it possible to climb up walls with this

The `LineCheck` is still working but doesn't make it impossible to scale up walls at all, because there it starts checking for walls at a specific height, similar to the Wall Corrections. It starts running for walls at 48 units above Link.

> TODO: It is not fully understood. This 48 number is present in many in game frame steps for collision correction with Line Checks in Link's case. However checking in game, walls are actually already considered at a height of 35 units. Possibly a distinction between general Wall Correction and Line Check?

With this in mind, Link now can scale up walls up to a maximum of 48 units per frame on these walls. This also means that when we are scaling walls and they suddenly go inwards, LineCheck will not see those walls, meaning you can clip through those structures.

![Image of clippable wall with Storage](/assets/glitches/door-storage/door-storage-clip.png){: .w-50 .normal }

{% youtube yXUzVuS2Uro %}

### Sliding Effect

> TODO

