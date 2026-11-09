# WIP network checks — 2026-11-09 (UTC)

Environment: OldUnreal 469e Linux amd64, real SDL offscreen/Mesa client and separate localhost dedicated server. IGPlus 11 runtime dependencies from the earlier proof. No physical mouse/visual acceptance or Windows/macOS check is claimed.

| Check | Result |
| --- | --- |
| Python tools including free-value input/validation/manifest/launch | 16 passing |
| Script syntax | `python -m compileall -q scripts` passed |
| UTATNetLab build | 0 errors, 0 warnings |
| Shock manual sandbox, 37 ms added RTT | Ready, actual IGPlus classes, 0 automatic hits; stayed open |
| Sniper automated regression, 143 ms added RTT | 1 server-confirmed hit |
| Interactive launcher, typed Shock and 85 | Request manifest and server URL retained 85; actual manual sandbox ready |
| Cancel interactive run | Both owned UDP ports 17777 / 18777 available afterward |

Selected excerpts (personal engine logs are not committed):

```text
NETLAB MANUAL ready added_rtt_ms=37 mean_rpc_rtt_ms=40.344696
NETLAB MANUAL status hits=0 pawn=InstaGibPlus_11.bbTMale2 weapon=InstaGibPlus_11.ST_ShockRifle
NETLAB PASS manual sandbox stays open without automatic firing
NETLAB RESULT hits=1 mean_rpc_rtt_ms=138.400909 pawn=InstaGibPlus_11.bbTMale2 weapon=InstaGibPlus_11.ST_SniperRifle
NETLAB PASS actual IGPlus client fire produced server hit
NETLAB MANUAL ready added_rtt_ms=85 mean_rpc_rtt_ms=81.372574
NETLAB MANUAL status hits=0 pawn=InstaGibPlus_11.bbTMale2 weapon=InstaGibPlus_11.ST_ShockRifle
PASS WIP shutdown released UDP port 17777
PASS WIP shutdown released UDP port 18777
```

RPC values are game-clock estimates and can differ from requested additional delay because of frame/tick timing. The 37 ms test deliberately verifies that manual mode does not auto-aim/fire, rather than treating a lack of hits as a failure. The 143 ms case separately exercises real client weapon firing and server damage. The interactive 85 ms run validates startup/config propagation and cancellation, not human aiming or a completed training round.

[Scope, pending integration and acceptance criteria](WIP_SELECTABLE_PING.md).
