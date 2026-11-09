# Standalone client regression evidence

Linux 469e, OpenGL/Mesa llvmpipe with SDL offscreen at 1280x720. Real viewport and actual UWindow callback integration; no physical mouse clicks or manual visual review. Inherited DM settings requested 8 bots, MinPlayers=8 and tournament readiness.

```text
PASS real standalone viewport is active
PASS hostile DM defaults do not spawn bots or kill trainee
PASS training controls created in real UWindow root
PASS Start button applies selected 30-second duration
PASS Start resumes gameplay and closes menu
PASS viewport weapon has true infinite ammo
PASS round clock advances in real standalone client
PASS Finish button ends round and retains scored statistics
PASS results stay visible in the live menu
PASS replay clears counters and old results
PASS 30-second round finishes automatically with results
PASS timed finish opens result controls
PASS persistent result HUD remains available after closing menu
DONE failures=0
```
