function Get-RecipeStep {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$RecipeId
    )

    Invoke-RecipeDbQuery -Query "SELECT * FROM Steps WHERE RecipeId = $RecipeId ORDER BY SortOrder;"
}
