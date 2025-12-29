function Set-RecipeIngredientsFromText {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$RecipeId,

        [string]$Text
    )

    $RecipeId = [int]$RecipeId
    
    if ($RecipeId -le 0) {
        throw "Invalid RecipeId: $RecipeId" 
    }

    $ingredients = ConvertFrom-IngredientText -Text $Text

    Invoke-RecipeDbQuery -Query "DELETE FROM Ingredients WHERE RecipeId = $RecipeId;" | Out-Null

    $i = 0
    foreach ($ing in @($ingredients)) {

        $qty = ConvertTo-SqlSafe $ing.Quantity
        $unit = ConvertTo-SqlSafe $ing.Unit
        $item = ConvertTo-SqlSafe $ing.Item

        if (-not $item) { continue }

        Invoke-RecipeDbQuery -Query @"
INSERT INTO Ingredients (RecipeId, Item, Quantity, Unit, SortOrder)
VALUES ($RecipeId, '$item', '$qty', '$unit', $i);
"@ | Out-Null

        $i++
    }
}
