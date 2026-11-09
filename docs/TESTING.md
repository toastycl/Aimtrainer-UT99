# Manual acceptance

Python tests check tooling, not UnrealScript gameplay. Use a complete clean test installation.

1. Compile with UCC: zero errors, inspect warnings. Install UTAT.u and UTAT.int.
2. Launch UTATGame on a stock map. Confirm custom player, Shock-only loadout and Mods entry.
3. Check panel readability at 1024x768 and 1920x1080. Verify separate slot selection/apply/save.
4. Record original sensitivity and smoothing flags/threshold. Save A, change/save B and alternate A/B. Check restoration after command, map travel, normal quit and relaunch.
5. Run 10-second flicks. Deliberately hit/miss. Confirm one shot per trace, one hit per target, and no scored alt-fire.
6. Run strafe. Verify consistent lateral motion, visible skin, collision, no floor/wall clipping and no hits while hidden.
7. Cancel, die or change FOV/mouse settings during a run. Each run must end incomplete and be excluded from comparisons.
8. Start facing a wall or in a narrow lane. Expect explicit cancellation, never a run without a valid target.
9. Export complete/no-shot/no-hit/incomplete sessions. Compare same anchor/yaw against different starts; different scenarios must remain separate.
10. Attempt listen/dedicated login in a test environment. Expect explicit local-only rejection.

Keep backend, FOV, DPI, polling rate, FPS, renderer and game speed constant. The alpha cannot detect all external changes. Report exact client/OS/version and reproduction steps for failures. Do not recommend daily use until restoration and runtime behavior pass.
