---
layout: post
title: Early Hyrule Castle
description: The holy grail of Twilight Princess glitch hunting
author: bdamja
categories: [Theory]
tags: [type-theory, map-castle-town, map-hyrule-castle, status-unsolved, meta-major-glitch]
pin: true
math: true
mermaid: true
date: 2025-09-12 00:00:00
---

Early Hyrule Castle (EHC), or Barrier Skip, is a theoretical sequence break which would involve getting to Hyrule Castle before defeating Zant. Depending on what would be required for the sequence break, it could allow skipping as much as the second half of Lakebed Temple, and all of Snowpeak Ruins, Arbiter's Grounds, City in the Sky, and Palace of Twilight. It has yet to be solved, but it would be a major skip that would likely save a lot of time (potentially over an hour) in categories such as Any% if a method was discovered. Because of how massive of a sequence break this would be, this trick has been sought out relentlessly for decades by many different players, ever since the game's release. The purpose of this page is to document all of the various avenues that have been searched, so that an interested glitch hunter can get caught up to pace with what has already been tried.

## The Different States of North Castle Town

As you progress through the game, the game loads the North Castle Town (NCT) stage on various layers, each with their own properties. There are two relevant states when it comes to the obstacles that stop us from getting into Hyrule Castle, which depends on whether or not we have completed Midna's Desparate Hour (MDH). When we refer to the "pre-MDH barrier", we are talking about layer 0, 2, 13, and 14, which has an invisible wall behind the guards called "Obj_Board". The "post-MDH barrier" refers to layer 1, where there is a giant energy barrier called "V_CTGWall". Below lists details about every layer of NCT:

- **Layer 0** - Post Lanayru Twilight, pre MDH: there is no energy barrier, the guards are in front of the doors, and there's an invisible wall (Obj_Board) behind the guards and in front of the doors
- **Layer 1** - Post MDH: the energy barrier (V_CTGWall) is present. Note that Obj_Board is not present in this layer, and the first door is open. Once you defeat Zant, this layer is still used, but a flag is set for the Squidna cutscene to play upon entering
- **Layer 2** - During MDH: same as layer 0, except it's raining
- **Layer 3** - Unused Dog Testing: developer layer assumed to be used to test the AI for dogs. This layer is inaccessible without cheats, but there are no barriers or invisible walls, so ending up here would allow for EHC
- **Layer 13, 14** - Pre Lanayru Twilight Completion: same as layer 0, except it's in Twilight
- **Layer 4, 5, 6, 7, 8, 9, 10, 11, 12, 15** - Unused: same as layer 3, except no dogs are present. EHC is possible if these layers are accessed

## Constraints

If you are trying to find a way past the invisible wall or barrier from NCT itself:

- You can't take out your sword
- Can't use items except for lantern and bottle
- No ground items or rupees exist (this means no pickup slides)
- Only push colliders other than Link are the guards
- You can't transform if the guards are present

## Dead Ends and Potential Leads

**Clipping**: clipping behind the guards with a backflip is trivial, but there is an invisible wall behind the guards (Obj_Board) which prevents us from opening the door. It's also possible to clip through push colliders with many chained frame perfect dig inputs as wolf, but this doesn't clip through solid walls

**Map Glitch**: if you call Midna and open the map on the same frame, then warp away, Midna will cancel the warp as it starts, which will disable load zones. This allows us to wander out of bounds without the game voiding us out or checking for load triggers. If we could get to the second door from out of bounds, this would allow for EHC as map glitch doesn't impact the door opening cutscene. Unfortunately, while there is out of bounds floor collision, there is an invisible wall that extends further than the floor, which we have no way to get around. Even if that's circumvented, there's still Obj_Board to worry about, which extends far out of bounds as well

**White Midna Glitch**: beating Lakebed Temple before completing Lanayru Twilight causes the game to enter the White Midna Glitch state, which has several strange properties. Midna is injured and loses most of her abilities, but retains the ability to warp. This makes it possible to complete Arbiter's Grounds and City in the Sky without ever meeting Zelda to heal Midna, which raises the barrier (V_CTGWall). However, Obj_Board is still present in this state with no way around it

**Golden Wolf Storage**: each golden wolf (besides North Faron) has a flag associated with it that's set when you enter the Hero's Shade realm, and cleared once you leave. When you leave, the game checks for the highest priority golden wolf flag that's set, and then uses that to determine where to put you once you exit. In theory you could enter one golden wolf, then exit to the NCT golden wolf, and simply enter Hyrule Castle from there. The problem is that the NCT golden wolf has the lowest priority out of all of them. Regardless, if we were to somehow set the NCT wolf's flag, enter a different golden wolf, clear that other golden wolf's flag, and then exit, the game would see that the NCT wolf's flag is the only one that's set, and would put us in NCT. However, there is no known way of setting a golden wolf's flag without accessing it first

