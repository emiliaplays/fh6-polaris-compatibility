#requires -Version 5.1
[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$BackupDirectory)
$ErrorActionPreference='Stop'
if(Get-Process -Name forzahorizon6 -ErrorAction SilentlyContinue){throw 'Close FH6 first.'}
$state=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'data\setup.json') -Raw | ConvertFrom-Json
$manifest=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'requirements.json') -Raw | ConvertFrom-Json
$backup=(Resolve-Path -LiteralPath $BackupDirectory).Path
$expectedParent=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot 'data')).Path
if((Split-Path -Parent $backup) -ne $expectedParent -or (Split-Path -Leaf $backup) -notlike 'game-dll-backup-*'){throw 'Choose a game-dll-backup folder created by this package.'}
$current=Join-Path $state.GameDirectory 'd3d12.dll'
if(Test-Path -LiteralPath $current){
    if((Get-FileHash -LiteralPath $current).Hash -ne $manifest.proxy.sha256){throw 'Current d3d12.dll is not our pinned proxy; stop before overwriting another file.'}
}
foreach($name in 'd3d12.dll','dxgi.dll'){
    $target=Join-Path $state.GameDirectory $name
    if($name -eq 'dxgi.dll' -and (Test-Path -LiteralPath $target)){throw 'An unexpected dxgi.dll already exists; inspect it manually.'}
}
if(Test-Path -LiteralPath $current){Move-Item -LiteralPath $current -Destination (Join-Path $backup ('removed-installed-proxy-'+(Get-Date -Format 'yyyyMMdd-HHmmss')+'.dll'))}
foreach($name in 'd3d12.dll','dxgi.dll'){
    $saved=Join-Path $backup $name
    if(Test-Path -LiteralPath $saved){Copy-Item -LiteralPath $saved -Destination (Join-Path $state.GameDirectory $name)}
}
Write-Host 'Game DLL state restored from backup. The display driver has NOT been rolled back; follow docs/WINDOWS.md.'
