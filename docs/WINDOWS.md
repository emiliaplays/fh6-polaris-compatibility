# Windows installation and rollback

## Requirements and limits

- 64-bit Windows and 64-bit Windows PowerShell 5.1 or newer.
- An RX 580 / RX 590 with the Polaris `VEN_1002&DEV_67DF` hardware ID. Other GPUs are not validated by this helper.
- An existing FH6 installation; no game files are supplied here.
- [7-Zip](https://www.7-zip.org/), internet access, administrator access for installation, and approximately 6 GB free for the download, extraction and backup. Actual backup size varies.
- Official AMD developer package **23.10.01.14**, downloaded by the helper. AMD publishes this package for RX 7000 hardware, not Polaris. The INF adaptation is experimental.
- The original upstream **single `d3d12.dll` Polaris proxy**. The universal dual-proxy version produced approximately 2 FPS on our test machine and is not the default here.

Our tested game version was `6.461.691.0`. Other builds may behave differently. Unsupported Windows preview builds, other injectors, multi-GPU configurations, overclocks and streaming can complicate diagnosis. We have not isolated all causes.

## 1. Extract and inspect

Extract the Windows release ZIP into a local folder. Review `requirements.json` and the PowerShell scripts. Run all steps with the game closed. Scripts with administrator privileges can alter the installed display driver, so read them before execution.

If Windows marks the ZIP as downloaded, inspect the files and use the file's **Properties → Unblock** where appropriate. Follow your machine's PowerShell execution policy; the package does not globally change that policy or bypass enterprise controls.

Keep a normal working-driver installer available before starting. Have access to any BitLocker recovery key before entering Windows Recovery. Save your work before each restart.

## 2. Identify the intended card

Open PowerShell in the extracted `windows` directory:

```powershell
Get-CimInstance Win32_PnPSignedDriver |
  Where-Object {$_.DeviceClass -eq 'DISPLAY'} |
  Select-Object DeviceName,DeviceID,InfName,DriverVersion
```

For a single matching Polaris card:

```powershell
.\Prepare-Windows.ps1 -GameDirectory 'D:\Games\Forza Horizon 6'
```

If more than one RX580/RX590 exists, preparation refuses to guess. Pass the exact `DeviceID` returned above:

```powershell
.\Prepare-Windows.ps1 -GameDirectory 'D:\Games\Forza Horizon 6' `
  -DeviceInstanceId 'PCI\VEN_1002&DEV_67DF&SUBSYS_XXXXXXXX&REV_XX\YOUR_DEVICE_INSTANCE'
```

Replace the complete example identifier. Do not copy an identifier from another computer. If driver export needs elevation on your PC, rerun this preparation in administrator PowerShell.

Preparation:

1. Downloads the official AMD installer and commit-pinned upstream proxy.
2. Verifies SHA-256 values and the AMD installer's Authenticode signature.
3. Extracts the driver with your installed 7-Zip.
4. Saves the original INF and adds the selected hardware ID to the existing Polaris10 section.
5. Exports the currently installed display-driver package into `windows/data/driver-backup-*`.
6. Writes a local `windows/data/setup.json` for installation.

It does not install a driver, alter the game folder, change security settings, or reboot.

**Retain the entire `data` directory locally. Never commit or upload it as a release.** It contains machine-specific state, proprietary downloads and backups.

## 3. Manual Windows startup prerequisites

Editing the INF invalidates the original catalog's hash for that INF. A valid signature on the downloaded AMD EXE does **not** make the edited driver package validly signed.

If you choose to test this unsupported package, the approach used in our session was:

1. Windows Security → Device security → Core isolation details → **Memory integrity: Off**.
2. Settings → System → Recovery → Advanced startup → Restart now.
3. Troubleshoot → Advanced options → Startup Settings → Restart.
4. Press **7/F7 — Disable driver signature enforcement**.

Handle security prompts and recovery screens yourself. These steps reduce protection; no helper changes boot flags, Secure Boot, Memory Integrity, signing enforcement or antivirus settings. If your policy or configuration prevents this, stop. Do not apply additional undocumented bypasses.

The Startup Settings option applies to the current boot. In our test the driver also loaded after a normal restart; this is an observation, not a promise for other Windows configurations. Verify the card after reboot.

## 4. Install and apply the game proxy

In **administrator 64-bit PowerShell**, from the extracted `windows` directory:

```powershell
.\Install-Windows.ps1
```

Windows may show an unsigned-driver confirmation. The helper does not auto-accept it. Installation can briefly blank screens and can affect other AMD cards because Windows shares the package between them.

On driver installation failure, the helper reports the native error and leaves the game DLLs unchanged. If installation succeeds, it backs up known existing Windows compatibility DLLs, removes the known `dxgi.dll` proxy if present, and places the pinned single `d3d12.dll` beside the game EXE. Unknown game DLLs are refused before installation.

Keep `install-result.json`, `setup.json` and the printed backup paths. The helper never automatically restarts Windows.

## 5. Verify before playing

```powershell
Get-CimInstance Win32_VideoController |
  Select-Object Name,DriverVersion,ConfigManagerErrorCode
```

Expected experimental display version: **31.0.21001.14018**. `ConfigManagerErrorCode=0` means the device reports no error, but does not prove gameplay or monitor output works. Visually check **every monitor**.

If displays disappear after installation, save work and restart Windows normally. Do not live-toggle either card in a linked multi-GPU system: this disrupted monitors on the other card in our test. Do not keep forcing card resets or hard shutdowns.

When launching FH6, an **FH301 old-driver warning** may appear. If proceeding with this experimental driver, use Ignore Warning. Start conservatively, with ray tracing off. Test game-only for at least 45–60 minutes, then compare streaming separately. A successful launch is not a stability test.

## 6. Roll back

### Driver

Use Device Manager → Display adapters → selected card → Properties → Driver → **Roll Back Driver**, if available. Otherwise use **Update driver → Browse my computer → Let me pick → Have Disk** and select the exported INF inside your recorded `driver-backup-*` directory, then the correct model. Because packages may be shared, check every AMD card afterward.

Alternatively reinstall the official current driver for your exact card from AMD. This can restore supported operation but can also restore FH6's original unsupported-hardware block.

If the display cannot recover, use Windows Recovery / Safe Mode to restore the official driver. After restoring the supported driver, re-enable Memory Integrity and restart. No helper automatically changes security settings.

### Game DLLs

Close FH6 and restore the recorded game-DLL backup:

```powershell
.\Restore-GameFiles.ps1 -BackupDirectory '.\data\game-dll-backup-YYYYMMDD-HHMMSS'
```

This restores only the proxy-file state; it does not roll back the display driver. It refuses an unexpected replacement DLL rather than overwrite it. Game saves and the game's `D3D12` subfolder are untouched.

## Sources

- [Forza official GPU support statement](https://support.forza.net/hc/en-us/articles/50088215399827-Forza-Horizon-6-PC-Specs)
- [AMD developer driver and compatibility list](https://www.amd.com/en/resources/support-articles/release-notes/RN-RAD-MS-AGILITY-SDK-2023-6-711.html)
- [Microsoft Startup Settings](https://support.microsoft.com/en-gb/windows/experience/startup-boot/windows-startup-settings)
- [Original Polaris proxy](https://github.com/Megadroidgames/Forza-Horizon-6-RX-580-FH201-FH205-Fix)
