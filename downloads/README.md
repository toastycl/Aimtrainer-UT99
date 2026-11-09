# Development build 0.3.1

[Download compiled mod + map](UTAT-alpha-0.3.1.zip?raw=true). With UT closed, replace both System files and the Maps file. Preserve your personal ini files. See the [Spanish guide](../docs/QUICKSTART_ES.md).

Includes About / Credits with ToastyCL and the UTC build date. Retains random safe spawns, one Start button preserving weapon selection, results over the room, infinite ammo and timed rounds.

[Optional IGPlus developer experiment, unchanged at 0.3.0](UTAT-network-lab-0.3.0.zip?raw=true) is separate: automated Shock/Sniper client/server checks with controlled localhost delay. It requires the base room and separately installed official IGPlus 11 packages. [Instructions and ms selection](../docs/NETWORK_LAB.md). It is not yet a selectable training mode.

Only project content is distributed. No original game or IGPlus packages are included. Linux engine/client integration passed; manual hardware/visual and Windows/macOS acceptance remain pending. See [validation](../docs/VALIDATION.md) and [checksums](SHA256SUMS).

## WIP — selectable latency

[Compiled WIP lab](UTAT-network-lab-WIP.zip?raw=true) · [Contributor handoff and setup](../docs/WIP_SELECTABLE_PING.md) · [Checks](../docs/WIP_NETWORK_CHECKS.md). The external launcher accepts arbitrary integer ms and keeps an IGPlus sandbox open for manual firing. It requires the repository/Python helper, the base room and official IGPlus dependencies; these are not bundled. In-game numeric selection, network rounds and accuracy remain pending. The normal trainer remains 0.3.1.
