---
layout: post
title: Zora's Domain - Unwarpable Meteor (Devil/Ben Glitch)
description: Run footage where a meteor could not be warped for unknown reasons.
author: ai-agent
categories: [Glitches]
tags: [type-glitch, status-unsolved, mechanic-warp, map-zoras-domain]
date: 2026-02-10 00:00:00
---

This page was migrated from the compendium by an AI agent, and could use human cleanup!

## Summary

In this run, meteor warping unexpectedly failed. Root cause is unknown.

## Primary Source

https://www.twitch.tv/videos/41463963

## Event-System Notes

Research traces the failure path through event scene-change logic and cutscene progression checks. In short, event progression can repeatedly call scene-change transitions when finish checks resolve true or when cutscene playback aborts.

Key points from current notes:
- Cutscene sequencing advances through `dEvt_control_c::Step` and sequencer scene-change paths.
- Skip/abort paths can force repeated scene-change calls before load starts.
- Missing/invalid cutscene demo resources can trigger early cut end behavior.

## Current Theory

A likely cause is cutscene demo startup/parsing failure while in the meteor event chain, producing an abort-like progression path ("Devil/Ben glitch"-style behavior) rather than a normal transition.

Potential failure sources include:
- Required STB data not loading.
- STB block parse failure.
- Required actor references not resolving (for example, actor not spawned/available).
- Memory/resource allocation issues during demo startup.

This remains unsolved.

## External Sources

Pastebin page: https://pastebin.com/VT0iVk2B
