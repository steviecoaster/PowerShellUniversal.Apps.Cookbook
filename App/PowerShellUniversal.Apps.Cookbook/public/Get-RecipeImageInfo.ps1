function Get-RecipeImageInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$RecipeId
    )

    $row = Invoke-RecipeDbQuery -Query @"
SELECT ImageFileName, ImageUpdatedAt
FROM Recipes
WHERE RecipeId = $RecipeId;
"@

    if (-not $row -or -not $row.ImageFileName) {
        return $null
    }

    $fileName = $row.ImageFileName
    $updated  = $row.ImageUpdatedAt

    [pscustomobject]@{
        FileName   = $fileName
        UpdatedAt  = $updated
        Extension  = [System.IO.Path]::GetExtension($fileName)
    }
}