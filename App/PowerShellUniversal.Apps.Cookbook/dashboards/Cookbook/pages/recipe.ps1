 $recipe = New-UDPage -Name "Recipe" -Url "/recipe/:id" -Content {

    # Route param :id becomes $id
    $recipeId = [int]$id

    New-UDStyle -Style @"
        :root {
            --lilac: #B58CFF;
            --lilac-dark: #8E6BFF;
            --border: rgba(181, 140, 255, 0.22);
            --text: #241A37;
            --muted: rgba(36, 26, 55, 0.70);
        }

        .page-wrap {
            padding: 18px;
            border-radius: 18px;
            background:
                radial-gradient(circle at 20% 0%, rgba(181,140,255,0.14) 0%, transparent 42%),
                radial-gradient(circle at 100% 25%, rgba(181,140,255,0.10) 0%, transparent 45%),
                linear-gradient(180deg, rgba(255,255,255,1) 0%, rgba(250,248,255,1) 100%);
        }

        .card {
            border-radius: 18px !important;
            border: 1px solid var(--border) !important;
            box-shadow: 0 14px 34px rgba(0,0,0,0.07) !important;
            overflow: hidden;
            background: rgba(255,255,255,0.95) !important;
        }

        .hero {
            border-radius: 18px;
            border: 1px solid var(--border);
            overflow: hidden;
            box-shadow: 0 14px 34px rgba(0,0,0,0.08);
            background: rgba(255,255,255,0.92);
        }

        .btn-primary button {
            border-radius: 14px !important;
            background: var(--lilac-dark) !important;
            color: white !important;
            font-weight: 950 !important;
            text-transform: none !important;
        }

        .btn-ghost button {
            border-radius: 14px !important;
            background: rgba(181, 140, 255, 0.08) !important;
            border: 1px solid rgba(181, 140, 255, 0.25) !important;
            color: var(--lilac-dark) !important;
            font-weight: 950 !important;
            text-transform: none !important;
        }

        .pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 10px;
            border-radius: 999px;
            border: 1px solid rgba(181, 140, 255, 0.25);
            background: rgba(181, 140, 255, 0.08);
            color: var(--text);
            font-weight: 800;
            font-size: 12px;
            margin-right: 8px;
            margin-top: 8px;
            user-select: none;
        }

        .muted { color: var(--muted); }

        ol.steps {
            padding-left: 22px;
            margin: 0;
        }

        ol.steps li {
            margin: 10px 0;
            line-height: 1.4;
            color: var(--text);
        }

        ul.ingredients {
            padding-left: 18px;
            margin: 0;
        }

        ul.ingredients li {
            margin: 8px 0;
            line-height: 1.35;
            color: var(--text);
        }
