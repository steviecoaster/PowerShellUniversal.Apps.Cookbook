function Set-RecipeFavorite {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int]$RecipeId,
        [Parameter(Mandatory)][bool]$IsFavorite
    )

    $fav = if ($IsFavorite) { 1 } else { 0 }

    Invoke-RecipeDbQuery -Query @"
UPDATE Recipes
SET IsFavorite = $fav,
    UpdatedAt = datetime('now')
WHERE RecipeId = $RecipeId;
"@ | Out-Null
}