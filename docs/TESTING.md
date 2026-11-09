# Manual client acceptance

1. Install UTAT.u + UTAT.int in System and DM-UTAT-Room.unr in Maps on a test UT99 469e client.
2. Open Mods → UT99 Aimtrainer from the main menu, select Sniper and use the single Start training button; verify it enters with Sniper. Check readable/non-overlapping controls at 1024x768 and 1920x1080.
3. Choose each weapon in turn. Verify primary timing/spread/physics, Sniper zoom and Minigun secondary. Other secondary modes should be explicitly unavailable.
4. Run static and moving exercises. Confirm three visible, human-shaped targets remain inside the room and respawn with 100 HP. Check head/body Sniper damage.
5. Deliberately hit and miss. Compare traces, Pulse projectiles, loaded rockets and Flak fragments against displayed denominators. One splash projectile damaging several targets must count as one successful emission. Accuracy must remain ≤100%.
6. Complete a timed round: results must appear over the world without opening the menu. Finish free practice manually: results must appear. Start again: different random safe start, new targets, zeroed counters and no leftover projectiles.
7. Finish a timed round early/cancel: show score but exclude it from completed summaries. Test zero-shot, no-hit and immediate-finish rounds.
8. Change DPI/sensitivity through normal settings between rounds. Verify no mandatory profile or automatic DPI/input switch. Test original-setting restoration if using optional profile commands.
9. Export retained logs, verify separate weapons/units/scenarios and legacy v1 compatibility.
10. Confirm settings, bindings and normal gameplay after leaving the map and restarting the client.

The opt-in dedicated-engine smoke harness tests real map/weapon/score logic without a rendered client. It is not proof of menu rendering or mouse behavior. Do not recommend daily use until the above acceptance checks pass.

## 0.2.1 regressions

- With your normal DM settings still enabling bots, launch the room and verify no combat bots appear. Do not clear your personal ini files.
- Confirm random safe positions on the player side and three targets in their separate area.
- Fire each weapon before and during a round. Ammo should remain at 999 without pickups/reloads.
- Select 30 seconds, click Start and play until automatic results appear. Opening the menu deliberately pauses active practice; Start training must resume it.
- During another round, open controls and choose Finish round. Controls must close and the score must appear over the room. A held fire must not skip the result; a fresh primary fire returns to selection without firing or changing counters.
- Repeat several times. Counters reset; there should be only one controls window and no old projectiles.
- Developer integration: `python scripts/client_smoke.py --ut-root /path/to/UT --offscreen` on Linux with a working SDL offscreen renderer, or omit --offscreen for a normal client. This requires a complete game installation and runs a 30-second viewport test.

## 0.3.0 regressions

- Eliminate targets repeatedly: their respawns must vary and stay separated from the trainee.
- Outside the room choose Sniper + 30 seconds and use Start training once. Neither choice may reset during travel.
- Confirm only one Start button exists.
- Let a round end while firing: results stay over the world. Release and press primary fire again to choose the next round. Check no extra shot is counted.
- Repeat with static/moving targets and each supported weapon.
- Optional network experiment and its separate limits: NETWORK_LAB.md.
