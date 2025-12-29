function Set-RecipeTagFromText {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int]$RecipeId,
        [string]$Text
    )

    $RecipeId = [int]$RecipeId

    if ($RecipeId -le 0) { 
        throw "Invalid RecipeId: $RecipeId" 
    }
    
    $tags = ConvertFrom-TagText -Text $Text

    Invoke-RecipeDbQuery -Query "DELETE FROM RecipeTags WHERE RecipeId = $RecipeId;" | Out-Null

    foreach ($tag in $tags) {
        $safeTag = ConvertTo-SqlSafe $tag

        Invoke-RecipeDbQuery -Query @"
INSERT OR IGNORE INTO Tags (Name) VALUES ('$safeTag');
INSERT OR IGNORE INTO RecipeTags (RecipeId, TagId)
SELECT $RecipeId, TagId FROM Tags WHERE Name='$safeTag';
"@ | Out-Null
    }
}
