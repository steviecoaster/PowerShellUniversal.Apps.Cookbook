function Get-RecipeImageFilePath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$RecipeId,

        [Parameter(Mandatory)]
        [string]$FileName
    )

    if (-not $FileName) {
        throw "Get-RecipeImageFilePath: FileName was null or empty."
    }

    $folder = Get-RecipeImageFolder
    Join-Path $folder $FileName
}
