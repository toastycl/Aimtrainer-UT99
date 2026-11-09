# Manual client acceptance

1. Install UTAT.u + UTAT.int in System and DM-UTAT-Room.unr in Maps on a test UT99 469e client.
2. Open Mods → UT99 Aimtrainer from the main menu, enter the room and reopen the panel. Check readable/non-overlapping controls at 1024x768 and 1920x1080.
3. Choose each weapon in turn. Verify primary timing/spread/physics, Sniper zoom and Minigun secondary. Other secondary modes should be explicitly unavailable.
4. Run static and moving exercises. Confirm three visible, human-shaped targets remain inside the room and respawn with 100 HP. Check head/body Sniper damage.
5. Deliberately hit and miss. Compare traces, Pulse projectiles, loaded rockets and Flak fragments against displayed denominators. One splash projectile damaging several targets must count as one successful emission. Accuracy must remain ≤100%.
6. Complete a timed round: results must appear automatically. Finish free practice manually: results must appear. Start again: same start, new targets, zeroed counters and no leftover projectiles.
7. Finish a timed round early/cancel: show score but exclude it from completed summaries. Test zero-shot, no-hit and immediate-finish rounds.
8. Change DPI/sensitivity through normal settings between rounds. Verify no mandatory profile or automatic DPI/input switch. Test original-setting restoration if using optional profile commands.
9. Export retained logs, verify separate weapons/units/scenarios and legacy v1 compatibility.
10. Confirm settings, bindings and normal gameplay after leaving the map and restarting the client.

The opt-in dedicated-engine smoke harness tests real map/weapon/score logic without a rendered client. It is not proof of menu rendering or mouse behavior. Do not recommend daily use until the above acceptance checks pass.
