# Project progress — selectable latency and IGPlus

**Created by ToastyCL · Development build 0.4.0 · 2026-11-09 (UTC)**

This is public project documentation for anyone inspecting or contributing. It is not an assignment to a particular collaborator. The project remains in development; no production deployment or GitHub Release is part of this delivery.

## Implemented

- In-game Local / IGPlus environment selection.
- Editable **0–300 ms**, in 1 ms increments; values are not rounded to presets.
- All eleven classic damage weapons in both environments, with secondary fire available.
- A private helper handshake: validated request, server startup, READY/ERROR, cancellation and timeout.
- UTPure's player and IGPlus-derived weapon/projectile adapters using normal-weapon settings.
- Fresh private server/relay sessions between network rounds, clearing delayed traffic from the previous session.
- Server-owned timed/free rounds, menu pause, infinite ammo, safe random starts/respawns, static/lateral-moving targets, damage and eliminations.
- Emission-scoped hit deduplication and separate Pulse beam contact-time scoring.
- Replicated result HUD over the room; held-fire clearing and fresh-primary-fire return to setup.
- Preserved weapon/exercise/duration/latency selection and an About panel with ToastyCL/date.
- A compiled package, standard-library helper, launch scripts and Spanish installation/testing guide.

Requested additional RTT and measured RPC estimate are distinct values. Latency changes apply between rounds. Local mode does not simulate ping. The normal IGPlus weapon profile is `WeaponSettingsOldNet`; this does not imply NewNet compensation for every weapon.

## Acceptance and remaining work

See [current validation](VALIDATION.md) and [Spanish test guide](QUICKSTART_ES.md). Native engine/viewport checks are not physical-input or platform certification.

- [ ] Tester acceptance on Windows with the actual mouse/input configuration.
- [ ] macOS `.app` launcher discovery and native Mac acceptance; current helper discovery targets Windows/Linux.
- [ ] Exact tester-server IGPlus version/configuration/tick-rate matching, and human-player hitbox validation.
- [ ] Separate anticheat/ACE compatibility validation.
- [ ] Manual visual review at common resolutions, especially result overlays and secondary weapon cameras/zoom.
- [ ] Network session CSV/history export and richer client metadata; current network records remain separate.
- [ ] Seed replay, difficulty/distance options and additional movement patterns.
- [ ] Optional jitter/loss/bandwidth emulation, designed separately from selected additional RTT.
- [ ] Select a source license before describing the repository as open source.

No remaining item is assigned exclusively to any person. Contributions can follow the architecture and tests below.

## Contributor entry points

| Concern | Files |
| --- | --- |
| Setup and validation | `UTAT/Classes/UTATPanel.uc`, `UTATNetworkBridge.uc`, `UTATWeaponCatalog.uc` |
| Local round and scoring | `UTATGame.uc`, `LC*.uc`, `LP*.uc`, `UTATProjectileNotify.uc` |
| Helper lifecycle/protocol | `scripts/start_aimtrainer.py`, `network_config.py`, `net_relay.py` |
| Actual IGPlus round | `UTATNetLab/Classes/UTATRoundGame.uc`, `UTATRoundState.uc` |
| IGPlus scoring adapters | `NW*.uc`, `NP*.uc`, `UTATNetProjectileNotify.uc` |
| Replication/HUD/result acknowledgement | `UTATNetworkState.uc`, `UTATNetworkHUD.uc` |
| Native checks | `arsenal_smoke.py`, `start_aimtrainer.py --integration-check`, `client_smoke.py`, `smoke.py` |
| Packaging | `scripts/package_dev.py`, `launchers/` |

[Architecture and protocol details](ARCHITECTURE.md) · [Earlier WIP proof](WIP_NETWORK_CHECKS.md) · [Original two-weapon proof](NETWORK_LAB.md).
