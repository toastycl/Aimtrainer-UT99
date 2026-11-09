# UT99 Aimtrainer

A practice-room mod for **Unreal Tournament 99**, created by **ToastyCL** for the whole UT99 community. Choose a weapon, shoot static or moving characters, and compare your accuracy while trying your usual DPI, sensitivity and input settings.

**Development build 0.4.0 · 2026-11-09 (UTC).** Local and IGPlus training, eleven classic weapons, editable 0–300 ms additional latency, timed rounds and results over the game view. [Validation](docs/VALIDATION.md) distinguishes executed checks from pending manual/platform acceptance.

[**Download the complete development package**](downloads/UTAT-dev-0.4.0.zip?raw=true) · [Guía de instalación y prueba en español](docs/QUICKSTART_ES.md) · [Checksums](downloads/SHA256SUMS)

## Install

Close UT and extract the package into a **test copy of a complete UT99 469e installation**, preserving folders:

| Package content | Destination |
| --- | --- |
| `System/UTAT.u`, `System/UTAT.int`, `System/UTATNetLab.u` | UT's `System` folder |
| `Maps/DM-UTAT-Room.unr` | UT's `Maps` folder |
| `tools/`, `Start-Aimtrainer.cmd`, `Start-Aimtrainer.sh`, `LEEME.md` | UT installation root |

Preserve User.ini and UnrealTournament.ini. No compilation, UnrealEd or Python libraries are needed to install the binaries. GitHub's **Code → Download ZIP** contains source; use the compiled package above to play.

