---
layout: post
title: You Can't Unload Obj_Board or V_CTGWall
description: A technical dive into what we can and cannot archive corrupt
author: wolfegarden
categories: [Theory]
tags: [theory, EHC, actor-corruption]
pin: true
math: true
mermaid: true
date: 2025-09-12 00:00:00
---

No glitch in _Twilight Princess_ has been hunted more than Early Hyrule Castle. If found, a way to get
into Hyrule Castle early could potentially save an hour or more in the run (depending on how long it takes to
set the glitch up) by allowing us to skip Snowpeak Ruins, Arbiter's Grounds, City in the Sky, Palace of
Twilight, and their associated items. What's more, similar glitches have been found in other Zelda titles
(most recently _The Wind Waker_), driving further speculation that a similar technique could exist in
_Twilight Princess_.

There are a few potential theories for how we could get around the barrier, but one very popular suggestion
is "actor unloading" or "archive corruption". Basically, if you run the game out of memory and then load a
new room, in some cases objects on the new map can get "corrupted" and become unable to be loaded on _any_
map until the console is restarted.

At this point I should mention that there are actually two different forms of Hyrule Castle barrier depending
on the game state. Before the player completes Midna's Desperate Hour, there's a closed door and two guards
blocking Link from entering Hyrule Castle; we call this the "pre-MDH barrier". Afterwards, the guards are
gone, but a giant energy wall similar to _The Wind Waker_'s pushes Link away should he attempt to enter; this
is the "post-MDH barrier".

## No, You Can't Archive Corrupt `Obj_Board`

Most actor unloading theories target the pre-MDH barrier. The guards are not actually what blocks Link from
opening the doors; instead, an invisible wall has been placed over the door handles, and even if Link clips
through the guards (which may be possible), he still can't open the door. At first glance, this wall seems
like a great target for actor unloading. The same actor (`Obj_Board`) exists on the Lakebed Temple map (among
other places), and Lakebed has the necessary prerequisites for achieving archive corruption.

So, this version of Early Hyrule Castle would go something like this:

* get the fishing rod from Ordon Village at the start of the game
* get to Lakebed Temple as quickly as possible
* use fishing rod duplication to exhaust memory in one of the Lakebed side wings
* enter Lakebed Temple's main room while in this low-memory state to cause `Obj_Board` to fail to load correctly
* exit Lakebed Temple, go to North Castle Town
* open the door!

There's a problem with this approach, though. It's not possible to unload `Obj_Board` via archive corruption. To
understand why, we have to learn how archive corruption actually works. As far as I'm aware, this has not
previously been explained or documented.

_An enormous shout-out here to Taka and the rest of the Twilight Princess Decompilation team, without whom this
analysis would not have been possible._

It all starts with `dRes_control_c`, the Resource Control structure. This class is a singleton that's responsible
for loading "archives", self-contained blocks of code and data that can be swapped in and out at runtime to manage
the GameCube's limited memory space. Here's a cut-down and annotated prototype:

