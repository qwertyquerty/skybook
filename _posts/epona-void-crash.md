---
layout: post
title: Epona Void Crash
description: Reset during an Epona void to cause a crash when reopening the file.
author: zcanann
categories: [Glitches]
tags: [type-glitch, mechanic-crash]
date: 2026-02-10 00:00:00
---

## Summary

Void on Epona, reset during the void sequence, then reopen the file to trigger a crash.

This behavior appears separate from standard [Back in Time](/posts/back-in-time) results and has at least two distinct crash outcomes depending on reset timing.

## Timing Findings

Observed reset windows (latest to earliest):
- Reset after respawn and control return: normal behavior.
- Reset after respawn but before control return: normal behavior.
- Reset after voiding but before respawn: normal behavior.
- Reset shortly before void-out resolves: immediate crash.
- Reset after triggering void, before void-out: reset appears normal, then delayed crash after file load in some cases.
- Reset well before void-out: normal behavior.
- Reset before void trigger: normal behavior.

The boundary between the delayed-crash window and normal behavior is narrow and timing-sensitive.

## Crash Modes

Two outcomes are documented:
- Immediate crash: occurs soon after reset timing near void-out resolution.
- Delayed crash: reaches file select and can crash on or after loading, depending on state/file.

## File Dependence Findings

Initial testing suggested the loaded file did not matter, but later testing showed file/state dependence.

Some BiTE-compatible files were observed to load successfully, while many other states crash. This means compatibility is not a simple "all files crash" rule and should be treated as scenario-dependent.

## BiT Relationship

This research treats the crash behavior as distinct from BiT-trigger outcomes, even though reset/void timing is nearby in practice. BiT-frame overlap was considered but not conclusively identified as the cause of these crash paths.

## Primary Source

### Initial crash (FL HFS Ordon D2)

{% youtube GEy1g5G7Z9E %}

## Research Playlist

### Full research playlist

https://www.youtube.com/playlist?list=PL6bG11NIEuAI07YjPdDgx9_fUl7VQwse0

## Additional Video Evidence

### Another crash like the first (FL HFS Ordon D2)

{% youtube mjIbNRymVMI %}

### Third simple crash (FL New Game)

{% youtube XHAvf4O6EHs %}

### Original research segment (FL HFS Ordon D2)

{% youtube pK8NER8eY-4 %}

### Original timing research (N/A)

{% youtube _5-cvvIdN_A %}

### Instacrash scenario (Instacrash)

{% youtube PpjEQax4Nz0 %}

### In-game load then crash (Link's House Area)

{% youtube sDihlFxaaXA %}

### Multiple save files test (Link's House Area)

{% youtube tM6PSfvw-BU %}

### In-game variant (Sera's Shop)

{% youtube kxVbOsr_NLo %}

### Ordon D2 variant (Sera's Shop)

{% youtube _qgE7nLLAuk %}

### Various Ordon areas (Sera's Shop)

{% youtube D6PX59-Cl7s %}

### Mayor Bo's House variant (Link's House Area)

{% youtube wulUaTEHBxo %}

### ppltoast Dolphin timing tests (Various)

{% youtube 2ekiZ8PJKXQ %}

### Barrier trigger behavior after OOB (N/A)

{% youtube CLxis4P8UJM %}

## External Sources

Pastebin page: https://pastebin.com/d7cF03EM
