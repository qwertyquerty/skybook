---
layout: post
title: Moon Boots
description: Getting a little extra height out of attacks
author: qwertyquerty
categories: [Glitches]
tags: [glitch]
pin: true
math: true
mermaid: true
date: 2025-09-14 00:00:00
---

## How it works

When Link does a jump attack, jump strike, ending blow, or backslice while wearing the iron boots / heavy magic armor and then force unequips them shortly after leaving the ground he can get more height out of the attack. This happens because each of these attacks is specifically programmed to give Link more vertical speed to overcome the increased downward gravity acceleration given by Link's heavy state

Normal gravity is 3.4 while gravity in a heavy state is 7.65. Unequipping immediately switches from high gravity back to low gravity allowing us to still reap the benefits of the higher vertical velocity for the remaining frames.

#### Version Differences

Normally it's only possible to do moon boots with jump attack and ending blow on frame 1 on Wii, as you can open the item wheel and start an attack on the same frame; the best GCN can do for those is frame 2 moon boots. However if GCN has jump strike, this unlocks frame 1 moon boots for jump attacks.

## Jump Attack

> Note: it is also possible to perform moon boots on a mid-air jump slash, gaining just 0.9 units of height for frame 1 MB on the Wii version only

#### Code

According to the following code, jump attacks get a 35% vertical speed boost when in a heavy state:

```c++
void daAlink_c::setCutJumpSpeed(int i_airAt) {
    if (checkNoResetFlg0(FLG0_UNDERWATER)) {
        ...
    } else if (checkHeavyStateOn(1, 1)) {
        speed.y *= 1.35f;
    }
  
    ...
}

int daAlink_c::procCutJumpInit(int i_airCut) {
    ...

    if (i_airCut) {
        mNormalSpeed = daAlinkHIO_cutJump_c0::m.mAirJumpSpeedH;
        speed.y = daAlinkHIO_cutJump_c0::m.mAirJumpSpeedV; // 13
    } else {
        mNormalSpeed = daAlinkHIO_cutJump_c0::m.mBaseJumpSpeedH;
        speed.y = daAlinkHIO_cutJump_c0::m.mBaseJumpSpeedV; // 27
    }

    setCutJumpSpeed(i_airCut);

    ...
}

```

#### Frame Data

The greatest Y displacement you can get with a jump attack moon boots is `136.8` units with frame 1 MB or `105.45` with frame 2 MB on GCN without jump strike

| Frame | No MB Y  | MB Frame 1 Y | MB Frame 2 Y |
| :---- | :------: | :----------: | :----------: |
| 1     |    0     |      0       |      0       |
| 2     |   23.6   |     28.8     |     28.8     |
| 3     |   43.8   |     54.2     |    49.95     |
| 4     |   60.6   |     76.2     |     67.7     |
| 5     |    74    |     94.8     |    82.05     |
| 6     |    84    |     110      |      93      |
| 7     |   90.6   |    121.8     |    100.55    |
| 8     | **93.8** |    130.2     |    104.7     |
| 9     |   93.6   |    135.2     |  **105.45**  |
| 10    |    90    |  **136.8**   |    102.8     |
| 11    |    83    |     135      |    96.75     |
| 12    |   72.6   |    129.8     |     87.3     |
| 13    |   58.8   |    121.2     |    74.45     |
| 14    |   41.6   |    109.2     |     58.2     |
| 15    |    21    |     93.8     |    38.55     |
| 16    |    0     |      75      |     15.5     |
| 17    |    -     |     52.8     |      0       |
| 18    |    -     |     27.2     |      -       |
| 19    |    -     |      0       |      -       |

## Jump Strike

#### Code

According to the following code, jump strikes get a 35% vertical speed boost when in a heavy state:

```c++
void daAlink_c::setCutJumpSpeed(int i_airAt) {
    if (checkNoResetFlg0(FLG0_UNDERWATER)) {
        ...
    } else if (checkHeavyStateOn(1, 1)) {
        speed.y *= 1.35f;
    }
  
    ...
}

int daAlink_c::procCutLargeJump() {
    ...

            if (!checkModeFlg(2) && frameCtrl->getFrame() >= 5.0f) {
                ...
                speed.y = daAlinkHIO_cutLargeJump_c0::m.mCutSpeedV; // 33
                setCutJumpSpeed(0);
            }

    ...
}
```

#### Frame Data

The greatest Y displacement you can get with jump strike moon boots is `218.9` units with frame 5 MB

