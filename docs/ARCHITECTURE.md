# Architecture

The standalone UnrealScript package is named `UTAT`. It does not depend on a community/server brand.

| Class | Responsibility |
| --- | --- |
| UTATGame | Local-only login, lifecycle, target placement, counters and result records |
| UTATPlayer | Commands, temporary mouse settings and restoration |
| UTATStore | Separate profile configuration and last result in UTAT.ini |
| UTATTarget | Controlled actor, stock Soldier mesh, standing-player-sized collision |
| UTATShock | Stock primary trace with shot hook; alternate fire disabled for this protocol |
| UTATHUD | Stock HUD plus lab counters |
| UTATMenuItem / UTATWindow / UTATPanel | Native Mods-menu entry and panel |

Targets are actors, not AI players. They do not reproduce every player hitbox detail or combat behavior. Flick locations use a fixed order without consuming global random state. Strafe position follows session time. There is a 250ms gap between targets.

Sessions snapshot mouse settings, FOV, exercise, duration, map and anchor/yaw. Detected configuration changes or invalid placement cancel the run. The input backend is explicitly unverified. Device settings, frame timing, renderer and network effects are outside this protocol and must be controlled manually.

Each run emits `UTAT: RESULT|version=1|...`. The exporter excludes cancelled rounds, validates counters and separates scenarios/configurations. Time-to-hit includes reaction and aiming; it is not hardware latency. There are no native DLLs, external services, player accounts or automatic deployment. Online login is rejected until replication and server-confirmed metrics are implemented.
