# IGPlus network laboratory — experimental

This is a separate automated proof for normal CTF weapons. It is **not yet a selectable training mode**: no network training rounds, in-game ping selector or network accuracy UI are included. The normal UTAT room remains standalone.

## What runs

A private localhost dedicated server loads `InstaGibPlus_11.UTPure` and `InstaGibPlus_11.ST_Mutator`. UTPure selects its actual `bbTMale2` player; the lab dynamically equips `ST_ShockRifle` or `ST_SniperRifle`. It never replaces those with UTAT weapon wrappers. The client sends eight RPC echoes, aims and fires its actual weapon; a server-authoritative dummy records damage. Success requires an IGPlus player/weapon class and a server-confirmed hit.

The Python UDP relay adds half of the requested **additional RTT** to each direction. Requesting 100 ms therefore adds 50 ms outbound + 50 ms inbound. It accepts one client and binds/forwards only on `127.0.0.1`. No loss, jitter or bandwidth emulation is implemented. Never point it at public servers; this runner only uses loopback.

Normal weapons in this experiment use IGPlus's `WeaponSettingsOldNet` profile, as selected by `ST_Mutator`. IGPlus does not automatically mean every normal CTF weapon is using NewNet compensation. A live server's IGPlus version, settings, tick rate and client settings must be matched before making comparisons.

## Executed results

OldUnreal 469e Linux amd64; SDL offscreen/Mesa client, actual separate dedicated server. One shot/hit per case; eight echo samples. Requested delay is a relay setting; the measured column is a **client game-clock RPC round-trip estimate**, not hardware latency or a forced scoreboard ping.

| Weapon | Added RTT requested (ms) | Mean RPC estimate (ms) | Server hits |
| --- | --- | --- | --- |
| Shock | 0 | 0.00 | 1 |
| Shock | 100 | 92.76 | 1 |
| Shock | 150 | 158.95 | 1 |
| Sniper | 0 | 0.00 | 1 |
| Sniper | 100 | 103.85 | 1 |
| Sniper | 150 | 154.88 | 1 |

Zero-delay RPCs returned within the same client update and recorded 0 at this game-clock resolution. This does not imply physically zero latency. Nonzero estimates vary with frame/tick timing and clock adjustment; do not interpret small deviations as relay precision. The UDP unit test separately verifies that payloads make a real round trip with at least the configured 100 ms delay.

All six cases logged `NETLAB PASS actual IGPlus client fire produced server hit`. This validates the minimal integration and delay path; one static shot does not validate hitbox interpolation, moving-target compensation, sustained accuracy or competitive equivalence. No anticheat/ACE compatibility test was performed.

Runtime dependency fingerprints (binaries not distributed):

- `InstaGibPlus_11.u` SHA256: `8d352a47599258bb800e9b66dfd193f60a733173ad38c772888aecd6310015c7`
- `InstaGibPlusAssets_v2.u` SHA256: `7422072cd9982da41ee4c984c992cebc5ed4e0d58fefa689620051214c6adac8`
- `InstaGibPlus.ini` SHA256: `63ba558ecbb8de894345cd967b591f96b41ebe5f2ec5ac94d8beaea7f0103d95`

The isolated test used IGPlus defaults generated in a fresh test installation. Game config used `NetServerMaxTickRate=50` and `LanServerMaxTickRate=50` in `IpDrv.TcpNetDriver` (`60` belongs to the separate demo driver). The server's runtime cadence may vary; these are configured limits, not a measured sustained tick rate. The runner uses a separate engine/user ini but IGPlus itself reads its usual `InstaGibPlus.ini`; use a **test copy** of UT and preserve your own settings. No live-server configuration was used.

## Build and reproduce

Requires Python 3.10+, a complete UT99 469e test installation and [official IGPlus release 11](https://github.com/utspect/InstaGibPlus/releases/tag/11). Install `InstaGibPlus_11.u` and `InstaGibPlusAssets_v2.u` from that release separately into UT's `System` folder. IGPlus is GPLv3 and remains a separate runtime dependency; its code/binaries are not copied here.

```sh
python scripts/build.py --ut-root "/path/to/UT"
python scripts/build_netlab.py --ut-root "/path/to/UT"
python scripts/net_smoke.py --ut-root "/path/to/UT" --weapon Shock --rtt-ms 0
python scripts/net_smoke.py --ut-root "/path/to/UT" --weapon Shock --rtt-ms 100
python scripts/net_smoke.py --ut-root "/path/to/UT" --weapon Sniper --rtt-ms 150
```

Add `--offscreen` on Linux only when the installed SDL/Mesa renderer supports it. Run cases sequentially: the lab reserves loopback ports 17777 and 18777. The client fires automatically. The runner stops its test processes after the result and retains local diagnostics under `build/net-*`. Do not use a production server or share raw personal logs. Windows/macOS runner acceptance remains pending.

The optional compiled `UTAT-network-lab-0.3.0.zip` contains only our `UTATNetLab.u` and this document. It also needs the base UTAT room/mod and official IGPlus dependencies above. It is for developers reproducing the proof, not an extra required installation for local training.

## Next integration

Expose a separate network lab in the selector, port the round lifecycle and per-weapon emission accounting without bypassing IGPlus, and add moving-target/manual acceptance. To reproduce a particular server, record its exact IGPlus build, relevant configuration, tick rate and client version first. Public release is manual; nothing deploys to a live server.
