---
layout: post
title: Vertical Angle Manipulation
description: How to manipulate Link's vertical first-person angle
author: qwertyquerty
categories: [Reference]
tags: [type-reference, mechanic-movement]
pin: true
math: true
mermaid: true
date: 2025-09-13 00:00:00
---

There are several ways to manipulate Link's vertical angle in first-person mode, enabling precise v-angle setups.

Vertical angle is stored as an `int16_t` storing values from -32768 to 32767 where 0 is fully horizontal and negative numbers are higher angles.

### V-angle range

The highest v-angle Link can look in first-person mode is -13000 and the lowest is 10000.

### V-angle buffering with item wheel

While in first person, holding the control still fully up or down will cause links v-angle to change by exactly -512 or 512 angle units per frame. This can be peformed precisely by using the item wheel to buffer stick angles. For example if you open the item wheel while in first-person, hold fully down on the control stick, then close/reopen the item wheel after 2 frames, links v-angle will change by 1024. 2 frames is the smallest frame increment that can be stepped using item wheel buffers in *Twilight Princess*. There is not a way to step single frames.

### C-up cancels

In first-person, holding c-up and pressing A will cause the camera to re-enter first person, modifying your v-angle. This is called a "c-up cancel" The angle change is always towards 0. The v-angle change is usually close to 3/4 of the previous angle, but this deviates for higher angles or small angles, so I decided to test every single starting angle to see what angle I would get after a single c-up cancel.

Linked **[here](/assets/reference/vertical-angle-manipulation/c-up-a_table.txt)** is a table linking every initial v-angle to every final v-angle after a single c-up+A press.

### V-angle setups

Using combinations of these methods together, we can create precise, simple, and consistent v-angle setups. Linked **[here](/assets/reference/vertical-angle-manipulation/easy_vangle_setups.txt)** is a list of simple setups for many v-angles I found with a brute force script. The setups assume you start a neutral horizontal v-angle (0). Below is a reference for the notation:

- `top`: Look all the way up in first person
- `bot`: Look all the way down in first person
- `c+a`: Hold C-up and press A a single time to c-up cancel
- `[n]fu`: Item wheel buffer `n` frames while holding fully up on the control stick
- `[n]fd`: Item wheel buffer `n` frames while holding fully down on the control stick
