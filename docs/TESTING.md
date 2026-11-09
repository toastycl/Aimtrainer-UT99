# Manual acceptance — 0.4.0

Use [QUICKSTART_ES.md](QUICKSTART_ES.md) to install and run the development package. Preserve normal settings and use a test copy of UT99 469e.

1. Check setup/About readability at 1024×768 and 1920×1080. Confirm eleven weapons in both Local and IGPlus.
2. Local: start each weapon, use both fire modes, verify stock behavior, unlimited ammo and three visible targets. Sniper secondary is zoom; Redeemer secondary has its guided camera.
3. IGPlus: launch through Start-Aimtrainer, enter arbitrary 0/37/85/143/300 ms, select a weapon/exercise/duration and Start. No external per-round command should be necessary.
4. Missing helper should time out with actionable feedback and keep setup available. Check invalid/blank/out-of-range ms, busy ports, missing packages and cancellation during startup.
5. Verify requested additional RTT and ping estimate are distinct. Do not require scoreboard ping to equal the requested delay. Local must not claim applied network delay.
6. Use static and moving targets, eliminate repeatedly, and confirm separated random respawns. Exercise movement, jump and dodge. Check Sniper head/body behavior against the simple target cylinder.
7. Deliberately hit and miss. Compare emitted traces/projectiles/fragments against counters; splash must not count one unit more than once. Check Shock combo component credit, Bio children, Flak shell fragments and Redeemer expanding blast.
8. Pulse secondary: inspect contact-time percentage separately from projectile accuracy. Test contact/loss of contact and a beam-only round.
9. Complete 30 seconds in each environment. Results must stay over the world. Hold fire at the deadline: it must not skip results. Release and press fresh primary fire: no extra shot and return to setup.
10. Free practice / Finish round, early Finish, Cancel, zero-shot rounds, menu pause/resume, replay and selection retention. No stale projectile should score in a new round.
11. Change weapon/ms/exercise/duration between rounds; a network Start must create a fresh session without stale delayed packets. Close the helper-owned game and check its owned helper/server/relay stop.
12. Change sensitivity/input using normal client settings, repeat the same weapon/fire style several times and verify settings/bindings remain usable. No DPI switch or mandatory profile should occur.

Native checks use actual engine/viewport/weapon calls and controlled target positions. They are not human aiming, hardware latency or complete visual acceptance. The first supported helper test path is Windows/Linux; macOS `.app` discovery is pending. No ACE or live-server equivalence is certified.
