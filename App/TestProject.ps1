Stop-Service PowerShellUniversal

$PSURoot = 'C:\ProgramData\UniversalAutomation\Repository\Modules'
$app = Join-Path $PSScriptRoot -ChildPath 'PowerShellUniversal.Apps.Cookbook'

Copy-Item $app -Recurse -Destination $PSURoot -Force

Start-Service PowerShellUniversal
Clear-Host