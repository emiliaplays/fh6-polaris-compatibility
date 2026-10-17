# FH6 Polaris compatibility: Windows and CachyOS

Experimental compatibility helpers for **Forza Horizon 6 on Radeon RX 580 / RX 590**.

**This is an unofficial workaround, not an official driver, a game update, or a guaranteed fix.** Forza officially excludes AMD Polaris/Vega from its supported GPU architectures. Bypassing a capability check does not implement missing GPU features.

| Platform | Approach | Observed / tested status |
| --- | --- | --- |
| Windows 11 + RX 590 | Original upstream Polaris D3D12 proxy + locally modified AMD Agility 23.10.01.14 INF | Reached gameplay around 50–60 FPS on Medium at 1080p on one PC; later GPU timeout and intermittent splash-screen exits. **Not stable.** |
| CachyOS / Linux + RX 580 | Proton / VKD3D-Proton feature-level launch profile | Shell behavior checked locally. **No Linux startup, performance, or gameplay validation yet.** |

The Discord stream used during the Windows session was 1440p/60; that was the stream setting, not the measured game render resolution. Streaming's contribution to the timeout is unconfirmed.

## Downloads and installation

Open [Releases](https://github.com/emiliaplays/fh6-polaris-compatibility/releases) and choose:

- **FH6-Polaris-Windows-v0.1.0.zip** — requirements downloader/verifier, hardware-specific preparation, installer, restoration helper, and Windows guide.
- **FH6-Polaris-Linux-v0.1.0.zip** — Bash launcher, optional diagnostics, known-Windows-DLL backup helper, and Linux guide.

Read the matching guide **before running a helper**:

- [Windows installation and rollback](docs/WINDOWS.md)
- [CachyOS / Linux installation and rollback](docs/LINUX.md)
- [Requirements and download provenance](docs/REQUIREMENTS.md)
- [Known issues and troubleshooting](docs/TROUBLESHOOTING.md)
- [What was actually tested](docs/VALIDATION.md)

The Windows ZIP does **not** redistribute the AMD driver or the upstream proxy binary. Its preparation helper downloads the official AMD installer and a pinned upstream proxy, verifies SHA-256 hashes and the AMD installer signature, then prepares the INF for the selected card on your PC. Install 7-Zip separately from its official site first. This avoids mirroring unlicensed third-party binaries and keeps the actual requirements explicit.

## Linux quick start

Use your normal `amdgpu` + Mesa RADV stack and an up-to-date Proton runner. For Steam launch options:

```bash
VKD3D_FEATURE_LEVEL=12_1 %command%
```

If using a game directory copied from Windows, first back up only the Windows workaround DLLs as described in the [Linux guide](docs/LINUX.md). Do not copy the modified Windows graphics driver to Linux.

## Windows quick outline

1. Install [7-Zip](https://www.7-zip.org/) and extract the Windows release ZIP.
2. Run `Prepare-Windows.ps1` as documented; it downloads/verifies prerequisites, backs up the installed display driver and prepares the INF.
3. Handle the documented Windows startup/security prerequisites manually. No helper changes boot-security settings.
4. Run `Install-Windows.ps1` as administrator and handle Windows' own driver warning if you choose to proceed.
5. Check **both** AMD cards and **every** monitor, then validate game startup and a long session.

On a PC with multiple AMD cards, Windows may apply the shared driver to more than the selected card. In our test this caused a temporary RX 580 Code 43; live card toggling disrupted the other card's monitors. **The helpers do not disable GPUs or change monitor topology.**

## Support reports

Use the [bug-report template](.github/ISSUE_TEMPLATE/bug_report.md). Include OS, GPU model/VRAM, runner or driver version, the exact error, and whether streaming was active. Review logs before posting: logs can contain local usernames and file paths. No helper automatically uploads diagnostics.

Do not post game executables, save files, personal crash dumps, credentials, or proprietary driver packages here.

## Credits and licenses

- Original Windows proxy: [Megadroidgames / João Lucas](https://github.com/Megadroidgames/Forza-Horizon-6-RX-580-FH201-FH205-Fix). Its binary is downloaded from a pinned upstream commit; it is **not included or relicensed** here.
- Linux translation/runtime: [VKD3D-Proton](https://github.com/HansKristian-Work/vkd3d-proton), [Proton](https://github.com/ValveSoftware/Proton), [Mesa RADV](https://docs.mesa3d.org/drivers/radv.html), and [CachyOS](https://wiki.cachyos.org/configuration/gaming/).
- AMD driver remains subject to AMD's own license and support policy.

Original scripts and documentation in this repository are [MIT licensed](LICENSE). See [third-party notices](THIRD_PARTY_NOTICES.md). This project is not affiliated with AMD, Microsoft, Playground Games, Valve, or CachyOS.
