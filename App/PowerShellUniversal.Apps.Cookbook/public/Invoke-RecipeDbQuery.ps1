function Invoke-RecipeDbQuery {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Query
    )

    $dbPath = Get-RecipeDatabasePath

    if (-not (Test-Path $dbPath)) {
        # Create DB file if missing (SQLite will also create, but your wrapper checks Test-Path)
        $dbFolder = Split-Path $dbPath -Parent
        if ($dbFolder -and -not (Test-Path $dbFolder)) {
            New-Item -Path $dbFolder -ItemType Directory -Force | Out-Null
        }

        New-Item -Path $dbPath -ItemType File -Force | Out-Null
    }

    Invoke-UniversalSQLiteQuery -Path $dbPath -Query $Query
}
