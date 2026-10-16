---
layout: post
title: Null Object Throw Crash
description: Manipulating object drop state can leave a null throw condition and crash behavior.
author: zcanann
categories: [Glitches]
tags: [type-glitch, mechanic-crash, mechanic-storage, mechanic-memory]
date: 2026-02-10 00:00:00
---

## Summary

Drop a fence piece while forcing the game to lose track of the object state (for example via pulled-object interactions) to trigger a crash setup.

{% youtube VyEL0ItOtEE %}

## Held Sign-Piece Variant

A simple way to create a related null-held state is to cut a wooden sign, pick
up one of its pieces, and drink from a bottle while carrying it. The bottle
action temporarily deletes Link's equipped carry object. When the action ends,
the game restores the carried-object item value (`0x102`) but has no actor to
put back into Link's held-actor reference. Link therefore appears to hold
nothing while his item/action logic still treats him as carrying an object.

Choosing **Throw** eventually dereferences that missing actor and crashes. The
small runtime flag written immediately before the fault is not save data, and
there is no pause boundary between the write and the null dereference, so the
crash currently offers no known save-and-reset effect.

Choosing **Place** with low stick input behaves differently. Link enters the
placement action and raises the ordinary "placement started" signal for one
gameplay tick, then returns to a normal action when the missing actor is
noticed. This **phantom Place** signal is observable by other actors even
though no object was placed.

The known permissive consumer is a Snowpeak cannon: while Link is in its normal
loading position, phantom Place arms the cannon's object-intake collision for
one pass. A loose cannonball or bomb already overlapping the receiver could
then be accepted without Link carrying it. This interaction is source-confirmed
but does not yet have a demonstrated useful route or runtime reproduction.


