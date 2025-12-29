function ConvertFrom-IngredientText {
    [CmdletBinding()]
    param(
        [string]$Text
    )

    if (-not $Text) { return @() }

    # ------------------------------------------------------------
    # 1) Normalize encoding junk (mojibake) + whitespace
    # ------------------------------------------------------------
    $t = $Text

    # Remove zero-width garbage
    $t = $t -replace "[\u200B-\u200D\uFEFF]", ""

    # Common mojibake variants for fractions
    $t = $t -replace "Â¼|Γö¼|Ã‚Â¼", "¼"
    $t = $t -replace "Â½|Γö½|Ã‚Â½", "½"
    $t = $t -replace "Â¾|Γö¾|Ã‚Â¾", "¾"
    $t = $t -replace "Â⅓|Γö⅓|Ã‚Â⅓", "⅓"
    $t = $t -replace "Â⅔|Γö⅔|Ã‚Â⅔", "⅔"
    $t = $t -replace "Â⅛|Γö⅛|Ã‚Â⅛", "⅛"
    $t = $t -replace "Â⅜|Γö⅜|Ã‚Â⅜", "⅜"
    $t = $t -replace "Â⅝|Γö⅝|Ã‚Â⅝", "⅝"
    $t = $t -replace "Â⅞|Γö⅞|Ã‚Â⅞", "⅞"

    # Normalize curly quotes / dashes
    $t = $t -replace "[“”]", '"'
    $t = $t -replace "[‘’]", "'"
    $t = $t -replace "[–—]", "-"

    # Normalize newlines + tabs/spaces
    $t = $t -replace "\r\n?", "`n"
    $t = $t -replace "[\t ]+", " "

    $lines = $t -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ }

    # ------------------------------------------------------------
    # 2) Unit dictionary (extend as you like)
    # ------------------------------------------------------------
    $unitMap = @(
        "teaspoon","teaspoons","tsp","tsp.","t",
        "tablespoon","tablespoons","tbsp","tbsp.","T",
        "cup","cups",
        "pint","pints","pt","pt.",
        "quart","quarts","qt","qt.",
        "gallon","gallons","gal","gal.",
        "ml","milliliter","milliliters",
        "l","liter","liters",
        "g","gram","grams",
        "kg","kilogram","kilograms",
        "oz","ounce","ounces",
        "lb","lbs","pound","pounds",
        "pinch","pinches",
        "dash","dashes",
        "clove","cloves",
        "can","cans",
        "package","packages","pkg",
        "stick","sticks",
        "slice","slices",
        "piece","pieces",
        "bunch","bunches"
    )

    # Make a regex like: ^(unit1|unit2|unit3)\b
    $unitRegex = "(?i)^(" + (($unitMap | Sort-Object -Descending) -join "|") + ")\b"

    # ------------------------------------------------------------
    # 3) Fraction conversion helpers
    # ------------------------------------------------------------
    function Convert-FractionGlyphToAscii {
        param([string]$s)

        if (-not $s) { return $s }

        $s = $s.Replace("¼","1/4").Replace("½","1/2").Replace("¾","3/4")
        $s = $s.Replace("⅓","1/3").Replace("⅔","2/3")
        $s = $s.Replace("⅛","1/8").Replace("⅜","3/8").Replace("⅝","5/8").Replace("⅞","7/8")
        $s
    }

    function Normalize-Quantity {
        param([string]$q)

        $q = (Convert-FractionGlyphToAscii $q).Trim()

        # Convert "1-1/2" -> "1 1/2"
        $q = $q -replace "^(\d+)-(\d+/\d+)$", '$1 $2'

        $q
    }

    # ------------------------------------------------------------
    # 4) Parse each line into Quantity, Unit, Item
    # ------------------------------------------------------------
    $results = foreach ($line in $lines) {

        $original = $line
        $line = Convert-FractionGlyphToAscii $line

        $quantity = ""
        $unit = ""
        $item = ""

        # Example patterns:
        # "1 1/2 cups flour"
        # "1/2 cup milk"
        # "2 tbsp cocoa powder"
        # "salt to taste" (no qty)
        # "1 (14 oz) can tomatoes" (qty + parenthetical + unit + item)

        # Capture quantity at the start:
        # - whole number: 2
        # - fraction: 1/2
        # - mixed: 1 1/2
        # - range: 2-3 (we keep it)
        $qtyPattern = '^(?<qty>(\d+\s+\d+/\d+)|(\d+/\d+)|(\d+(\.\d+)?)|(\d+\s*-\s*\d+(\.\d+)?))\s+(?<rest>.+)$'

        if ($line -match $qtyPattern) {
            $quantity = Normalize-Quantity $Matches.qty
            $rest = $Matches.rest.Trim()

            # If next token is a parenthetical like "(14 oz)" keep it in item
            # but still parse unit after it
            $paren = ""
            if ($rest -match '^(?<paren>\([^)]+\))\s+(?<after>.+)$') {
                $paren = $Matches.paren.Trim()
                $rest  = $Matches.after.Trim()
            }

            # Parse unit at start of rest
            if ($rest -match $unitRegex) {
                $unit = $Matches[1]
                $rest = ($rest -replace $unitRegex, "").Trim()
            }

            # Put parenthetical back in front of item if it exists
            if ($paren) {
                $item = "$paren $rest".Trim()
            }
            else {
                $item = $rest
            }
        }
        else {
            # No quantity found - try to parse unit anyway (rare)
            $rest = $line
            if ($rest -match $unitRegex) {
                $unit = $Matches[1]
                $rest = ($rest -replace $unitRegex, "").Trim()
            }
            $item = $rest
        }

        # Final cleanup
        $quantity = ($quantity ?? "").Trim()
        $unit     = ($unit ?? "").Trim()
        $item     = ($item ?? "").Trim()

        if (-not $item) { continue }

        [pscustomobject]@{
            Quantity = $quantity
            Unit     = $unit
            Item     = $item
            Original = $original
        }
    }

    @($results)
}
