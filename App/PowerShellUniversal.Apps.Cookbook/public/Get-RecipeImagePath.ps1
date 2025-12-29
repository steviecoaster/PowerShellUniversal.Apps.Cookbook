function Get-RecipeImagePath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$RecipeId
    )

    # Assumes your recipe record has ImageFileName
    $recipe = Get-RecipeById -RecipeId $RecipeId
    if (-not $recipe -or -not $recipe.ImageFileName) {
        return $null
    }

    $path = Get-RecipeImageFilePath -RecipeId $RecipeId -FileName $recipe.ImageFileName
    if (-not (Test-Path $path)) {
        return $null
    }

    $path
}
