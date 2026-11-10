# UT99 Aimtrainer

A simple **standalone practice-room mod for Unreal Tournament 99**, created by **ToastyCL** for the entire UT99 community. Install the mod/map, open UT, choose a weapon and train using your normal mouse settings.

**Development build 0.5.0.** No Python, IGPlus, launcher or external helper is required to play. The earlier network/latency experiment is deferred; the current focus is the training experience inside UT.

[**Download the standalone mod + map**](downloads/UTAT-standalone-0.5.0.zip?raw=true) · [Guía en español](docs/QUICKSTART_ES.md) · [Validation](docs/VALIDATION.md) · [Checksums](downloads/SHA256SUMS)

## Install and play

Close UT and extract the compiled ZIP into a test copy of **UT99 469e**, preserving folders:

| File | Destination |
| --- | --- |
| `System/UTAT.u` | UT's `System` folder |
| `System/UTAT.int` | UT's `System` folder |
| `Maps/DM-UTAT-Room.unr` | UT's `Maps` folder |

Keep your normal ini files. No compiler or UnrealEd is needed to install this ZIP. GitHub's Code → Download ZIP downloads source, not the compiled package linked above.

1. Open UT normally, then **Mods → UT99 Aimtrainer**.
2. Choose a weapon, target exercise, distance, size and 30/60/120 seconds or free practice.
3. Press the single **Start training** button. It enters the room with your selection.
4. Shoot three human-shaped targets with unlimited ammo, including random aerial targets. Player starts and target respawns are random and separated. You can move, jump and dodge.
5. Timed rounds end automatically. Free practice ends through **Finish round** / `AimFinish`.
6. Read accuracy, emission counts, eliminations and elapsed time over the room. Release fire, then press a **fresh primary fire** to return to setup without firing or changing the score.

Opening setup pauses practice. Replay resets counters and removes old projectiles. The included map is a simple flat room with project-made grid textures. There are no enemy combat bots or flag objectives.

Console fallback: `open DM-UTAT-Room?Game=UTAT.UTATGame?Mutator=` followed by `AimMenu`.

## Weapons and scoring

All eleven classic damage weapons are available, with primary and secondary fire: **Shock, Sniper, Minigun, Pulse, Rocket, Flak, Enforcer, Bio, Ripper, Impact Hammer and Redeemer**. Sniper secondary is zoom. The Translocator is a utility, outside the damage-weapon selector.

**Accuracy = emitted units that damaged a target / emitted units × 100.** Units are traces/bullets, projectiles or Flak fragments. Splash counts once per successful unit even when damaging several targets. Explosion children retain the parent token; damaging Shock combos credit orb and detonating trace. Damage and eliminations are tracked separately.

**Pulse secondary uses beam contact time**, shown separately from projectile accuracy. Compare the same weapon and fire style across multiple rounds. Random placement varies difficulty. Targets are controlled Pawn collision cylinders using the Soldier mesh, not complete enemy AI.

Use your usual DPI, sensitivity and input backend. Change hardware DPI in mouse software and client settings through UT. The mod does not detect/switch DPI or measure hardware latency. Profiles remain optional; `AimSensitivity`, `AimSave`, `AimProfile` and `AimRestore` support local trials.

## Target exercises and round history

| Setting | Choices |
| --- | --- |
| Targets | Static, lateral strafe, evasive with direction/speed changes and simulated jumps, random aerial movement |
| Distance | Mixed, close (700–1050), medium (1150–1550), far (1750–2300 horizontal UT units) |
| Target size | Normal, small (60%), large (140%); mesh and collision cylinder scale together |

Aerial targets spawn with their center at random heights of 200–600 UT units and move toward changing 3D destinations. Evasive targets use varied ground directions/speed and short jump arcs and brief dodge-like speed bursts. These are training trajectories, not human player AI, real dodge physics or IGPlus/network simulation. Unsafe movement steps are rejected without ending the round. Distance bands are measured from the round's starting position; walking closer still works, including for Hammer practice. Spawns remain random.

**Round history** opens from setup and retains the last ten rounds across game restarts in the mod's own `UTAT.ini`. It shows weapon, sensitivity, target settings, fire-input style, hits/units, accuracy, beam contact, eliminations, FOV/smoothing and completion/time. Newest rounds appear first, three per page. Finishing or cancelling an active round saves one entry; early finishes are marked partial. Pulse contact stays separate from projectile accuracy.

History is a review of your trials, not an automatic sensitivity recommendation. Compare the same weapon, fire style, target settings and duration over several completed rounds. Placement remains random, DPI/input backend is not detected, and player movement can change the actual engagement distance.

[Roadmap](docs/ROADMAP.md). Optional repeatable scenarios remain a future idea. IGPlus/ping is [deferred](docs/WIP_SELECTABLE_PING.md); its historical files remain isolated under `experimental/igplus/` and excluded from the player package.

## About

Open **About / Credits** in setup for **ToastyCL**, development version/date and project information. The tool is for all UT99 players and is not specific to a community/server.

## Developer build and checks

Players do not need these tools. Developers need Python 3.10+ and a complete UT99 469e installation/compiler:

```sh
python scripts/build.py --ut-root "/path/to/UT"
python -m unittest discover -s tests -v
python scripts/training_smoke.py --ut-root "/path/to/UT"
python scripts/client_smoke.py --ut-root "/path/to/UT" --offscreen
python scripts/arsenal_smoke.py --ut-root "/path/to/UT" --offscreen
python scripts/arsenal_smoke.py --ut-root "/path/to/UT" --offscreen --alt
python scripts/smoke.py --ut-root "/path/to/UT"
```

Use --offscreen only with a compatible Linux SDL/Mesa renderer, or omit it for a normal client. Native callback/weapon tests are distinct from physical input and manual visual/platform acceptance. The local exporter `scripts/analyze.py` supports local results and separate beam contact metrics.

[Architecture](docs/ARCHITECTURE.md) · [Manual testing](docs/TESTING.md) · [Validation](docs/VALIDATION.md)

## Contributions and rights

Created by **ToastyCL** for the whole UT99 community. Include client version, OS, weapon/fire mode, exercise and reproduction steps in feedback. Do not commit private ini files, personal logs or original game assets.

A source license has not been selected. Public visibility alone does not grant an open-source license. Original game assets/toolchain remain external dependencies. No automatic production deployment is performed.
