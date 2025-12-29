function Get-Tag {
    [CmdletBinding()]
    param(
        [int]$Limit = 50
    )

    Invoke-RecipeDbQuery -Query @"
SELECT
    t.TagId,
    t.Name,
    COUNT(rt.RecipeId) AS RecipeCount
FROM Tags t
LEFT JOIN RecipeTags rt ON rt.TagId = t.TagId
GROUP BY t.TagId, t.Name
ORDER BY RecipeCount DESC, t.Name ASC
LIMIT $Limit;
"@
}
