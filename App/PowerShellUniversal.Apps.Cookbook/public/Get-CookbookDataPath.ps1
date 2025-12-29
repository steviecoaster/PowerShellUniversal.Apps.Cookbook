function Get-CookbookDataPath {
    [CmdletBinding()]
    param()

    # 1) Allow override if you ever want it
    if ($env:COOKBOOK_DATA_PATH) {
        $path = $env:COOKBOOK_DATA_PATH
        if (-not (Test-Path $path)) {
            New-Item -Path $path -ItemType Directory -Force | Out-Null
        }
        return $path
    }

    # 2) Find the repository root based on the module path
    # /home/psuniversal/.PowerShellUniversal/Repository/Modules/<Module>/<Version>/public
    # -> /home/psuniversal/.PowerShellUniversal/Repository
    $repoRoot = $PSScriptRoot

    while ($repoRoot -and (Split-Path $repoRoot -Leaf) -ne 'Repository') {
        $parent = Split-Path $repoRoot -Parent
        if ($parent -eq $repoRoot) { break }
        $repoRoot = $parent
    }

    # Fallback if we can't locate Repository
    if (-not $repoRoot -or (Split-Path $repoRoot -Leaf) -ne 'Repository') {
        if ($env:HOME) {
            $repoRoot = Join-Path $env:HOME ".PowerShellUniversal\Repository"
        }
        else {
            # absolute last fallback
            $repoRoot = $PSScriptRoot
        }
    }

    # 3) Stable app data folder lives here
    $dataPath = Join-Path $repoRoot "Data/Cookbook"

    if (-not (Test-Path $dataPath)) {
        New-Item -Path $dataPath -ItemType Directory -Force | Out-Null
    }

    $dataPath
}
