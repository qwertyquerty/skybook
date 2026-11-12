---
layout: post
title: Link's Position in One Frame
description: Every step that moves or judges human Link's position in one frame, in the order the code runs it.
author: qwertyquerty
categories: [Reference]
tags: [type-reference, mechanic-collision, mechanic-movement]
math: true
mermaid: true
date: 2026-11-11 00:00:00
---

This page walks through one frame of human Link on foot: every step that moves his position or judges it, in the order the code runs them. It covers on-foot Link only; wolf, swimming and riding branch off elsewhere ([`execute`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L18151-L18155)). Code links point to the decomp at commit `c8fa8c9`.

## Terms

- **pos**: the point at Link's feet. **old.pos**: pos at the start of the frame.
- **CrrPos**: the background collision routine that runs steps 4 to 10 ([`dBgS_Acch::CrrPos`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/d_bg_s_acch.cpp#L310-L463)).
- **Circle**: one of three horizontal test circles at fixed heights above the feet.
- **Slice**: the line where a wall crosses a circle's height. **Pusher**: the slice moved one circle radius out from the wall.
- **Mode**: flags that every proc (Link's current action) sets.
- **CC push**: the push from colliding with another actor, such as a pot or an enemy.

![Face types](/assets/reference/link-frame-collision/00_surface_types.png)

- Every face is a roof, wall or floor by its normal's y part (n.y) ([`c_bg_w.cpp`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/SSystem/SComponent/c_bg_w.cpp#L24-L45)).
- The ground check uses its own, looser rule: n.y >= 0.014 (step 8).

All diagrams share one color key, listed in each legend: green floors, orange walls, pink roofs, teal water, blue Link and his result, gray earlier positions, yellow arrows for movement (before to after), purple dashed probes, red bad outcomes.

## Overview

![Overview](/assets/reference/link-frame-collision/00_overview.png)

- Steps 1 to 3 and 11 to 15 run in Link's `execute`; steps 4 to 10 run inside CrrPos.
- A few sub-steps run outside their step's slot: 13.1 and 13.2 run before step 11, and 9.3 runs after it.

## Flow chart

![Order](/assets/reference/link-frame-collision/00_flow_order.png)

- Boxes run top to bottom; the italic line says when a step runs.
- Red boxes are outcomes: a proc change, a restart or a scene change.

![Values (a)](/assets/reference/link-frame-collision/00_flow_values_a.png)

![Values (b)](/assets/reference/link-frame-collision/00_flow_values_b.png)

- Each row is a value: the steps that write it, then the steps that read it this frame and next frame.
- One link worth knowing: the wall pass reads the ground slope before this frame's ground check runs, so it uses last frame's slope.

## 1. Frame start and moving floors

![Frame start](/assets/reference/link-frame-collision/01_frame_start.png)

- **1.1** The framework copies pos into old.pos before every frame ([`f_op_actor.cpp`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/f_op/f_op_actor.cpp#L331)).
- **1.2 to 1.3** If Link stands on a moving platform (or a moving magnetic surface), its motion is added to both pos and old.pos ([`execute`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L17726-L17770)).
- **1.4** A copy of old.pos is kept for steps 11 and 12.
- **Why it matters:** the carry moves both points, so the line check never sees it. Only the one-sided wall pass can stop a platform carrying Link into a wall.

## 2. Action checks before the proc

![Auto-jump judge](/assets/reference/link-frame-collision/02_3_auto_jump.png)

Before the proc runs, a chain of checks can switch it ([`execute`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L18086-L18097)):

- **2.1** Event demos ([`checkDemoAction`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink_demo.inc#L71-L139)).
- **2.2** Death at 0 HP ([`checkDeadAction`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink_demo.inc#L1269-L1296)).
- **2.3** Auto-jump: with no ground hit and the ground more than 50.01 below, Link starts a jump, fall or ledge proc ([`checkAutoJumpAction`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L10733-L10747)). It uses last frame's ground. Smaller drops are handled by the snap in step 12.
- **2.4** Entering deep water ([`checkSwimAction`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink_swim.inc#L346-L470)).
- **2.5** Taking a hit ([`checkDamageAction`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink_damage.inc#L376-L470)).
- **2.6** Catching the boomerang.
- 2.1 to 2.4 form an else-if chain; 2.5 and 2.6 always run.

Other proc changes in a frame:

- **3.1** The proc itself can switch, for example landing from a fall or starting a slide.
- **14.3, 14.4, 14.6** The lava and freeze returns start their own procs.
- Restarts, voids and scene exits do not change the proc: they set a demo mode with no proc and restart the room or change the scene. The overview tags every step that can change the proc.

## 3. posMove

All the frame's movement is added to pos here, before any collision runs ([`posMove`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L12908-L13293)).

### 3.1 Set-pos

![Set-pos](/assets/reference/link-frame-collision/03_1_set_pos.png)

- The proc runs first and may place Link directly (ledge grabs, hang starts).
- Those placements keep old.pos, so the line check covers the jump.
- Event placements also reset old.pos, so their jump is never line-checked ([`setPlayerPosAndAngle`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L9188-L9195)).

### 3.2 Root offsets and the old.pos reset

![old.pos reset](/assets/reference/link-frame-collision/03_2_old_reset.png)

- In hang states and step moves, one root mode sets old.pos = pos, so the next line check has zero length ([`transAnimeProc`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L12763-L12770)).
- Other root modes move pos by the animation offset and leave old.pos alone.

### 3.3 to 3.6 Angle, speed, gravity, ice

![Ground angle](/assets/reference/link-frame-collision/03_3_ground_angle.png)

- **3.3 to 3.4** Speed follows the facing, scaled by the cosine of the slope, and by 0.85 downhill ([`posMove`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L12919-L12963)). The slope counts only on floor-type ground.
- **3.5** Gravity: -3.4 per frame, down to -200; iron boots use 2.25 times the gravity ([`posMove`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L13050-L13065)).
- **3.6** On ice, part of each speed change goes into a separate slip velocity ([`setIceSlipSpeed`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L5259-L5299)).

### 3.7 to 3.14 Moves added to pos

![Move chain](/assets/reference/link-frame-collision/03_7_move_chain.png)

- In order: speed and grab offset, CC push, outside power, ice slip, water stream, wind, root motion ([`posMove`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L13096-L13243)).
- The CC push and the other forces are skipped while hanging (mode 0x40).
- **3.14** Hanging and magnet boots run their own small wall checks; nothing else in posMove checks collision.

## 4. Line check, pass 1

One line per circle, from where Link was to where he is now ([`LineCheck`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/d_bg_s_acch.cpp#L209-L308)).

- **4.1 Trigger:** forced on for Link, so even a 1-unit move is checked ([`commonProcInit`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L15158-L15163)). It is off while hanging, in step moves and on door open.
- **Why it matters:** the wall pass cannot pull back a center that ends behind a wall, so this line is the only guard against crossing a wall in one frame.

### 4.2 Line heights

![Line heights](/assets/reference/link-frame-collision/04_2_line_heights.png)

- Lines run at the circle heights 50.01, 129.99 and 180.
- Under a low roof, the first line above it runs just under the roof and the rest are skipped.
- When falling outside fly states, the lines stay level at the old heights.

### 4.3 Front faces only

![Front faces](/assets/reference/link-frame-collision/04_3_front_faces.png)

- A face counts only if the line starts in front of it and ends behind it; the nearest hit wins ([`LineCheck`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/d_bg_w_kcol.cpp#L427-L433)).
- With only three lines, a crack in the collision at those heights lets a move through.

### 4.4 Wall-type hit

![Wall hit](/assets/reference/link-frame-collision/04_4_wall_hit.png)

- Link is placed 1 unit in front of the hit, and that circle's wall check is pinned to this height ([`LineCheck`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/d_bg_s_acch.cpp#L263-L272)).

### 4.5 Floor-type hit

![Floor hit](/assets/reference/link-frame-collision/04_5_floor_hit.png)

- Link is placed at the hit and a ground check runs there, which can pop him up onto the floor ([`LineCheck`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/d_bg_s_acch.cpp#L273-L276)).

## 5. Wall pass

The wall pushers that hold Link's body away from walls ([`WallCorrectSort`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/d_bg_w_kcol.cpp#L1013-L1460)). See also [Wall Collisions and Correction](/posts/wall-correct-sort).

- **5.1** Skipped while wall correction is off (door open, chest open, a boar knockback).

### 5.2 Circles

![Circles](/assets/reference/link-frame-collision/05_2_circles.png)

- Three circles of radius 35 at 50.01, 129.99 and 180 above the feet, sharing one center ([`create`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L4498-L4500)).
- Some states change them, for example 25/25/25 while ledge hanging.

### 5.3 Sorted list

![Sorted list](/assets/reference/link-frame-collision/05_3_sorted_list.png)

- Walls are sorted so the one Link faces is corrected last and has the final say.
- At most 84 walls per collision source; any wall found after that is dropped ([`WallCorrectSort`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/d_bg_w_kcol.cpp#L1163-L1229)).

### 5.4 Slice height and slice test

![Slope term](/assets/reference/link-frame-collision/05_4a_slope_term.png)

![Slice test](/assets/reference/link-frame-collision/05_4b_slice_test.png)

- Each circle tests walls at its height, raised a little when the ground rises toward the wall.
- A wall band that lies between two circle heights never pushes.

### 5.5 to 5.6 Push zone

![Push zone](/assets/reference/link-frame-collision/05_5_push_zone.png)

- A center between the wall and its pusher is pushed out to 1 unit inside the pusher ([`WallCorrectSort`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/d_bg_w_kcol.cpp#L1350-L1364)).
- **One-sided:** a center behind the wall line is never pushed back out.
- The pusher sits about 35.0064 out, which leaves the seam used by the [displacement clip](/posts/displacement-clipping).

### 5.7 Corners

![Corner push](/assets/reference/link-frame-collision/05_7_corner.png)

- Past the end of a wall, the circle is pushed until the wall's end touches it.

## 6. Line check, pass 2

![Line check pass 2](/assets/reference/link-frame-collision/06_line_check_2.png)

- Runs again from old.pos only if a wall pushed Link ([`CrrPos`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/d_bg_s_acch.cpp#L376-L378)).
- It catches a corner push that carried Link across another wall. Nothing wall-corrects its result again.

## 7. Roof check

![Roof check](/assets/reference/link-frame-collision/07_roof_check.png)

- Finds the lowest roof above the feet. If it is less than 180 above, Link has a roof hit and a roof limit 180 below the roof ([`CrrPos`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/d_bg_s_acch.cpp#L380-L396)).
- It moves nothing itself; steps 8 and 15 use it.

## 8. Ground check

### 8.1 to 8.2 Start and thin-ceiling clamp

![Thin ceiling](/assets/reference/link-frame-collision/08_2_thin_ceiling.png)

- The search starts 60 above the feet, lowered to any roof in between ([`GroundCheck`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/d_bg_s_acch.cpp#L142-L157)).
- A roof face within 60 above the feet hides every floor above it.

### 8.3 to 8.4 Search and step-up

![Ground search](/assets/reference/link-frame-collision/08_3_search.png)

- Takes the highest face below the start with n.y >= 0.014, so steep walls count as ground here ([`GroundCross`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/d_bg_w_kcol.cpp#L570-L587)).
- If it is above Link, he is lifted onto it: this is the step-up. It never moves him down.

### 8.5 Roof-limit clamp

![Roof limit](/assets/reference/link-frame-collision/08_5a_roof_limit.png)

![Floor-level roof](/assets/reference/link-frame-collision/08_5b_floor_level_roof.png)

- If the ground is below the roof limit and Link is above it, he is lowered to the limit ([`GroundRoofProc`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/d_bg_s_acch.cpp#L193-L207)).
- A roof face level with a floor (a closed shutter, for example) puts Link 180 under that floor.

## 9. Water check

![Water check](/assets/reference/link-frame-collision/09_water_check.png)

- Looks for a water surface between the ground and the roof above Link. It never moves him ([`CrrPos`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/d_bg_s_acch.cpp#L408-L453)).
- The water height feeds the restart checks.

## 10. Line-down check

![Line-down check](/assets/reference/link-frame-collision/10_line_down.png)

- A downward line exists in the code, but its flag is never set, so it never runs ([`LineCheck`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/d_bg_s_acch.cpp#L281-L307)).

## 11. Ice slip wall check

![Ice slip check](/assets/reference/link-frame-collision/11_ice_slip.png)

- While sliding on ice, one line at feet height + 10 stops Link 35 short of a wall along the slide ([`iceSlipBgCheck`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L5232-L5257)).

## 12. autoGroundHit

![autoGroundHit](/assets/reference/link-frame-collision/12_auto_ground_hit.png)

- With no ground hit, Link snaps down to floor-type ground up to 50.01 below (more on slopes) ([`autoGroundHit`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L13341-L13382)).
- This keeps him on stairs and slopes. Further drops leave him in the air for the auto-jump judge (2.3) next frame.

## 13. Position restores

![Position restores](/assets/reference/link-frame-collision/13_restores.png)

- Some states throw the collision result away ([`execute`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L18194-L18229)).
- Mode 0x4000 (ledge hang, crawl, item get, chest) keeps the old x/z but the new y, so sideways drift in those states passes through walls.

## 14. Restart checks

![Restart checks](/assets/reference/link-frame-collision/14_restart_checks.png)

- An else-if chain; the first match wins ([`checkRestartRoom`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L13557-L13658)).
- Lava ground starts the lava return; ground codes 4 and 10 exit through the floor's exit.
- With no ground at all, Link only voids after falling more than 2000 in a jump or fall state.

## 15. Crush check

![Crush check](/assets/reference/link-frame-collision/15_crush_check.png)

- With a roof hit and a ground hit, a roof below Link's head top minus 10 voids him ([`checkRoofRestart`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L13524-L13555)).
- The head height comes from the animation, so crouching lowers the threshold.
