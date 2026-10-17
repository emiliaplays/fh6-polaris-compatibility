# Validation record

## Observed Windows session

- Windows 11 preview build 26300; Intel i9-13900K; 32 GiB RAM; RX590 8 GB plus RX580 and UHD770.
- Game version `6.461.691.0`, rendering at 1920×1080 in the recorded crash report.
- Official Polaris/Vega 26.5.2 did not launch this game with the installed workaround.
- Locally modified AMD Agility 23.10.01.14, display version `31.0.21001.14018`, plus the original single upstream Polaris proxy reached reported 50–60 FPS at Medium.
- The universal pair had previously produced approximately 2 FPS.
- A later long session timed out in the AMD driver while Discord streaming was active; stock GPU settings were reported. Subsequent launch failures also occurred. **Long-session stability was not established.**
- Driver installation affected the second AMD card. A reboot cleared its Code 43. A later disable/enable test disturbed monitor output until another normal reboot. That action is not automated or recommended by this repository.

## Repository / release checks

Windows helpers are newly written for public distribution. They are parsed for PowerShell syntax; the generic hardware-selection, download and driver-install workflow has **not** been end-to-end tested on another computer. The earlier successful local installation used a separate session-specific helper, not this release script.

Linux scripts are checked for Bash syntax, safe command-argument forwarding, exit status, optional local logging and refusal to move unknown DLLs. A local check also verified that backing up the known Windows DLL preserves its bytes. Repeat local checks with `bash tools/check-linux.sh` and `./tools/Check-Scripts.ps1` in PowerShell. These checks do not run FH6 or install a driver.

No Linux FH6 startup or gameplay has been tested. No Linux GPU-performance claim is made.

## Reporting a result

Include exact versions, GPU/VRAM, game settings, whether streaming was active, total session duration, and the precise error. Separate startup success, observed frame rate, and sustained stability. A menu screenshot alone is not a stable-gameplay result.
