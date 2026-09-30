---
layout: post
title: File Name Cursor Breakout
description: Moving the name entry cursor past the bounds of the name entry lets you write character records up to 2 KB past the name buffer.
authors: [qwertyquerty, zcanann]
categories: [Glitches]
tags: [type-glitch, mechanic-memory, meta-major-glitch, eyeshredder]
date: 2026-02-10 00:00:00
---

## Summary

The name entry cursor can move past the end of the 8 character name, and typing there writes an 8 byte name record out of bounds. The cursor is a `u8`, so positions `9-255` reach the end of the name screen object and about 1.9 KB of heap after it. Link's and Epona's name screens share the same object.

{% youtube kSMeK8R7JHQ %}

## The Bug

In `dName_c` ([d/d_name.cpp](https://github.com/zeldaret/tp/blob/main/src/d/d_name.cpp)), each name slot is an 8 byte `ChrInfo_c`: keyboard column, row, character set, `1`, then the character code as an `int`.

D-pad right only stops at exactly position `7`. When you type an addition character, the cursor gets moved to position `8`, allowing d-pad right to advance again. It can keep going to `255` and wrap to `0`:

```c++
    if (mDoCPd_c::getTrigRight(PAD_1)) {
        // BUG: this check only fails if the cursor is at exactly 7
        // setMoji allows the cursor to reach 8, which is out of bounds here
        if (mCurPos != 7) {
            mDoAud_seStart(Z2SE_SY_DUMMY, 0, 0, 0);
            mLastCurPos = mCurPos;
            mCurPos++;
            nameCursorMove();
        }
```

`setMoji` fails only at exactly `8` or when all 8 slots are full. Past `8`, its check for letters after the cursor (`for (int i = mCurPos; i < 8; i++)`) doesn't run, so it takes the last branch and writes to `mChrInfo[mCurPos]` with no bounds check:

```c++
void dName_c::setMoji(int moji) {
    if (mCurPos == 8 || nameCheck() == 8) {
        mDoAud_seStart(Z2SE_SYS_ERROR, NULL, 0, 0);
    } else {
        /* ... */
        } else {
            mChrInfo[mCurPos].mColumn = mCharColumn;
            mChrInfo[mCurPos].mRow = mCharRow;
            mChrInfo[mCurPos].mMojiSet = mMojiSet;
            mChrInfo[mCurPos].field_0x3 = 1;
            #if REGION_PAL
            mChrInfo[mCurPos].mCharacter = moji & 0xFF;
            #else
            mChrInfo[mCurPos].mCharacter = moji;
            #endif

            if (mCurPos != 8) {
                mLastCurPos = mCurPos;
                mCurPos++;
                nameCursorMove();
            }
        }
```

Pressing B past position `8` only blanks slot `7` and moves back one, which un-fills the name so typing works again.

## Setup

1. Press Right to position `7` and type any character (cursor goes to `8`).
2. Press Right to one past the target position, then press B.
3. Type. Each character writes one record and moves forward one. `255` wraps to `0`.

## What Gets Written

Position `p` writes 8 bytes at `dName_c + 0x2CC + 8 * p`:

| Byte | Value | Range |
|---|---|---|
| `0` | column (`u8`) | `0-12` |
| `1` | row (`u8`) | `0-4` |
| `2` | char set (`u8`) | NTSC-U `2`. PAL `0`/`1` (upper/lower). JP `0`/`1`/`2` (Hiragana/Katakana/English) |
| `3` | `1` (`u8`) | |
| `4-7` | char code (`u32`) | NTSC-U `0x20-0x7A`, PAL `0x20-0xFF`, JP is Shift-JIS |

The key decides all 8 bytes (`M` on NTSC-U is always `0C 00 02 01 00 00 00 4D`), so the first word is at most `0x0C040201` and the second at most `0xFFFF`.

On Wii the address is the same, `dName_c + 0x2CC + 8 * p`, but the `dName_c` heap block is `0x338` bytes instead of `0x334`. Therefore position `p` lands `8 * p - 0x68` bytes into the memory after the `dName_c` block on GameCube, and `8 * p - 0x6C` bytes on Wii. Because of this, on GameCube every object after `dName_c` lines up with the records, but on Wii each record will straddle two fields.

## Reachable Memory

`dName_c` is on the name scene's own `0x180000` byte heap. I measured what follows `dName_c` from a GZ2E01 Dolphin save state:

| Block | Address | Size | Positions | Contents |
|---|---|---|---|---|
| `dName_c` | `0x81457034` | `0x334` | `9-12` | End of the name screen |
| `STControl` | `0x81457378` | `0x30` | `13-20` | Keyboard stick control |
| `J2DScreen` | `0x814573B8` | `0x118` | `21-57` | Name screen layout |
| `J2DResReference` | `0x814574E0` | `0x130` | `58-97` | Texture names |
| `J2DResReference` | `0x81457620` | `0x30` | `98-105` | Font names |
| `J2DMaterial[145]` | `0x81457660` | `0x4D18` | `106-255` | Materials, first 9 reachable |

#### Small Objects and Headers

| Position | Overwrites | Effect |
|---|---|---|
| `9` | Saved keyboard cursor positions | Harmless |
| `10-12` | `mNextNameStr` | Harmless, rewritten before use |
| `13`, `21`, `58`, `98`, `106` | Heap header magic, flags, size | Harmless, the glitch always breaks the magic, so the block is never freed |
| `14`, `22`, `59`, `107` | Heap header links | Crash when file select closes **(tested)** |
| `99` | Font list header links | No effect seen **(tested)** |
| `15` | `STControl` vtable | Crash **(tested)** |
| `16-20` | Stick timers and thresholds | Bits change with stick input, no other effect seen **(tested)** |
| `60-97`, `100-105` | Texture and font names | Harmless **(tested)** |
| `108` | Material array size and count | Most values crash when entering the game **(tested)** |
| `109` | Padding | Harmless **(tested)** |

#### J2DScreen

| Position | Fields | Effect |
|---|---|---|
| `23` | vtable | Crash **(tested)** |
| `24-26` | Pane kind and tags (`PAN1`, `root`) | Harmless **(tested)** |
| `27-32` | Bounds, clip rect | Copied into the global bounds, some values cause a yellow screen **(tested)** |
| `33-44` | Position and global matrices | Rewritten every frame, so writes don't stick **(tested)** |
| `45` | `mVisible`, `mAlpha`, and other flags | Flags are rewritten every frame, the rest has no effect **(tested)** |
| `46-49` | Rotation, scale, X position | Changes the matrices above, some values cause a yellow screen **(tested)** |
| `50` | Y position, child list head | Crash **(tested)** |
| `51` | Child list tail, length | Tail harmless, length crashes **(tested)** |
| `52` | Parent link | Crash **(tested)** |
| `53` | Sibling links | Harmless **(tested)** |
| `54` | `mTransform` | Crash **(tested)** |
| `55` | `mScissor`, `mMaterialNum`, `mMaterials` | Crash, `mScissor` alone causes 2D artifacts in Dolphin **(tested)** |
| `56` | Texture and font lists | Harmless **(tested)** |
| `57` | `mNameTable`, `mColor` | Crash when entering the game, `mColor` has no effect **(tested)** |

#### Materials

Each material is 17 positions long, so position `110 + 17 * k + j` writes record `j` of material `k`. Materials 0-8 are the border around the character grid, drawn every frame. Material 8 is only reachable up to record 9.

| Material | Pane | Part of the border |
|---|---|---|
| 0 | `w_na_12` | Divider line under the keyboard |
| 1 | `w_na_11` | Top left |
| 2 | `w_na_10` | Bottom left |
| 3 | `w_na_09` | Top mid/left |
| 4 | `w_na_08` | Bottom mid/left |
| 5 | `w_na_07` | Top right |
| 6 | `w_na_06` | Bottom right |
| 7 | `w_na_05` | Top mid/right |
| 8 | `w_na_04` | Bottom mid/right |

Testing confirmed this mapping: the yellow artifacts below show up at each material's part of the border.

| `j` | Fields | Effect |
|---|---|---|
| `0` | vtable, `field_0x4` | Harmless, the destructor rewrites the vtable when entering the game **(tested)** |
| `1` | `mVisible` | No effect seen **(tested)** |
| `2` | Material colors | No effect seen **(tested)** |
| `3` | `mColorChanNum`, `mColorChan[0-2]` | [Eye Shredder](#eye-shredder), "Mismatched configuration between XF and BP stages" in Dolphin **(tested)** |
| `4` | `mColorChan[3]`, `mCullMode`, color block vtable | Yellow artifact on materials 1-8, the vtable is rewritten when entering the game **(tested)** |
| `5` | `mTexGenNum`, `mTexGenCoord[0]` | Crash or Dolphin GPU errors ("Unknown Opcode", "XF load exceeds address space"), `mTexGenCoord[0]` gives a yellow artifact on materials 1-8 **(tested)** |
| `6-8` | Unused texgens | Harmless **(tested)** |
| `9` | `mTexGenCoord[7]`, `mTexMtx[0]` | No effect seen **(tested)** |
| `10-13` | `mTexMtx[1-7]`, texgen block vtable | `mTexMtx[1-7]` crash, the vtable has no effect **(tested)** |
| `14` | TEV and indirect blocks | Crash **(tested)** |
| `15` | Alpha compare, blend | Yellow artifact on materials 1-8 **(tested)** |
| `16` | `mDither`, `mAnmPointer` | Crash **(tested)** |

### Other Versions

| Version | `dName_c` address | `dName_c` block size | Blocks after it |
|---|---|---|---|
| GZ2E01 | `0x81457034` | `0x334` | Shown above |
| GZ2P01 | `0x81456C14` | `0x334` | Same as above |
| RZDE01 rev 0 | `0x81160494` | `0x338` | Same blocks, 4 bytes later |

On Wii, the `dName_c` block is 4 bytes bigger, so every object after it starts 4 bytes later relative to the records (meaning that each record position gets offset by half a record).

### Region Differences

* **PAL:** Y switches uppercase and lowercase. Lowercase letters in a preloaded name keep the blank slot's column and row because `NameStrSet` compares them wrongly. This doesn't affect the glitch.
* **JP:** The X button and the dakuten (like ゛) keys adjust the word at `+4` of the record before the cursor, but only if it has the format of a kana record (the first byte is `0-12` and the char set is not `2`).

## Eye Shredder

Writing a specific record makes colors and shading look kaleidoscopic and makes HUD elements appear when they shouldn't. It only works on console, and it doesn't change gameplay.

{% youtube 6BB251TuVwI %}

1. Choose a new save file and press Right to the end of the name.
2. Enter `M`, press Right 106 times, press B, and enter `M` again.
3. Press Start repeatedly to finish creating the file.

These inputs write `M` to position `113`, which is record 3 of material 0. Material 0 belongs to the divider line under the keyboard. The first byte of that record is the material's color channel count, `mColorChanNum`, which is normally `1`. `M` is in keyboard column 12, so the count becomes `12`.

The divider line is drawn every frame, and each time, the overwritten `mColorChanNum` value causes two side effects:

* The GPU's channel count register is set to `12`, but it only accepts `0-2`.
* `J2DColorBlock::setGX` calls `GXSetChanCtrl` twice per channel (color and alpha), so it loops 24 times instead of 2. That reads past the material's channel settings and sends garbage to the GPU's 4 color channel registers.

Any column 12 character works (`M`, `Z`, `m`, `z`, space on NTSC-U). Testing found the same Dolphin error ("Mismatched configuration between XF and BP stages") from record 3 of every reachable material, positions `113`, `130`, `147`, `164`, `181`, `198`, `215`, `232` and `249`.

## Why It's Not Useful

* **Nothing important is in range:** Only reaches name screen objects, on a heap that gets freed when file select is closed. The saved name in your file is built from slots `0-7` only.
* **No way to write valid pointers:** Records replace whole words with a limited set of too small of values, so every pointer it can touch will become invalid and crash on console.
  * Pointers are 4 byte aligned, so each one lines up with exactly one half of a record. The first word can be at most `0x0C040201`. The second word is the character code stored big-endian as a 4 byte `int`, so it's at most `0x000000FF` (PAL `moji & 0xFF`) or `0x0000FFFF` (JP Shift-JIS). The only byte that can be `0x80` or higher is the last byte of the record, and a 4 byte aligned pointer can never start there. Every overwritten pointer will always be below `0x0D000000`, and memory is only mapped from `0x80000000` up.
* **No path to a bigger write:** A small write could become a big one if it changed a count or index that the game later uses to write memory, like a loop bound. All but one of the counts in range don't work that way:
  * `mTexGenNum` (material record `5`) makes a loop call `GXSetTexCoordGen` too many times. That only sends GPU register writes, and its one CPU-side write is limited by a `switch` state whose `default` case stays in bounds.
  * `mColorChanNum` (material record `3`, Eye Shredder) makes a loop call `GXSetChanCtrl` with garbage. That masks the channel with `& 3` and only sends GPU register writes.
  * `mMaterialNum` (`J2DScreen`, position `55`) is in the same record as the `mMaterials` pointer, so changing it also breaks the pointer and crashes.
  * **Exception, needs more testing:** position `108` overwrites the material array's size and count. When file select closes, `delete[]` runs `~J2DMaterial` on `mMaterials + size * i` for each of `count` elements. Each call writes vtable pointers into that address and frees pointers read from it. Larger columns make the size `0x01000201` or more, which spreads the addresses across all of memory. This is the one way found so far that the glitch could write outside the heap. Nothing can control the values written, however, and the frees will likely crash first. Prior testing found most values crash when entering the game.

## Open Questions

* **Is the layout the same on other versions?** Checked on GZ2E01, GZ2P01 and RZDE01 rev 0 only.
* **What does a corrupted material array header do?** Writing position `108` makes `delete[]` destroy materials at addresses past the materials array when file select closes. Testing found most values crash when entering the game, but which values don't, and what they write, hasn't been exhaustively checked.

## References

**Documentation of console-tested scenarios:** https://docs.google.com/spreadsheets/d/1T_f2LXGN4YINsxMIMZ0O0zuYlJRCToV68hh1pD0X1kU/edit#gid=0
