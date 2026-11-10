# Standalone architecture — 1.0.0

UTATGame/UTATPlayer own a local room. Native UWindow controls select weapon, exercise, distance, size and duration, pass them across map travel and start the round. UTATRoundController advances only active unpaused play time. Native projectile/trace adapters preserve classic weapons and emission accounting.

UTATTrainingOptions centralizes labels, scale and horizontal distance bands. UTATGame places three UTATTarget Pawn dummies with mesh/collision scaling and room/LOS/separation checks. Static and lateral patterns remain; evasive movement chooses random ground destinations/speeds, jump arcs and short dodge-like speed bursts, aerial movement chooses random 3D destinations. Invalid steps are rejected and retried; they do not terminate a round. All trajectories are controlled training motion, not human physics/network actors. Distance is relative to the starting anchor, while spawn safety also checks current player position.

UTATStore saves optional input profiles and ten bounded RoundEntry config records in UTAT.ini. Each finish saves once, shifts older entries and records completion plus weapon/target/input/metric context. Large config arrays are accessed/formatted inside the owning object to respect UE1's context-bytecode size limit. Native history pages render three entries and preserve setup choices. Beam contact is separate from projectile/trace accuracy. Fire style describes observed primary/secondary input, not hardware input verification.

The player ZIP contains compiled mod, int, own map and Spanish instructions. Python is developer tooling only. IGPlus/helper sources remain archived outside the build. No game assets or live server configuration are distributed or changed.
