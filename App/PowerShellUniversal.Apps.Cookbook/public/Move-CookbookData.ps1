function Move-CookbookData {
    [CmdletBinding()]
    param()

    $stableDb = Get-RecipeDatabasePath

    # Old DB probably lived next to module functions or at module root
    $oldDbCandidates = @(
        Join-Path $PSScriptRoot "..\cookbook.db"
        Join-Path $PSScriptRoot "..\..\cookbook.db"
        Join-Path $PSScriptRoot "cookbook.db"
    ) | ForEach-Object { [System.IO.Path]::GetFullPath($_) } | Select-Object -Unique

    $oldDb = $oldDbCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $oldDb) {
        return
    }

    if (-not (Test-Path $stableDb)) {
        $destFolder = Split-Path $stableDb -Parent
        if (-not (Test-Path $destFolder)) {
            New-Item -Path $destFolder -ItemType Directory -Force | Out-Null
        }

        Copy-Item -Path $oldDb -Destination $stableDb -Force
    }
}
