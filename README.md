# UT99 Aimtrainer

A practice-room mod for **Unreal Tournament 99**, created by **ToastyCL** for the entire UT99 community. Choose a classic weapon, shoot static or moving characters, and compare your accuracy while trying your usual DPI, sensitivity and client input settings.

**Current development build: 0.3.1 · 2026-11-09 (UTC).** Work in progress. [Validation and known limits](docs/VALIDATION.md).

## Download and install

[**Download the compiled mod + map**](downloads/UTAT-alpha-0.3.1.zip?raw=true) · [SHA256 checksums](downloads/SHA256SUMS) · [Guía en español](docs/QUICKSTART_ES.md)

Close UT and extract the compiled ZIP into a **test copy of UT99 469e**, preserving folders. Replace all three files:

| ZIP file | Destination |
| --- | --- |
| `System/UTAT.u` | `UnrealTournament/System/UTAT.u` |
| `System/UTAT.int` | `UnrealTournament/System/UTAT.int` |
| `Maps/DM-UTAT-Room.unr` | `UnrealTournament/Maps/DM-UTAT-Room.unr` |

You do not need Python, UnrealEd or a compiler to play this build. Preserve your personal ini files. GitHub's **Code → Download ZIP** downloads source; use the compiled ZIP linked above to install the mod.

## Play a round

1. Open **Mods → UT99 Aimtrainer**.
2. Select your weapon, **static characters** or **moving / lateral strafe**, and **30 / 60 / 120 seconds** or **free practice**.
3. Press **Start training**. This single button enters the room and starts with your chosen settings.
4. Shoot three human-shaped targets. Ammo is unlimited, and targets have 100 health. Each new round gives you a random safe starting position; eliminated targets respawn at different random points.
5. When time expires, read the results **over the room**. In free practice, use **Finish round** in the setup panel or `AimFinish` in the console.
6. Press a **fresh primary fire** to return to selection. That acknowledgement does not shoot or alter your accuracy. Choose your next settings and press Start training again.

Opening the setup panel pauses local practice. Finish closes it and shows the result over the world. Holding fire when a round ends must not skip the result. You can move, jump and dodge normally.

Console fallback to enter the room:

```text
open DM-UTAT-Room?Game=UTAT.UTATGame?Mutator=?NumBots=0
```

Then use `AimMenu` for setup. The included map is a simple, flat rectangular room with project-made grid textures. Combat bots and inherited DeathMatch warmup are disabled. This is weapon practice for CTF players; it does not include flag objectives or enemy combat AI.

## Weapons and scoring

| Weapon | Available fire | Accuracy unit |
| --- | --- | --- |
| Shock Rifle | Primary | One emitted trace |
| Sniper Rifle | Primary; secondary zoom | One emitted trace |
| Minigun | Primary and secondary | One emitted trace/bullet |
| Pulse Gun | Primary projectiles | One plasma projectile |
| Rocket Launcher | Primary, including loaded rockets | One rocket |
| Flak Cannon | Primary fragments | One fragment |

**Accuracy = units that damaged a target / units emitted × 100.** Splash can damage several targets but counts once per successful projectile. Flak accuracy counts fragments, not shells. Eliminations, damage and elapsed time are recorded separately. Shock combos, Pulse beam, Flak shells, Rocket grenades and the remaining weapons are pending.

Compare multiple rounds using the same weapon, fire mode and exercise. Random placement varies difficulty. Logs retain the spawn seed, but selecting/replaying a seed from the menu is pending. Cancelled or early-finished timed rounds show statistics and are excluded from completed-round summaries. Old-round projectiles cannot score in a new round.

## Sensitivity and input

Use your normal mouse configuration. Change **DPI in your mouse software** and sensitivity/input in the UT client, then repeat the exercise. The mod does not detect or switch hardware DPI, verify Raw Input/DirectInput, or measure hardware latency. Profiles are optional.

Keep DPI, FOV, renderer and FPS conditions consistent when comparing settings. Optional `AimSensitivity`, `AimSave`, `AimProfile` and `AimRestore` console commands support temporary sensitivity/profile trials. They do not call the player's SaveConfig; the client menus and other mods can persist settings independently.

## WIP: selectable latency + IGPlus

**In development:** [implementation plan and contributor handoff](docs/WIP_SELECTABLE_PING.md). The normal 0.3.1 trainer does not yet include an in-game ping field.

