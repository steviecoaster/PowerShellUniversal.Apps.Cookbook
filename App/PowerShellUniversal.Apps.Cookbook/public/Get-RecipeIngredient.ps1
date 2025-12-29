function Get-RecipeIngredient {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$RecipeId
    )

    Invoke-RecipeDbQuery -Query "SELECT * FROM Ingredients WHERE RecipeId = $RecipeId ORDER BY SortOrder;"
}
