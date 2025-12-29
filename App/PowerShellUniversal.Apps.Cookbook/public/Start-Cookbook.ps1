function Start-Cookbook {
    [CmdletBinding()]
    param()

    # If DB doesn't exist, init file + schema
    if (-not (Test-Path $Script:RecipeDbPath)) {
        Initialize-RecipeDbFile -Database $Script:RecipeDbPath
        Initialize-RecipeDatabase -Schema $Script:RecipeSchemaSql -Database $Script:RecipeDbPath
        return
    }

    # If Recipes table doesn't exist, schema didn't apply
    $tables = Invoke-UniversalSQLiteQuery -Path $Script:RecipeDbPath -Query @"
SELECT name FROM sqlite_master WHERE type='table' AND name='Recipes';
"@

    if (-not $tables) {
        Initialize-RecipeDatabase -Schema $Script:RecipeSchemaSql -Database $Script:RecipeDbPath
    }
}
