# 0.3.1 client regression evidence

Linux 469e, SDL offscreen / Mesa llvmpipe at 1280x720. Real viewport and UWindow callbacks. About was opened and closed both before and after room travel, retaining the selected Sniper and duration. No physical clicks or manual visual acceptance. Hostile inherited DM settings requested 8 bots and tournament readiness.

```text
PASS About opens with ToastyCL credit and build information
PASS closing About preserves selected weapon and duration
PASS About opens with ToastyCL credit and build information
PASS closing About preserves selected weapon and duration
PASS one Start button keeps selected Sniper across room travel
PASS selected duration survives room travel
PASS real standalone viewport is active
PASS combat bots and warmup remain disabled
PASS Start uses selected weapon and 30-second duration
PASS Start resumes world
PASS round clock advances
PASS manual finish stores results over the room
PASS manual finish does not open selection menu
PASS held fire is cleared at finish
PASS finish-frame fire cannot skip results or add a shot
PASS fresh fire acknowledges result and opens selector
PASS acknowledgement does not fire weapon or alter accuracy
PASS replay clears counters
PASS new round chooses a different safe trainee start
PASS eliminated target respawns
PASS target respawns at a different random point
PASS respawn stays away from trainee
PASS timed round finishes at selected duration
PASS timed result stays on screen without menu
PASS result HUD stays available
PASS post-timer fire opens selector without shooting
DONE failures=0
```
