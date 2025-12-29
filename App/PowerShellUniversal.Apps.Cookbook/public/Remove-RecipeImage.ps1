function Remove-RecipeImage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$RecipeId
    )

    $recipe = Get-RecipeById -RecipeId $RecipeId
    if (-not $recipe -or -not $recipe.ImageFileName) {
        return $false
    }

    $path = Get-RecipeImageFilePath -RecipeId $RecipeId -FileName $recipe.ImageFileName
    if (Test-Path $path) {
        Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
    }

    Invoke-RecipeDbQuery -Query @"
UPDATE Recipes
SET ImageFileName = NULL,
    ImageUpdatedAt = NULL,
    UpdatedAt = datetime('now')
WHERE RecipeId = $RecipeId;
"@ | Out-Null

    $true
}
