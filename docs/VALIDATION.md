# Validation — development build 0.4.0

| Check | Status |
| --- | --- |
| Python tools/protocol/input/encoding tests | 22 passing |
| UnrealScript, both packages | 0 errors, 0 warnings |
| Real training map rebuild | PASS, six polygons |
| Local primary / secondary | 11 + 11 native cases passing |
| IGPlus primary / secondary | 11 + 11 native cases passing |
| Infinite client ammo in IGPlus | PASS for ammo-bearing weapons |
| In-game menu → helper → IGPlus round → result → fresh-fire return | PASS, real 30-second round |
| Server pause/resume while setup is open | PASS |
| Added latency endpoints 0 / 300 ms | PASS with actual client/server; native game ping recorded separately |
| Standalone viewport/UWindow regression | 26 assertions passing |
| Dedicated-engine regression | 52 assertions passing |
| Local beam CSV export | PASS; beam contact independent of projectile accuracy |
| Packaged installation bootstrap | See DELIVERY_CHECK.md |
| Physical mouse, visual and Windows acceptance | Pending on tester's actual client |
| Native macOS helper discovery | Pending; `.app` discovery not implemented |
| Exact live-server profile, human hitboxes and ACE | Pending, no certification or deployment |

Evidence: [weapon matrix and network flow](INTEGRATION_SMOKE.md), [standalone callbacks](CLIENT_SMOKE.md), [dedicated checks](ENGINE_SMOKE.md).

Toolchain/runtime: OldUnreal 469e Linux amd64, SDL offscreen/Mesa llvmpipe. Tests exercise real rendering viewports, UWindow callbacks, weapon implementations and actual UDP-delayed client/server traffic. They do not use physical mouse clicks or certify hardware latency. Selected near-target fixtures make scoring tests controlled; they are disabled in ordinary play.

IGPlus 11 player behavior is retained through UTPure; weapon/projectile adapters derive from its normal-weapon implementations and delegate to Super. Tests used the normal `WeaponSettingsOldNet` profile. The targets are simple controlled Pawn collision cylinders, not equivalent to replicated human IGPlus players. Exact server/client configuration matters for comparisons.

Original game assets/toolchain and official IGPlus packages remain separate local dependencies. The local exporter handles local RESULT records, including beam contact. NETRESULT CSV/history import remains pending. Older proof documents are historical; the current build has in-game selection and network rounds.
