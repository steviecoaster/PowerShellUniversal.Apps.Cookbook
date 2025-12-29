function Save-Recipe {
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$RecipeId = 0,

        [Parameter(Mandatory)]
        [string]$Title,

        [string]$Description,
        [string]$Notes,
        [string]$Source,

        [int]$PrepTimeMin = 0,
        [int]$CookTimeMin = 0,
        [int]$Servings = 0
    )

    $Title = ($Title ?? '').Trim()
    if (-not $Title) { throw "Save-Recipe: Title is required." }

    $titleSafe = ConvertTo-SqlSafe $Title
    $descSafe  = ConvertTo-SqlSafe ($Description ?? '')
    $notesSafe = ConvertTo-SqlSafe ($Notes ?? '')
    $sourceSafe = ConvertTo-SqlSafe ($Source ?? '')

    $PrepTimeMin = [int]($PrepTimeMin ?? 0)
    $CookTimeMin = [int]($CookTimeMin ?? 0)
    $Servings    = [int]($Servings ?? 0)

    if ($RecipeId -gt 0) {

        Invoke-RecipeDbQuery -Query @"
UPDATE Recipes
SET Title = '$titleSafe',
    Description = '$descSafe',
    Notes = '$notesSafe',
    Source = '$sourceSafe',
    PrepTimeMin = $PrepTimeMin,
    CookTimeMin = $CookTimeMin,
    Servings = $Servings,
    UpdatedAt = datetime('now')
WHERE RecipeId = $RecipeId;
"@ | Out-Null

        return [int]$RecipeId
    }

    # INSERT new recipe and return the new ID
    $result = Invoke-RecipeDbQuery -Query @"
INSERT INTO Recipes (Title, Description, Notes, Source, PrepTimeMin, CookTimeMin, Servings, CreatedAt, UpdatedAt)
VALUES ('$titleSafe', '$descSafe', '$notesSafe', '$sourceSafe', $PrepTimeMin, $CookTimeMin, $Servings, datetime('now'), datetime('now'));

SELECT last_insert_rowid() AS RecipeId;
"@

    # sqlite3 json returns an array; last statement will be the last row
    $row = @($result)[-1]

    if (-not $row -or -not $row.RecipeId) {
        throw "Save-Recipe: Failed to retrieve new RecipeId."
    }

    return [int]$row.RecipeId
}
