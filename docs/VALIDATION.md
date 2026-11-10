# Validation — standalone development build 0.4.1

| Check | Result |
| --- | --- |
| Active developer Python tests | 14 passing |
| UnrealScript standalone package | 0 errors, 0 warnings |
| Real training map rebuild | PASS, six polygons |
| Native viewport/UWindow regression | 26 assertions passing |
| All eleven weapons, primary / secondary | 11 + 11 native cases passing |
| Dedicated-engine regression | 52 assertions passing |
| Player ZIP contents | Mod, int, map and Spanish instructions only |
| Physical mouse, visual and Windows acceptance | Pending on tester's actual client |

[All-weapon evidence](ARSENAL_SMOKE.md) · [Standalone callbacks](CLIENT_SMOKE.md) · [Dedicated checks](ENGINE_SMOKE.md).

Toolchain: OldUnreal 469e Linux amd64, SDL offscreen/Mesa llvmpipe. Native tests use actual engine viewports, UWindow callbacks and weapon implementations. They do not certify physical input latency or replace manual platform testing. Opt-in arsenal fixtures use controlled target positions and a centered muzzle; ordinary play is unaffected. Projectile scoring and Pulse beam contact remain separate metrics.

IGPlus, ping selection and external helpers are excluded from the active package. Their earlier implementation and validation are historical under experimental/igplus. Original game assets/toolchain are external build dependencies and are not redistributed.
