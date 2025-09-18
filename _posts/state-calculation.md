---
layout: post
title: Area State Calculatuon
description: How the game calculates what the state the next area should be in
authors: jacquaid, qwertyquerty
categories: [Reference]
tags: [reference, layer]
pin: true
math: true
mermaid: true
date: 2025-09-17 00:00:00
---

Every time you load a new area in a loading zone (fadeout to black), the game calculates what the state the next area should be in. Now lots of areas will just be 0 by default, but in certain areas that the developers wanted to change throughout the game, there is a sort of state progression based on chronological flag checks. The game will check to see the chronologically latest state-changing flag for that area that is on and use that to determine the area's state (if no state-changing flags for an area are set, the state will be 0, with a few exceptions).

To make sure what I'm saying is completely understood, the state progression is listed in the order in which the states would evolve in normal play, HOWEVER, the game checks them in the reverse order.

So for example, if you beat SPR, Faron Woods will be state 5 regardless of whether or not you beat Forest Temple, cleared MDH, etc. (this ofc, assuming you beat Faron Twilight, which as is mentioned later, gets checked before any of this other stuff).

The first thing the game will check for is state override. This is often used to mandate a certain state for cutscenes. Basically if the game wants to force a certain state it will and it just skips the rest of the code. *See [addendum note 1](#addendum) for some oddities*

## Twilight Checking

Next the game checks to see if the region should be in Twilight. If so, it runs a few other checks to see if the state should in fact *NOT* be `E` (the standard twilight state). Those checks are as follows:

- In basically any Lanayru Twilight area, the game will see if the meteor has been warped. If it has, the state gets corrected to `D`.
- In the Sewers Prison area, the game will check to see if this is the first time Link has been to the Sewers, if it is, the game corrects to state `B` to show the cutscene (this is because with a save right beforehand, override could not be relied upon).
- In Zant's Boss Room, the game checks to see if you have beaten him. If you have, it corrects to `1`. If you haven't, it corrects to `0` (this is the only room in Palace that isn't in state `E`, because Twilight effects are hard coded to state `E` and they didn't want Twilight effects, thus non-`E` states).

## Standard State Checking

After all that is done, the game does its standard state checking for areas that aren't always state `0`. I fear this list may be incomplete because there might be a second function for certain areas. Later items in the list take precedence:

### Snowpeak/Snowpeak Ruins

- Yeta unlocks NW Door sets state 1
- Yeta unlocks W Door sets state 2
- Beating SPR sets state 3

*See [addendum note 2](#addendum) for some thoughts*

### Faron Woods

- Prior to saving Talo, state is 1
- Saving Talo clears that to get to state 0
- Beating Forest Temple sets state 2
- MDH Clear sets state 3
- Beating SPR sets state 5

### Coro's Lantern Shop

- Prior to saving Talo, state is 1
- Saving Talo clears that to get to state 0
- Beating Forest Temple sets state 2

### Kakariko Village/Graveyard

- Tripping the KB1 Trigger sets state 1
- Beating KB1 sets state 2
- Beating Goron Mines sets state C
- Watching the Post-GM cutscene sets state 2 again
- Finishing Zora Escort sets state 4
- Getting Zora Armor from Rutela sets state 2 again (changes to state 3 at night)

### Kakariko Indoors/Basement

#### Barnes's Bomb Shop

- Tripping the KB1 Trigger sets state 1
- Beating KB1 sets state 2 (changes to state 3 at night)
- Beating Lakebed sets state 4 (changes to state 5 at night)

#### Anywhere else in these areas

- Tripping the KB1 Trigger sets state 1
- Beating KB1 sets state 2 (changes to state 3 at night)

### Death Mountain
- Beating Goron Mines sets state 2
 
### Death Mountain Sumo 

- Beating Goron Mines sets state 1
- Watching the Master Sword CS sets state 2
- Beating Temple of Time sets state 4
- Watching the Ilia Horse Call CS sets state 3
 
### Lake Hylia

#### Outside Area:
- Beating Lakebed sets state 2
- Warping the Cannon to Lake Hylia sets state 1
- Fixing the Cannon sets state 3

#### Lanayru Spring
- Beating Lakebed sets state 9
- Starting MDH sets state 2

### Castle Town:

#### West Road/Central Square:
- Beating Lakebed sets state 2
- MDH Clear sets state 0 again
 
#### South Road:
- Finishing Zora Escort sets state 1
- Beating Lakebed sets state 2
- MDH Clear sets state to 1 again
 
#### East Road/North Road:
- Beating Lakebed sets state 2
- MDH Clear sets state 1
 
#### Telma's Bar:
- Beating Lakebed sets state 2
- Master Sword Cutscene sets state 4

> You'll have to excuse any mistakes in Lake Hylia/Castle Town Areas, since the section in code was stupidly complicated for no reason
 
### Zora's Domain
- Beating SPR sets state 2

### Upper Zora's River
- Unlocking Iza 1 sets state 1 (by Unlocking Iza 1 I mean beating the shadow beasts and following her inside normally)
 
### Gerudo Desert:
- Starts off at state 8
- Watching the enter desert cs sets state 0 again
 
### Zora's River:
- Starting the Iza 1 Minigame sets state 2 (this flag can be unset if you fail and then say no to trying again)
- Beating the Iza 1 Minigame sets state 1
 
### Ordon Village:

#### Main Area:
- Starts off at state 6
- Finishing Goats 1 sets state 0
- Saving Talo sets state 7
- Finishing Sewers sets state 1
- Clearing Faron Twilight sets state 2 (changes to state 4 at night)
- Taming Epona sets state 4 (changes to state 5 at night)

#### Outside Link's House:
- Starts off at state 3
- Finishing Goats 1 sets state 4
- Saving Talo sets state 0
- Finishing Sewers sets state 1
- Clearing Faron Twilight sets state 2
 
#### Sera's Shop:
- Clearing Faron Twilight sets state 2
 
#### Talo/Malo's House:
- Finishing Sewers sets state 1
- Clearing Faron Twilight sets state 2
- Watching the Colin CS after beating KB1 sets state 3
 
#### Rusl's House:
- Clearing Faron Twilight sets state 2
- Taming Epona sets state 4
 
### Ordon Spring:
- Starts off at state 1
- Finishing the Slingshot and Sword Tutorials sets state 3
- Saving Talo sets state 0
- Finishing Sewers sets state 4
- Clearing Faron Twilight sets state 2
 
### Ordon Ranch:
- Starts off at state C
- Finishing Goats 1 sets state B
- Saving Talo sets state 9
- Finishing Goats 2 sets state A
- Finishing Sewers sets state 1
- Clearing Faron Twilight sets state 2 (State 2 changes to state 3 at night)
 
### Hyrule Field:
- Some stuff gets checked in RAM to see if state should be escort and if so, what part of escort
- Finishing Zora Escort sets state 0 again
- Starting MDH sets state 4
- MDH Clear sets state 6
 
### Castle Town Fields:

#### West Field:
- Starting MDH sets state 4
- MDH Clear sets state 6
 
#### South Field:
- Starting MDH sets state 4
- MDH Clear sets state 6
- Talking to Louise before getting the Wooden Statue sets state 1
- Getting the Wooden Statue sets state 6 (does not require proper source to set this flag)
 
#### East Field:
- Starting MDH sets state 4
- MDH Clear sets state to 0 again
 
### Hidden Village:
- Watching the Ilia Horse Call cutscene sets state 1
 
### Castle Town Shops:

#### Jovani's House:
- Starts off at state 1
- MDH Clear sets state 0
 
#### All Other areas in Castle Town Interiors not explicitly mentioned:
- Finishing the Malo Mart Quest to open the Castle Town Malo Mart sets state 1
 
### Sacred Grove:
- Beating SPR sets state 2
 
### Bulblin Camp:
- Escaping the Burning Tent after beating KB3 sets state 1
- Beating Stallord sets state 2
- Watching the cutscene for fixing the Mirror sets state 3
 
### Faron Woods Cave:
- Saving Talo sets state 1
 
### Sewers:
- Midna on Back sets state D
 
### Hyrule Castle:
- Inside areas are all state 1
- outside areas are all state 0
 
### Fishing Pond/Hena's Cabin:

State starts off at 0 and increments every time you leave the fishing pond, looping after 3 (0 -> 1 -> 2 -> 3 -> 0 -> ...)

> It's worth noting that the state will reset to 0 every time you open the file again; saving and quitting after being in state 2 does not mean you'll get state 3 next. You'll get state 0 instead

And that should be all areas with possible non-zero states in that function. If none of the flags are set for an area, unless I say "State starts off at [some value]", the state will be 0, unless the area starts off in Twilight ofc. This goes for any areas not mentioned at all as well (Forest Temple, Goron Mines, etc. will always be state 0).

...however, there are a few areas where I know the state changes (Cave of Ordeals, Hidden Grottoes, for example) that aren't mentioned, so it's possible there's another function, so I'll update this if I learn of said function. *edit*: those are probably just dealt with using state overrides, since there's no permanent state change in any of the aforementioned areas.
 
## Addendum

### Note 1

When loading in a save, state override doesn't work for some reason (and in these cases, there is usually a flag set after watching the cutscene so that in normal play, the cutscene will still play after a savewarp anyways).

One example of this is after beating Goron Mines. The game has a cutscene in Kakariko after beating Goron Mines, but you can save right before it. So the game has a flag check inserted for having watched the cutscene and then relies on you not being able to set chronologically later Kakariko state flags out of order.

This leads to some humorous results if you save to disable the override after beating Goron Mines in a file that has already done Zora Escort and gotten the Zora Armor. There is a similar case after beating Lakebed Temple (known as White Midna Glitch), where you could in theory do the same thing, so it seems the developers decided not to even bother coding in a state override. In this case, the twilight state ends up taking precedence over the normal Lanayru Spring cutscene state (because twilight states basically always take precedence over non-overrides) and the cutscene fails to play.

This in turn stops Midna's Desperate Hour from activating properly and so the player can still warp like normal (Midna is only White because she is always that way when the Midna on Back flag is set without the MDH clear flag being set; it's just a graphical thing, but that's pretty much the end of the phenomena). The only areas that get put into MDH state despite MDH not being active are the Castle Town areas since those look at the Lakebed Done flag instead of the MDH start flag.

### Note 2

For whatever reason, Yeta opening up parts of Snowpeak Ruins changes the state for *all* of Snowpeak Province.

It also so happens that only state 0 will void Link for not having the Reekfish Scent.

Layers 1, 2, and 3 all allow you to get through the blizzard without Reekfish Scent. So to further troll HD runners, all we need now is to get to Snowpeak Ruins to get to Snowpeak Ruins early. Hooray.
