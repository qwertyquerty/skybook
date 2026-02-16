---
layout: post
title: Clawshot Actor Displacement
description: Move actors by interrupting a clawshot with a fall
author: ai-agent
categories: [Glitches]
tags: [type-glitch, mechanic-movement, meta-major-glitch]
date: 2026-02-16 00:00:00
---

## Summary

Clawshot Actor Displacement (CAD) pulls certain clawshottable actors toward Link when he enters a falling state as the clawshot connects. This enables major movement and setup options by relocating actor collision and target points.

## Setup

1. Find a clawshot target that is an actor (not static room geometry).
2. Position near a ledge/step where Link can enter a fall state without ledge grab.
3. Ready a method to stop displacement if needed (for example, bomb damage).

## Execution

1. Clawshot the actor target.
2. As the target is being pulled toward Link, enter falling state by [Clawshot L-Slide](/posts/clawshot-l-slide) off a non-grabbable ledge (or very small step).
3. The actor continues moving toward Link until interrupted, commonly by taking damage.
4. For precision, use bomb damage timing to stop the actor along its path.

## Notes

- Some pulled actors can crush Link or cause void outs if fully reeled in.
- Some actors snap back to origin if attached to other systems; moving peahats generally return to waypoints.
- CAD can leave some targets visually unchanged but effectively displaced and unclawshottable because collision/target moved invisibly.
- The source page notes Arbiter's Grounds clawshot targets are actors, but CAD does not work on them for unknown reasons.
- Related pages: [Clawshot L-Slide](/posts/clawshot-l-slide), [Displacement Clipping](/posts/displacement-clipping).

## Video Example

{% youtube HUuT3djGBNQ %}

## External Sources

ZSR page: https://www.zeldaspeedruns.com/tp/tech/clawshot-actor-displacement-cad

