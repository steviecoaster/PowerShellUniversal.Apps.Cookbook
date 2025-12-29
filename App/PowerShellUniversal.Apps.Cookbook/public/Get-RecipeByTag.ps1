function Get-RecipeByTag {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$TagName,

        [int]$Limit = 200
    )

    $tagSafe = ConvertTo-SqlSafe $TagName

    Invoke-RecipeDbQuery -Query @"
SELECT r.RecipeId, r.Title, r.Description, r.PrepTimeMin, r.CookTimeMin, r.Servings, r.IsFavorite, r.UpdatedAt
FROM Recipes r
JOIN RecipeTags rt ON rt.RecipeId = r.RecipeId
JOIN Tags t ON t.TagId = rt.TagId
WHERE t.Name = '$tagSafe'
ORDER BY r.UpdatedAt DESC
LIMIT $Limit;
"@
}
