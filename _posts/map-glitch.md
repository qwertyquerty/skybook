---
layout: post
title: Map Glitch
description: Interrupting a warp leaves Link in a state where most loading zones and void triggers do nothing.
author: qwertyquerty
categories: [Glitches]
tags: [type-glitch, mechanic-warp, mechanic-cutscene, mechanic-crash, map-castle-town, map-zoras-river]
date: 2026-02-10 00:00:00
---

## Summary

Choosing a warp and interrupting it before it starts leaves loading zones and void planes disabled. Link walks through loading zones and falls through voids without anything happening. Cutscene triggers and save point triggers generally still work. It lasts until an area is loaded (Howling Stone, area-loading cutscene, savewarp, or warp).

Map warping is unlocked by the forced warp after the Kakariko Gorge portal (event flag `M_021`, checked in [`dMenu_Fmap2DTop_c::isWarpAccept`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/d_menu_fmap2D.cpp#L2988-L2997)). Some methods only need Midna warping.

It works on GCN USA/PAL and Wii USA 1.0/PAL/JPN.

## Side Effects

- **Game Over** softlocks: choosing Continue does nothing.
- **Dig spots into another area** leave Wolf Link stuck digging forever, since the loading zone never triggers.
- **Snowpeak's freezing water** still reloads the area, so it can end Map Glitch.
- **Doors:** going through one while holding a one handed item gives [Door Storage](/posts/door-storage), which distorts Link's collision. A door Link cannot go through without falling softlocks.
- **Voids:** Link will never void out while falling. Some cutscene triggers and all water extend downward forever, so they can be reached this way.
- **Senses:** once turned on as Wolf Link, they cannot be turned off, and cutscenes do not turn them off either.
- If Wolf Link is interrupted by Midna, a Midna Jump can happen instead; this still gives Map Glitch.

## Methods

Every method is frame-perfect: there is only a one-frame window on the required inputs, either two inputs on the same frame or one input on a specific frame.

### Common Methods

#### Map Warp + Midna Button Cancel (GCN only)

1. Press D-Right (if the minimap is open) or D-Left (if the minimap is hidden) and Z on the same frame.
2. Select any warp destination on the map screen and choose to warp there.
3. If successful, Midna will talk to you, interrupting the warp.

- **Unplug method:** unplug the controller, press and hold both Z + D-pad, then plug the controller back in. The game reads both inputs on the same frame. For the fastest results, unplug the controller during the loading zone into the area you want Map Glitch in, then plug it back in on the 5th frame after regaining control of Link.
- **Controller reset combo method:** hold the controller reset combo (X + Y + Start) and the Map Glitch inputs (Z + D-Right/Left), then release X, Y, or Start. The game reads the remaining inputs on the same frame. For the fastest results, start holding these buttons during the loading zone into the area you want Map Glitch in, then release X, Y, or Start on the 5th frame after regaining control of Link.

Unplug method:

{% youtube IuReOKB3qLs %}

Controller reset combo method:

{% youtube ydxYu9v8lFE %}

#### Icon Shortcuts + Midna Button Cancel (Wii only)

1. Turn on Icon Shortcuts in the options menu on the pause screen.
2. Open the map with Icon Shortcuts and call Midna on the same frame.
3. Select any warp destination on the map screen and choose to warp there.
4. If successful, Midna will talk to you, interrupting the warp.

The full inputs for step 2: standing still and holding Z, press A, B, and D-Up on the same frame. One of A or B can be held down in advance after Z is held, but the other one plus D-Up must be pressed on the same frame.

{% youtube MX1t6HAPres %}

#### Universal Map Delay (GCN only)

[Universal Map Delay (UMD)](/posts/universal-map-delay-umd) holds the map back for as long as A and B are alternated frame-perfectly. This can be done without map warping.

1. Open the map screen: call Midna and choose to warp, press D-Right (D-Left with the minimap closed), or let a gameplay cutscene bring it up.
2. Start alternating A and B on the frame you select the warp option or open the map screen.
3. While alternating, enter or start a cutscene, such as a door opening, a gameplay cutscene like the Master Sword cutscene, or transforming.
4. Stop the inputs during the cutscene so the map comes up, then choose a warp destination.
5. If successful, the cutscene interrupts the warp, and you have Map Glitch once it ends or is skipped.

This only works when there is enough time to start the delay before the map opens, so it does not work for the forced warp after the Kakariko Gorge portal.

{% youtube qia298nVPt8 %}

### Other Methods

#### Midna Warp + Fast Action Button Cancel

This can be done without the ability to warp from the map screen, though warping through Midna is still required. It only works as Wolf Link with Midna riding on his back.

1. Stand next to a Howling Stone or a patch of horse/bird grass as Wolf Link.
2. Call Midna and choose to warp.
3. Select any warp destination on the map screen and choose to warp there.
4. Press A to interact with the Howling Stone or grass.
5. If successful, the warp is interrupted.

This only works on these objects because of how long the A button takes to reappear after talking to Midna. For most objects there is about a one second delay, but for these the A button reappears almost instantly.

{% youtube S2TwgXTIY_A %}

#### Map Warp + Animation Item Cancel

1. Equip an item that plays a short cutscene when used. Known working items include a bottle filled with most things, and Auru's Note or Ashei's Sketch.
2. Press D-Right (D-Left with the minimap closed) on GCN, or 1 on Wii.
3. Select any warp destination on the map screen and choose to warp there.
4. As the map screen closes, immediately use the item from step 1.
5. If successful, you pull out the item instead of warping.

{% youtube MvkInMuZGLw %}

#### Map Screen Delay

Originally found as an alternative for the Wii versions, where the GCN-style inputs (Midna button + map button) do not register together. The Animation Item Cancel method above is generally easier and has the same requirements.

1. Equip an item that plays a short cutscene when used (same items as above).
2. Press D-Right (D-Left with the minimap closed) on GCN, or 1 on Wii, and the item's button on the same frame. If done correctly, the map screen sound plays, but the animation keeps the map from opening.
3. Just as the animation finishes, call Midna. The timing is tricky, as Midna can appear before the map does.
4. Select any warp destination on the map screen and choose to warp there.
5. If successful, Midna will talk to you, interrupting the warp.

{% youtube qSGknKi1MxM %}

#### Map Warp + Action Button Cancel (Wii only)

1. Find something that can be talked to or interacted with using A and that results in a cutscene state. Examples include:
   - Talking with someone or something (including Epona as a wolf), as long as you can transform in front of them or talk to them as a wolf.
   - Signs, chests, and doors.
2. Press 1 and A on the same frame.
3. Select any warp destination on the map screen and choose to warp there.
4. If successful, you talk or interact instead of warping.

{% youtube byE_troKbOo %}

#### Midna Warp + Dig Spot

This can also be done without the ability to warp from the map screen, though warping through Midna is still required. It only works as Wolf Link with Midna riding on his back.

1. Stand next to a dig spot that causes a cutscene as Wolf Link.
2. Call Midna and choose to warp.
3. Select any warp destination on the map screen and choose to warp there.
4. Press Y (GCN) or D-Down (Wii) to interact with the dig spot.
5. If successful, the warp is interrupted.

Because of the restrictions on the dig spot, this is by far the most limited method. Only a few dig spots work for it, and two of them are in Snowpeak Ruins, where warping is not possible. Others are in the Kakariko Gorge area, at the gate blocking the entrance to Kakariko Village before it is opened, and in South Faron, at the side of the gate blocking the dark tunnel between South Faron and Faron Woods (as shown in the video).

{% youtube Ow0ZU3zkwI0 %}

#### Object Warp Cancel

Interrupting one of Midna's object warp cutscenes (the bridges, the Death Mountain meteor, or the Sky Cannon) with an object pull also gives Map Glitch.

{% youtube 5bGlLAhyzvY %}

#### Keeping Map Glitch Through a Loading Zone

[UMD](/posts/universal-map-delay-umd) can keep Map Glitch active through the loading zone into the Hidden Skill fight.

{% youtube Hjt9NZ-Ph7I %}

## Crashes

Entering Castle Town with Map Glitch can crash or freeze the game. This is believed to be because a dummy NPC in the fake Castle Town map behind the door notices wolf Link and tries to react:

{% youtube zDOZDdx8fJs %}

With [Door Storage](/posts/door-storage), Link can get under Iza's house. Where he would normally void out, the game can crash instead:

{% youtube EQK5HJhtD48 %}

## How It Works

Link has a "scene change started" flag, [`FLG0_UNK_4000`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/include/d/actor/d_a_player.h#L341), set whenever a loading zone, void respawn, Game Over respawn, or warp starts, so that two transitions cannot start at once. Nothing clears it; it only goes away when Link is recreated by an area load.

[`daAlink_c::checkWarpStart`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink_demo.inc#L4368-L4423) sets the flag as soon as a warp is chosen, then requests the warp cutscene (object warps use the same code with their own cutscenes). If the warp cutscene never runs (another action takes over that frame) or is cancelled before it changes scenes, the flag stays set:

```c++
#if VERSION != VERSION_GCN_JPN && VERSION != VERSION_SHIELD_DEBUG
onNoResetFlg0(FLG0_UNK_4000);    // set before the warp has started
#endif
if (dMeter2Info_getWarpStatus() == WARP_STATUS_DECIDED_e) {
    // ...
    fopAcM_orderOtherEvent(this, portal, 0xFFFF, 1, 1);
}
```

On GCN JPN, the flag is instead set when the warp actually begins ([`procCoWarpInit`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink_demo.inc#L4451-L4571)), so Map Glitch is not possible there.

While the flag is set, every transition that checks it is blocked.

### Loading zones

[`checkSceneChange`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L13693-L13853) returns as if the change were already handled, without changing scenes ([source](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L13717-L13719)):

```c++
if (checkNoResetFlg0(FLG0_UNK_4000)) {
    return 1;
}
```

### Dig spots

Once a dig into another area reaches frame 21, [`procWolfDigThrough`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink_wolf.inc#L9250-L9284) only requests the scene change each frame and never reaches the end of the dig, leaving it to `checkSceneChange`, which never changes scenes ([source](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink_wolf.inc#L9254-L9276)):

```c++
if (mProcVar3.field_0x300e != 0) {
    onSceneChangeArea(mProcVar4.field_0x3010, 0xFF, NULL);    // stuck here every frame
} else {
    // ... end of dig ...
    if (mProcVar4.field_0x3010 >= 0 && frameCtrl_p->checkPass(21.0f)) {
        mProcVar3.field_0x300e = 1;
    }
}
```

### Voids

[`startRestartRoom`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L13478-L13517) does nothing while the flag is set ([source](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L13478-L13481)), and the void exits in [`checkRestartRoom`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L13557-L13658) check it too ([source](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L13618-L13619)):

```c++
int daAlink_c::startRestartRoom(u32 i_mode, int param_1, int i_dmgAmount, BOOL i_isEventRun) {
    if (!checkNoResetFlg0(FLG0_UNK_4000) &&
        (i_isEventRun || dComIfGp_event_compulsory(this, NULL, 0xFFFF)))
    {
        // ... respawn ...
```

```c++
if (exitID != 0x3F) {
    if (!checkNoResetFlg0(FLG0_UNK_4000) && dComIfGp_event_compulsory(this, NULL, 0xFFFF) && !checkRestartDead(4, FALSE)) {
        // ... load the void's exit ...
```

### Game Over

Game over with map glitch is a softlock as [`procCoDead`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink_demo.inc#L3001-L3100) only respawns Link after the continue prompt when the flag is clear ([source](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink_demo.inc#L3060-L3062)):

```c++
if (mProcVar2.field_0x300c != 0 && dComIfGp_getGameoverStatus() == 2 &&
    !checkNoResetFlg0(FLG0_UNK_4000))
{
    // ... respawn ...
```

### Senses

While senses are on, [`daAlink_c::execute`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L17947-L17992) sets the senses timer ([`mWolfEyeUp`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/include/d/actor/d_a_alink.h#L4305)) to exactly `mSensesLingerTime` every frame while the flag is set. The branch that turns senses off during cutscenes comes later in the same `if`/`else` chain, so it is never reached ([source](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink.cpp#L17972-L17989)):

```c++
} else if (checkEndResetFlg1(ERFLG1_WOLF_EYE_KEEP)
    // ...
    || checkNoResetFlg0(FLG0_UNK_4000)
    // ...
{
    // map glitch lands here every frame
    mWolfEyeUp = mpHIO->mWolf.m.mSensesLingerTime;
} else if (mTargetedActor != NULL || dComIfGp_checkPlayerStatus0(0, 0x2000)) {
    mWolfEyeUp = mpHIO->mWolf.m.mSensesLingerTime - 1;
} else if (!dComIfGp_getEvent()->isOrderOK() && mProcID != PROC_GET_ITEM &&
           mWolfEyeUp <= mpHIO->mWolf.m.mSensesLingerTime)
{
    // cutscene turn-off, never reached
    offWolfEyeUp();
}
```

The senses button in [`checkWolfUseAbility`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink_wolf.inc#L1329-L1353) only works while the timer is below `mSensesLingerTime`, so it can never turn them off ([source](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink_wolf.inc#L1339-L1351)):

```c++
if (dComIfGs_isEventBit(dSv_event_flag_c::F_0550)
    && field_0x2fd2 == 0
    && !checkEventRun()
    && mWolfEyeUp < mpHIO->mWolf.m.mSensesLingerTime && wolfSenseTrigger())
{
    if (!checkWolfEyeUp()) {
        onWolfEyeUp();
    } else {
        offWolfEyeUp();
    }
}
```

Code that calls `offWolfEyeUp` directly, such as taking damage as Wolf Link ([`setDamagePoint`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink_damage.inc#L166-L202)), skips this check, so that will still turn senes off.

### Snowpeak freezing water

This is the one reload that does not check the flag. [`procCoSwimFreezeReturn`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_alink_damage.inc#L2048-L2063) calls `dStage_changeScene` directly, unless the freeze damage is fatal, which leads to Game Over instead:

```c++
if (checkRestartDead(4, 1)) {
    onNoResetFlg1(FLG1_FREEZE_DAMAGE);
} else {
    // ...
    dStage_changeScene(3, 0.0f, mode, fopAcM_GetRoomNo(this), shape_angle.y, -1);
}
```

## External Sources

ZSR page: https://www.zsr.gg/tp/tech/map-glitch
