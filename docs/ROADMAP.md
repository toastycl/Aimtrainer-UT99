# Tasks

## 0.2 — Room → choose → shoot → score → repeat

- [x] Create a simple flat training room and editable T3D source.
- [x] Compile and package a real .unr with the mod.
- [x] Remove mandatory profile workflow; use normal mouse settings.
- [x] Add weapon selector: Shock, Sniper, Minigun, Pulse, Rocket, Flak.
- [x] Add three static or laterally moving human-shaped targets.
- [x] Add timed rounds, free practice, end score and replay controls.
- [x] Count successful emissions once, including splash/fragment behavior.
- [x] Separate weapons/units in v2 result exports.
- [ ] Validate the complete rendered menu/input flow in a real Windows client.
- [ ] Validate the complete rendered menu/input flow on macOS/Linux.

## Next

- Add remaining weapons and secondary modes with clearly defined scoring.
- Add Shock combo exercises and continuous Pulse beam tracking.
- Add distance/target-size choices, direction changes, jumps and dodge exercises.
- Improve in-game history and comparisons; capture client/render/input metadata.
- Decide a source license before describing the project as open source.

## Later

Online lab with server-confirmed hits, replication and netcode/anticheat compatibility. Manual installation only; no automatic changes to live servers.

## 0.2.1 — tester-reported regressions

- [x] Separate player staging/round position from targets.
- [x] Disable inherited combat bots, tournament readiness and DM match ending.
- [x] True infinite ammo without depending on round tick/refill.
- [x] Independent active-play clock honoring selected seconds.
- [x] Manual Finish, automatic timed result, replay and persistent result HUD.
- [x] Run actual Linux viewport/UWindow callback integration with a 30-second round.
- [ ] Verify the corrected flow manually on the tester's client and mouse hardware.

## 0.3.0 — random spawns and result flow

- [x] Random safe trainee starts and distinct random target respawns.
- [x] Single Start control preserves weapon/duration through room travel.
- [x] Finish over the world; fresh primary fire returns to selection without shooting.
- [x] Real Linux client regression, including a 30-second timed round.
- [x] Separate IGPlus 11 Shock/Sniper client/server proof with localhost UDP delay.
- [ ] Integrate network lab selection, training rounds and accuracy accounting.
- [ ] Match a tester's exact IGPlus version/configuration and validate manually.
- [ ] Expose deterministic spawn seed replay for comparable sensitivity trials.

## 0.3.1 — project information

- [x] Add in-game About / Credits with ToastyCL, UTC build date and project scope.
- [x] Preserve setup selections when opening/closing About.
- [x] Rewrite README with installation, usage, scoring and explicit latency-selection instructions.
