function Show-RecipeModal {
    [CmdletBinding()]
    param(
        [int]$RecipeId = 0,
        [string[]]$SyncId = @()
    )

    $isEdit = $RecipeId -gt 0

    $recipe = $null
    $ingredientsText = ""
    $stepsText = ""
    $tagsText = ""

    if ($isEdit) {
        $recipe = Get-RecipeById -RecipeId $RecipeId

        $ingredients = Get-RecipeIngredient -RecipeId $RecipeId
        $steps       = Get-RecipeStep -RecipeId $RecipeId
        $tags        = Get-RecipeTag -RecipeId $RecipeId

        $ingredientsText = ConvertTo-IngredientText -Ingredients $ingredients
        $stepsText       = ConvertTo-StepText -Steps $steps
        $tagsText        = ConvertTo-TagText -Tags $tags
    }

    Show-UDModal -FullWidth -MaxWidth xl -Header {
        New-UDTypography -Text ($isEdit ? "Edit Recipe" : "Add Recipe") -Variant h5 -Style @{
            "font-weight" = "950"
        }
    } -Content {

        New-UDForm -Id "recipeForm" -Content {

            New-UDGrid -Container -Spacing 2 -Content {

                # LEFT COLUMN
                New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -Content {

                    # IMAGE BLOCK (only when editing)
                    if ($isEdit) {

                        $imgPath = Get-RecipeImagePath -RecipeId $RecipeId

                        if ($imgPath) {
                            New-UDImage -Path $imgPath -Height 150 -Attributes @{
                                style = @{
                                    width = "100%"
                                    borderRadius = "16px"
                                    border = "1px solid rgba(181,140,255,0.22)"
                                    objectFit = "cover"
                                    marginBottom = "10px"
                                }
                            }
                        }
                        else {
                            New-UDElement -Tag "div" -Attributes @{
                                style = @{
                                    height = "150px"
                                    borderRadius = "16px"
                                    border = "1px solid rgba(181,140,255,0.22)"
                                    marginBottom = "10px"
                                    background = "linear-gradient(120deg, rgba(181,140,255,0.25), rgba(142,107,255,0.10))"
                                }
                            } -Content { }
                        }

                        New-UDUpload -Text "Upload Image" -Accept "image/*" -OnUpload {

                            $data = $Body | ConvertFrom-Json

                            if (-not $data -or -not $data.Data) {
                                Show-UDToast -Message "Upload failed: no file data received." -Duration 5000 -BackgroundColor "#C62828"
                                return
                            }

                            $bytes = [System.Convert]::FromBase64String($data.Data)

                            if (-not $bytes -or $bytes.Length -eq 0) {
                                Show-UDToast -Message "Upload failed: decoded file was empty." -Duration 5000 -BackgroundColor "#C62828"
                                return
                            }

                            Set-RecipeImage -RecipeId $RecipeId -Bytes $bytes -OriginalFileName $data.Name

                            Show-UDToast -Message "Image saved!" -Duration 2000

                            foreach ($id in $SyncId) {
                                if ($id) { Sync-UDElement -Id $id -ErrorAction SilentlyContinue }
                            }

                            Sync-UDElement -Id "recipeForm"
                        }

                        New-UDButton -Text "Remove Image" -Variant outlined -OnClick {
                            Remove-RecipeImage -RecipeId $RecipeId
                            Show-UDToast -Message "Image removed" -Duration 2000

                            foreach ($id in $SyncId) {
                                if ($id) { Sync-UDElement -Id $id -ErrorAction SilentlyContinue }
                            }

                            Sync-UDElement -Id "recipeForm"
                        }

                        New-UDHtml -Markup "<div style='height: 12px;'></div>"
                    }
                    else {
                        New-UDAlert -Text "Save the recipe first, then edit it to upload an image." -Severity info
                        New-UDHtml -Markup "<div style='height: 12px;'></div>"
                    }

                    # Fields
                    New-UDTextbox -Id "Title" -Label "Title" -FullWidth -Value ($recipe.Title ?? "")
                    New-UDTextbox -Id "Description" -Label "Description" -FullWidth -Value ($recipe.Description ?? "")
                    New-UDTextbox -Id "Source" -Label "Source" -FullWidth -Value ($recipe.Source ?? "")
                    New-UDTextbox -Id "Tags" -Label "Tags (comma separated)" -FullWidth -Value $tagsText

                    New-UDGrid -Container -Spacing 2 -Content {
                        New-UDGrid -Item -ExtraSmallSize 4 -Content {
                            New-UDTextbox -Id "PrepTimeMin" -Label "Prep (min)" -Value ($recipe.PrepTimeMin ?? "")
                        }
                        New-UDGrid -Item -ExtraSmallSize 4 -Content {
                            New-UDTextbox -Id "CookTimeMin" -Label "Cook (min)" -Value ($recipe.CookTimeMin ?? "")
                        }
                        New-UDGrid -Item -ExtraSmallSize 4 -Content {
                            New-UDTextbox -Id "Servings" -Label "Servings" -Value ($recipe.Servings ?? "")
                        }
                    }

                    New-UDTextbox -Id "Notes" -Label "Notes" -FullWidth -Multiline -Rows 4 -Value ($recipe.Notes ?? "")
                }

                # RIGHT COLUMN
                New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -Content {
                    New-UDTextbox -Id "Ingredients" -Label "Ingredients (qty|unit|item per line)" -FullWidth -Multiline -Rows 10 -Value $ingredientsText
                    New-UDTextbox -Id "Steps" -Label "Steps (one per line)" -FullWidth -Multiline -Rows 10 -Value $stepsText
                }
            }

        } -OnSubmit {

            $Title = ($EventData.Title ?? "").Trim()
            if (-not $Title) {
                Show-UDToast -Message "Title is required." -Duration 3000
                return
            }

            $recipeIdOut = Save-Recipe -RecipeId $RecipeId `
                -Title $Title `
                -Description ($EventData.Description ?? "") `
                -Notes ($EventData.Notes ?? "") `
                -Source ($EventData.Source ?? "") `
                -PrepTimeMin (ConvertTo-Int $EventData.PrepTimeMin) `
                -CookTimeMin (ConvertTo-Int $EventData.CookTimeMin) `
                -Servings (ConvertTo-Int $EventData.Servings)

            Set-RecipeIngredientsFromText -RecipeId $recipeIdOut -Text ($EventData.Ingredients ?? "")
            Set-RecipeStepsFromText       -RecipeId $recipeIdOut -Text ($EventData.Steps ?? "")
            Set-RecipeTagFromText        -RecipeId $recipeIdOut -Text ($EventData.Tags ?? "")

            Hide-UDModal
            Show-UDToast -Message "Saved!" -Duration 2000

            foreach ($id in $SyncId) {
                if ($id) { Sync-UDElement -Id $id -ErrorAction SilentlyContinue }
            }
        }

        # Cancel button (bottom-right of the modal)
        New-UDElement -Tag 'div' -Attributes @{ 
            style = @{ 
                display = 'flex'
                justifyContent = 'flex-end'
                marginTop = '16px'
            }
        } -Content {
            New-UDButton -Text "Cancel" -Variant text -OnClick {
                Hide-UDModal
            }
        }
    } -Persistent
}
