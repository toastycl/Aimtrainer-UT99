# Architecture — practice room

`UTATGame` runs a local room, not a settings wizard. `UTATRoomInfo` defines the start anchor. Each round resets the player, equips the selected weapon, creates three static/strafe `UTATTarget` Pawns and resets counters. Targets have 100 HP and respawn after elimination.

Six adapters inherit stock weapons. Hitscan adapters surround each stock TraceFire with a `UTATShot` token. `UTATProjectileNotify` replaces exact stock primary projectile classes with subclasses that preserve stock flight/damage functions. Initial velocity/acceleration/physics and instigator are preserved. SpawnNotify returns compatible subclasses so subsequent stock weapon setup (such as loaded-rocket fields) applies to the replacement.

Each token belongs to a round and can count as a successful emission only once. Damage to multiple targets can increase damage/eliminations without increasing successful-emission count again. Round transitions clear tokens and remove pending player projectiles. Flak denominators count fragments, not shells.

The native UWindow panel is accessible from Mods even before entering the room. It provides room entry, weapon/exercise/duration selection, start/replay, finish and cancel. End-of-round results reopen the panel; detailed configuration profiles remain optional console commands.

The included T3D room is rebuilt to a real .unr by UCC exec. Own grid textures are imported into UTAT.u. Unlit polygons permit a deterministic headless build without renderer-dependent lightmaps. Original assets and the compiler are not repository content.

Result schema v2 includes weapon, emission unit, eliminations and damage. The exporter supports legacy v1, separates weapon/scenario groups, and handles free practice. Continuous multi-target rounds do not claim a time-to-hit metric. Input backend and hardware latency are unverified.

`UTATSmokeTest`, enabled only by explicit ?SmokeTest=1, exercises engine map/round/weapon behavior without a rendered client. It does not validate UWindow rendering, mouse feel or real player input. Online player login remains disabled.
