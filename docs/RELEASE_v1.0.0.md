# UT99 Aimtrainer v1.0.0

The first public release of **UT99 Aimtrainer**, a standalone practice-room mod created by **ToastyCL** for the entire Unreal Tournament 99 community.

## Included

- All eleven classic damage weapons, primary and secondary fire, and unlimited ammunition.
- Static, lateral-strafe, evasive and random aerial targets.
- Mixed/close/medium/far distances and small/normal/large targets, with matching collision scaling.
- Random, separated player and target spawn positions.
- 30/60/120-second rounds and free practice, with restart, finish and cancel controls.
- Results displayed over the room; a fresh primary fire returns to setup without adding a shot.
- Persistent history of the last ten rounds, including sensitivity, training conditions, accuracy and eliminations.
- Separate Pulse secondary beam-contact statistics.
- Native setup and About/Credits, plus a simple included training map.

## Install or update

1. Download **UTAT-1.0.0.zip** from this release's Assets. GitHub's automatically generated Source code archives are for development, not installation.
2. Close UT. Extract the ZIP into a test copy of **UT99 469e**, preserving folders.
3. Copy/replace `System/UTAT.u`, `System/UTAT.int` and `Maps/DM-UTAT-Room.unr`.
4. Keep your ini files to preserve your normal settings, optional profiles and existing round history.
5. Open UT normally, then **Mods → UT99 Aimtrainer**. Choose weapon, targets, distance, size and duration, then **Start training**.

Players do not need Python, IGPlus, a compiler or an external launcher/helper. Previous network-experiment launchers are not used.

Quick test: **Sniper → Random aerial → Medium → Normal → 30 seconds**. After results, release fire and press primary fire again, then open **Round history**.

## Validation and scope

Built with OldUnreal 469e Linux. Source-tool tests, native target/motion/history checks, viewport/UWindow checks, round regression and eleven-weapon primary/secondary cases are documented in [Validation](https://github.com/toastycl/aimtrainer-ut99/blob/v1.0.0/docs/VALIDATION.md).

Physical mouse input, visual fit and Windows/macOS acceptance remain to be checked on the player's own client. This publication does not certify those platforms or hardware latency. Aerial/evasive movement is a training pattern, not exact human AI/dodge physics. Distance bands are measured from the round's starting position. Accuracy uses emitted traces/projectiles/fragments; compare the same weapon and fire style. Pulse beam contact is a separate time metric.

DPI and input backends are not detected or switched automatically. IGPlus/ping simulation and repeatable seeded scenarios remain deferred. Original game assets are not included. Public source visibility does not establish an open-source license; no source license has been selected.

For feedback, include UT client version, OS, weapon/fire style, exercise, distance/size, duration and reproduction steps.

Created by **ToastyCL**. Release date: **2026-11-09 (Chile)**.