**Item Wheel Delay**: when Iza gives you bombs the game schedules to open the item wheel automatically. By frame perfectly alternating A and B presses, you can delay the item wheel coming up even through loading zones (which is very TAS only). On the frame where the item wheel is scheduled to pop up, you can pause and savewarp, which allows for saving and quitting in places you aren't supposed to be able to - namely cutscenes. One idea is that you could complete MDH (which removes Obj_Board) but savewarp in the cutscene afterwards, in hopes that it would cause the game to not load V_CTGWall, but this isn't the case. Another idea is that you could access Palace of Twilight early by savewarping during the intro cutscene when you enter Gerudo Desert (which briefly loads the Palace of Twilight stage). This doesn't work, as your savmem isn't updated in this cutscene

**Layer Manipulation**: it's possible to respawn Link on the wrong layer in very specific circumstances, like with Empty Lake Hylia, where we die in a minigame and the game applies the layer of the minigame to the wrong stage. Since there are 11 different layers of NCT in which EHC would be trivial if accessed, layer manipulation seems promising. However, we have no way of dying in a different stage/layer and respawning in NCT, or any other way to manipulate layers

**Archive Corruption / Actor Unloading**: if the game runs out of memory and you load a new area, the game may fail to load certain actors. There already exists applications of this, namely getting to the forest temple as early as possible via fishing rod duping. There's no known way to unload any actors while already in NCT, so you would need to corrupt the archive in a different area before going to NCT, and then hope the specific actor fails to load. Obj_Board actually does exist on other maps such as Lakebed Temple where archive corruption in general is possible. So, the theory is that you would corrupt Obj_Board in Lakebed and then go to NCT, and the invisible wall would no longer be there. Unfortunately, due to how loading the resource data is uniquely handled for Obj_Board, it is impossible to corrupt this actor. It's not possible to corrupt V_CTGWall either, as there is no room transition which tries to load that actor other than when entering NCT. If we could put the game in a low memory state that persists across load zones (not just room transitions) we could actually prevent V_CTGWall from loading in the first place. The problem is that we don't know of a way to prevent the allocation of only V_CTGWall by itself. If we prevent allocation of V_CTGWall, then we also prevent allocation of other crucial resources, which results in the game crashing. [Here](/posts/cant-unload-barrier) is a detailed, technical writeup of why none of this is possible

**Save Leak**: on the Wii NTSC-U 1.0 version of the game, there is a way to corrupt memory called "save leak". On the pause screen, reset and then press A to enter the save menu 1 frame later. If you do this repeatedly (over 40 times), this can cause some interesting memory corruption, and can prevent actors from loading properly. One thing noteworthy is that this can persist through loading areas. This might not be useful for EHC for the same reason archive corruption in general isn't useful, but that's not a definitive assessment, as save leak has not been looked into as thoroughly as some of the other avenues mentioned. It's possible there could be something promising here if more research is done

**[Mistargeted DMA](/posts/mistargeted-dma)**: by performing the Amazing Fly Glitch, resetting once "FISH ON!" appears, loading a save, and do one of various actions such as talking to an NPC or picking up an item, we can cause the game to copy a chunk of data from RAM to main memory, which sometimes causes code to start executing in a completely different place. This is the closest Twilight Princess has gotten to arbitrary code execution, an extremely powerful glitch in many other games, which would allow for EHC and many other applications. This glitch is difficult to research and poorly understood, but a better understanding could yield something very promising.

## Other Avenues

EHC may become possible if any of the listed below become doable in the game. Many of these
would likely be extremely useful, for much more than just EHC. However, none of these have any
leads and are purely idealistic:

- More versatile method of layer manipulation
- Story flag manipulation
- Ability to clip through solid, unmoving wall collision without need for ground items
- Getting thousands of units up in the air
- Extremely high speed
- Wrong warping

## Requirements for beating Hyrule Castle after EHC

If a method for EHC was discovered, there would still be several requirements to complete Hyrule Castle itself:

- Need to have Master Sword
- Need to have Clawshot
- Need to have either Boomerang or Spinner
- Need to have Lantern (or various less-straightforward alternatives)
- Need to have Ending Blow

There is no other equipment that would be required for beating Hyrule Castle itself. Here's how you would skip all of the believed-to-be required items:

- **Chandelier room:** instead of using the Double Clawshots, there exists a precise position in which you can skip clawshotting one of the chandeliers
- **Tower climb Double Claws section:** you can clear this section with just the Clawshot
- **Tower climb Spinner section:** you can clear this section with a combination of boomerang LJAs and damage boosts
- **Beast Ganon:** instead of using the Bow or Ball and Chain, you can simply transform wolf to knock Beast Ganon over all three times. You don't even need to have Midna on your back for this to be possible
