---
layout: post
title: Bubble mDownPos Offset
description: The glitch that causes ending blow to sometimes aim at the wrong spot when targeting bubbles
author: qwertyquerty
categories: [Glitches]
tags: [glitch, poe-gate-skip, minor]
pin: true
math: true
mermaid: true
date: 2025-09-13 00:00:00
---

## Why the glitch happens

Below is an excerpt from `d_a_e_bu.cpp`

```c++
static s8 action(e_bu_class* i_this) {
    switch (i_this->action) {
    ...
    case ACTION_HEAD:
        do_smoke_eff = e_bu_head(i_this);
        is_mtrl_eff = FALSE;
        down_status = 1;
        break;
    ...
    }
        
    if (down_status == 1) {
        enemy->onDownFlg();
        enemy->setDownPos(&actor->current.pos);
    } else {
        enemy->offDownFlg();
    }
    
    ...

    
    i_this->acch.CrrPos(dComIfG_Bgsp());
    ...
}
```

`action` is run every frame to control a Bubble's behavior based on its state. If its in state "head" (knocked down by the playing and hopping on the ground) it is marked as "down" meaning the player could perform an ending blow on it. When an ending blow is initiated, the Link is set to angle directly towards the "down position" of the enemy he is attacking instead of the current actor position.

The "down position" is stored from the bubble's current actor position on `enemy->setDownPos(&actor->current.pos);`, and this is performed AFTER the bubble's position is updated from the movement for the frame, shown in the following excerpt from `e_bu_head`:

```c++
static s8 e_bu_head(e_bu_class* i_this) {
    ...

    sp20.x = 0.0f;
    sp20.y = 0.0f;
    sp20.z = actor->speedF;
    MtxPosition(&sp20, &sp14);
    actor->current.pos.x += sp14.x;
    actor->current.pos.z += sp14.z;
    actor->current.pos.y += actor->speed.y;
    actor->speed.y -= 7.0f + JREG_F(8);
    return is_smoke_eff;
}
```

The problem is, this new position after movement is not corrected for wall collision (`i_this->acch.CrrPos(dComIfG_Bgsp());`) until after the "down position" is stored. The sequence of operations looks like this:

- Update current bubble position from speed / angle in `e_bu_head`
- Store current bubble position into the "down position"
- Wall correct current bubble position to keep the bubble in bounds

Therefore, the down position always stores the non wall corrected bubble position. In the case where a bubble is in the head state and bouncing into a wall, the down position stores a position with 1 frame of extra bubble movement *into* the wall, while the bubble still looks visually in-bounds. If Link initiates an ending blow on a bubble that is actively hopping into a wall, the ending blow angles slightly more into that wall than it otherwise would have.

## Video example

This behavior of the down position being offset from the bubble's wall corrected position can be visualized in the following video:

<iframe width="500" height="300" src="https://www.youtube.com/embed/7U74obSt69o" frameborder="0" allowfullscreen></iframe>
