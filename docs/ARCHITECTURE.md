# Architecture — practice room

`UTATGame` runs a local room, not a settings wizard. `UTATRoomInfo` defines separate player/target spawn zones. `UTATSpawnPlanner` uses a per-round recorded random seed and placement rejection checks. Each round resets the player, equips the selected weapon, creates three static/strafe `UTATTarget` Pawns and resets counters. Targets have 100 HP and respawn after elimination.

Six adapters inherit stock weapons. Hitscan adapters surround each stock TraceFire with a `UTATShot` token. `UTATProjectileNotify` replaces exact stock primary projectile classes with subclasses that preserve stock flight/damage functions. Initial velocity/acceleration/physics and instigator are preserved. SpawnNotify returns compatible subclasses so subsequent stock weapon setup (such as loaded-rocket fields) applies to the replacement.

Each token belongs to a round and can count as a successful emission only once. Damage to multiple targets can increase damage/eliminations without increasing successful-emission count again. Round transitions clear tokens and remove pending player projectiles. Flak denominators count fragments, not shells.

The native UWindow panel is accessible from Mods even before entering the room. It provides weapon/exercise/duration selection and a single Start control that travels and starts with URL-carried settings if outside the room. Finish and cancel return to a world result overlay. A fresh primary fire acknowledges results without emitting a weapon shot; detailed configuration profiles remain optional console commands.

The included T3D room is rebuilt to a real .unr by UCC exec. Own grid textures are imported into UTAT.u. Unlit polygons permit a deterministic headless build without renderer-dependent lightmaps. Original assets and the compiler are not repository content.

Result schema v2 includes weapon, emission unit, eliminations and damage. The exporter supports legacy v1, separates weapon/scenario groups, and handles free practice. Continuous multi-target rounds do not claim a time-to-hit metric. Input backend and hardware latency are unverified.

`UTATSmokeTest`, enabled only by explicit ?SmokeTest=1, exercises engine map/round/weapon behavior without a rendered client. It does not validate UWindow rendering, mouse feel or real player input. Online player login remains disabled.

## 0.2.1 lifecycle fixes

InitGame/PostBeginPlay clear inherited DM bot/tournament/warmup preferences in memory, and AddBot/ForceAddBot/NeedPlayers are disabled. The level's trainee PlayerStart is a staging point separate from the round anchor and target origin. Training-player damage/telefrag protection prevents practice deaths.

UTATAmmo* classes override UseAmmo, retaining 999 units independently of round updates. UTATRoundController owns round updates instead of relying on GameInfo match ticking. Delta is divided by TimeDilation for real active-play seconds. Menu pause remains explicit; Start/Replay closes the menu and unpauses.

The controls window is unique/reused. If the UWindow root has not yet been created, opening is deferred until the console creates it. Finish is idempotent and results appear in the HUD without opening the menu. UTATClientTest drives a real standalone viewport and the actual UWindow callbacks, including a selected 30-second round, manual finish and replay.

## Optional network experiment

UTATNetLab builds independently and dynamically loads IGPlus 11 weapon classes. UTPure retains control of its player class. Its owner probe measures client-clock RPC round trips and fires from the actual client; the server target counts damage calls. A Python loopback UDP relay delays each direction by half the requested added RTT. The experiment does not reuse standalone UTAT accuracy accounting and has no training UI yet. IGPlus is a separate GPLv3 runtime dependency, not copied into this repository. See NETWORK_LAB.md.
