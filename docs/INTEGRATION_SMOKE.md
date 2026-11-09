# Native integration evidence — 0.4.0

OldUnreal 469e Linux amd64; actual SDL/Mesa viewport and private dedicated server. This is native code/callback testing, not physical input or manual visual acceptance.

| Weapon | Local primary | Local secondary | IGPlus primary | IGPlus secondary |
| --- | --- | --- | --- | --- |
| Shock | PASS | PASS | PASS | PASS |
| Sniper | PASS | PASS | PASS | PASS |
| Minigun | PASS | PASS | PASS | PASS |
| Pulse | PASS | PASS | PASS | PASS |
| Rocket | PASS | PASS | PASS | PASS |
| Flak | PASS | PASS | PASS | PASS |
| Enforcer | PASS | PASS | PASS | PASS |
| Bio | PASS | PASS | PASS | PASS |
| Ripper | PASS | PASS | PASS | PASS |
| Hammer | PASS | PASS | PASS | PASS |
| Redeemer | PASS | PASS | PASS | PASS |

All 44 cases passed the appropriate check: emitted units and server/target hits, beam contact for Pulse secondary, or zero damaging emissions for Sniper zoom. Accuracy bounds and timer completion were checked. IGPlus checks additionally verify true infinite client ammo for ammo-bearing weapons.

Target positions are controlled near the trainee for scoring regression. Ripper was rechecked with a centered-muzzle test fixture to avoid grazing/parallax instability. Those controls are opt-in test code only; ordinary training retains normal weapon behavior and user hand settings.

## Full menu flow

```text
MENUTEST selected IGPlus, Shock, 85 ms and 30 seconds through Start
ROUNDTEST PASS true infinite client ammo
ROUNDTEST PASS server pause while setup is open
ROUNDTEST RESULT weapon=Shock shots=2 hits=2 kills=0 elapsed=30.000000 requested=85 measured=83.005890
ROUNDTEST PASS weapon, score, timer and result HUD
ROUNDTEST fresh fire acknowledged result
MENUTEST DONE failures=0
```

The flow selected IGPlus / Shock / 85 ms / 30 seconds through the real UWindow controls, waited for helper readiness, paused/resumed the server from setup, finished automatically, acknowledged by fresh primary fire and retained settings on return.

## Additional latency boundaries

```text
ROUNDTEST RESULT weapon=Shock shots=2 hits=2 kills=0 elapsed=7.000000 requested=0 measured=0.000000 game_ping=18
```
```text
ROUNDTEST RESULT weapon=Shock shots=2 hits=2 kills=0 elapsed=7.000000 requested=300 measured=300.066437 game_ping=387
```

Requested added delay, native game ping and RPC diagnostic are different observations. Game ping includes native estimation/processing; the RPC number uses a frame/tick-sensitive game clock. Zero additional delay is not zero physical latency.
