
function Get-RecipeImageUrl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$RecipeId
    )

    $info = Get-RecipeImageInfo -RecipeId $RecipeId
    if (-not $info) { return $null }

    # Cache bust based on ImageUpdatedAt ticks
    if ($info.UpdatedAt) {
        $ticks = [DateTime]::Parse($info.UpdatedAt).Ticks
        return "/recipe-image/$RecipeId?v=$ticks"
    }

    "/recipe-image/$RecipeId"
}