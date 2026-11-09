# Validation status — 0.2.0

| Check | Status |
| --- | --- |
| Python tools tests | 12 passing locally |
| UnrealScript compilation | PASS — final UCC 469e build: 0 errors, 0 warnings |
| Real .unr build from T3D | Passed with 0 errors/warnings; 6 BSP polygons and 1 zone |
| Engine-level map/weapon/session smoke | PASS — 32 assertions, 0 failures; see ENGINE_SMOKE.md |
| Rendered Mods panel and end-of-round UI | Not tested |
| Mouse feel / Windows/macOS/Linux client acceptance | Not tested |
| Online / anticheat | Not supported or tested |

Toolchain: official OldUnreal 469e Linux amd64 UCC. Python checks, compiler/map build, dedicated engine behavior and rendered-client acceptance are separate validations. Original game dependencies remain local and are not redistributed. See TESTING.md for the remaining client checks.

The engine run exercised actual primary weapon emissions/hits for all six weapons, map/player/target placement, strafe motion, repeated-hit deduplication, restart isolation and timed completion. The exporter then read 9 engine sessions into 7 completed groups. The harness produces stock ClientFire warnings because its synthetic pawn has no Player connection; see ENGINE_SMOKE.md. Rendered UI and player input still need manual client acceptance.
