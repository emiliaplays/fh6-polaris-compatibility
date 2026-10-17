#requires -Version 5.1
#requires -RunAsAdministrator
[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
if(-not [Environment]::Is64BitProcess){throw 'Use 64-bit PowerShell.'}
if(Get-Process -Name forzahorizon6 -ErrorAction SilentlyContinue){throw 'Close FH6 first.'}
$data=Join-Path $PSScriptRoot 'data'
$state=Get-Content -LiteralPath (Join-Path $data 'setup.json') -Raw | ConvertFrom-Json
$manifest=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'requirements.json') -Raw | ConvertFrom-Json
if(-not (Test-Path -LiteralPath $state.InfPath)){throw 'Prepared driver missing; run Prepare-Windows.ps1 first.'}
if((Get-FileHash -LiteralPath $state.ProxyPath).Hash -ne $manifest.proxy.sha256){throw 'Proxy verification failed.'}
$device=Get-CimInstance Win32_PnPEntity | Where-Object {$_.PNPDeviceID -eq $state.DeviceInstanceId}
if(-not $device){throw 'The selected device is no longer present.'}
if(-not (Get-ChildItem -LiteralPath $state.BackupDirectory -Filter '*.inf')){throw 'Original driver backup missing.'}
$hvci=Get-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity' -ErrorAction SilentlyContinue
if($hvci.Enabled -eq 1){throw 'Memory Integrity is enabled. Read the manual prerequisites. This helper will not change security settings.'}
$game=$state.GameDirectory
$paths=@()
foreach($name in 'd3d12.dll','dxgi.dll'){
    $path=Join-Path $game $name
    if(Test-Path -LiteralPath $path){
        $item=Get-Item -LiteralPath $path
        if($item.Attributes -band [IO.FileAttributes]::ReparsePoint){throw ('Refusing linked file: '+$path)}
        if((Get-FileHash -LiteralPath $path).Hash -notin $manifest.knownProxyHashes){throw ('Unknown game DLL; inspect manually before continuing: '+$path)}
        $paths+=,$path
    }
}
Write-Warning 'Experimental driver installation can reset displays and affect other AMD cards sharing the package.'
Write-Warning 'The modified INF has an invalidated catalog hash. Handle any Windows confirmation yourself.'
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class FH6PolarisInstall {
[DllImport("newdev.dll", CharSet=CharSet.Unicode, SetLastError=true)]
[return: MarshalAs(UnmanagedType.Bool)]
public static extern bool UpdateDriverForPlugAndPlayDevicesW(IntPtr parent,string hardwareId,string infPath,uint flags,[MarshalAs(UnmanagedType.Bool)] out bool rebootRequired);
}
'@
$reboot=$false
$ok=[FH6PolarisInstall]::UpdateDriverForPlugAndPlayDevicesW([IntPtr]::Zero,$state.HardwareId,$state.InfPath,1,[ref]$reboot)
$errorCode=[Runtime.InteropServices.Marshal]::GetLastWin32Error()
@{Success=$ok;Win32Error=$errorCode;RebootRequired=$reboot;Time=(Get-Date -Format o)} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $data 'install-result.json')
if(-not $ok){throw ('Driver installation failed: 0x{0:X8}. Game DLLs have not been changed.' -f $errorCode)}
$gameBackup=Join-Path $data ('game-dll-backup-'+(Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Path $gameBackup | Out-Null
foreach($path in $paths){Move-Item -LiteralPath $path -Destination $gameBackup}
Copy-Item -LiteralPath $state.ProxyPath -Destination (Join-Path $game 'd3d12.dll')
Write-Host ('Installed. Game DLL backup: '+$gameBackup)
Write-Host ('Windows reports reboot required: '+$reboot)
Write-Host 'Check every GPU and monitor before launching FH6. Do not disable/re-enable cards to recover a linked multi-GPU desktop.'
Write-Host 'Read the rollback guide if a card fails, displays disappear, or GPU timeouts recur.'