| Frame | No MB Y | MB Frame 5 Y | MB Frame 6 Y | MB Frame 7 Y |
| :---- | :-----: | :----------: | :----------: | :----------: |
| 1     |    0    |      0       |      0       |      0       |
| 2     |    0    |      0       |      0       |      0       |
| 3     |    0    |      0       |      0       |      0       |
| 4     |    0    |      0       |      0       |      0       |
| 5     |  29.6   |     36.9     |     36.9     |     36.9     |
| 6     |  55.8   |     70.4     |    66.15     |    66.15     |
| 7     |  78.6   |    100.5     |      92      |    87.75     |
| 8     |   98    |    127.2     |    114.45    |    105.95    |
| 9     |   114   |    150.5     |    133.5     |    120.75    |
| 10    |  126.6  |    170.4     |    149.15    |    132.15    |
| 11    |  135.8  |    186.9     |    161.4     |    140.15    |
| 12    |  141.6  |     200      |    170.25    |    144.75    |
| 13    | **144** |    209.7     |    175.7     |  **145.95**  |
| 14    |   143   |     216      |  **177.75**  |    143.75    |
| 15    |   138   |  **218.9**   |    176.4     |    138.15    |
| 16    |  130.8  |    218.4     |    171.65    |    129.15    |
| 17    |  119.6  |    214.5     |    163.5     |    116.75    |
| 18    |   105   |    207.2     |    151.95    |    100.95    |
| 19    |   87    |    196.5     |     137      |    81.75     |
| 20    |  65.6   |    182.4     |    118.65    |    59.15     |
| 21    |  40.8   |    164.9     |     96.9     |    33.15     |
| 22    |  12.6   |     144      |    71.75     |     3.75     |
| 23    |    0    |    119.7     |     43.2     |      0       |
| 24    |    -    |      92      |    11.25     |      -       |
| 25    |    -    |     60.9     |      0       |      -       |
| 26    |    -    |     26.4     |      -       |      -       |
| 27    |    -    |      0       |      -       |      -       |

## Ending Blow

#### Code

According to the following code, ending blow attacks get a 50% vertical speed boost when in a heavy state:

```c++
int daAlink_c::procCutDownInit() {
    ...

        speed.y = daAlinkHIO_cutDown_c0::m.mRecoverSpeedH; // 40

        if (checkNoResetFlg0(FLG0_UNDERWATER)) {
            ...
        } else if (checkHeavyStateOn(1, 1)) {
            speed.y *= 1.5f;
        }

    ...
}
```

#### Frame Data

The greatest Y displacement you can get with ending blow moon boots on Wii is `429.6` units with frame 1 MB and for GCN `368.75` units with frame 2 MB

| Frame |  No MB Y  | MB Frame 1 Y | MB Frame 2 Y | MB Frame 3 Y | MB Frame 4 Y | MB Frame 5 Y |
| :---- | :-------: | :----------: | :----------: | :----------: | :----------: | :----------: |
| 1     |     0     |      0       |      0       |      0       |      0       |      0       |
| 2     |   36.6    |    52.35     |    52.35     |    52.35     |    52.35     |      0       |
| 3     |   69.8    |    101.3     |    97.05     |    97.05     |    97.05     |    52.35     |
| 4     |   99.6    |    146.85    |    138.35    |    134.1     |    134.1     |    97.05     |
| 5     |    126    |     189      |    176.25    |    167.75    |    163.5     |    134.1     |
| 6     |    149    |    227.75    |    210.75    |     198      |    189.5     |    163.5     |
| 7     |   168.6   |    263.1     |    241.85    |    224.85    |    212.1     |    185.25    |
| 8     |   184.8   |    295.05    |    269.55    |    248.3     |    231.3     |    203.6     |
| 9     |   197.6   |    323.6     |    293.85    |    268.35    |    232.03    |    218.55    |
| 10    |    207    |    348.75    |    314.75    |     285      |    232.03    |    230.1     |
| 11    |    213    |    370.5     |    332.25    |    298.25    |    232.03    |    238.25    |
| 12    | **215.6** |    388.85    |    346.35    |    308.1     |    232.03    |     243      |
| 13    |   214.8   |    403.8     |    357.05    |    314.55    |  **232.04**  |  **244.35**  |
| 14    |   210.6   |    415.35    |    364.35    |  **317.6**   |    230.84    |    242.3     |
| 15    |    203    |    423.5     |    368.25    |    317.25    |    226.24    |    236.85    |
| 16    |    192    |    428.25    |  **368.75**  |    313.5     |    218.24    |     228      |
| 17    |    178    |  **429.6**   |    365.85    |    306.35    |    206.84    |    215.75    |
| 18    |   159.8   |    422.1     |    359.55    |    295.8     |    192.04    |    200.1     |
| 19    |   138.6   |    413.25    |    349.85    |    281.85    |    173.84    |    181.05    |
| 20    |    114    |     401      |    336.75    |    264.5     |    152.24    |    158.6     |
| 21    |     0     |    385.35    |    320.25    |    243.75    |    127.24    |    132.75    |
| 22    |     -     |    366.3     |    300.35    |    219.6     |    98.84     |    103.5     |
| 23    |     -     |    343.85    |    277.05    |    192.05    |    67.04     |    70.85     |
| 24    |     -     |     318      |    250.35    |    161.1     |    31.84     |     34.8     |
| 25    |     -     |    288.75    |    220.25    |    126.75    |      0       |     2.1      |
| 26    |     -     |    256.1     |    186.75    |      89      |      -       |     2.45     |
| 27    |     -     |    220.05    |    149.85    |    47.85     |      -       |      0       |
| 28    |     -     |    180.6     |    109.55    |     3.3      |      -       |      -       |
| 29    |     -     |    137.75    |    65.85     |      0       |      -       |      -       |
| 30    |     -     |     91.5     |    18.75     |      -       |      -       |      -       |
| 31    |     -     |    41.85     |      0       |      -       |      -       |      -       |
| 32    |     -     |    1.5284    |      -       |      -       |      -       |      -       |
| 33    |     -     |    1.7221    |      -       |      -       |      -       |      -       |
| 34    |     -     |      0       |      -       |      -       |      -       |      -       |


