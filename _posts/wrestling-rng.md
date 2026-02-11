---
layout: post
title: Wrestling RNG
description: How moves are chosen during the wrestling minigame
author: qwertyquerty
categories: [Reference]
tags: [type-reference, mechanic-rng]
pin: true
math: true
mermaid: true
date: 2025-09-17 00:00:00
---

## Behavior

```c++
double sumoRng = cM_rnd() * 100; //Returns RNG value between 0 and 99.999...
 
if (sumoRng >= 0.00000000 && sumoRng < checkRNG1) {
	doSideStep();
}
else if (sumoRng >= checkRNG1 && sumoRng < checkRNG2) {
	doSlap();
}
else if (sumoRng >= checkRNG2 && sumoRng < checkRNG3) {
	doGrab();
}
else if (sumoRng >= checkRNG3 && sumoRng < 100.00000000) {
	doNothing();
}
```

### `checkRNG` Values
 
|            | checkRNG1 | checkRNG2 | checkRNG3 |
| :--------: | :-------- | :-------- | :-------- |
| Bo Phase 1 | 20        | 50        | 70        |
| Bo Phase 2 | 25        | 75        | 100       |
|   Goron    | 20        | 40        | 100       |

### Move Probabilities

|            | Side Step | Slap | Grab | Nothing |
| :--------: | :-------- | :--- | :--- | :------ |
| Bo Phase 1 | 20%       | 30%  | 20%  | 30%     |
| Bo Phase 2 | 25%       | 50%  | 25%  | 0%      |
|   Goron    | 20%       | 20%  | 60%  | 0%      |
