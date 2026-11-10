# Standalone architecture — 0.4.1

UTATGame and UTATPlayer own a local practice room. The UWindow panel chooses weapon, exercise and duration, enters the map when necessary, starts the round and returns results over the world. There is no network environment selector or helper handshake in the active package.

LC weapon adapters and LP projectile adapters inherit stock UT weapons/projectiles and delegate behavior to their parents. Round-scoped emission tokens prevent splash/children from inflating successful-unit counts. Damage and eliminations are separate. Pulse beam contact time is scored independently of projectile accuracy. Custom simulated ammo UseAmmo retains 999 units.

Projectile replacement preserves instigator initialization and collision/physics properties and disables the original placeholder collision before replacement. Round completion clears projectiles; stale round tokens cannot score. UTATRoundController maintains active-play timing independently of inherited DM warmup/bot logic. Placement uses checked random player/target zones.

The player ZIP contains only project mod/int/map files and installation instructions. Developer Python build/test/export tools are not player dependencies. Historical IGPlus classes/helpers are archived outside the active build tree.
