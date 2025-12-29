function Get-Recipe {
    [CmdletBinding()]
    param(
        [string]$Search = "",
        [string]$Tag = "",
        [switch]$FavoriteOnly
    )

    $safeSearch = ($Search ?? "").Replace("'", "''")
    $safeTag    = ($Tag ?? "").Replace("'", "''")

    $favClause = if ($FavoriteOnly) { "AND r.IsFavorite = 1" } else { "" }

    $query = @"
SELECT
    r.RecipeId,
    r.Title,
    r.Description,
    r.PrepTimeMin,
    r.CookTimeMin,
    r.Servings,
    r.IsFavorite,
    r.UpdatedAt,
    COALESCE(GROUP_CONCAT(t.Name, ', '), '') AS Tags
FROM Recipes r
LEFT JOIN RecipeTags rt ON rt.RecipeId = r.RecipeId
LEFT JOIN Tags t ON t.TagId = rt.TagId
WHERE
    (r.Title LIKE '%$safeSearch%' OR r.Description LIKE '%$safeSearch%')
    $favClause
    AND (
        '$safeTag' = ''
        OR EXISTS (
            SELECT 1
            FROM RecipeTags rt2
            JOIN Tags t2 ON t2.TagId = rt2.TagId
            WHERE rt2.RecipeId = r.RecipeId
              AND t2.Name = '$safeTag'
        )
    )
GROUP BY r.RecipeId
ORDER BY r.IsFavorite DESC, r.UpdatedAt DESC;
"@

    Invoke-RecipeDbQuery -Query $query
}