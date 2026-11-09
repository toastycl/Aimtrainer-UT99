# Architecture — development build 0.4.0

## Local practice

`UTATGame` runs standalone with `UTATPlayer`, an independent active-play round controller, random safe player/target placement and three stationary/lateral-strife Pawn targets. DeathMatch bot fill, warmup and ordinary match ending are disabled. `LC*` adapters inherit the eleven stock weapons; `LP*` adapters inherit stock projectiles. Custom ammo implements simulated `UseAmmo` without depletion, both before and during rounds.

Each emitted trace/projectile/fragment receives a round-scoped token. Damage to several targets marks it successful once. Spawned explosion children inherit an existing parent token. Damage and eliminations remain separate. Shock combo damage credits the orb and its detonating trace. Pulse secondary tracks beam contact time separately rather than inventing projectile shots for a continuous beam.

## Network practice

`UTATRoundGame` owns the authoritative timer, placement, respawns, scoring and round completion. It keeps UTPure's actual player class. `NW*` and `NP*` instrumentation adapters inherit IGPlus 11 implementations and delegate behavior to Super; they do not substitute stock weapons for IGPlus weapons.

The projectile SpawnNotify runs server-side only. It temporarily inherits the original instigator **before** spawning its replacement, disables the original placeholder collision to prevent replacement/original contact, then preserves owner, location, rotation, collision dimensions/flags, velocity, acceleration and physics; subsequent weapon initialization applies to the returned compatible subclass. This matters for parent PostBeginPlay initialization, such as Shock projectiles and the Pulse beam. Projectile wrapping must not run as a non-simulated all-actor replacement on clients, which could disrupt unrelated client actors/move pools.

`UTATRoundState` derives from the package-independent `UTATNetworkState` view model in UTAT. It replicates server counters, elapsed time and result state, measures owner RPC round trips and requests menu pause/finish. Its always-ticking owner controller remains reachable while the private level is paused; closing setup resumes it through the owner RPC. `UTATNetworkHUD` renders live statistics and the result over the world. A fresh primary fire is intercepted by the compatible weapon adapter, acknowledges the result and travels to local setup without firing. Held fire is cleared when the result arrives. Configuration is retained in UTATStore.

## In-game selection and helper

The UWindow setup provides environment, an integer 0–300 ms field, eleven weapons, exercise and duration. Local mode starts directly. IGPlus sends a strict localhost UDP request through `UTATNetworkBridge`; it keeps setup visible until a READY or ERROR reply and has a timeout/cancel path.

The Python standard-library helper validates requests, replaces its previous private session, starts a dedicated server and a single-client UDP delay relay, waits for engine readiness, then replies READY. Only then does the client travel through the relay. Requested latency is split evenly between directions. Closing the helper-owned client stops owned processes/transports. Nothing targets production servers.

| Port | Purpose |
| --- | --- |
| UDP 18778 on 127.0.0.1 | Control request/ready/error/cancel |
| UDP 18777 on 127.0.0.1 | Delayed game endpoint |
| UDP 17777 on 127.0.0.1 | Private dedicated game server |

The control packet is `START|request-id|weapon-key|added-rtt-ms|exercise|duration`. Replies are `READY|request-id` or `ERROR|request-id|message`; `CANCEL|request-id` cancels a matching owned request. No arbitrary command, destination address or game class is accepted from the menu.

The helper copies normal engine/user settings on first startup into practice ini files. Client and dedicated-server engine ini files are separate to avoid competing writes. Normal User.ini / UnrealTournament.ini are not edited. The package uses UCC as a server executable, not as a compiler on the player's machine.

## Metrics and limits

Requested added RTT is distinct from native UT Game ping, displayed from PlayerReplicationInfo.Ping. The separate client-clock RPC diagnostic includes frame/tick effects and is not a hardware-latency measurement. Neither value is forced to match the request. A 0 ms request adds no delay; it is not a zero-latency physical connection. No jitter, loss or bandwidth emulation is included.

Local logs retain schema v2 with a new `all-fire-units-v3` protocol and optional beam fields; the exporter supports beam-only rounds without treating them as zero-percent projectile accuracy. Network logs currently use `NETRESULT` and are not imported by the local exporter. Native tests are opt-in and disabled during ordinary play.

The simple Pawn targets are not equivalent to replicated IGPlus human-player hitboxes. Exact live-server profiles, physical input, Windows/macOS behavior and anticheat compatibility require separate acceptance. Original UT assets/toolchain and IGPlus are external dependencies.
