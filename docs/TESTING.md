# Manual acceptance — standalone 0.5.0

1. Close a test UT99 469e installation and replace the mod/int/map, preserving ini files. Open UT normally, Mods → UT99 Aimtrainer.
2. Choose Sniper, Random aerial, Medium, Normal, 30 seconds. Start with the only Start button. Confirm elevated dummies spawn/move and can be shot. Confirm timer ends and results stay over the room. Release fire then use fresh primary fire to return to setup.
3. Repeat with Small and Large: visual model and impact area should both change. Try Close/Medium/Far; measure from the initial anchor if checking UT units, not from a player who has moved.
4. Try Evasive / jumps for direction/speed changes and jump arcs. Repeat static/strafe to confirm original exercises remain available. Move around and check targets stay in the room and rounds do not stop at a wall.
5. Test all eleven weapons and both fire modes, infinite ammo, ground/aerial respawn, replay resets and safe random trainee placement. Hammer remains available; you may need to approach a reachable target. Pulse secondary shows beam contact separately; Sniper secondary zooms.
6. After finishing open Round history. Check latest settings/metrics and partial status for early finish/cancel. Navigate older/newer pages, return to setup and confirm selections are preserved. Generate more than ten rounds and confirm bounded history. Restart UT and check entries persist.
7. Test native GUI fit and readable labels at your normal resolution, OS/client and actual mouse input. Developer offscreen callbacks do not replace this acceptance.

For a report include client version, OS, resolution, weapon/fire style, exercise, distance/size, duration and reproduction steps. Preserve the relevant log before restarting and review it before sharing. No Python, external helper, IGPlus or ping controls should be required for players.
