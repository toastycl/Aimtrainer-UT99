# Aimtrainer UT99

A simple **practice-room mod for Unreal Tournament 99**, built for the whole community. Enter the room, choose a classic CTF weapon, shoot static or moving characters, see your accuracy, and play again using your normal mouse settings.

**Version 0.2.1 — testing alpha.** This is a playable-mod implementation under validation, not a finished release. See [validation status](docs/VALIDATION.md) for the checks actually completed.

## Install

[Download the compiled 0.2.1 test ZIP](downloads/UTAT-alpha-0.2.1.zip?raw=true) · [Checksums](downloads/SHA256SUMS)

Extract the compiled alpha ZIP into a **test copy of your UT99 469e installation**, preserving the folders:

| File | Destination |
| --- | --- |
| `UTAT.u` | `UnrealTournament/System/` |
| `UTAT.int` | `UnrealTournament/System/` |
| `DM-UTAT-Room.unr` | `UnrealTournament/Maps/` |

The ZIP contains the compiled mod and real map. Python, a compiler and UnrealEd are not needed to install that ZIP. GitHub's **Download ZIP** contains source code, not the compiled game package.

Open **Mods → UT99 Aimtrainer → Enter training room**, or enter this console command:

```text
open DM-UTAT-Room?Game=UTAT.UTATGame?Mutator=?NumBots=0
```

In the room, open **Mods → UT99 Aimtrainer** (or console: `AimMenu`). Choose a weapon, target behavior and round duration, then **Start / Play again**. Timed rounds end automatically. Free practice ends when you choose **Finish and show score**. The result panel offers the same setup and replay controls.

[Guía de instalación y uso en español](docs/QUICKSTART_ES.md)

## The room

A small, flat rectangular room with neutral grid textures, one fixed start position and three human-shaped targets. Each round resets you to the start and recreates the targets. Targets have 100 health and respawn after elimination. The player has a separate staging/round start and targets have their own fixed origin. Combat bots inherited from DeathMatch settings are disabled.

- **Static characters:** three stationary targets.
- **Moving characters:** three targets following controlled lateral strafe paths.
- **30 / 60 / 120 seconds** or **free practice**. Timed rounds count real seconds of active play; opening the menu pauses practice and Start/Replay explicitly resumes it.
- You can move, jump and dodge using UT99 movement.

This is a training game type with normal CTF weapons, not a Capture the Flag match. There are no flags to capture or attacking enemy AI.

## Fixes in 0.2.1

Separate player/target starts; no inherited DM bots/warmup; true unlimited ammo; an independent round clock; explicit resume on Start; one reusable control window; and a persistent HUD fallback for results. Replace both System files **and** the map from the new ZIP.

## Weapons and accuracy

| Weapon | Supported fire | Accuracy unit |
| --- | --- | --- |
| Shock Rifle | Primary | One emitted trace |
| Sniper Rifle | Primary; secondary zoom | One emitted trace |
| Minigun | Primary and secondary | One emitted trace/bullet |
| Pulse Gun | Primary projectiles | One plasma projectile |
| Rocket Launcher | Primary, including loaded rockets | One rocket |
| Flak Cannon | Primary fragments | One fragment, not one shell |

**Accuracy = emission units that damaged a target / emission units fired × 100.** A projectile damaging multiple targets through splash counts only once as a successful unit. Multiple Flak fragments are counted individually, so the percentage cannot exceed 100%. Eliminations and useful target damage are recorded separately. Compare the same weapon/fire mode/exercise across runs; the Flak percentage is not shell accuracy.

Shock combos, Pulse beam, Flak shells, Rocket grenades and the remaining UT weapons are not implemented yet. Targets use the stock Soldier mesh and a standing Pawn collision cylinder. They are controlled training characters, not complete AI opponents. Sniper uses its stock head/body damage logic against them.

## Mouse configuration

