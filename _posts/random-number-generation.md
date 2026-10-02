---
layout: post
title: Random Number Generation
description: A complete guide to how random number generation works
author: qwertyquerty
categories: [Reference]
tags: [type-reference, mechanic-rng]
pin: true
math: true
mermaid: true
date: 2025-09-12 00:00:00
---

Almost all random number generation in *Twilight Princess* is done with the following functions from [`SSystem/SComponent/c_math.cpp`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/SSystem/SComponent/c_math.cpp) ([source](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/SSystem/SComponent/c_math.cpp#L180-L205)):

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

[`cM_rnd`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/SSystem/SComponent/c_math.cpp#L180-L187) is an implementation of a well known RNG algorithm called [Wichmann-Hill](https://en.wikipedia.org/wiki/Wichmann%E2%80%93Hill). It returns a value in `[0, 1)`, [`cM_rndF`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/SSystem/SComponent/c_math.cpp#L194-L196) scales it to `[0, max)`, and [`cM_rndFX`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/SSystem/SComponent/c_math.cpp#L203-L205) to `[-max, max)`.

From startup, it always generates the same sequence of numbers. The unpredictability comes from the player influencing how many times it has been called. In theory, reproducing the same inputs from startup would reproduce the same RNG.

The period of the function is `6,953,607,871,644` (the least common multiple of `30268`, `30306`, and `30322`), after which it repeats.

`r0`, `r1`, and `r2` are always all initialized to 100 at startup by [`cM_initRnd`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/SSystem/SComponent/c_math.cpp#L170-L174) in [`mDoMch_Create`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/m_Do/m_Do_machine.cpp#L741-L975) ([source](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/m_Do/m_Do_machine.cpp#L962)):

```c++
int mDoMch_Create() {
  ...
  cM_initRnd(100, 100, 100);
  ...
}
```

If any of `r0`, `r1`, or `r2` were ever 0, it would stay 0 forever. If there was some way to set all three to 0, `cM_rnd` would always return 0, effectively removing RNG from the game.

## Secondary RNG

`c_math.cpp` also has a second, identical generator with separate state ([`cM_rnd2`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/SSystem/SComponent/c_math.cpp#L219-L226), seeded by [`cM_initRnd2`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/SSystem/SComponent/c_math.cpp#L213-L217)), so it never affects the main RNG. Most of the actors that use it reseed it themselves right before use, with fixed or actor-ID-based values, so their results are predictable. It is used by:

- [`d_a_demo00`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_demo00.cpp)
- [`d_a_e_rd`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_e_rd.cpp)
- [`d_a_e_rdy`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_e_rdy.cpp)
- [`d_a_e_s1`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_e_s1.cpp)
- [`d_a_e_th`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_e_th.cpp)
- [`d_a_e_yg`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_e_yg.cpp)
- [`d_a_mg_fshop`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_mg_fshop.cpp)
- [`d_a_obj_msima`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_obj_msima.cpp)
- [`d_a_obj_rock`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_obj_rock.cpp)
- [`d_a_obj_tatigi`](https://github.com/zeldaret/tp/blob/c8fa8c9e2aab72cf4e5db0e5d1c84a9ea6ee6eb0/src/d/actor/d_a_obj_tatigi.cpp)
