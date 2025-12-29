function Get-RecipeDatabasePath {
    [CmdletBinding()]
    param()

    if (-not $Script:RecipeDbPath) {
        throw "Recipe database path not initialized. `$Script:RecipeDbPath is not set. Check module initialization (.psm1)."
    }

    $Script:RecipeDbPath
}
