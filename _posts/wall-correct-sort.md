---
layout: post
title: Wall Collisions and Correction
description: A reference for how collider positions are resolved with wall polygons
author: qwertyquerty
categories: [Reference]
tags: [reference, mechanic-collision]
pin: true
math: true
mermaid: true
date: 2026-02-18 00:00:00
---

## Annotated C++ Code for `dBgW::WallCorrectSort`

Annotated from decomp, original found [here](https://github.com/zeldaret/tp/blob/main/src/d/d_bg_w.cpp)

```c++
bool dBgW::WallCorrectSort(dBgS_Acch* collider) {
    l_start = NULL;
    l_wcsbuf_num = 0;

    WallCorrectGrpRpSort(collider, m_rootGrpIdx, 1);

    bool corrected = false;

    wcs_data* data = l_start;

    // Iterate through wall polys
    while (true) {
        if (data == NULL) {
            break;
        }

        int poly_index = data->poly_idx;

        cBgW_TriElm* tri = &pm_tri[poly_index];

        // Calculate the length of the normal vector of the wall on the XZ plane, will be 1 unless the wall is vertically slanted
        f32 wallNormalXZLength = JMAFastSqrt(tri->m_plane.GetNP()->x * tri->m_plane.GetNP()->x + tri->m_plane.GetNP()->z * tri->m_plane.GetNP()->z);
        // Also 1 unless the wall is vertically slanted
        f32 wallSlant = 1.0f / wallNormalXZLength;

        cBgD_Tri_t* tri_data = &pm_bgd->m_t_tbl[poly_index];

        // Iterate through collider circles
        int circleIndex = 0;
        while (circleIndex < collider->GetTblSize()) {
            // Calculate the length of the wall pusher
            f32 wallPusherLength = wallSlant * collider->GetWallR(circleIndex);

            // Calculate the offset of the wall pusher from the wall itself
            Vec wallPusherOffset;
            wallPusherOffset.x = wallPusherLength * tri->m_plane.GetNP()->x;
            wallPusherOffset.y = 0.0f;
            wallPusherOffset.z = wallPusherLength * tri->m_plane.GetNP()->z;

            // Calculate the circle's y height at the point of collision
            f32 collisionYHeight;
            if (!collider->ChkWallHDirect(circleIndex)) {
                collisionYHeight = (collider->GetWallAddY(wallPusherOffset) + (collider->GetPos()->y + collider->GetWallH(circleIndex))) - collider->GetSpeedY();
            } else {
                collisionYHeight = collider->GetWallHDirect(circleIndex);
            }

            // Calculate the triangles y coordinates in relation to the XZ plane at the circle's y height
            f32 triangleYOffset[3];
            triangleYOffset[0] = pm_vtx_tbl[tri_data->m_vtx_idx0].y - collisionYHeight;
            triangleYOffset[1] = pm_vtx_tbl[tri_data->m_vtx_idx1].y - collisionYHeight;
            triangleYOffset[2] = pm_vtx_tbl[tri_data->m_vtx_idx2].y - collisionYHeight;

            if ( // Plane triangle intersection, does the plane of this current circle intersect with the triangle ever? If so, do collision checks on it!
                (!(triangleYOffset[0] > 0.0f) || !(triangleYOffset[1] > 0.0f) || !(triangleYOffset[2] > 0.0f)) &&
                (!(triangleYOffset[0] < 0.0f) || !(triangleYOffset[1] < 0.0f) || !(triangleYOffset[2] < 0.0f))
            )
            {
                // Count the number of triangle points intersect the circle plane
                int triangleVertPlaneIntersectionCount = 0;
                if (cM3d_IsZero(triangleYOffset[0])) {
                    triangleVertPlaneIntersectionCount++;
                }
                if (cM3d_IsZero(triangleYOffset[1])) {
                    triangleVertPlaneIntersectionCount++;
                }
                if (cM3d_IsZero(triangleYOffset[2])) {
                    triangleVertPlaneIntersectionCount++;
                }

                int triangleVertA, triangleVertB, triangleVertC;
                // If exactly one triangle point intersects the plane of the circle, the segment length would be 0 so we can skip collision checking at this y height
                if (triangleVertPlaneIntersectionCount != 1) {
                    // Figure out the order of the triangle points, so we can find the orientation of the triangle and find the two segments of the triangle the plane intersects
                    if (
                        (triangleYOffset[0] > 0.0f && (triangleYOffset[1] <= 0.0f) && (triangleYOffset[2] <= 0.0f)) ||
                        (triangleYOffset[0] < 0.0f && (triangleYOffset[1] >= 0.0f) && (triangleYOffset[2] >= 0.0f)))
                    {
                        triangleVertA = 0;
                        triangleVertB = 1;
                        triangleVertC = 2;
                    } else if (
                        (triangleYOffset[1] > 0.0f && (triangleYOffset[0] <= 0.0f) && (triangleYOffset[2] <= 0.0f)) ||
                        (triangleYOffset[1] < 0.0f && (triangleYOffset[0] >= 0.0f) && (triangleYOffset[2] >= 0.0f)))
                    {
                        triangleVertA = 1;
                        triangleVertB = 0;
                        triangleVertC = 2;
                    } else {
                        triangleVertA = 2;
                        triangleVertB = 0;
                        triangleVertC = 1;
                    }

                    // Calculate the length of those two segments
                    f32 triangleSegABLen = triangleYOffset[triangleVertA] - triangleYOffset[triangleVertB];
                    f32 triangleSegACLen = triangleYOffset[triangleVertA] - triangleYOffset[triangleVertC];

                    // If either segments are zero length, ignore
                    if (!cM3d_IsZero(triangleSegABLen) && !cM3d_IsZero(triangleSegACLen)) {
                        f32 triangleSegABNormal = -triangleYOffset[triangleVertB] / triangleSegABLen;
                        f32 triangleSegACNormal = -triangleYOffset[triangleVertC] / triangleSegACLen;

                        // Get the absolute positions of each triangle vertex
                        f32 vtxAX = pm_vtx_tbl[tri_data->m_vtx_idx0].x;
                        f32 vtxAZ = pm_vtx_tbl[tri_data->m_vtx_idx0].z;
                        f32 vtxBX = pm_vtx_tbl[tri_data->m_vtx_idx1].x;
                        f32 vtxBZ = pm_vtx_tbl[tri_data->m_vtx_idx1].z;
                        f32 vtxCX = pm_vtx_tbl[tri_data->m_vtx_idx2].x;
                        f32 vtxCZ = pm_vtx_tbl[tri_data->m_vtx_idx2].z;

                        f32 wallPusherSegmentX0, wallPusherSegmentY0, wallPusherSegmentX1, wallPusherSegmentY1;

                        // Calculate the wall pusher segment, first find the line of intersection with the circle plane and the triangle
                        // (we use the previously identified triangle orientation again here)
                        if (triangleVertA == 0) {
                            wallPusherSegmentX0 = vtxBX + triangleSegABNormal * (vtxAX - vtxBX);
                            wallPusherSegmentY0 = vtxBZ + triangleSegABNormal * (vtxAZ - vtxBZ);
                            wallPusherSegmentX1 = vtxCX + triangleSegACNormal * (vtxAX - vtxCX);
                            wallPusherSegmentY1 = vtxCZ + triangleSegACNormal * (vtxAZ - vtxCZ);
                        } else if (triangleVertA == 1) {
                            wallPusherSegmentX0 = vtxAX + triangleSegABNormal * (vtxBX - vtxAX);
                            wallPusherSegmentY0 = vtxAZ + triangleSegABNormal * (vtxBZ - vtxAZ);
                            wallPusherSegmentX1 = vtxCX + triangleSegACNormal * (vtxBX - vtxCX);
                            wallPusherSegmentY1 = vtxCZ + triangleSegACNormal * (vtxBZ - vtxCZ);
                        } else {
                            wallPusherSegmentX0 = vtxAX + triangleSegABNormal * (vtxCX - vtxAX);
                            wallPusherSegmentY0 = vtxAZ + triangleSegABNormal * (vtxCZ - vtxAZ);
                            wallPusherSegmentX1 = vtxBX + triangleSegACNormal * (vtxCX - vtxBX);
                            wallPusherSegmentY1 = vtxBZ + triangleSegACNormal * (vtxCZ - vtxBZ);
                        }

                        // Offset the wall pusher from the wall, normal to the wall, by the length of the circle radius
                        wallPusherSegmentX0 += wallPusherOffset.x;
                        wallPusherSegmentY0 += wallPusherOffset.z;
                        wallPusherSegmentX1 += wallPusherOffset.x;
                        wallPusherSegmentY1 += wallPusherOffset.z;

                        // Calculate the nearest point on the wall pusher segment to the circle center
                        f32 colliderDistanceToWallPusherSquared, wallPusherNearestPointX, wallPusherNearestPointZ;
                        bool colliderPerpendicularToWall = cM3d_Len2dSqPntAndSegLine(
                            collider->GetCx(), collider->GetCz(), wallPusherSegmentX0, wallPusherSegmentY0, wallPusherSegmentX1, wallPusherSegmentY1,
                            &wallPusherNearestPointX, &wallPusherNearestPointZ, &colliderDistanceToWallPusherSquared
                        );

                        // Calculate the XZ offset to that nearest point from the circle center
                        f32 circleOffsetFromWallPusherX = wallPusherNearestPointX - collider->GetCx();
                        f32 circleOffsetFromWallPusherZ = wallPusherNearestPointZ - collider->GetCz();
                        
                        f32 circleRadiusSquared = collider->GetWallRR(circleIndex);

                        if (
                            // Checks that the collider isn't too far from the wall pusher segment to collide
                            !(colliderDistanceToWallPusherSquared > circleRadiusSquared) &&
                            // Checks that the collider isn't on the other side of the wall
                            !(circleOffsetFromWallPusherX * wallPusherOffset.x + circleOffsetFromWallPusherZ * wallPusherOffset.z < 0.0f)
                        ) {
                            if (colliderPerpendicularToWall) {
                                // The collider is perpendicular to the wall (not on one of the corners) so we push the collider out normal to the wall
                                positionWallCorrect(collider, wallSlant, tri->m_plane, collider->GetPos(), JMAFastSqrt(colliderDistanceToWallPusherSquared));
                                collider->CalcMovePosWork();
                                collider->SetWallCirHit(circleIndex);
                                collider->SetWallPolyIndex(circleIndex, poly_index);
                                collider->SetWallAngleY(circleIndex, cM_atan2s(tri->m_plane.GetNP()->x, tri->m_plane.GetNP()->z));
                                corrected = true;
                            } else {
                                // The collider is along one of the ends of the segment, the corners of the wall
                                wallPusherSegmentX0 -= wallPusherOffset.x;
                                wallPusherSegmentY0 -= wallPusherOffset.z;
                                wallPusherSegmentX1 -= wallPusherOffset.x;
                                wallPusherSegmentY1 -= wallPusherOffset.z;

                                JUT_ASSERT(0, collider->GetPos()->x == collider->GetWallCirP(circleIndex)->GetCx());
                                JUT_ASSERT(0, collider->GetPos()->z == collider->GetWallCirP(circleIndex)->GetCy());

                                // Find the collider distance to each corner so we can see which one we are closer to
                                f32 circleDistanceToPusherSegmentStartSquared = cM3d_Len2dSq(
                                    wallPusherSegmentX0, wallPusherSegmentY0, collider->GetPos()->x, collider->GetPos()->z
                                );

                                f32 circleDistanceToPusherSegmentEndSquared = cM3d_Len2dSq(
                                    wallPusherSegmentX1, wallPusherSegmentY1, collider->GetPos()->x, collider->GetPos()->z
                                );

                                // Calculate negative normals of the wall
                                f32 negWallNormalX = -tri->m_plane.GetNP()->x;
                                f32 negWallNormalY = -tri->m_plane.GetNP()->z;

                                JUT_ASSERT(0, !(cM3d_IsZero(negWallNormalX) && cM3d_IsZero(negWallNormalY)));

                                if (circleDistanceToPusherSegmentStartSquared < circleDistanceToPusherSegmentEndSquared) {
                                    // We are closer to the start of the segment, correct based on that
                                    if (!(circleDistanceToPusherSegmentStartSquared > circleRadiusSquared) && !(fabsf(circleDistanceToPusherSegmentStartSquared - circleRadiusSquared) < 0.008f)) {
                                        JUT_ASSERT(0, !isnan(wallPusherSegmentX0));
                                        JUT_ASSERT(0, !isnan(wallPusherSegmentY0));

                                        // Draws a line starting at the edge of the wall pusher, towards the wall, until it intersects with the collider circle
                                        f32 circleLineCollisionX, circleLineCollisionY;
                                        cM2d_CrossCirLin(
                                            *collider->GetWallCirP(circleIndex), wallPusherSegmentX0, wallPusherSegmentY0, negWallNormalX, negWallNormalY,
                                            &circleLineCollisionX, &circleLineCollisionY
                                        );
                                        
                                        // Move the collider circle so it doesn't interesect with the wall pusher corner anymore
                                        collider->GetPos()->x += wallPusherSegmentX0 - circleLineCollisionX;
                                        collider->GetPos()->z += wallPusherSegmentY0 - circleLineCollisionY;

                                        JUT_ASSERT(0, !isnan(collider->GetPos()->x));
                                        JUT_ASSERT(0, !isnan(collider->GetPos()->z));

                                        collider->CalcMovePosWork();
                                        collider->SetWallCirHit(circleIndex);
                                        collider->SetWallPolyIndex(circleIndex, poly_index);
                                        collider->SetWallAngleY(circleIndex, cM_atan2s(tri->m_plane.GetNP()->x, tri->m_plane.GetNP()->z));
                                        corrected = true;
                                        collider->SetWallHit();
                                    }
                                } else if (!(circleDistanceToPusherSegmentEndSquared > circleRadiusSquared) && !(fabsf(circleDistanceToPusherSegmentEndSquared - circleRadiusSquared) < 0.008f)) {
                                    // We are closer to the end of the segment, correct based on that
                                    JUT_ASSERT(0, !isnan(wallPusherSegmentX1));
                                    JUT_ASSERT(0, !isnan(wallPusherSegmentY1));

                                    // Draws a line starting at the edge of the wall pusher, towards the wall, until it intersects with the collider circle
                                    f32 circleLineCollisionX, circleLineCollisionZ;
                                    cM2d_CrossCirLin(
                                        *collider->GetWallCirP(circleIndex), wallPusherSegmentX1, wallPusherSegmentY1, negWallNormalX, negWallNormalY,
                                        &circleLineCollisionX, &circleLineCollisionZ
                                    );

                                    // Move the collider circle so it doesn't interesect with the wall pusher corner anymore
                                    collider->GetPos()->x += wallPusherSegmentX1 - circleLineCollisionX;
                                    collider->GetPos()->z += wallPusherSegmentY1 - circleLineCollisionZ;

                                    JUT_ASSERT(0, !isnan(collider->GetPos()->x));
                                    JUT_ASSERT(0, !isnan(collider->GetPos()->z));

                                    collider->CalcMovePosWork();
                                    collider->SetWallCirHit(circleIndex);
                                    collider->SetWallPolyIndex(circleIndex, poly_index);
                                    collider->SetWallAngleY(circleIndex, cM_atan2s(tri->m_plane.GetNP()->x, tri->m_plane.GetNP()->z));

                                    corrected = true;

                                    collider->SetWallHit();
                                }
                            }
                        }
                    }
                }
            }

            circleIndex++;
        }

        data = data->next;
    }

    return corrected;
}
```
