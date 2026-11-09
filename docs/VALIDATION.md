# Validation status — 0.2.1

| Check | Status |
| --- | --- |
| Python tools/geometry tests | 12 passing |
| UnrealScript and real .unr rebuild | PASS — 0 errors, 0 warnings |
| Dedicated-engine regressions | PASS — 52 assertions, 0 failures; ENGINE_SMOKE.md |
| Real standalone viewport / UWindow callbacks | PASS — 13 assertions, 0 failures; CLIENT_SMOKE.md |
| Actual selected 30-second round | PASS — automatic completion and retained results |
| Manual Finish, replay and results after menu close | PASS in the standalone integration test |
| Physical mouse feel / manual visual review | Pending on tester's client |
| Windows/macOS-specific acceptance | Pending |
| Online / anticheat | Not supported |

Toolchain/client: OldUnreal 469e Linux amd64. Client integration used SDL offscreen with Mesa llvmpipe at 1280x720 and a real viewport. It exercised actual UWindow callbacks, not external mouse/keyboard clicks. The test explicitly enabled inherited DM bot/tournament defaults and confirmed zero combat bots and a living trainee.

Dedicated tests verify separate player/target starts, real weapon hits, infinite ammo before/after round updates, hit deduplication, restart isolation and timed completion. The synthetic dedicated pawn still lacks a Player connection and can produce stock ClientFire warnings; the real-client test does not use that synthetic pawn.

Python checks, compiler/map build, engine tests, viewport/control integration and manual hardware/visual acceptance remain distinct checks. Original game dependencies are not redistributed.
