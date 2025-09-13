---
layout: post
title: Random Number Generation
description: A complete guide to how random number generation works
author: qwertyquerty
categories: [Reference]
tags: [reference, RNG]
pin: true
math: true
mermaid: true
---

Almost all random number generation in *Twilight Princess* is done with the following functions from `SSystem/SComponent/c_math.cpp`

```c++
f32 cM_rnd() {
    r0 = (r0 * 171) % 30269;
    r1 = (r1 * 172) % 30307;
    r2 = (r2 * 170) % 30323;

    f32 var_f31 = r0 / 30269.0f + r1 / 30307.0f + r2 / 30323.0f;
    return fabsf(fmodf(var_f31, 1.0));
}

f32 cM_rndF(f32 max) {
    return cM_rnd() * max;
}

f32 cM_rndFX(f32 max) {
    return max * (cM_rnd() - 0.5f) * 2.0f;
}
```

`cM_rnd` is an implementation of a common, well known RNG function called [Wichmann Hill](https://en.wikipedia.org/wiki/Wichmann%E2%80%93Hill)

From startup, it will always generate the same sequence of numbers in order. The indeterminacy of the function is brought about by the player influencing how many times it has been called. In theory, reproducing the same set of inputs from startup would lead to the same RNG.

The overall period of the function is `6,953,607,871,644` after which it will repeat.

`r0`, `r1`, and `r2` are always all initialized to 100 at startup in `mDoMch_Create`:

```c++
int mDoMch_Create() {
  ...
  cM_initRnd(100, 100, 100);
  ...
}
```

It's worth noting that if there was some way to get `r0`, `r1`, and `r2` to all be 0, they would remain 0 effectively removing RNG from the game.
