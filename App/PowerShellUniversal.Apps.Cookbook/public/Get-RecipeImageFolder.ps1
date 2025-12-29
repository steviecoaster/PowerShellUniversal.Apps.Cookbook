function Get-RecipeImageFolder {
    [CmdletBinding()]
    param()

    if (-not $Script:RecipeImageRoot) {
        throw "Recipe image folder not initialized. `$Script:RecipeImageRoot is not set. Check module initialization (.psm1)."
    }

    if (-not (Test-Path $Script:RecipeImageRoot)) {
        New-Item -Path $Script:RecipeImageRoot -ItemType Directory -Force | Out-Null
    }

    $Script:RecipeImageRoot
}
