---
layout: post
title: Back in Time
description: Explanation and consequences of why we can move and save on the title screen
author: spicyjuice04
categories: [Glitches]
tags: [type-glitch, mechanic-memory, mechanic-crash, mechanic-back-in-time, meta-major-glitch]
pin: true
math: true
mermaid: true
date: 2025-12-27 00:00:00
---

## Back in Time Glitch

When resetting the game, either with the Power button on the console or the Game Cube reset combo X+B+Start or resetting the game in the Wii home menu, the game fades out and starts to reset. On the title screen, Link is supposed to move automatically and you can only press A or Start to make the logo appear and then fade out into the file selection screen. However the Back in Time glitch (BiT for short) allows us to move around freely.

### Initialization

When resetting the game, most states Link can be in are overwritten so that nothing unintentional does happen. However there are a few cases that got overlooked. Most noticeably voiding out on the same frame as resetting the game does actually set the respawn animation on the title screen. Similarly, using Ooccoo Jr or Ooccoo Sr to warp to a different area, and resetting on the same frame as you warp away, sets the Ooccoo spawning animation on the title screen.

This allows for us to break out of the cutscene state and move around freely on the title screen.

### Title Screen behavior

The first time you respawn on the title screen, you can move around freely and still make the logo appear by pressing A or Start buttons. The rest of the hud is not visible. You can proceed to the file selection menu like normal when the `Press Start` appears. 

You can delay that the `Press Start` appears by having your first press be picking up Horse Grass. The logo is then also slightly displaced as long as you stay in the cutscene.

You can not pull out the map or the item wheel and also not the pause menu after the first respawn.

### Voiding out once

After voiding out the hud appears and you can not bring out the logo anymore. You are on one heart now aswell. You can bring out the map, item wheel and pause menu. Since we can bring up the title screen, we can now save the game and select it as a save file. We now keep some properties from the title screen map and transfer them onto a new save file and continue our game from there. More about those properties follows in the next segment.

## Title Screen features

The title screen itself is an overworld map. While it looks like the Eldin Field Map from Hyrule Field `F_SP121` Room 2, it has actually its own map `F_SP102` with its only Room 0. Of course since it should look similarly, the bolders, bridge piece, as well as the owl statue on the Eldin Bridge portion are also present, though some features like the chests are missing. The only other difference aside from there being no enemies, is that there is horse grass at both sides of the Eldin Bridge which are not at those places on the Hyrule Field map when playing the game. Epona is also present on this map on the west side of the title screen map.

Most importantly, this map does not have anything interesting to interact with. There are no loading zones to go through. The only things you can really do here is go to the file selection screen like intended or unintendedly save the game on the title screen or void and die for another map reload.

### Dying on the Title Screen

After dying, you respawn on the Bridge of Eldin on layer 0. Previously we were on layer 10 where the title screen should play out, however layer 0 is used for a different sequence. The game suddenly starts the cutscene of the first King Bulblin encounter. This fight actually takes place on the title screen map on layer 0.

If you do not skip the cutscene, you may see that it is quite weird. Epona gallops in but Link is nowhere to be seen. Furthermore the screen shakes but there are none of the bulblins there who are supposed to spawn. Well that is because our spawn is still our previous spawn point where we voided out on the bridge so Link is now over there, far away from where he was supposed to. From here though we can't do anything.

### Defeating King Bulblin

If you die again or on the first time skipped the cutscene, you start the fight properly. Because you have the Ordon Sword, you can fully complete the next sequence and defeat King Bulblin in the first phase and also the second phase. There are no notable differences aside from having no equipment that you are supposed to have at this point but the fight plays out the same way.

### Twilight Kakariko

After defeating King Bulblin and watching or skipping the cutscene of Collin's rescue in covered in Twilight, you now find yourself inside Kakariko Village in layer 2, even though it is covered in twilight.

This version of Kakariko is basically the state you are supposed to have currently after defeating King Bulblin. Even though it looks like we are in the twilight, the game did not actually care to update the layer to a twilight one after the cutscene though it does set the time of day to midnight. 

Epona is part of this state for the time being so with her we can go to the North Eldin Field if we want. Though if we enter another area while we are on Epona the game will crash, since she is not part of the twilight state's actor list. In North Eldin we can't do anything though. The Rocks blocking the way to Lanayru are gone but even if we reach the Twilight Wall, since we are already in a twilight state, we can't become wolf and enter Lanayru that way, instead it starts a cutscene trying to walk us back, though stopping at the invisible wall of the Lanayru Twilight Wall resulting in a softlock.

### The unfortunate ending

After reloading Kakariko Village, we end up back in the correct twilight layer 14. It is possible to obtain the Kakariko Portal and the Eldin Vessel early now since we can defeat Shadow Beasts with a spin attack of our Ordon Sword, however since we can't transform, it all becomes useless. Since we never had any early progression, we can't transform into wolf in this area and we never unlocked Midna or the senses either so we can't collect the tears of light and can't clear the Eldin Twilight. Furthermore we can't leave Eldin in itself so we are softlocked in this area, unable to progress.

