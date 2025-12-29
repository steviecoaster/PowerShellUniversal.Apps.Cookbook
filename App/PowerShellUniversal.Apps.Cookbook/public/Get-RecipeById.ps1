function Get-RecipeById {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$RecipeId
    )

    Invoke-RecipeDbQuery -Query "SELECT * FROM Recipes WHERE RecipeId = $RecipeId;"
}