**For IGPlus:** install Python 3.10+ and separately install `InstaGibPlus_11.u` and `InstaGibPlusAssets_v2.u` from [official IGPlus 11](https://github.com/utspect/InstaGibPlus/releases/tag/11) into `System`. Those third-party binaries and original UT assets are not bundled. Local practice also works without IGPlus, directly through the normal UT executable and Mods menu.

## Start and play

On Windows, run **Start-Aimtrainer.cmd** from your test UT root. Keep its window open. It starts the private helper and opens UT's setup panel. On Linux, use `bash Start-Aimtrainer.sh`.

1. Choose **Local practice** or **IGPlus / all classic weapons**.
2. For IGPlus, enter any whole **additional RTT from 0 to 300 ms**: 37, 85, 112, 143 and 300 are all valid. There is no preset-only list.
3. Choose weapon, static/moving targets and 30/60/120 seconds or free practice.
4. Press the single **Start training** button. Network mode waits for the helper's ready handshake before entering.
5. Play with unlimited ammo against three human-shaped targets. Player starts and target respawns are randomized and separated. Targets have 100 HP; the trainee is protected from practice damage.
6. Timed rounds finish automatically. Free practice finishes through **Finish round** in the Mods setup panel. Results appear **over the room**.
7. Release fire, then press a **fresh primary fire** to return to selection without shooting or changing the score.

Reconfigure latency between rounds. Each IGPlus Start creates a fresh private server/relay session, clearing old delayed packets. Opening setup pauses active training, with network propagation delay in IGPlus; closing it resumes. Closing the helper-owned UT client shuts down its private server/relay.

For Local without the launcher: **Mods → UT99 Aimtrainer**, or `open DM-UTAT-Room?Game=UTAT.UTATGame?Mutator=` followed by `AimMenu`.

## Latency and actual IGPlus behavior

The helper binds only to localhost. It owns a dedicated UT server, a UDP delay relay and the client it launched. The in-game menu sends a validated request and travels only after a ready reply; startup errors remain visible in setup. UDP ports 17777 / 18777 / 18778 must be free.

The configured value means **additional round-trip delay**. For example, 85 ms adds 42.5 ms outbound and 42.5 ms inbound. It does not force an exact scoreboard ping or reduce baseline latency. The HUD separately shows requested delay and the native **Game ping** reported by UT. RPC game-clock estimates remain diagnostics in test logs. Zero additional delay does not mean zero physical latency.

IGPlus mode retains its actual `bbTMale2` player and derives its instrumentation adapters from IGPlus 11's weapon/projectile classes, delegating behavior to their parent implementations. It uses the normal-weapon `WeaponSettingsOldNet` profile. It does not imply every CTF weapon uses NewNet compensation. A particular live server's exact build/settings, human-player hitbox behavior and anticheat compatibility need separate validation.

No jitter, packet loss or bandwidth emulation is included. No public relay, live-server deployment or automatic production configuration changes are performed. The helper uses separate practice engine/user ini files; it copies normal settings on first use and retains practice settings afterward.

## Arsenal and scoring

All eleven weapons are selectable in both environments. Primary and secondary fire remain available; Sniper secondary is zoom. The Translocator is a utility, outside this damage-weapon selector.

| Weapon | Scoring unit / behavior |
| --- | --- |
| Shock Rifle | Trace / orb; a damaging combo credits both components |
| Sniper Rifle | Trace; secondary zoom emits no damage unit |
| Minigun | Emitted bullet/trace |
| Pulse Gun | Plasma projectile; secondary beam contact time shown separately |
| Rocket Launcher | Rocket / grenade, including loaded projectiles |
| Flak Cannon | Primary fragment / secondary shell |
| Enforcer | Emitted trace, including rapid secondary fire |
| Bio Rifle | Primary/charged glob; derived splash retains its parent's token |
| Ripper | Blade / explosive secondary projectile |
| Impact Hammer | Primary/secondary trace; no ammo required |
| Redeemer | Warhead; expanding blast retains its original token |

**Accuracy = emission units that damaged a target / emission units emitted × 100.** Splash counts once per successful unit even if several targets are damaged. Child fragments/splashes retain an existing parent token when generated by an explosion. Eliminations, useful damage and elapsed time are separate counters.

**Pulse beam tracking is time-based:** contact time / active beam time, shown independently from projectile accuracy. It is not a projectile hit percentage. Compare the same weapon and fire mode across repeated rounds; random placement varies difficulty. Continuous-beam and mixed-fire statistics are not interchangeable with hitscan accuracy.

The targets are controlled Pawn collision cylinders using the original Soldier mesh, not complete enemy AI or fully equivalent replicated human players. You can move, jump and dodge. The room uses project-made grid textures.

## Mouse settings and project information

Use your normal DPI, sensitivity and input backend. Change DPI in mouse software and sensitivity/input in the client. The mod does not detect/switch DPI, certify Raw Input/DirectInput or measure hardware latency. Keep renderer, FOV and FPS conditions consistent.

Optional local `AimSensitivity`, `AimSave`, `AimProfile` and `AimRestore` commands remain available. Profiles are not required. Open **About / Credits** for **ToastyCL**, development version, UTC date, repository and scope.

## Build and verify

Requires Python 3.10+ and a complete UT99 469e installation/compiler. Install official IGPlus 11 dependencies before building its adapters.

```sh
python scripts/build.py --ut-root "/path/to/UT"
python scripts/build_netlab.py --ut-root "/path/to/UT"
python scripts/package_dev.py --ut-root "/path/to/UT"
python -m unittest discover -s tests -v
python -m compileall -q scripts
```

Native checks require a full game/renderer and run sequentially:

```sh
python scripts/arsenal_smoke.py --ut-root "/path/to/UT" --offscreen --local
python scripts/arsenal_smoke.py --ut-root "/path/to/UT" --offscreen
python scripts/arsenal_smoke.py --ut-root "/path/to/UT" --offscreen --alt
python scripts/start_aimtrainer.py --ut-root "/path/to/UT" --offscreen --integration-check
python scripts/client_smoke.py --ut-root "/path/to/UT" --offscreen
python scripts/smoke.py --ut-root "/path/to/UT"
```

`--offscreen` requires a compatible Linux SDL/Mesa renderer; omit it for a normal viewport. These tests invoke real game/UI/weapon code but do not replace physical mouse, visual or Windows/macOS acceptance. The launcher does not yet discover a macOS `.app` installation.

Local records use schema v2 with `all-fire-units-v3` protocol; `scripts/analyze.py` exports supported local `RESULT` records. Network diagnostics currently use a separate `NETRESULT` record, not imported by that exporter. Retain logs before restarting. Do not publish raw personal logs/settings.

[Validation](docs/VALIDATION.md) · [Manual testing](docs/TESTING.md) · [Architecture](docs/ARCHITECTURE.md) · [Project progress](docs/WIP_SELECTABLE_PING.md) · [Roadmap](docs/ROADMAP.md)

## Contributions and rights

Created by **ToastyCL** for all UT99 players. Work is public for anyone to inspect or contribute; no individual is assigned to finish it. Include client version, OS, weapon/fire mode, environment, requested ms and reproduction steps in bug reports.

A source license has not been selected; public visibility alone does not grant an open-source license. Original game assets/toolchain and IGPlus remain separate dependencies. No original or third-party binaries are redistributed in this project package. There is no automatic production deployment.
