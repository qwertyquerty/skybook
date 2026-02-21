---
layout: post
title: File Name Cursor Breakout
description: Filename cursor overflow that can write data outside the intended 256-byte filename range.
author: zcanann
categories: [Glitches]
tags: [type-glitch, mechanic-memory, meta-major-glitch]
date: 2026-02-10 00:00:00
---

This page is missing important technical information and could use cleanup!

## Summary

By pushing cursor state outside normal bounds in the file name screen, you can write data beyond the expected 256-byte filename range.

## Primary Source

{% youtube kSMeK8R7JHQ %}

## Eye Shredder

Use cursor breakout and write to specific cursor positions to trigger a console-only rendering bug.

{% youtube 6BB251TuVwI %}

## Additional Notes

Flag documentation: https://docs.google.com/spreadsheets/d/1T_f2LXGN4YINsxMIMZ0O0zuYlJRCToV68hh1pD0X1kU/edit#gid=0

