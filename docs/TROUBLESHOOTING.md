# Troubleshooting and known issues

| Symptom | Evidence / next step |
| --- | --- |
| Windows FH201/FH205 | Check driver version, exact GPU ID, and that the original pinned proxy is beside the EXE. Do not replace shader capabilities blindly. |
| FH301 | Expected older-driver warning with the experimental branch. Ignoring it is part of testing this workaround, not evidence of official support. |
| Approximately 2 FPS despite low settings | Our universal dual-proxy setup did this; the original single Polaris proxy improved performance on that machine. It is not a universal diagnosis. |
| Black screen / exit at splash | Save crash/pre-crash reports and proxy log. A driver timeout, hard reboot, changed cache or multi-GPU topology can complicate startup. There is no confirmed general fix here. |
| GPU driver reset after 20–40 minutes | Observed in our Windows session: `LiveKernelEvent 141`, AMD `amdkmdag.sys`, and `DXGI_ERROR_DEVICE_HUNG`. Test without streaming at stock GPU settings and compare. The cause remains unconfirmed. |
| RX580 Code 43 after installing on RX590 | Observed because the AMD package was shared. A normal reboot cleared it in our test; check all cards and monitors. Roll back if it persists. |
| Main/secondary monitors disappear after live card toggle | Observed on a linked RX590/RX580 setup. Both cards were re-enabled and a normal Windows restart restored the screens. Do not use live GPU disable/enable as a troubleshooting recipe here. |
| Linux still reports unsupported hardware | Confirm the runner actually uses VKD3D-Proton/RADV and the launch environment reaches the game; collect Proton logs. The single override may be insufficient. |

## What the reports proved

In the recorded long-session Windows failure, FH6 used about 4.7 GiB of a 7.2 GiB video-memory budget. That report did not indicate VRAM exhaustion. It does not rule out a memory-management bug. The GPU was on stock settings and Discord streaming was active; a causal link to streaming has not been established.

Windows GPU performance counters confirmed FH6 rendered on the RX590 during the low-FPS test. Intel UHD activity alone did not mean the game was rendering there. No claim is made that Discord was encoding on Intel; that was not measured.

## Preserve useful evidence

Windows local reports are normally under `%LOCALAPPDATA%\ForzaHorizon6`. The original proxy log is `ForzaFix_RX580.log` beside the game executable. Keep event timestamps, error codes, driver/game versions and whether streaming was active. Do not upload full dumps by default.

For Linux, collect `collect-info.sh`, Proton/VKD3D logs and the kernel GPU-reset messages from the Linux guide. Review paths and identifiers before publishing.

Do not lengthen watchdog/TDR limits as a generic fix. It may simply turn a recovered timeout into a longer freeze. Do not repeatedly reset cards or force power off. If the setup is unstable, restore the supported graphics driver and remove the workaround; FH6 may then return to its original hardware block.

## Official references

- [Microsoft: video engine timeout 0x141](https://learn.microsoft.com/en-us/windows-hardware/drivers/debugger/bug-check-0x141---video-engine-timeout-detected)
- [Microsoft: TDR registry keys are for driver development/testing](https://learn.microsoft.com/en-us/windows-hardware/drivers/display/tdr-registry-keys)
- [Forza: supported GPU architectures](https://support.forza.net/hc/en-us/articles/50088215399827-Forza-Horizon-6-PC-Specs)
