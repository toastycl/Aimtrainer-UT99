# Validation — standalone version 1.0.0

| Check | Result |
| --- | --- |
| Developer Python tests | 16 passing |
| UnrealScript and own room build | 0 errors, 0 warnings |
| Exercise/distance/size matrix | 48 combinations; 199 native geometry/motion/history checks |
| Aerial respawn/scoring, scaled collision and movement bounds | PASS |
| Persistent ten-entry history, beam/partial status, no duplicate finish | PASS |
| Native viewport/UWindow, selection travel and rendered history pages | 36 checks passing |
| Dedicated round/weapon regression | 52 checks passing |
| Eleven weapons × primary/secondary native client checks | 22 cases passing |
| Player ZIP | Mod, int, map and Spanish instructions only |
| Actual mouse, visual fit and Windows/macOS acceptance | Pending on tester's client |

Evidence: [target/history matrix](TRAINING_SMOKE.md), [native UI](CLIENT_SMOKE.md), [round regression](ENGINE_SMOKE.md), [arsenal](ARSENAL_SMOKE.md).

Toolchain: OldUnreal 469e Linux amd64, SDL offscreen/Mesa llvmpipe for viewport tests. Native callbacks, real weapon implementations and actual rendered history frames are exercised. Opt-in geometry fixtures advance a controlled round clock; arsenal fixtures center the muzzle and move a target near the player. They are disabled in ordinary play. These checks do not certify physical input latency, human hitboxes or exact dodge physics. Random aerial/evasive motion is a training pattern.

Projectile/trace accuracy and Pulse beam contact remain separate. History records observed fire input, settings and completion; it does not detect DPI or recommend a best sensitivity. The exporter keeps distance, size and fire style in separate cohorts and still imports older logs. Random start/layout remains a source of trial variation.

IGPlus/ping/helpers remain deferred and excluded from the active package. Original game assets/toolchain remain external and are not distributed. The v1.0.0 package is prepared for manual GitHub Release publication by the maintainer. No live server deployment was performed.
