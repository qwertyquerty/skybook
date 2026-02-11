---
layout: post
title: Mystery Teleport
description: Theories on why Mystery Teleports can happen
author: spicyjuice04
categories: [Theory]
tags: [type-theory, mechanic-collision, status-unsolved]
pin: true
math: true
mermaid: true
date: 2025-11-10 00:00:00
---

There fastest way to travel in this game from one place to another is usually Epona. However there is a mysterious glitch we didn't yet solve that allows Link to teleport seemingly accross the map.

We know about one instance that can happen consistently. In the Inside West Corridor 1 there are Crystal Switches inside small chambers. However if Link goes up to one of those using a Backslice Moon Boots we can for some reason teleport accross the room into one specific place.

{% youtube 37avmtiTkQI %}

This specific instance works when going up the ledge after a ledge grab and hold in a direction at the right corner (usually up or upright). This does not work for the other crystal switch chambers.

Taking a further look with the help of custom map editing tools we can confirm that this specific instance happens because of the floor and the ceiling. The difference between the ceiling and the floor are exactly 180 units, which is exactly Link's height.

The developers made a slight overside though because the vertices  on the back side of the chamber are slightly higher than the vertices at the hole. This makes the ceiling and the floor just ever so slightly slanted.

There is a behavior in this game that if you walk against a slanted ceiling it behaves very similar to a wall and tries to push you out. Since the ceiling and the floor are slanted similarly, Link will be pushed the whole duration he is inside the ceiling.

Though we know the requirements, it is still unknkown why this behavior could create such a big push that it even looks like a teleport.

In the video it might not look like a big teleport but that is because there is a wall which triggers the `LineCheck` code, meaning you will stop moving past the wall. If we remove this wall we would have moved 30000 units, way further into out of bounds. If we remove the walls of the chamber itself we can get even bigger teleports with up to 240000 units!

{% youtube V2QeZEEFlW8 %}

This is the only other instance a kind of similar teleport happened. There are no ceilings in this area so it is unknown why this happened. No one has been able to replicate this teleport and it stays a mystery.

