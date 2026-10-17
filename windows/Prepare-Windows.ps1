#requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$GameDirectory,
    [string]$DeviceInstanceId,
    [string]$SevenZip
)
$ErrorActionPreference='Stop'
if(-not [Environment]::Is64BitProcess){throw 'Use 64-bit PowerShell.'}
if(Get-Process -Name forzahorizon6 -ErrorAction SilentlyContinue){throw 'Close FH6 before preparation.'}
$manifest=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'requirements.json') -Raw | ConvertFrom-Json
$game=(Resolve-Path -LiteralPath $GameDirectory).Path
if(-not (Test-Path -LiteralPath (Join-Path $game 'forzahorizon6.exe'))){throw 'Choose the folder containing ForzaHorizon6.exe.'}
if(-not $SevenZip){
    $candidates=@("$env:ProgramFiles\7-Zip\7z.exe",'C:\Program Files\7-Zip\7z.exe')
    $SevenZip=$candidates | Where-Object {Test-Path -LiteralPath $_} | Select-Object -First 1
}
if(-not $SevenZip -or -not (Test-Path -LiteralPath $SevenZip)){throw 'Install 7-Zip from https://www.7-zip.org/ or pass -SevenZip with the full path to 7z.exe.'}
$devices=@(Get-CimInstance Win32_PnPSignedDriver | Where-Object {$_.DeviceClass -eq 'DISPLAY' -and $_.DeviceName -match 'RX\s*(580|590)'})
if($DeviceInstanceId){$devices=@($devices | Where-Object {$_.DeviceID -eq $DeviceInstanceId})}
if($devices.Count -ne 1){
    $devices | Select-Object DeviceName,DeviceID | Format-List | Out-Host
    throw 'Specify exactly one RX580/RX590 using -DeviceInstanceId. No hardware or files have been changed.'
}
$device=$devices[0]
$hardwareId=($device.DeviceID -split '\\')[0..1] -join '\'
if($hardwareId -notmatch '^PCI\\VEN_1002&DEV_67DF&SUBSYS_[0-9A-F]{8}&REV_[0-9A-F]{2}$'){throw 'Unsupported hardware identifier; stop rather than guess an INF entry.'}
$data=Join-Path $PSScriptRoot 'data'
New-Item -ItemType Directory -Path $data -Force | Out-Null
function Get-VerifiedDownload($entry){
    $destination=Join-Path $data $entry.file
    if(-not (Test-Path -LiteralPath $destination)){
        Write-Host ('Downloading '+$entry.file)
        [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -UseBasicParsing -Uri $entry.url -Headers @{Referer='https://www.amd.com/'} -OutFile $destination
    }
    $actual=(Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash
    if($actual -ne $entry.sha256){throw ('SHA256 mismatch: '+$destination+'. Stop; do not bypass this verification.')}
    return $destination
}
$driver=Get-VerifiedDownload $manifest.amd
$signature=Get-AuthenticodeSignature -LiteralPath $driver
if($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notmatch 'O=Advanced Micro Devices Inc\.'){
    throw 'The downloaded AMD installer does not have the expected valid AMD signature.'
}
$proxy=Get-VerifiedDownload $manifest.proxy
$extract=Join-Path $data 'agility-driver'
$inf=Join-Path $extract 'Packages\Drivers\Display\WT6A_INF\u0393161.inf'
if(-not (Test-Path -LiteralPath $inf)){
    & $SevenZip x $driver ('-o'+$extract) -y -bsp0 -bso0
    if($LASTEXITCODE -ne 0){throw '7-Zip extraction failed.'}
}
$originalInf=Join-Path $data 'u0393161.original.inf'
if(-not (Test-Path -LiteralPath $originalInf)){Copy-Item -LiteralPath $inf -Destination $originalInf}
$text=[IO.File]::ReadAllText($originalInf)
$section='[ATI.Mfg.NTamd64.10.0.1..16299]'
if(-not $text.Contains($section) -or -not $text.Contains('[ati2mtag_Polaris10]') -or -not $text.Contains('[Strings]')){throw 'Unexpected INF layout.'}
$entry='"%FH6PolarisExperimental%" = ati2mtag_Polaris10, '+$hardwareId
$text=$text.Replace($section,($section+"`r`n"+$entry))
$text=$text.Replace('[Strings]',('[Strings]'+"`r`n"+'FH6PolarisExperimental="Radeon Polaris - Experimental Agility 23.10.01.14"'))
[IO.File]::WriteAllText($inf,$text,[Text.Encoding]::Unicode)
$backup=Join-Path $data ('driver-backup-'+(Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Path $backup | Out-Null
& pnputil.exe /export-driver $device.InfName $backup
if($LASTEXITCODE -ne 0){throw 'Could not export the original display driver. Do not install until a backup is available.'}
$state=@{Version=$manifest.version;GameDirectory=$game;DeviceInstanceId=$device.DeviceID;HardwareId=$hardwareId;OriginalInf=$device.InfName;OriginalDriver=$device.DriverVersion;BackupDirectory=$backup;InfPath=$inf;ProxyPath=$proxy;PreparedAt=(Get-Date -Format o)}
$state | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $data 'setup.json') -Encoding UTF8
Write-Host 'Prepared and verified. No display driver has been installed and no game DLL has been changed.'
Write-Host ('Original display driver backup: '+$backup)
Write-Host 'Read docs/WINDOWS.md for the manual startup prerequisites, installation and rollback.'
