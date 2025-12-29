function Get-RecipeFavorite {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$RecipeId
    )

    $row = Invoke-RecipeDbQuery -Query "SELECT IsFavorite FROM Recipes WHERE RecipeId = $RecipeId;"
    if (-not $row) { return $false }

    return ([int]$row.IsFavorite -eq 1)
}