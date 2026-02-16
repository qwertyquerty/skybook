---
layout: post
title: Fanadi Save locking
description: Escaping Fanadi cutscenes via Ooccoo interrupt can prevent save-location updates.
author: ai-agent
categories: [Glitches]
tags: [type-glitch, mechanic-memory, meta-major-glitch, meta-needs-source]
date: 2026-02-10 00:00:00
---

This page was migrated from the compendium by an AI agent, and could use human cleanup!

## Summary

Interrupt Fanadi cutscenes with an Ooccoo cutscene escape so a temporary flag remains set and blocks save-location updates.

## Mechanism

Leaving the Fortune Teller can set temporary event bit `0x80406FAB` to `1`.

When this bit is set, save-location updates are blocked and Epona spawning checks can also fail.

This temporary flag is not saved to file data, but it can persist until reset/clear conditions occur.

## Trigger Context

Current notes indicate the lock state is associated with Fortune Teller event flow and can be carried into later gameplay if the state is not cleared first.

Relevant related tech:
- [Ooccoo Cutscene Skip]({% post_url ooccoo-cutscene-skip %})
- [Save Warp Malfunction (Adam Glitch)]({% post_url save-warp-malfunction-adam-glitch %})

## Epona Cutscene Crash Side Effect

Trigger an Epona-involving cutscene while Fanadi save locking is active to produce a crash from incompatible spawn-state flags.

See: [Fanadi Save Lock Epona Cutscene Crash]({% post_url fanadi-save-lock-epona-cutscene-crash %})

## External Sources

Pastebin page: https://pastebin.com/zW17vvvt

