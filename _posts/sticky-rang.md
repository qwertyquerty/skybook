---
layout: post
title: Sticky Rang
description: Explanation of how Sticky Rang works
author: Chris is Awesome
categories: [Glitches]
tags: [glitch, collision, minor]
pin: true
math: true
mermaid: true
date: 2025-09-15 00:00:00
---

**Sticky Rang** is a glitch that involves throwing the Boomerang at a freestanding item, like a Heart Piece, and having Epona recoil off a wall at the right moment when the Boomerang comes back to you. While you're on Epona, the item will appear to be stuck to Link. Though certain frames of some animations can move Link's hitbox enough to touch the pickup's collider.

### What happens

When you have a pickup object (Heart Piece or grass/enemy drop) in the Boomerang, the item's hitbox is enlarged. For most items, this enlargement is minor. But Heart Pieces get like a 6x enlargement.

When you have certain objects in the rang (from testing, this seems to only apply with Heart Pieces and random drops from enemies/grass), the item's collection hitbox is much larger.

### Interesting Side Effects

If you pull out Clawshot or talk to Midna while on Epona, the Heart Piece will drop, but will maintain its larger hitbox. This allows you to push it around with Epona.

Note that you can trigger the same enlarged hitbox by cutscene dropping the Heart Piece by having it in the Boomerang and using a cutscene item (bottle, Skyboox, Horse Call, etc.)

You can take the Heart Piece to another part of Hyrule Field, but it will immediately despawn when it enters another section (ex. going from Faron field to Gorge). An interesting side effect of this is if you grab the Heart Piece at the time it despawns, you get softlocked in the "get item" state, as the item it references no longer exists.

### Examples

Example showing hitbox difference (left normal Heart Piece hitbox, right is enlarged hitbox):
![Example showing hitbox difference (left normal Heart Piece hitbox, right is enlarged hitbox)](/assets/glitches/sticky-rang/sticky-rang-hitbox-size-comparison.png)

Example of Heart Piece being attached to Link on Epona:
![Example of Heart Piece being attached to Link on Epona](/assets/glitches/sticky-rang/sticky-rang-on-epona.png)

Video example:
<iframe width="500" height="300" src="https://www.youtube.com/embed/QdQJC76LdIo" frameborder="0" allowfullscreen></iframe>