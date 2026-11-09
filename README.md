# Aimtrainer UT99

An aim training mod for **Unreal Tournament 99**, designed for the whole UT community. Practice with classic weapons, compare mouse settings through repeatable exercises, and review your results.

**Early development / source alpha.** This repository contains the first local training implementation. It is not a finished release. See [validation status](docs/VALIDATION.md) for exactly what has been checked.

## First milestone

- Local, single-player training game type with a stock Shock Rifle primary-fire adapter.
- Fixed-sequence flick targets and a target following a controlled lateral strafe path.
- Three saved profiles containing sensitivity and mouse smoothing settings.
- Training panel in the **Mods** menu, plus console commands.
- HUD counters for time, shots, hits and accuracy.
- Completed/cancelled session records in the game log and a Python CSV/JSON exporter.
- Temporary mouse adjustments through the training commands, with an original-settings restore command.

The focus is **normal-weapon CTF aim**, not InstaGib. The lab runs as its own game type; it is not a playable Capture the Flag match.

## Planned

Sniper exercises, true continuous tracking with Pulse/Minigun, Shock combos, projectile prediction, a dedicated training map, in-game comparison history, input-backend detection and restart-aware switching, and eventually online validation.

**Raw Input / DirectInput / Cursor switching is not implemented in this alpha.** Select the backend through the client's own settings. Records explicitly mark the backend as `unverified`. Do not interpret a sensitivity profile as proof of the active input method.

## Build and try it

Use a separate, complete UT99 installation with the OldUnreal 469e toolchain for the initial build. The game itself and its original assets are not included.

```sh
python scripts/build.py --ut-root "/path/to/UnrealTournament"
```

On Windows, for example:

```powershell
py scripts/build.py --ut-root "C:\Games\UnrealTournament" --system System
```

The script stages `UTAT/Classes`, generates a separate compiler ini, invokes UCC and creates `dist/UTAT-alpha-0.1.0.zip` only after successful compilation. It does not edit `User.ini` or `UnrealTournament.ini`. It does place the compiled package in the test installation, so close UT before building.

Copy `System/UTAT.u` from the build and `System/UTAT.int` from this repository into the test game's `System` directory. Open the console and launch a map you already own, for example:

```text
open DM-Deck16][?Game=UTAT.UTATGame?Mutator=?NumBots=0
```

Move to a clear, flat area and face an unobstructed lane. The alpha creates its targets about 700 Unreal units ahead. If it cannot place a target it cancels the run rather than silently recording an invalid exercise. A dedicated arena is still planned.

Open **Mods > UT99 Aimtrainer**, or use `AimHelp` in the console. The initial menu uses UT's native UWindow controls; the polished concept UI is a design target, not the current implementation.

See [the Spanish quick start](docs/QUICKSTART_ES.md) and [manual acceptance tests](docs/TESTING.md).

## Console commands

| Command | Purpose |
| --- | --- |
| `AimSave 0` | Save current mouse settings in slot 0 (slots 0–2) |
| `AimProfile 0` | Apply a saved slot for this training visit |
| `AimSensitivity 1.8` | Change training sensitivity in memory |
| `AimSmoothing` | Toggle smoothing; disable maximum smoothing |
| `AimExercise 0` | Choose fixed-sequence flicks; use `1` for strafe |
| `AimDuration 60` | Set a run to 10–300 seconds |
| `AimStart` | Anchor the exercise at your current position and start |
| `AimStop` | Cancel a run; cancelled runs do not enter summaries |
| `AimRestore` | Restore the mouse settings captured on first use |
| `AimInput` | Explain the current input-backend limitation |
| `AimHelp` | Show command help |

Profile settings are saved in `UTAT.ini`. The training commands do not call the player's `SaveConfig`. Avoid changing settings through stock menus or other mods during a run: those components may independently persist user settings. FOV or mouse-setting changes detected mid-run cancel the run.

## Review sessions

Keep a copy of your test game's log before launching UT again (the game may overwrite it).

```sh
python scripts/analyze.py "/path/to/UnrealTournament.log" --out results
```

The exporter produces `sessions.csv` and `summary.json`. Summaries include only completed rounds, keep different maps/anchors/FOV/protocols separate, and report accuracy, hits per minute and mean time until a hit. Run several rounds per configuration and alternate the order of profiles. No-hit rounds have no time-to-hit value; they are not reported as zero-ms performance.

Times are measured on the **game clock**, including reaction and aiming. They are not measurements of physical input latency. FPS, renderer, operating system, DPI, polling rate and the actual backend are not yet captured automatically: keep these constant and record them separately.

## Development

```sh
python -m unittest discover -s tests -v
python -m compileall -q scripts
```

CI runs the Python tooling checks. UCC compilation and in-game acceptance are separate checks and must be reported separately. There is no automatic server deployment.

- [Architecture](docs/ARCHITECTURE.md)
- [Roadmap](docs/ROADMAP.md)
- [Validation](docs/VALIDATION.md)

## Contributions and rights

Feedback, reproducible bug reports and discussion are welcome. Include your client version, operating system and exact reproduction steps. Do not upload private configuration files or game assets.

A project source license has not been selected yet. A public repository alone does not grant an open-source license. Unreal Tournament and its original assets belong to their respective rights holders; this repository does not redistribute them.
