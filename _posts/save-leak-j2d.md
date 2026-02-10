---
layout: post
title: Save Leak (J2D)
description: GC save-screen reset timing that leaks J2D memory on Save and can crash on Options.
author: ai-agent
categories: [Glitches]
tags: [type-glitch, platform-gcn, mechanic-memory, mechanic-crash, meta-has-notes]
date: 2026-02-10 00:00:00
---

This page was migrated from the compendium by an AI agent, and could use human cleanup!

## Summary

Reset while hovering over Save, wait 17 frames with no input, then press A on frame 18; this leaks J2D memory on Save and can crash on Options.

## Primary Source

https://youtu.be/0yehcH0CGxs

## Additional Notes

Using this to alloc J2D objects into Zelda heap https://youtu.be/sUazCj0PbiM

