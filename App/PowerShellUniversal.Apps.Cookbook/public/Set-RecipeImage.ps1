function Set-RecipeImage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$RecipeId,

        [Parameter(Mandatory)]
        [byte[]]$Bytes,

        [Parameter(Mandatory)]
        [string]$OriginalFileName
    )

    if (-not $Bytes -or $Bytes.Length -eq 0) {
        throw "Set-RecipeImage: Bytes were null or empty."
    }

    $folder = Get-RecipeImageFolder

    $ext = [System.IO.Path]::GetExtension($OriginalFileName)
    if (-not $ext) { $ext = ".jpg" }

    # Normalize extension
    $ext = $ext.ToLowerInvariant()

    # Create predictable name: Recipe_<id>.<ext>
    $fileName = "Recipe_{0}{1}" -f $RecipeId, $ext
    $fullPath = Join-Path $folder $fileName

    [System.IO.File]::WriteAllBytes($fullPath, $Bytes)

    # Update DB
    $safeFile = ConvertTo-SqlSafe $fileName

    Invoke-RecipeDbQuery -Query @"
UPDATE Recipes
SET ImageFileName = '$safeFile',
    ImageUpdatedAt = datetime('now'),
    UpdatedAt = datetime('now')
WHERE RecipeId = $RecipeId;
"@ | Out-Null

    $fullPath
}
