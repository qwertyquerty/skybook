---
layout: post
title: Back in Time Equipped
description: Explanation of the wrongwarp into the King Bulblin Fight
author: spicyjuice04
categories: [Glitches]
tags: [type-glitch, mechanic-memory]
pin: true
math: true
mermaid: true
date: 2025-12-30 00:00:00
---

Aka *BiTE*

This page is a continuation of the [Back in Time](/posts/back-in-time) page.

## Initialization

During Back in Time, make the logo appear. Then void out and while falling press A or Start to come to go to the file selection menu. If done correctly, you should hear Link's falling scream and the void out sound while you are transitioning to the file selection menu. This causes the game to pause the reload of the map until the next load. This load does not include resetting the game as this resets the voiding property since , unlike Back in Time, this doesn't happen on the same frame as the reset.

### File selection

After selecting a file and pressing Start, on the transition to the TV Settings Screen, the game updates your Save information. This includes everything on that file including equipment, flags and save stage information. After the screen fades to black from the TV Settings screen, the property of save stage information get applied to the location where Link should spawn now. Though the respawn animation we still have from Back in Time overwrites the stage information as it still tries to respawn us on the stage of the title screen. 

*This information doesn't yet go over to why certain saves work or not so please continue reading to get an understanding*

## Spawn point information

To understand where the game attempts to spawn Link, we need to understand how the spawn point in this game works. When you boot up the game or reset the game, the save information will set three variables for the save point information. 

First is the variable of the stage we are in. The default one is stage `F_SP108` *South Faron Woods*. The second variable is the room we are currently in of that stage. The default of that is `1` *Faron Spring*. 

The third variable is the spawn point. This game doesn't save the coordinates of where you are standing but instead uses points that set specific coordinates and properties to Link when spawning or respawning on the map. The default of that is set to `0` in that case. With all of this information combined, this determines the exact location Link should spawn in.

### Updating Saving Information

To update the save point information, the 'Savmem' actor must be present. This actor updates those mentioned variables once the actor spawns in. The values each variable gets updated to is determined by the parameters of that savmem actor. 

Since this actor needs to be present, there are limited save locations we can use.

### Stage Properties

The stage variable in iteself does also set other variables. There are a lot of them and not all are thoroughly documented. Those can be for example what music play, Epona's speed modifyer and sometimes even present actors.

Most importantly for this though is that also the layer of the stage gets set. 

## Working Save Files

After the initialization is done, the game attempts to spawn Link on the Title Screen map `F_SP102` with the save point information of the save file that got selected. There are of course several cases that the game doesn't load which is a *crash*. This section goes over all the things to keep in mind for the save files that do or do not work.

### Save Room

The Title Screen Map only has one room. That one is Room `0`. If the save information tries to spawn Link in a room that is not `0` it will result in a crash.

### Save Point

If our save location is in room `0` that said room has save points. The save information has to have a save point that exists on the title screen map since those only set Link's properties and coordinates. 

The title screen has 10 save points. Those are: 

 - `0`, `1`, `3`: Spawn on top of Epona
 - `2`, `4`, `5`: Spawn without Epona

 - `20`         : Defeated King Bulblin Cutscene *Warp Kakariko*
 - `53`         : Mirror Chamber Cutscene *Warp Mirror Chamber*
 - `100`        : Demo Movie
 - `101`        : Credits

Let's go over the cutscene related points first. On the title screen, some parts of cutscenes play. After spawning in that area and fading to black, the next cutscene plays. Since the way we spawn is just the basic fade in - fade out, the cutscene on the map itself doesn't play but only the part after.

### Layers impact

Layers determine the current actors present on the map. Depending on the point we spawn in, the layer can still determine if the actors present can result in a crash or not.

The cutscene spawn points `20`, `53`, and `101` can all spawn Link on all the layers. The demo movie one for spawn `100` is the only exception as it needs the `demo00` actors of it present on the map for the transition. Those only seem to exist on layers `0`, `8`, and `10`.

The spawn points `0`, `1`, `3`, can only spawn Link on actors Epona is part of the actor list. Those working layers are `0`, `4`, `8` and `10`. The other spawn points that don't spawn Epona work on all layers.

Most of the layers are unused and have only the basic actors on them. Some have different backgrounds as they are used for cutscenes. The only Actors present are the basic ones for most. Layers that do have a big impact when spawning without a cutscene spawn point are the layers 0, which start the first phase of the King Bulblin Fight, and layer 4, which starts the second phase of the King Bulblin Fight. 

For the King Bulblin Cutscenes you spawn in, the game always tries to spawn Epona. If the Epona Stolen flag is set and the Epona Tamed flag is not, this will also result in a crash. For the spawns on top of Epona the stage will simply not load and for the spawns without Epona, it results in a *hard crash*

### BiTE Table

DragonBane0 has created a BiTE table with all of the Savmem actors in this game and their effect on BiTE. You can find this table [here](https://docs.google.com/spreadsheets/d/1rrU7KF9PcrdIb-qs2HvGYCCLHY4mQcIPgNvQtwO2Vdo)

To read it, in the first collumn it mentiones the Stage, in the second column the Room, in the third the Savepoint and in the fourth the description of what happens. The Savepoint can look something like this `Global: 00->00`. The Global mentioned in this is the layer. The Savmem actor can either be present in a specific layer or in all layers which then is Global. The second value is the Room and the third is the spawn point. Keep in mind that this table here is displaying values in hex and not in decimal like this page has done

As you can see in this table, there are no valid save points that lead to any of those cutscene spawn points. If they existed, early desert or even a credits warp would be possible. The only saves we can make use of are ones that spawn in the King Bulblin fight.

## King Bulblin Fight

Once a file has been selected that works for the King Bulblin fight, the cutscene starts to fight him and the load was successful. When skipping the cutscene, we can fight King Bulblin like normal. The difference is that we do have all of our equipment and flags from the selected save file. We can even spawn into the fight as wolf, that won't crash.

After beating the second phase of the fight, we end up in Kakariko Village. For speedruns or certain routes this is useful because that is another method to reach this area early.

### Bridge

Interestingly, the event flag `0xA0` on offset `0x20` has impact on BiTE. When the bridge piece is stolen after blowing up the rocks on the path to Lanayru, that flag is set and this bridge piece is also gone from the title screen map. This does have an impact on the second phase of the King Bulblin fight because that means that it can't be completed without a Bow, since King Bulblin just rides into the void.

What is more interesting though is that the event flag `0x0F` on offset `0x08`, which warps the bridge piece back, does not have an impact on the title screen map. The bridge is still gone.

### Not Skipping the Cutscene

In case the cutscene of the King Bulblin fight is not skipped, the game does not properly update the stage and still has the stage properties of the stage, the save from BiTE was used on. So as previously mentioned, the music or Epona's speed modifyer can change if your BiTE save is in Faron.

Those properties have not been thoroughly documented but there has not yet been much motivation to look into that since most of the stage properties ,with the exception of the layer, are probably not having a big impact on the outcome of the fight.

If stage flags would have been set for the Title Screen map from a different save, that would have been for sure interesting but the game does recognize that we are in Eldin even if the save for BiTE was outside of that region.