"@ -Content {

        New-UDElement -Tag "div" -Attributes @{ className = "page-wrap" } -Content {

            # Top bar
            New-UDStack -Direction row -JustifyContent space-between -AlignItems center -Content {

                New-UDStack -Direction column -Spacing 0 -Content {
                    New-UDTypography -Text "Recipe" -Variant overline -Style @{ color = "rgba(36,26,55,0.55)"; fontWeight = "900" }
                    New-UDTypography -Text "Details" -Variant h4 -Style @{ fontWeight = "950"; color = "#241A37"; margin = "0" }
                }

                New-UDStack -Direction row -Spacing 1 -Content {

                    New-UDButton -Text "Back to Browse" -ClassName "btn-ghost" -OnClick {
                        Invoke-UDRedirect -Url "/browse"
                    }

                    New-UDButton -Text "Print" -ClassName "btn-ghost" -OnClick {
                        Invoke-UDRedirect -Url "/print/$recipeId"
                    }

                    New-UDButton -Text "Edit" -ClassName "btn-primary" -OnClick {
                        Show-RecipeModal -RecipeId $recipeId -SyncId @("recipeView")
                    }
                }

            }

            New-UDHtml -Markup "<div style='height:16px;'></div>"

            # Main content is dynamic so edit modal can refresh the page
            New-UDDynamic -Id "recipeView" -Content {

                $recipeRow = Get-RecipeById -RecipeId $recipeId

                if (-not $recipeRow) {
                    New-UDAlert -Severity error -Text "Recipe not found."
                    return
                }

                $ingredients = Get-RecipeIngredient -RecipeId $recipeId
                $steps = Get-RecipeStep -RecipeId $recipeId
                $tags = Get-RecipeTag -RecipeId $recipeId
                $imgPath = Get-RecipeImagePath -RecipeId $recipeId

                # Hero card
                New-UDElement -Tag "div" -Attributes @{ className = "hero" } -Content {

                    if ($imgPath) {
                        New-UDImage -Path $imgPath -Height 260 -Attributes @{
                            style = @{
                                width     = "100%"
                                objectFit = "cover"
                                display   = "block"
                            }
                        }
                    }
                    else {
                        New-UDElement -Tag "div" -Attributes @{
                            style = @{
                                height     = "180px"
                                background = "linear-gradient(120deg, rgba(181,140,255,0.30), rgba(142,107,255,0.12))"
                            }
                        } -Content { }
                    }

                    New-UDElement -Tag "div" -Attributes @{
                        style = @{
                            padding = "16px 16px 18px 16px"
                        }
                    } -Content {

                        New-UDTypography -Text $recipeRow.Title -Variant h4 -Style @{
                            fontWeight = "950"
                            color      = "#241A37"
                            margin     = "0"
                            lineHeight = "1.15"
                        }

                        if ($recipeRow.Description) {
                            New-UDTypography -Text $recipeRow.Description -Variant body1 -Style @{
                                color      = "rgba(36,26,55,0.78)"
                                marginTop  = "8px"
                                lineHeight = "1.35"
                            }
                        }

                        # Meta pills
                        New-UDElement -Tag "div" -Content {

                            if ($recipeRow.PrepTimeMin -gt 0) { New-UDHtml -Markup "<span class='pill'>⏱️ Prep: $($recipeRow.PrepTimeMin)m</span>" }
                            if ($recipeRow.CookTimeMin -gt 0) { New-UDHtml -Markup "<span class='pill'>🔥 Cook: $($recipeRow.CookTimeMin)m</span>" }
                            if ($recipeRow.Servings -gt 0) { New-UDHtml -Markup "<span class='pill'>🍽️ Serves: $($recipeRow.Servings)</span>" }
                            if ($recipeRow.Source) { New-UDHtml -Markup "<span class='pill'>🔗 $($recipeRow.Source)</span>" }
                        }

                        # Tag pills
                        if ($tags) {
                            New-UDElement -Tag "div" -Content {
                                foreach ($t in @($tags)) {
                                    New-UDHtml -Markup "<span class='pill'>🏷️ $($t.Name)</span>"
                                }
                            }
                        }
                    }
                }

                New-UDHtml -Markup "<div style='height:16px;'></div>"

                # Two-column content cards
                New-UDGrid -Container -Spacing 2 -Content {

                    # Ingredients
                    New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 5 -Content {

                        New-UDCard -ClassName "card" -Content {

                            New-UDTypography -Text "Ingredients" -Variant h6 -Style @{
                                fontWeight   = "950"
                                color        = "#241A37"
                                marginBottom = "10px"
                            }

                            if (-not $ingredients) {
                                New-UDTypography -Text "No ingredients saved." -Variant body2 -ClassName "muted"
                            }
                            else {
                                $li = foreach ($ing in @($ingredients)) {
                                    $q = ($ing.Quantity ?? "").Trim()
                                    $u = ($ing.Unit ?? "").Trim()
                                    $i = ($ing.Item ?? "").Trim()

                                    $line = if ($q -and $u) { "$q $u $i" }
                                    elseif ($q) { "$q $i" }
                                    elseif ($u) { "$u $i" }
                                    else { "$i" }

                                    "<li>$line</li>"
                                }

                                New-UDHtml -Markup ("<ul class='ingredients'>" + ($li -join "") + "</ul>")
                            }
                        }
                    }

                    # Steps
                    New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 7 -Content {

                        New-UDCard -ClassName "card" -Content {

                            New-UDTypography -Text "Directions" -Variant h6 -Style @{
                                fontWeight   = "950"
                                color        = "#241A37"
                                marginBottom = "10px"
                            }

                            if (-not $steps) {
                                New-UDTypography -Text "No steps saved." -Variant body2 -ClassName "muted"
                            }
                            else {
                                $li = foreach ($st in @($steps)) {
                                    $s = ($st.Instruction ?? "").Trim()
                                    "<li>$s</li>"
                                }

                                New-UDHtml -Markup ("<ol class='steps'>" + ($li -join "") + "</ol>")
                            }
                        }
                    }
                }

                # Notes
                if ($recipeRow.Notes) {
                    New-UDHtml -Markup "<div style='height:16px;'></div>"

                    New-UDCard -ClassName "card" -Content {
                        New-UDTypography -Text "Notes" -Variant h6 -Style @{
                            fontWeight   = "950"
                            color        = "#241A37"
                            marginBottom = "10px"
                        }

                        New-UDTypography -Text $recipeRow.Notes -Variant body1 -Style @{
                            color      = "rgba(36,26,55,0.78)"
                            lineHeight = "1.4"
                        }
                    }
                }
            }
        }
    }
}
