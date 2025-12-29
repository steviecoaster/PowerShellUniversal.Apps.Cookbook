function Get-RecipeTag {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$RecipeId
    )

    Invoke-RecipeDbQuery -Query @"
SELECT t.Name
FROM Tags t
JOIN RecipeTags rt ON rt.TagId = t.TagId
WHERE rt.RecipeId = $RecipeId
ORDER BY t.Name;
"@
}
