function Get-RecipeStat {
    [CmdletBinding()]
    param()

    $result = Invoke-RecipeDbQuery -Query @"
SELECT
  (SELECT COUNT(*) FROM Recipes) AS RecipeCount,
  (SELECT COUNT(*) FROM Recipes WHERE IsFavorite = 1) AS FavoriteCount,
  (SELECT COUNT(*) FROM Tags) AS TagCount;
"@

    if (-not $result) {
        return [pscustomobject]@{
            RecipeCount   = 0
            FavoriteCount = 0
            TagCount      = 0
        }
    }

    # sqlite3 -json returns an array even for one row
    $row = @($result)[0]

    if (-not $row) {
        return [pscustomobject]@{
            RecipeCount   = 0
            FavoriteCount = 0
            TagCount      = 0
        }
    }

    [pscustomobject]@{
        RecipeCount   = [int]($row.RecipeCount   ?? 0)
        FavoriteCount = [int]($row.FavoriteCount ?? 0)
        TagCount      = [int]($row.TagCount      ?? 0)
    }
}
