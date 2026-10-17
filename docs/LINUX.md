# CachyOS / Linux installation

## Requirements

- RX580, a working `amdgpu` kernel driver and current Mesa **RADV** Vulkan stack.
- A configured Steam/Proton installation, or a properly configured Lutris/Heroic runner with VKD3D-Proton.
- Bash; `sha256sum` if using the Windows-proxy backup helper.
- For diagnostics: `vulkan-tools` (`vulkaninfo`) and `pciutils` (`lspci`). These are optional to launching.

This package has **not** been gameplay-tested on Linux. It implements a feature-level compatibility profile, not a compiled native driver or a complete port of the Windows DLL.

The Linux graphics path is game → Proton/VKD3D-Proton → Vulkan → RADV → amdgpu. Do **not** install the modified Windows AMD driver, disable kernel signing, or copy Windows system DirectX DLLs into Linux.

## 1. Prepare your runner

Update the installed CachyOS system through its normal full-update process. Use the distribution's Radeon/Mesa packages. VKD3D-Proton recommends RADV on AMD.

CachyOS recommends `proton-cachyos-slr` over its native flavor. If needed, install it using the [CachyOS gaming guide](https://wiki.cachyos.org/configuration/gaming/), restart Steam, and select it under **FH6 → Properties → Compatibility**. A current Valve Proton can also be a comparison runner. Do not change multiple runners/settings simultaneously while diagnosing.

Extract the Linux release ZIP, for example into:

```text
/home/YOU/FH6-Polaris-Linux-v0.1.0/
```

## 2. If the game folder came from Windows

Close the game. If our Windows `d3d12.dll` or `dxgi.dll` proxies are present beside the EXE, back them up:

```bash
bash "/home/YOU/FH6-Polaris-Linux-v0.1.0/linux/prepare-game.sh" "/path/to/Forza Horizon 6"
```

This moves only files matching the known patch SHA-256 values into `.fh6-windows-patch-backups` inside the specified game folder. It refuses unknown DLLs **before moving anything**. It does not delete the game's `D3D12` subfolder, runtime DLLs, save data or Proton prefix.

Use Proton's normal D3D12/DXGI loader setup. Remove old overrides specifically intended to load the Windows proxy. A shared Windows/Linux folder will need the saved Windows proxy files restored before returning to that Windows workaround.

Prefer a native Linux filesystem for the Proton prefix. For a shared NTFS game library, consult CachyOS's game-partition guidance; do not assume prefix behavior matches ext4/Btrfs.

## 3. Basic Steam launch option

In **FH6 → Properties → General → Launch Options**:

```bash
VKD3D_FEATURE_LEVEL=12_1 %command%
```

This uses VKD3D-Proton's upstream override instead of loading the Windows proxy. It can satisfy a feature-level query, but cannot implement unsupported shader instructions. Upstream's override also advertises some capabilities associated with feature level 12_1, so it is not an exact behavioral clone of the Windows patch.

## 4. Optional launcher and logs

For the included launcher, replace the username/path and keep the quotes:

```bash
bash "/home/YOU/FH6-Polaris-Linux-v0.1.0/linux/fh6-rx580.sh" %command%
```

Explicit `bash` invocation means no chmod is required. For a diagnostic run:

```bash
FH6_RX580_LOG=1 bash "/home/YOU/FH6-Polaris-Linux-v0.1.0/linux/fh6-rx580.sh" %command%
```

Local logs normally go to `~/.local/state/fh6-rx580/logs` (or `$XDG_STATE_HOME/fh6-rx580/logs`). Proton logs are named by the app ID; VKD3D logs are timestamped. Nothing uploads them. Turn logging off after reproducing a problem and review files for personal paths before sharing.

Collect system information:

```bash
bash "/home/YOU/FH6-Polaris-Linux-v0.1.0/linux/collect-info.sh"
```

For a GPU reset, separately inspect recent kernel messages:

```bash
journalctl -b -k --no-pager | grep -Ei 'amdgpu.*(timeout|reset|fault)|ring.*timeout' | tail -n 60
```

## Multiple GPUs

The helper does not disable cards or change screens. If the wrong adapter is selected, get its actual name from `vulkaninfo --summary`, then use a matching substring:

```bash
FH6_RX580_DEVICE="RX 580" bash "/home/YOU/FH6-Polaris-Linux-v0.1.0/linux/fh6-rx580.sh" %command%
```

A wrong filter can expose no usable GPU; remove it if device creation fails. Do not assume `DRI_PRIME=1` identifies the RX580 on a different PC.

## Lutris / Heroic

Use an already configured Proton/VKD3D runner. In the game's environment variables set **VKD3D_FEATURE_LEVEL** to **12_1**. Follow CachyOS's runner-specific setup guide. The included launcher can wrap a complete existing runner command, but cannot execute a bare Windows EXE itself.

## Validation and removal

Begin with ray tracing off, a conservative preset, and no Discord streaming. Test at least 45–60 minutes, then compare streaming. If it still reports FH201/FH205, collect the exact error and Proton log before adding more overrides.

To remove the profile, clear the launch option/environment override. Restore the backed-up Windows DLLs only if returning to the Windows setup. No Linux driver, boot setting, kernel option, or save file is changed.

## Sources

- [VKD3D-Proton implementation of feature-level override](https://github.com/HansKristian-Work/vkd3d-proton/blob/master/libs/vkd3d/device.c)
- [VKD3D-Proton driver and logging documentation](https://github.com/HansKristian-Work/vkd3d-proton/blob/master/README.md)
- [Proton configuration](https://github.com/ValveSoftware/Proton/blob/proton_10.0/README.md)
- [CachyOS gaming guide](https://wiki.cachyos.org/configuration/gaming/)
