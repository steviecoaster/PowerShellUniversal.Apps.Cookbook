function Get-FavoriteRecipe {
    [CmdletBinding()]
    param(
        [int]$Limit = 6
    )

    Invoke-RecipeDbQuery -Query @"
SELECT RecipeId, Title, PrepTimeMin, CookTimeMin, Servings, UpdatedAt
FROM Recipes
WHERE IsFavorite = 1
ORDER BY UpdatedAt DESC
LIMIT $Limit;
"@
}
