#requires -Version 5.1
[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
Get-ChildItem -LiteralPath (Join-Path $root 'windows') -Filter '*.ps1' | ForEach-Object {
    $parseErrors=$null
    $tokens=$null
    [Management.Automation.Language.Parser]::ParseFile($_.FullName,[ref]$tokens,[ref]$parseErrors) | Out-Null
    if($parseErrors.Count){throw ($parseErrors | Out-String)}
}
Write-Output 'Windows helper syntax checks passed. No driver installation was tested.'
Write-Output 'On Linux / Git Bash, also run: bash tools/check-linux.sh'