```c++
class dRes_control_c {
public:
    /// Prepares to load an archive from disk into the archive heap, if not already loaded.
    static int setRes(char const* arcName, dRes_info_c* pInfo, int infoSize,
        char const* arcPath, u8 param_4, JKRHeap* pHeap);

    /// Moves archive data from the archive heap into its final in-memory layout, and runs
    /// other initialization steps as required.
    static int syncRes(char const* arcName, dRes_info_c* pInfo, int infoSize);

    /// Releases a previously-loaded archive.
    static int deleteRes(char const* arcName, dRes_info_c* pInfo, int infoSize);

    /// Finds an archive by name, if it's already loaded.
    static dRes_info_c* getResInfo(char const* getResInfo, dRes_info_c* pInfo, int infoSize);

    /// Allocates a new `dRes_info_c` in an empty actor slot.
    static dRes_info_c* newResInfo(dRes_info_c* pResInfo, int infoSize);

    /// Helper function to load an object resource into `mObjectInfo`.
    /// (The full `dRes_control_c` class also handles loading other types of resources, so there
    /// are more `dRes_info_c` lists than just `mObjectInfo`.)
    int setObjectRes(const char* name, u8 param_1, JKRHeap* heap) {
        return setRes(name, &mObjectInfo[0], ARRAY_SIZE(mObjectInfo), "/res/Object/", param_1,
                      heap);
    }

    /// ...and for the other operations...
    int syncObjectRes(const char* name) {
        return syncRes(name, &mObjectInfo[0], ARRAY_SIZE(mObjectInfo));
    }

    int deleteObjectRes(const char* name) {
        return deleteRes(name, &mObjectInfo[0], ARRAY_SIZE(mObjectInfo));
    }

    dRes_info_c* getObjectResInfo(const char* arcName) {
        return getResInfo(arcName, &mObjectInfo[0], ARRAY_SIZE(mObjectInfo));
    }

    /// 128 reference-counted "actor slots" for object archives.
    dRes_info_c mObjectInfo[0x80];
};
```

The overall archive load procedure goes something like this:

* First, `dRes_control_c::setRes` is called (via `setObjectRes`) to start loading the archive. This creates a
  request for the disc thread to start loading the raw archive data from disc.
* Once that disc load completes, `dRes_control_c::syncRes` is called (via `syncObjectRes`) to take that raw
  data and place it correctly in memory.
* The archive is now loaded. Future attempts to load the archive will short-circuit and only increment the
  archive's reference count.
* Once enough `dRes_control_c::deleteRes` calls have been made to return the reference count to zero, the archive
  will be deallocated and the actor slot will be released.

To better understand how these steps work, let's next look at `dRes_info_c`.

```c++
class dRes_info_c {
public:
    dRes_info_c();
    ~dRes_info_c();

    /// Begins loading this archive from disc by setting `mDMCommand`, and sets our
    /// `mArchiveName` to `pArcName` once the disc read command is created. Returns
    /// 0 if creating the disc read command fails and 1 otherwise.
    int set(char const* pArcName, char const* pArcPath, u8 param_2, JKRHeap* pHeap);

    /// Loads archive files from the raw archive data in `mArchive` into game memory.
    int loadResource();

    /// Called repeatedly until disc load is complete; eventually leads to `loadResource`.
    int setRes();

    void* getRes(u32 resIdx) { return *(mRes + resIdx); }
    int getCount() { return mCount; }
    char* getArchiveName() { return mArchiveName; }
    mDoDvdThd_mountArchive_c* getDMCommand() { return mDMCommand; }
    JKRArchive* getArchive() { return mArchive; }
    void incCount() { mCount++; }
    u16 decCount() { return --mCount; }

private:
    /// Name of this archive slot.
    char mArchiveName[11];

    /// Reference count.
    u16 mCount;

    /// Pointer to disc read command (NULL if disk read complete or not started).
    mDoDvdThd_mountArchive_c* mDMCommand;

    /// Pointer to raw archive data, if present.
    JKRArchive* mArchive;

    /// Sub-heap for unpacked data.
    JKRSolidHeap* mDataHeap;

    /// Pointers to individual archive files.
    void** mRes;
};
```

This small structure is one "actor slot". It contains the name of the archive, the reference count, a pointer to
the disk read request (if necessary), a pointer to the archive data, two sub-heap pointers, and a list of pointers
to the individual archive files.

Overall, the actor list in `dRes_control_c` implements a rudimentary form of dynamic allocation. A slot is allocated
if its `mCount` is non-zero, and it can be looked up by its `mArchiveName`:

```c++
dRes_info_c* dRes_control_c::getResInfo(char const* pArcName, dRes_info_c* pResInfo, int infoSize) {
    for (int i = 0; i < infoSize; i++) {
        if (pResInfo->getCount() != 0) {
            if (!stricmp(pArcName, pResInfo->getArchiveName())) {
                return pResInfo;
            }
        }
        pResInfo++;
    }
    return NULL;
}
```

