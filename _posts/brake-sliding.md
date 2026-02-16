---
layout: post
title: Brake Sliding
description: TAS-oriented movement technique to maintain speed
author: ai-agent
categories: [Glitches]
tags: [type-glitch, mechanic-movement, meta-tas]
date: 2026-02-16 00:00:00
---

## Summary

Brake Sliding (Brakesliding on the source page) preserves speed by using ESS input with `L-target` to create very low deceleration movement.

The source page distinguishes two forms:
- Regular Brake Slide: Link slides forward.
- Extended Brake Slide: release `L` after setup so Link turns and slides backward with even lower deceleration.

## ESS Basics

- ESS is a slight analog input just outside deadzone.
- In TP, The source page describes ESS as a narrow input band that is easier to miss than normal movement inputs.
- Closer-to-minimum ESS gives better slide retention.

## How To

1. Move in any direction.
2. On the same frame, press `L` and hold ESS in the opposite direction.
3. Keep the ESS hold steady to sustain the slide.

For an Extended Brake Slide, start from a regular brake slide and release `L` quickly.

## Buffering Methods

- Input during animations that temporarily ignore stick influence (for example out of [Epona Slide](/posts/epona-slide)).
- Buffer through the item wheel while moving, then hold `L`+ESS as it closes.

## Known Use Cases

- TAS movement optimization on flat sections, doors, and ladders where tiny frame gains matter.
- Traversing sand/snow while preserving speed (regular brake slide variant).
- Slope abuse with extended brake slides due to negative speed behavior.

## Notes

- The source page notes this is difficult RTA but can be stabilized with controller replug neutral tricks.
- Wolf brake sliding exists, but normal repeated wolf dashes usually overtake it on longer distances.
- Related pages: [Dash Cancel](/posts/dash-cancel), [Quick Climb](/posts/quick-climb), [Long Jump Attack (LJA)](/posts/long-jump-attack-lja), [Moon Boots](/posts/moon-boots).

## Video Examples

Regular:
{% youtube cEQA-7qSjf0 %}

Sand/Snow:
{% youtube ENXe4VbfPac %}

Deep Snow:
{% youtube xtmVrQKnXmM %}

Extended:
{% youtube ZLd19lIHcUA %}

Wolf
{% youtube R2l0TvPw-fY %}

## Additional Notes

## External Sources

ZSR page: https://www.zeldaspeedruns.com/tp/tech/brakesliding

