---
layout: post
title: City in the Sky Save Warp Malfunction (Adam Glitch)
description: A rare glitch that can happen which causes a save warp to return to the incorrect location.
author: zcanann
categories: [Theory]
tags: [type-theory, type-glitch, status-unsolved, platform-wii, mechanic-warp]
date: 2026-02-16 00:00:00
---

## Summary

Rare save warp malfunction in City in the Sky where the game returns Link to the wrong stage/room after saving.

## Full Run of the Glitch

This run demonstrates the CitS Save Warp Malfunction sequence from console boot through glitch activation.

{% youtube 1e3KypWUf_Q %}

Alternate recording:
https://www.twitch.tv/videos/497498235

## Technical Notes

During stage load, `d_a_kytag14` updates save return data every frame by writing stage/room/spawn values.

If temporary event bit `0x80406FAB` is set, `d_a_kytag14` skips save-location updates entirely. Current research indicates the Fortune Teller can set this bit.

Potential causes considered so far:
- Save-memory actor creation/update race conditions in City in the Sky.
- Unexpected save-room overwrite behavior during actor creation.
- Temporary event-bit behavior interfering with normal save update flow.

This appears closely related to behaviors seen in [Save Warp Malfunction (Adam Glitch)]({% post_url save-warp-malfunction-adam-glitch %}).

## External Sources

Pastebin page: https://pastebin.com/jBwZqMjs