The external WIP launcher accepts **any integer added RTT from 0 to 2000 ms**, including 37, 85, 112 or 143; it is not limited to preset values. It starts a private localhost IGPlus client/server sandbox and leaves aiming/firing to you. Network rounds and accuracy scoring are pending.

After building the base mod and WIP lab with the separate official IGPlus 11 dependencies:

```sh
python scripts/network_lab.py --ut-root "/path/to/UnrealTournament"
# Or choose the exact value directly:
python scripts/network_lab.py --ut-root "/path/to/UnrealTournament" --weapon Shock --rtt-ms 85
```

The launcher asks for weapon and ms, records the validated request and opens the manual sandbox. Close UT and rerun to change the delay. It does not select a value inside the UT menu yet. [WIP package](downloads/UTAT-network-lab-WIP.zip?raw=true) · [Setup and pending work](docs/WIP_SELECTABLE_PING.md).

The value is **additional round-trip delay**, split equally between outbound/inbound traffic. An 85 ms request adds 42.5 ms each way; it does not guarantee an exact scoreboard ping. The WIP reports requested delay, a client-clock RPC estimate and server impact feedback separately. Impacts alone are not accuracy.

The automated developer runner remains available, for example:

```sh
python scripts/net_smoke.py --ut-root "/path/to/UnrealTournament" --weapon Sniper --rtt-ms 143
```

IGPlus 11's actual player/weapon classes are retained. The tested normal-weapon profile is `WeaponSettingsOldNet`. Matching a live server requires its exact build/settings; NewNet behavior and anticheat compatibility are not implied. [Earlier proof and dependency fingerprints](docs/NETWORK_LAB.md).

## About and project information

Open **Mods → UT99 Aimtrainer → About / Credits**. The in-game panel shows:

- **Created by ToastyCL**.
- Development build **0.3.1**, dated **2026-11-09 (UTC)**.
- The community-wide purpose, supported training features and measurement limits.
- Repository address and the separate experimental status of IGPlus latency testing.

Closing About returns to setup and preserves your selected weapon and duration.

## Console reference

| Command | Purpose |
| --- | --- |
| `AimMenu` | Open setup |
| `AimWeapon 0..5` | Shock, Sniper, Minigun, Pulse, Rocket, Flak |
| `AimExercise 0` / `AimExercise 1` | Static / moving targets |
| `AimDuration 60` | Timed round, 10–300 seconds |
| `AimDuration 0` | Free practice |
| `AimStart` | Start at a random safe room position |
| `AimFinish` | Finish and show results |
| `AimRestart` | Cancel the current round and start again |
| `AimStop` | Cancel and show current counters |
| `AimHelp` | Command help |

## Build and verify

Requires Python 3.10+ and a complete UT99 installation with the **OldUnreal 469e** compiler. Original game assets/toolchain remain local dependencies.

```sh
python scripts/build.py --ut-root "/path/to/UnrealTournament"
# Windows:
py scripts/build.py --ut-root "C:\Games\UnrealTournament" --system System
```

The builder compiles `UTAT.u`, imports/rebuilds `maps/DM-UTAT-Room.t3d` into a real `.unr`, and creates `dist/UTAT-alpha-0.3.1.zip`. It writes separate build ini files without editing User.ini or UnrealTournament.ini. The room uses unlit project textures. Its optional generator, `scripts/create_room.py`, requires Pillow; ordinary builds use the committed T3D/PCX inputs.

```sh
python -m unittest discover -s tests -v
python scripts/smoke.py --ut-root "/path/to/UnrealTournament"
python scripts/client_smoke.py --ut-root "/path/to/UnrealTournament"
python scripts/analyze.py "/path/to/UnrealTournament.log" --out results
```

Engine checks and real viewport/UWindow callback checks are distinct from manual mouse/visual acceptance. Linux 469e has been exercised; Windows/macOS acceptance remains pending. Retain logs before restarting UT. The exporter supports legacy v1 and weapon/unit-separated v2 records.

[Validation](docs/VALIDATION.md) · [Manual testing](docs/TESTING.md) · [Architecture](docs/ARCHITECTURE.md) · [Roadmap](docs/ROADMAP.md)

## Contributions and rights

Created by **ToastyCL** for all UT99 players. Feedback should include client version, OS, weapon, exercise and reproduction steps. Do not commit original game assets, private settings or personal logs.

A source license has not been selected. Public visibility alone does not grant an open-source license. Unreal Tournament and its original assets belong to their rights holders. IGPlus is a separate GPLv3 dependency. There is no automatic server deployment.
