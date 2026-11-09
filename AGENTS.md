# Aimtrainer UT99

- Build a community-wide UT99 aim training tool. Use neutral branding and normal CTF weapon behavior; do not assume InstaGib.
- Keep the UTAT UnrealScript package self-contained. Never commit original game binaries/assets, personal ini files, credentials or local training logs.
- Report Python tests, UCC compilation and in-game validation separately. Never call a source alpha a working release without runtime evidence.
- Preserve the user's settings. New input-backend switches must identify actual OS/client support, restart requirements and restoration behavior.
- Use manual test installation/deployment. Do not change live game servers.
- Maintain README/roadmap/validation status alongside behavior changes. No open-source license has been selected.

- The main product flow is practice room → weapon/exercise → shoot → score → replay. Configuration profiles are optional.
- Include the simple map in installable ZIPs. Own compiled mod/map downloads are allowed; original UT packages are not.
