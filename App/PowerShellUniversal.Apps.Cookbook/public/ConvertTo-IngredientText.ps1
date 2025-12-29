function ConvertTo-IngredientText {
    [CmdletBinding()]
    param(
        [array]$Ingredients
    )

    if (-not $Ingredients) { return "" }

    $lines = foreach ($i in @($Ingredients)) {

        $q = ($i.Quantity ?? "").Trim()
        $u = ($i.Unit ?? "").Trim()
        $item = ($i.Item ?? "").Trim()

        if ($q -and $u) {
            "$q $u $item".Trim()
        }
        elseif ($q) {
            "$q $item".Trim()
        }
        elseif ($u) {
            "$u $item".Trim()
        }
        else {
            "$item".Trim()
        }
    }

    ($lines -join "`n")
}
