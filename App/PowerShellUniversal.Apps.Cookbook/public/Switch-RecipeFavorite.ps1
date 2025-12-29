function Switch-RecipeFavorite {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$RecipeId
    )

    Invoke-RecipeDbQuery -Query @"
UPDATE Recipes
SET IsFavorite = CASE WHEN IsFavorite = 1 THEN 0 ELSE 1 END,
    UpdatedAt = datetime('now')
WHERE RecipeId = $RecipeId;
"@ | Out-Null
}