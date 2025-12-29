function Get-RecipeImageResponse {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$Id
    )

    # Find the image filename in the DB
    $row = Invoke-RecipeDbQuery -Query @"
SELECT ImageFileName
FROM Recipes
WHERE RecipeId = $Id;
"@

    if (-not $row -or -not $row.ImageFileName) {
        return New-PSUApiResponse -StatusCode 404 -Body "Image not found."
    }

    $imageFolder = Join-Path $env:ProgramData "RecipeBook\Images"
    $path = Join-Path $imageFolder $row.ImageFileName

    if (-not (Test-Path $path)) {
        return New-PSUApiResponse -StatusCode 404 -Body "Image file missing."
    }

    # Content type based on extension
    $ext = ([IO.Path]::GetExtension($path) ?? "").ToLower()
    $contentType = switch ($ext) {
        ".png"  { "image/png" }
        ".gif"  { "image/gif" }
        ".webp" { "image/webp" }
        ".bmp"  { "image/bmp" }
        ".jpg"  { "image/jpeg" }
        ".jpeg" { "image/jpeg" }
        default { "application/octet-stream" }
    }

    $bytes = [System.IO.File]::ReadAllBytes($path)

    # Return as a PSU API response
    New-PSUApiResponse -ContentType $contentType -Data $bytes
}