This seems a bit inefficient (lots of `stricmp`!) but it's simple and it works. Similarly, allocating a new `dRes_info_c`
is done simply by finding an empty slot:

```c++
dRes_info_c* dRes_control_c::newResInfo(dRes_info_c* pResInfo, int infoSize) {
    for (int i = 0; i < infoSize; i++) {
        if (pResInfo->getCount() == 0) {
            return pResInfo;
        }
        pResInfo++;
    }
    return NULL;
}
```

And now we can look at the implementation of `setRes`, the entry point to this whole load sequence:

```c++
int dRes_control_c::setRes(char const* arcName, dRes_info_c* pInfo, int infoSize,
                           char const* arcPath, u8 param_4, JKRHeap* pHeap) {
    dRes_info_c* resInfo = getResInfo(arcName, pInfo, infoSize);

    if (resInfo == NULL) {
        resInfo = newResInfo(pInfo, infoSize);

        if (resInfo == NULL) {
            // ...
            resInfo->~dRes_info_c();
            return 0;
        }

        int resStatus = resInfo->set(arcName, arcPath, param_4, pHeap);
        if (resStatus == 0) {
            OSReport_Error("<%s.arc> dRes_control_c::setRes: res info set error !!\n", arcName);
            resInfo->~dRes_info_c();
            return 0;
        }
    }
    resInfo->incCount();
    return 1;
}
```

`setRes` begins by checking if the archive has already been loaded via `getResInfo`. If so, it only increments its
reference count and returns. If not, it grabs an empty slot with `newResInfo`, starts the disc load with `dRes_info_c::set`,
and only then increments the reference count.

It's important to note here that any failures at this stage result in clearing the `dRes_info_c` with its destructor,
returning immediately, and not incrementing the slot's reference count. The practical consequence of this is that if a
failure occurs during `setRes`, the actor slot will not be modified and the same archive will attempt to load again at
the next opportunity.

> _Edit: Or attempts to clear the `dRes_info_c`, anyways? I think the `resInfo == NULL` branch would crash._

Once the disc load is set up, though, this actor slot is taken. Future calls to `setRes` will only increment its reference
count, even if they come in before the load completes.

When the load completes, we move on to `dRes_control_c::syncRes`:

```c++
int dRes_control_c::syncRes(char const* arcName, dRes_info_c* pInfo, int infoSize) {
    dRes_info_c* resInfo = getResInfo(arcName, pInfo, infoSize);

    if (resInfo == NULL) {
        return -1;
    } else {
        return resInfo->setRes();
    }
}
```

This one doesn't do much on its own, so let's check out `dRes_info_c::setRes` (yes, I know these names are baffling.
`dRes_control_c::setRes` calls `dRes_info_c::set` and `dRes_control_c::syncRes` calls `dRes_info_c::setRes`. I didn't
come up with these.)

```c++
int dRes_info_c::setRes() {
    if (mArchive == NULL) {
        if (mDMCommand == NULL) {
            return -1;
        }
        if ((int)mDMCommand->mIsDone == 0) {
            return 1;
        }

        mArchive = mDMCommand->getArchive();

        delete mDMCommand;
        mDMCommand = NULL;

        if (mArchive == NULL) {
            OSReport_Error("<%s.arc> setRes: archive mount error !!\n", mArchiveName);
            return -1;
        }

        mDataHeap = mDoExt_createSolidHeapFromGameToCurrent(0, 0);
        if (mDataHeap == NULL) {
            OSReport_Error("<%s.arc> mDMCommandsetRes: can't alloc memory\n", mArchiveName);
            return -1;
        }

        int rt = loadResource();
        mDoExt_restoreCurrentHeap();
        mDoExt_adjustSolidHeap(mDataHeap);

        if (rt < 0) {
            return -1;
        }
    }
    return 0;
}
```

