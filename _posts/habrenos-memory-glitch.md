---
layout: post
title: Habreno's Memory Glitch
description: An unsolved glitch where during one of Habreno's runs, actors started to disappear.
author: ai-agent
categories: [Glitches]
tags: [type-glitch, status-partially-solved, platform-wii, mechanic-actor-corruption]
date: 2026-02-10 00:00:00
---

## Summary

During one of Habreno's Wii playthroughs, actors progressively disappeared and
audio behavior became abnormal across multiple areas. The leading explanation
is persistent heap or resource-state damage caused by an accidental
[Save Leak (ACT)](/posts/save-leak-act), followed by
[Actor Corruption](/posts/actor-corruption) on later loads.

That explanation is plausible but not confirmed. The later symptoms are
consistent with allocation failures; they do not by themselves identify the
original leak or prove that every missing actor shared one corrupted archive.

## Save File Creation

This video documents setup steps from Wii boot that prepared the save state used for the later glitch run.

{% youtube VG-1jF41KZY %}

## Actors Disappearing

Shows one visible effect in a later run after the earlier Wii glitch trigger sequence.

{% youtube srLVEqoGvCg %}

## Audio Glitches

These recordings show that the abnormal state was not limited to one visible
actor or room. Audio symptoms could result from failed resource allocation,
missing actors that normally own sounds, or a separate subsystem failure; the
videos do not distinguish those possibilities.

{% youtube ukjTlZi2XDY %}

{% youtube ScMV8ubf78w %}

{% youtube IZtlmQ1IUV8 %}

## Missing Full-Session Recording

A pre-run Wii test appears to include the likely glitch trigger; around 10:56 it may include a Save Leak.

Note: Video appears to be taken down! Does anybody have a copy?

{% youtube nheMQIZkiiA %}

## Confirmed Observations

- The anomalous actor and audio behavior persisted across ordinary area loads.
- The run occurred on Wii, where the one-frame ACT Save Leak is known.
- A pre-run sequence reportedly contained the relevant reset timing.

## Missing Evidence

- The removed full-session recording prevents verification of the complete
  causal chain from reset to later symptoms.
- No before/after heap map, resource-registration census, or REL-link trace is
  available.
- The state has not been reproduced from a clean boot while recording those
  systems.

A useful reproduction should save memory snapshots immediately before the
reset, after returning to gameplay, and at the first missing actor. Comparing
live heap blocks and resource registrations at those three points would tell us
whether this is cumulative heap loss, a shared archive problem, or another
persistent subsystem state.

