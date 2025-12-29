function Set-RecipeStepsFromText {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int]$RecipeId,
        [string]$Text
    )

    $RecipeId = [int]$RecipeId

    if ($RecipeId -le 0) { 
        throw "Invalid RecipeId: $RecipeId" 
    }

    $steps = ConvertFrom-StepText -Text $Text

    Invoke-RecipeDbQuery -Query "DELETE FROM Steps WHERE RecipeId = $RecipeId;" | Out-Null

    $s = 0
    foreach ($step in $steps) {
        $instruction = ConvertTo-SqlSafe $step
        if (-not $instruction) { continue }

        Invoke-RecipeDbQuery -Query @"
INSERT INTO Steps (RecipeId, Instruction, SortOrder)
VALUES ($RecipeId, '$instruction', $s);
"@ | Out-Null

        $s++
    }
}
