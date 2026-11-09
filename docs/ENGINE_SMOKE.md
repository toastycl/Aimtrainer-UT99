# Engine smoke evidence

OldUnreal 469e, Linux amd64 dedicated engine; this does not render a client or test real mouse input. Reproduce with `python scripts/smoke.py --ut-root /path/to/UT`.

```text
PASS room marker exists
PASS player fits inside map
PASS round starts with three targets
PASS emissions counted: Shock Rifle
PASS real weapon hits target: Shock Rifle
PASS accuracy bounded: Shock Rifle
PASS round starts with three targets
PASS emissions counted: Sniper Rifle
PASS real weapon hits target: Sniper Rifle
PASS accuracy bounded: Sniper Rifle
PASS round starts with three targets
PASS emissions counted: Minigun
PASS real weapon hits target: Minigun
PASS accuracy bounded: Minigun
PASS round starts with three targets
PASS emissions counted: Pulse Gun
PASS real weapon hits target: Pulse Gun
PASS accuracy bounded: Pulse Gun
PASS round starts with three targets
PASS emissions counted: Rocket Launcher
PASS real weapon hits target: Rocket Launcher
PASS accuracy bounded: Rocket Launcher
PASS round starts with three targets
PASS emissions counted: Flak Cannon
PASS real weapon hits target: Flak Cannon
PASS accuracy bounded: Flak Cannon
PASS one emission can hit multiple targets only once
PASS moving exercise changes target position
PASS restart clears counters
PASS old-round projectile cannot score
PASS timed round ends automatically
PASS no emissions after finish
DONE failures=0
```

The synthetic test pawn has no live Player connection. Stock TournamentWeapon.ClientFire therefore emits Accessed None Player warnings in this harness. The game-logic assertions passed, but these checks are not a claim of a warning-free rendered client. No local network identifiers or personal logs are included in this evidence.
