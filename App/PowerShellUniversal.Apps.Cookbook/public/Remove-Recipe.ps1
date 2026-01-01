function Remove-Recipe {
    <#
    .SYNOPSIS
    Deletes a recipe and all related data (ingredients, steps, tags, image).

    .DESCRIPTION
    Removes a recipe from the database by RecipeId. The database foreign keys
    are set to ON DELETE CASCADE, so related ingredients, steps, and recipe-tag
    relationships are automatically removed. This function also removes the
    recipe's image file if it exists.

    .PARAMETER RecipeId
    The ID of the recipe to delete.

    .EXAMPLE
    Remove-Recipe -RecipeId 42

    .NOTES
    This operation cannot be undone. Use with caution.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$RecipeId
    )

    if ($RecipeId -le 0) {
        throw "Remove-Recipe: RecipeId must be greater than 0."
    }

    # Remove the image file if it exists
    try {
        Remove-RecipeImage -RecipeId $RecipeId -ErrorAction SilentlyContinue
    }
    catch {
        Write-Warning "Failed to remove recipe image: $_"
    }

    # Delete the recipe (cascades to ingredients, steps, recipe-tags)
    Invoke-RecipeDbQuery -Query @"
DELETE FROM Recipes
WHERE RecipeId = $RecipeId;
"@ | Out-Null

    Write-Verbose "Removed recipe $RecipeId and all related data."
}
