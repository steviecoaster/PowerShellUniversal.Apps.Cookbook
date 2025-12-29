function Invoke-RecipeImageEndpoint {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$Id
    )

    $info = Get-RecipeImageInfo -RecipeId $Id

    if (-not $info) {
       New-PSUApiResponse -StatusCode 404 -Body 'Image file missing.'
        return
    }

    $path = Join-Path (Get-RecipeImageFolder) $info.FileName
    if (-not (Test-Path $path)) {
        New-PSUApiResponse -StatusCode 404 -Body 'Image folder missing'
        return
    }

    $ext = ($info.Extension ?? "").ToLower()
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

    New-PSUApiResponse -ContentType $contentType -Data $bytes
}
