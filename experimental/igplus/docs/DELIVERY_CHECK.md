# Packaged installation check — 0.4.0

PASS on OldUnreal 469e Linux amd64 with an SDL offscreen/Mesa viewport.

The development ZIP was extracted into a separate test installation. Existing project packages were removed from both System and System64 before extraction; staged project source directories were not copied. Original UT/IGPlus dependencies remained local prerequisites and are not in the ZIP.

The check ran the helper extracted from the package, without compiling in that installation:

```sh
python tools/start_aimtrainer.py --ut-root "/path/to/testUT" --offscreen --integration-check
```

```text
MENUTEST selected IGPlus, Shock, 85 ms and 30 seconds through Start
ROUNDTEST PASS true infinite client ammo
ROUNDTEST PASS server pause while setup is open
ROUNDTEST RESULT weapon=Shock shots=2 hits=2 kills=0 elapsed=30.000000 requested=85 measured=82.882416 game_ping=93
ROUNDTEST PASS weapon, score, timer and result HUD
ROUNDTEST fresh fire acknowledged result
MENUTEST DONE failures=0
```

This verifies installation layout, packaged Python imports, helper readiness, actual IGPlus connection, timer, pause/resume, HUD and fresh-fire return with retained settings. Final packaging adds documentation; runtime hashes are checked against the tested ZIP.

Physical mouse/visual and Windows acceptance remain pending. Native macOS .app discovery is not implemented. See [the guide](QUICKSTART_ES.md) and [validation](VALIDATION.md).
