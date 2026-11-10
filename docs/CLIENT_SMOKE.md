# Native viewport and UWindow — 1.0.0

36 checks passing on OldUnreal 469e Linux amd64. Native engine/viewport callbacks are separate from physical mouse, visual and platform acceptance. Developer test fixtures are opt-in only.

```text
PASS round history opens inside native UT setup
PASS history pagination respects available entries
PASS history preserves aerial/distance/size selection
PASS About opens with ToastyCL credit and build information
PASS closing About preserves selected weapon and duration
PASS round history opens inside native UT setup
PASS history pagination respects available entries
PASS history preserves aerial/distance/size selection
PASS About opens with ToastyCL credit and build information
PASS closing About preserves selected weapon and duration
PASS one Start button keeps selected Sniper across room travel
PASS aerial, distance and size selections survive room travel
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
PASS history renders saved rounds in native viewport
PASS history pagination renders without leaving setup
PASS closing history preserves setup after results
DONE failures=0
```