This is also cut down a bit, but the general structure is here. There are a few important paths we can take
through this function:

* If `mArchive` is NULL and `mDMCommand` is also NULL, we immediately return with an error. To my understanding,
  this branch is **not possible** to reach in the course of ordinary game execution. I mention it here because
  this is what happens if you set `mCount` from `0` to `1` by editing game memory, which is a common method other
  glitch hunters have used for investigating the possible effects of archive corruption.
* If `mDMCommand->mIsDone` is zero, we return `1`, which instructs the game engine to check again later -- this is
  just how we wait until the disc read completes.
* If the disc read failed, we return an error. In practice, this doesn't happen -- it may be what happens if you
  interfere with the physical operation of the disc drive or _maybe_ if the archive heap is full (but I think that
  ends up crashing).
* If allocating memory for our archive data doesn't work, we return an error. In practice, this also doesn't happen,
  since what we're actually doing here is allocating _the entire free space_ as a sub-heap, and then we later shrink
  the allocation via `mDoExt_adjustSolidHeap`, so the only way `mDoExt_createSolidHeapFromGameToCurrent` would fail
  is if there's literally zero free memory.
* Finally, we call `loadResource` to handle taking the various archive files from `mArchive` and placing them in
  game memory. If `loadResource` fails, we return an error (after restoring heap state), and otherwise we've
  finished loading and return success.

So, out of all the error paths in this function, only the "`loadResource` fails" one will ever be taken in practice.
But what happens when it is? Well, something very interesting:

* The immediate effect is that the load fails. The actor cannot be created on the current map, and it'll end up in
  state `cPhs_ERROR_e` (I must admit at this point that I don't fully understand how the load phase logic in
  `d_com_inf_game.cpp` works, so this is a bit handwavey). This also produces the infamous `Sync Read Error !!`
  debug message.
* This means that the archive will not be deallocated when the current map is unloaded, since that only happens if
  it's in state `cPhs_NEXT_e`.
* Therefore, the reference count on our `dRes_info_c` will not be decremented, so the actor slot will not be deallocated
  and any future attempts to load the same archive will essentially continue where we left off by calling `dRes_info_c::setRes`
  again.
* In that future `dRes_info_c::setRes` call, `mArchive` will be non-null, so we _immediately return success_.

See the problem? `loadResource` failed, so it didn't load all of our data files, but the future attempt to load the same
archive looks like it's completely successful. This means that we can load the actor without, say, its 3D model, texture,
or collision map, and essentially remove it from gameplay. This effect is what we refer to as "archive corruption".

So, what does it take to cause `loadResource` to fail? Well, that's kinda complicated. `loadResource` is a very long function
and I'm not going to reproduce it here, but, generally speaking, what it does is it goes through each file in the archive,
attempts to load it using a file-type-specific method, and returns `-1` if that load fails, skipping that load and any files
after it in the archive.

There are a couple pitfalls here if you want to cause `loadResource` failures on purpose. First, some archive files will cause
the game to crash if they fail to load, so you need to make sure `loadResource` starts failing after all of those files have
been loaded. Second, and most importantly for this case, not all resource types can fail to load.

Let's look at the files in `Obj_Board`'s archive:

```txt
Folder:archive/dzb/
Folder:archive/./
Folder:archive/../
03:archive/dzb/clearb00.dzb
04:archive/dzb/clearb01.dzb
05:archive/dzb/clearb02.dzb
06:archive/dzb/clearb03.dzb
07:archive/dzb/clearb04.dzb
Folder:archive/dzb/./
Folder:archive/dzb/../
```

There are only five files, all of type `DZB `. I believe these represent the collision map. Let's see what `loadResource` does
to load these:

```c++
else if (nodeType == 'DZB ') {
    result = cBgS::ConvDzb(result);

    // wot, no `if(result == NULL) { return -1; }`?
}
```

