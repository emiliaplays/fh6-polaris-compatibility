# Requirements and provenance

## Contents of releases

Both ZIPs contain only original scripts, documentation, MIT license and third-party notices. No game files, AMD binaries, downloaded hardware state or credentials are included.

### Windows

| Requirement | How obtained | Verification |
| --- | --- | --- |
| AMD Agility 23.10.01.14, about 645 MiB | Preparation script, directly from `drivers.amd.com` | Pinned SHA-256 **and** valid AMD Authenticode signature |
| Polaris `d3d12.dll` | Original author's repository at commit `8448b2a0f5f4350f6e574a293a7b34f6cbbc59e1` | Pinned SHA-256 |
| 7-Zip command-line extractor | Install separately from [7-zip.org](https://www.7-zip.org/) | Use the official distribution; not bundled |
| Original installed-driver backup | Exported locally using `pnputil /export-driver` | Retained locally with its original INF/catalog/files |

All URLs/hashes are in [`windows/requirements.json`](../windows/requirements.json). If a downloaded hash changes, **stop and investigate**. Do not edit the manifest just to silence verification.

Downloads require network access; the Windows ZIP is a preparation kit, not a self-contained offline driver installer. To prepare an offline installation, run preparation on the target Windows PC while online, retain its entire generated `windows/data` directory, then perform the documented installation there. Do not distribute your machine-specific backup/state as a public release.

### Linux

The package uses the existing distribution graphics stack and Proton runner. It does not redistribute Mesa or Proton. On CachyOS/Arch the relevant packages normally include `mesa`, `vulkan-radeon`, the 32-bit equivalents needed by your runner, and optionally `vulkan-tools`, `pciutils`, and `proton-cachyos-slr`. Use the distribution's current full-update/install instructions rather than a partial system upgrade.

## Why the AMD driver is not in the release ZIP

The driver is a proprietary third-party download. The original proxy repository also had no detected redistribution license when checked. This project credits the owners and downloads the prerequisites from their sources, instead of granting rights it does not own. Local changes to the INF do not change the driver's license or add official Polaris support.
