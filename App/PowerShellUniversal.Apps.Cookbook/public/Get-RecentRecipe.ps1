function Get-RecentRecipe {
    [CmdletBinding()]
    param(
        [int]$Limit = 6
    )

    Invoke-RecipeDbQuery -Query @"
SELECT RecipeId, Title, PrepTimeMin, CookTimeMin, Servings, UpdatedAt, IsFavorite
FROM Recipes
ORDER BY UpdatedAt DESC
LIMIT $Limit;
"@
}