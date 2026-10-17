#requires -Version 5.1
[CmdletBinding()]
param([string]$Version='0.1.0')
$ErrorActionPreference='Stop'
if($Version -notmatch '^\d+\.\d+\.\d+$'){throw 'Expected a semantic version such as 0.1.0.'}
$root=Split-Path -Parent $PSScriptRoot
$dist=Join-Path $root 'dist'
New-Item -ItemType Directory -Path $dist -Force | Out-Null
$archives=@()
foreach($platform in 'Windows','Linux'){
    $name='FH6-Polaris-'+$platform+'-v'+$Version
    $stage=Join-Path $dist ($name+'-stage-'+[Guid]::NewGuid().ToString('N'))
    $package=Join-Path $stage $name
    New-Item -ItemType Directory -Path $package -Force | Out-Null
    foreach($file in 'README.md','LICENSE','THIRD_PARTY_NOTICES.md'){Copy-Item -LiteralPath (Join-Path $root $file) -Destination $package}
    Copy-Item -LiteralPath (Join-Path $root 'docs') -Destination $package -Recurse
    $subdir=$platform.ToLowerInvariant()
    $target=Join-Path $package $subdir
    New-Item -ItemType Directory -Path $target | Out-Null
    if($platform -eq 'Windows'){
        Get-ChildItem -LiteralPath (Join-Path $root 'windows') -File | Where-Object {$_.Extension -in '.ps1','.json'} | Copy-Item -Destination $target
    }else{
        Get-ChildItem -LiteralPath (Join-Path $root 'linux') -File -Filter '*.sh' | Copy-Item -Destination $target
    }
    $start="Read docs/$($platform.ToUpperInvariant()).md before use.`nThis release is experimental. Read docs/VALIDATION.md for tested limits.`nWindows prerequisites are downloaded and verified locally; third-party drivers are not bundled.`n"
    [IO.File]::WriteAllText((Join-Path $package 'START-HERE.txt'),$start,[Text.UTF8Encoding]::new($false))
    $sumLines=Get-ChildItem -LiteralPath $package -File -Recurse | Sort-Object FullName | ForEach-Object {
        $relative=$_.FullName.Substring($package.Length+1).Replace('\','/')
        (Get-FileHash -LiteralPath $_.FullName).Hash.ToLowerInvariant()+'  '+$relative
    }
    [IO.File]::WriteAllText((Join-Path $package 'SHA256SUMS'),(($sumLines -join "`n")+"`n"),[Text.UTF8Encoding]::new($false))
    $zip=Join-Path $dist ($name+'.zip')
    Compress-Archive -LiteralPath $package -DestinationPath $zip -Force
    $archives+=,$zip
}
$releaseHashes=$archives | ForEach-Object {(Get-FileHash -LiteralPath $_).Hash.ToLowerInvariant()+'  '+(Split-Path -Leaf $_)}
[IO.File]::WriteAllText((Join-Path $dist 'SHA256SUMS'),(($releaseHashes -join "`n")+"`n"),[Text.UTF8Encoding]::new($false))
$archives | ForEach-Object {Write-Output $_}