## Back Slice

> Note: Back slice moon boots does not work with iron boots and must be done with magic armor

#### Code

According to the following code, back slice attacks get a 50% vertical speed boost when in a heavy state:

```c++
int daAlink_c::procCutFinishJumpUpInit() {
    ...
  
    speed.y = daAlinkHIO_cutFnJU_c0::m.mSpeedV; // 33

    ...

    if (checkNoResetFlg0(FLG0_UNDERWATER)) {
        ...
    } else if (checkHeavyStateOn(1, 1)) {
        speed.y *= 1.5;
    }

    ...
}
```

#### Frame Data

The greatest Y displacement you can get with back slice moon boots on is `278.85` units with frame 1 MB

| Frame | No MB Y | MB Frame 1 Y | MB Frame 2 Y | MB Frame 3 Y | MB Frame 4 Y | MB Frame 5 Y |
| :---- | :-----: | :----------: | :----------: | :----------: | :----------: | :----------: |
| 0     |    0    |      0       |      0       |      0       |      0       |      0       |
| 1     |  29.6   |    41.85     |    41.85     |    41.85     |    41.85     |    41.85     |
| 2     |  55.8   |     80.3     |    76.05     |    76.05     |    76.05     |    76.05     |
| 3     |  78.6   |    115.35    |    106.85    |    102.6     |    102.6     |    102.6     |
| 4     |   98    |     147      |    134.25    |    125.75    |    121.5     |    121.5     |
| 5     |   114   |    175.25    |    158.25    |    145.5     |     137      |    132.75    |
| 6     |  126.6  |    200.1     |    178.85    |    174.8     |    149.1     |    140.6     |
| 7     |  135.8  |    221.55    |    196.05    |    184.35    |    157.8     |    145.05    |
| 8     |  141.6  |    239.6     |    209.85    |    190.5     |    163.1     |  **146.1**   |
| 9     | **144** |    254.25    |    220.25    |  **193.25**  |   **165**    |    143.75    |
| 10    |   143   |    265.5     |    227.25    |    192.6     |    163.5     |     138      |
| 11    |  138.6  |    273.35    |    230.85    |    188.55    |    158.6     |    128.85    |
| 12    |  130.8  |    277.8     |  **231.05**  |    181.1     |    150.3     |    116.3     |
| 13    |  119.6  |  **278.85**  |    227.85    |    170.25    |    138.6     |    100.35    |
| 14    |   105   |    276.5     |    221.25    |     156      |    123.5     |      81      |
| 15    |   87    |    270.75    |    211.25    |    138.35    |     105      |    58.25     |
| 16    |  65.6   |    261.6     |    197.85    |    117.3     |     83.1     |     32.1     |
| 17    |  40.8   |    249.05    |    181.05    |    92.85     |     57.8     |     2.55     |
| 18    |  12.6   |    233.1     |    160.85    |      65      |     29.1     |      0       |
| 19    |    0    |    213.75    |    137.25    |    33.75     |      0       |      -       |
| 20    |    -    |     191      |    110.25    |      0       |      -       |      -       |
| 21    |    -    |    164.85    |    79.85     |      -       |      -       |      -       |
| 22    |    -    |    135.3     |    46.05     |      -       |      -       |      -       |
| 23    |    -    |    102.35    |     8.85     |      -       |      -       |      -       |
| 24    |    -    |      66      |      0       |      -       |      -       |      -       |
| 25    |    -    |    26.25     |      -       |      -       |      -       |      -       |
| 26    |    -    |      0       |      -       |      -       |      -       |      -       |