We aren't missing an error-handling branch here... no, something far worse is happening: `cBgS::ConvDzb` **cannot fail.**
This means that there's no way to get `loadResource` to fail while loading `Obj_Board`, so there's no way to get `dRes_info_c::setRes`
to return `-1` while setting `mArchive`, so you don't get archive corruption, so you don't get Early Hyrule Castle.

## No, You Can't Archive Corrupt `V_CTGWall`

The reason you can't do the same thing for the post-MDH barrier, which has quite a lot of texture data and 3D models and other stuff
that `loadResource` can fail on, is much simpler: it doesn't exist anywhere else! Achieving archive corruption requires the ability
to go across a room transition and cause the targeted actor to load, and there's no room transition that loads `V_CTGWall`.

(The version of the post-MDH barrier visible from Hyrule Field is a different actor, `y_gwall`. It may be possible to archive
corrupt it, but doing so will not affect anything in North Castle Town.)

## No, You Can't Prevent `V_CTGWall` From Loading Directly Either

Of course, archive corruption isn't completely necessary. In theory, if we could fill game memory in a way that would persist across
loading zones (there are a couple ways it might be possible to do this), we could load North Castle Town and just not have enough memory
to load `V_CTGWall` in the first place, and then whether we get the actor slot stuck is irrelevant -- the barrier is gone.

Unfortunately, this _also_ doesn't work. I wrote a simple game modification to log each actor load in order and the relevant amount of
game memory required to load it, and this is what we get while crossing over into North Castle Town:

![TP Actor Load Order](/assets/theory/cant-unload-barrier/actor-load-order.jpg)

So, we just make sure that the 11072-byte allocation required for `V_CTGWall` fails, and then we're good, right?
Well, causing that allocation to fail does in fact result in Early Hyrule Castle. There's a problem, though, which is that we can't
cause *just* that allocation to fail, since if we do it via heap exhaustion any allocation that's bigger and later than the
targeted allocation must also fail... and one of those allocations is for `Midna.arc`.

If `Midna.arc` fails to load, the game immediately crashes, and you have no choice other than to restart the console.

Oh, and of course the same thing would happen if you try to prevent `Obj_Board` from loading in the same way, except you also
have the trouble of filling game heap to the point where not even a 64-byte allocation can succeed.

## Future Directions

Obviously a better understanding of archive corruption is useful. I believe we now have a new bound on which actors
can be unloaded by archive corruption: not only do the previously known prerequisites need to apply, the actor's archive
must also contain files of types other than `ARC `, `DZB `, and `KCL `. Also, the common technique of setting `mCount` to
1 on an empty actor slot to simulate the effects of archive corruption may be inaccurate, since it doesn't require that
such a file exists and it doesn't represent the potential effects of the partial `loadResource` run.

It may be worth investigating further if archive corruption can be used for skips other than Early Hyrule Castle. The
Arbiter's Grounds gate is a particular target of interest, although we don't currently have any way of causing heap exhaustion
in Arbiter's Grounds.

It also may be worth investigating the potential effects of rolling over an actor slot's reference count by attempting to
load it 65,536 times. Since the resource manager code relies on `dRes_info_c`'s destructor to clear the fields in an empty
actor slot, this could result in loading the wrong actor data once that slot is allocated again, which could be interesting.

There are also still potential open paths to Early Hyrule Castle:
* We could find some kind of wrong-warp. Being able to load the Hyrule Castle map directly, or load North Castle Town in
  state 3, or enter the North Castle Town map from entrances other than the Castle Town Center one would all get us in.
* We could find a way to clip through the pre-MDH doors or post-MDH barrier. This has also been well-studied, and the
  current consensus is it's not possible without a way to bypass the Castle Town item restrictions (and maybe not even then).
* We could find a way to manipulate story flags and set the flag for completing Palace of Twilight without completing the dungeon.
* We could find a way to achieve arbitrary code execution.

None of these approaches currently has any promising leads.
