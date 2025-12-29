function Initialize-CookbookData {
    [CmdletBinding()]
    param()

    # Stable paths (must already be set by your psm1)
    if (-not $Script:RecipeDbPath) {
        throw "Initialize-CookbookData: `$Script:RecipeDbPath is not set."
    }

    if (-not $Script:RecipeSchemaSql) {
        throw "Initialize-CookbookData: `$Script:RecipeSchemaSql is not set."
    }

    # Ensure DB file exists
    Initialize-RecipeDbFile -Database $Script:RecipeDbPath

    # Apply schema FROM Schema.sql
    Initialize-RecipeDatabase -Schema $Script:RecipeSchemaSql -Database $Script:RecipeDbPath
}
