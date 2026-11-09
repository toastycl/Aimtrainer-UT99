# Validation status — 0.3.0

| Check | Status |
| --- | --- |
| Python tools/geometry/UDP relay | 13 passing |
| UnrealScript + real .unr rebuild | PASS — 0 errors, 0 warnings |
| Dedicated-engine regressions | PASS — 52 assertions; ENGINE_SMOKE.md |
| Real standalone viewport / UWindow callbacks | PASS — 22 assertions; CLIENT_SMOKE.md |
| Selected Sniper + duration across room travel | PASS |
| Random safe player start and target respawn | PASS in real-client regression |
| 30-second automatic end, world result, fresh-fire acknowledgement | PASS |
| IGPlus 11 client/server Shock + Sniper | Separate proof; NETWORK_LAB.md |
| Physical mouse feel / manual visual review | Pending on tester's client |
| Windows/macOS-specific acceptance | Pending |
| Live-server / anticheat compatibility | Pending; no deployment |

Toolchain/client: OldUnreal 469e Linux amd64. The standalone integration used SDL offscreen with Mesa llvmpipe at 1280x720 and a real viewport. It invoked actual UWindow callbacks, not external physical clicks. DM bot/tournament defaults were deliberately enabled and the test confirmed zero combat bots and a living trainee.

Dedicated checks exercise actual weapon hits, infinite ammo, splash/fragment deduplication, old-round isolation and timed completion. Their synthetic pawn lacks a Player connection and can produce stock ClientFire warnings. The real-client integration uses an actual viewport instead.

The network proof uses actual IGPlus 11 classes with normal weapon settings and controlled localhost delay. It is not integrated round scoring, a hardware/input latency benchmark, or certification against the tester's server settings. No ACE test was performed. Original game dependencies and IGPlus binaries are not redistributed.