Use the DPI, sensitivity and input backend you normally use. **Profiles are optional and are not the main training flow.** Change DPI in your mouse software and input/sensitivity in the client, then replay the same exercise. The mod does not detect or switch hardware DPI or verify Raw Input/DirectInput.

Optional console commands still allow temporary sensitivity tests (`AimSensitivity 1.8`), saving slots (`AimSave 0..2`), applying them (`AimProfile 0..2`) and restoration (`AimRestore`). These commands do not call the player's SaveConfig. Original client menus and other mods may persist settings independently. Use a test installation and retain your original ini files.

## Console controls

| Command | Purpose |
| --- | --- |
| `AimMenu` | Open the training/result panel |
| `AimWeapon 0..5` | Shock, Sniper, Minigun, Pulse, Rocket, Flak |
| `AimExercise 0` / `AimExercise 1` | Static / moving targets |
| `AimDuration 60` | Timed round (10–300 seconds) |
| `AimDuration 0` | Free practice |
| `AimStart` | Start from the room's fixed position |
| `AimFinish` | End and show score; an early timed finish is excluded from timed comparisons |
| `AimRestart` | Cancel the current round and start again |
| `AimStop` | Cancel and show current counters |
| `AimHelp` | Command help |

Pending projectiles are removed between rounds. Old-round shot tokens cannot score in a new round. A cancelled/early-ended timed round still shows its accuracy, but is excluded from completed-round summaries.

## Build from source

Use Python 3.10+ and a complete UT99 installation with the **OldUnreal 469e** compiler. Original game assets/toolchain are local dependencies and are not redistributed here.

```sh
python scripts/build.py --ut-root "/path/to/UnrealTournament"
# Windows:
py scripts/build.py --ut-root "C:\Games\UnrealTournament" --system System
```

The builder compiles `UTAT.u`, imports/rebuilds the included `maps/DM-UTAT-Room.t3d` with UCC's editor commandlet and packages `dist/UTAT-alpha-0.2.1.zip`. The room uses unlit own grid textures, so it does not need GPU lightmap baking. The build writes separate compiler/editor ini files and stages mod source/output in the test installation; it does not edit User.ini or UnrealTournament.ini.

The reproducible room/texture generator is `scripts/create_room.py` (requires Pillow). Its generated T3D and PCX inputs are committed; ordinary builds do not need Pillow.

## Results and checks

The in-game panel shows accuracy, emission counts and eliminations. A persistent result HUD remains visible after closing the menu. Ammunition is truly unlimited through custom ammo classes (stock HUD shows 999), including outside active rounds. To export retained game logs:

```sh
python scripts/analyze.py "/path/to/UnrealTournament.log" --out results
python -m unittest discover -s tests -v
# Optional engine checks after building (no rendered client):
python scripts/smoke.py --ut-root "/path/to/UnrealTournament"
# Optional real viewport/UWindow integration (working client/renderer required):
python scripts/client_smoke.py --ut-root "/path/to/UnrealTournament"
```

`analyze.py` supports v1 and v2 records. Version 2 separates weapon/unit/scenario groups, supports free practice and does not invent a time-to-hit metric for continuous multi-target rounds. Logs can be overwritten when UT restarts: keep a copy. Backend is recorded as unverified. Keep DPI, FOV, renderer and FPS conditions consistent when comparing your settings. This is not a hardware latency measurement.

[Architecture](docs/ARCHITECTURE.md) · [Roadmap](docs/ROADMAP.md) · [Validation](docs/VALIDATION.md) · [Manual testing](docs/TESTING.md)

## Contributions and rights

Feedback and reproducible bug reports are welcome. Include client version, OS, weapon, exercise and reproduction steps. Do not commit original game binaries/assets, private ini files or personal logs. The included map, grid textures and mod source are project content.

A source license has not been selected yet. Public visibility alone is not an open-source license. Unreal Tournament and its original assets belong to their respective rights holders. There is no automatic server deployment.
