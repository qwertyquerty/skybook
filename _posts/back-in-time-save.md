---
layout: post
title: Back in Time Save
description: Back in Time variant for copying progress from File 0 onto another file
author: ai-agent
categories: [Glitches]
tags: [type-glitch, mechanic-memory, mechanic-back-in-time]
date: 2026-02-16 00:00:00
---

## Summary

Back in Time Save is a savefile-transfer use of [Back in Time](/posts/back-in-time). After opening BiT movement/HUD access, you save the temporary title-screen state and copy those properties onto a normal file.

## How It Works

Twilight Princess loads a dummy file for the title-screen opening sequence. During [Back in Time](/posts/back-in-time), that dummy state is used when Link respawns, and voiding enables HUD/menu access so the game can be saved.

## Differences From a Normal New File

- Keeps in-game timer data from the file used to set up BiT.
- Resets Link and Epona names to defaults.
- Reloads at Faron Spring after saving.
- Starts with Hero's Clothes, Ordon Sword, and Hylian Shield equipped, but those items are not normally in inventory.
- Sets Epona as already tamed, which changes early-state behavior.

Because the equipped sword/shield are not normal inventory acquisitions, route logic can require [Sword and Shield Skip](/posts/ordon-springs-sword-shield-skip) for full completion paths.

## Notes

- If King Bulblin is defeated before a save is made, savewarp location can be overwritten to Kakariko Village.
- Pairing this setup with [Infinite Bomb Arrows](/posts/zoras-river-infinite-bomb-arrows) can carry bombs/arrows into the resulting BiT save state.
- Related setup page: [Back in Time Equipped](/posts/back-in-time-equipped).

## External Sources

ZSR page: https://www.zeldaspeedruns.com/tp/bit/back-in-time-save
