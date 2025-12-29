function Invoke-CookbookDatabaseMigration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$DestinationDbPath
    )

    # Don't overwrite an existing DB
    if (Test-Path $DestinationDbPath) {
        return
    }

    # Old DB candidates - module versioned folder patterns
    $oldCandidates = @(
        Join-Path $PSScriptRoot "data/recipes.db"
        Join-Path $PSScriptRoot "data/cookbook.db"
        Join-Path $PSScriptRoot "recipes.db"
        Join-Path $PSScriptRoot "cookbook.db"
    ) | ForEach-Object {
        try { [System.IO.Path]::GetFullPath($_) } catch { $_ }
    } | Select-Object -Unique

    $sourceDb = $oldCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $sourceDb) {
        return
    }

    $destFolder = Split-Path $DestinationDbPath -Parent
    if (-not (Test-Path $destFolder)) {
        New-Item -Path $destFolder -ItemType Directory -Force | Out-Null
    }

    Copy-Item -Path $sourceDb -Destination $DestinationDbPath -Force
    Write-Information "Migrated DB from '$sourceDb' to '$DestinationDbPath'" -InformationAction Continue
}