## Saving on the Title Screen

When resetting the game, most properties get reset to some default value. Mostly zero. But there are some properties part of the title screen that you do not have at the start of the game, but can still get carried over when saving the game. Those include:

 - Ordon Sword 
 - Hylian Shield 
 - Hero's Tunic
 - Epona Tamed Event Flag `0x06` on offset `0x01`
 - Default save location `F_SP108` in Room 1 with save point 0

After selecting that specific save you spawn in the Spring of Faron Woods, the map for `F_SP108` that you are first supposed to enter in the second day of Ordon after the Slingshot and Sword tutorials. Of course you could also enter this area just with Ordon Gate Clip like performed earlier, however then you do not have the properties of the title screen like you do now.

### Collection

While we have now obtained the Ordon Sword, Hylian Shield and Hero's Tunic early, they are not actually inside our inventory. If we try to replace them and equip something else, we can not equip it back since it is not there. They are funcional though as if we do have them to some extend. For example, as human you can't pick up the Master Sword with the Ordon Clothes since the game crashes when attempting to play the cutscene, but with the Hero's Clothes we get from Back in Time, we can obtain it as a human early. Also the Ordon Sword is a weapon to deal decent damage at the start of the game.

Since the items are not part of the inventory, in some cases the game still assumes you do not have them. For example the hidden skill `Shield Attack` is unobtainable with the Hylian Shield you get from BiT. The Hero's Shade expects you to have a shield to learn that hidden skill and assumes that you don't have one despite you wearing the Hylian Shield from BiT. In that case you should buy another one.

### Consequences of Epona Tamed Flag

The Epona taming sequence is a key story progression in the game. This specific flag allows for you to ride Epona again after she had been stolen on Ordon Day 3 and its corrisponding Event Flag `0x05` on offset `0x80` got set. So after that flag has been set, Epona is now obtainable the whole time from the start of the game, as long as she is part of the actor list.

The Area State Calculation in Ordon Village. Since the area state calculation are a bunch of if statements, the first one goes through. The developers have ordered those statements in an order that the first if statement is supposed to happen last in the game, after all the other parts have already been completed long ago. Let's look into the state calculation of Ordon Village.

```c++

 // Stage is Ordon Village
            else if (!strcmp(i_stageName, "F_SP103"))
            {
                // Room is Main Village
                if (i_roomNo == 0) {
                    // Tamed Epona
                    if (dComIfGs_isEventBit(dSv_event_flag_c::saveBitLabels[56])) {
                        o_layer = 4;
                        dComIfG_get_timelayer(&o_layer);
                    }

                    // Cleared Faron Twilight
                    else if (dComIfGs_isDarkClearLV(0))
                    {
                        o_layer = 2;
                        dComIfG_get_timelayer(&o_layer);
                    }

                    // Escaped Hyrule Castle Sewers (1st Time)
                    else if (dComIfGs_isEventBit(dSv_event_flag_c::saveBitLabels[47]))
                    {
                        o_layer = 1;
                    }

                    // Finished Ordon Day 2
                    else if (dComIfGs_isEventBit(0x4510))
                    {
                        o_layer = 7;
                    }

                    // Finished Ordon Day 1
                    else if (dComIfGs_isEventBit(0x4A40))
                    {
                        o_layer = 0;
                    } else {
                        o_layer = 6;
                    }
                }
            ...
            }
```

Since the Epona Tamed Flag has been set, the first if statement is already true. So the layer will be set to 4 and the other conditions will get ignored. This also means that you can't go back to previous states. This means that the items that you were supposed to have up until this point, which are the Fishing Rod, Milk Bottle, Slingshot, (Real) Ordon Sword and Ordon Shield are all unobtainable.

Because of the Epona Tamed Flag however, another event gets possible to trigger. The Iron Boots inside Bo's House are obtainable now.

### Beating the game with BiT

To beat the game with BiT, we need to find ways that make it possible to skip the items that are unobtainable. The first obstacle is right when entering Faron Twilight, Midna wants to obtain the Ordon Sword and Ordon Shield from the village. Since the Epona Tamed flag changed the state, meeting this requirement becomes impossible. Fortunately, there is a Bulblin in the Area that helps jumping over the trigger, resulting in skipping this sequence all together and skipping their requirements.

The Fishing Rod *or actually the Coral Earring* is another item you are supposed to need later in the game to fish a Reekfish for its scent to climb up Snowpeak Summit. Fortunately with another glitch, that being Map Glitch, you can climb the Summit freely without the requirement of the scent. 

## Back in Time J2D Crash

Perform Back in Time and game over with title-screen UI state active to produce a likely J2D heap exhaustion crash.

{% youtube 9_yOnMgyiA4 %}
