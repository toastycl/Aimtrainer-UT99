# Validation status

Early source alpha, not a tested gameplay release.

| Check | Status |
| --- | --- |
| Python metrics/build-helper tests | 7 passing |
| UnrealScript compilation | PASS — UCC 469e Linux amd64: 0 errors, 0 warnings |
| Native Mods panel in client | Not tested |
| Target visibility/collision and shot counters in client | Not tested |
| Restoration across travel/exit | Not tested |
| Windows/macOS/Linux gameplay | Not tested |
| Online / IGPlus / anticheat | Not supported or tested |

Initial toolchain: official OldUnreal 469e Linux amd64 patch. Original assets required by Botpack are separate local dependencies, not distributed here. Source availability, compilation and runtime acceptance must be reported separately.

## Compiler evidence

All nine project classes parsed and compiled successfully with official 469e Linux amd64 UCC. `make -silent` acknowledges the intentional dependency on 469-era mouse properties; this package does not target v436. This is compiler validation, not runtime validation.

Build output: `dist/UTAT-alpha-0.1.0.zip`. Compiled package SHA-256: `3566daaeccc3f0c0259c452b0c13f3589987acaa069c49a3c303adf638ac7b40`.
