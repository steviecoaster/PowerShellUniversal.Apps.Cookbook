$print = New-UDPage -Name "Print" -Url "/print/:id" -Blank -Content {

    $recipeId = [int]$id

    $recipe = Get-RecipeById -RecipeId $recipeId
    if (-not $recipe) {
        New-UDTypography -Text "Recipe not found." -Variant h5
        return
    }

    $ingredients = Get-RecipeIngredient -RecipeId $recipeId
    $steps       = Get-RecipeStep -RecipeId $recipeId

    New-UDStyle -Style @"
        /* -------------------------------------------------------
           Make the PRINT page look NOTHING like the main app
           ------------------------------------------------------- */

        /* Hide app chrome even on screen view for this route */
        header, nav, aside, .MuiAppBar-root, .MuiDrawer-root, .MuiToolbar-root {
            display: none !important;
        }

        body {
            background: #ffffff !important;
            color: #111111 !important;
            margin: 0 !important;
            padding: 0 !important;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
        }

        .print-wrap {
            max-width: 900px;
            margin: 0 auto;
            padding: 24px 24px 60px 24px;
        }

        h1 {
            font-size: 34px;
            font-weight: 900;
            margin: 0 0 10px 0;
            line-height: 1.1;
        }

        .meta {
            font-size: 13px;
            color: #444;
            margin-bottom: 14px;
        }

        .section-title {
            margin-top: 18px;
            margin-bottom: 8px;
            font-size: 18px;
            font-weight: 900;
            border-bottom: 1px solid #ddd;
            padding-bottom: 4px;
        }

        ul.ingredients {
            margin: 0;
            padding-left: 18px;
        }

        ul.ingredients li {
            margin: 4px 0;
            font-size: 14px;
            line-height: 1.4;
        }

        ol.steps {
            margin: 0;
            padding-left: 22px;
        }

        ol.steps li {
            margin: 8px 0;
            font-size: 14px;
            line-height: 1.5;
        }

        .top-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-bottom: 10px;
        }

        /* Buttons */
        .top-actions button {
            border-radius: 10px !important;
            font-weight: 900 !important;
            text-transform: none !important;
        }

        /* PRINT mode */
        @media print {
            .top-actions {
                display: none !important;
            }

            body {
                background: #ffffff !important;
                color: #111111 !important;
            }

            .print-wrap {
                padding: 0 !important;
            }
        }
"@ -Content {

        New-UDElement -Tag "div" -Attributes @{ className = "print-wrap" } -Content {

            # Top action buttons (screen only)
            New-UDElement -Tag "div" -Attributes @{ className = "top-actions" } -Content {

                New-UDButton -Text "Back" -Variant outlined -OnClick {
                    Invoke-UDRedirect -Url "/recipe/$recipeId"
                }

                New-UDButton -Text "Print" -OnClick {
                    Invoke-UDJavaScript -JavaScript "window.print();"
                }
            }

            # Title
            New-UDHtml -Markup "<h1>$([System.Web.HttpUtility]::HtmlEncode($recipe.Title))</h1>"

            # Meta line
            $meta = @()
            if ($recipe.PrepTimeMin -gt 0) { $meta += "Prep: $($recipe.PrepTimeMin)m" }
            if ($recipe.CookTimeMin -gt 0) { $meta += "Cook: $($recipe.CookTimeMin)m" }
            if ($recipe.Servings -gt 0)    { $meta += "Serves: $($recipe.Servings)" }
            if ($recipe.Source)            { $meta += "Source: $($recipe.Source)" }

            if ($meta.Count -gt 0) {
                New-UDHtml -Markup "<div class='meta'>$([System.Web.HttpUtility]::HtmlEncode(($meta -join '  •  ')))</div>"
            }

            if ($recipe.Description) {
                New-UDHtml -Markup "<div class='meta'>$([System.Web.HttpUtility]::HtmlEncode($recipe.Description))</div>"
            }

            # Ingredients
            New-UDHtml -Markup "<div class='section-title'>Ingredients</div>"

            if (-not $ingredients) {
                New-UDHtml -Markup "<div class='meta'>No ingredients saved.</div>"
            }
            else {
                $li = foreach ($ing in @($ingredients)) {
                    $q = ($ing.Quantity ?? "").Trim()
                    $u = ($ing.Unit ?? "").Trim()
                    $i = ($ing.Item ?? "").Trim()

                    $line = if ($q -and $u) { "$q $u $i" }
                            elseif ($q)     { "$q $i" }
                            elseif ($u)     { "$u $i" }
                            else            { "$i" }

                    "<li>$([System.Web.HttpUtility]::HtmlEncode($line))</li>"
                }

                New-UDHtml -Markup ("<ul class='ingredients'>" + ($li -join "") + "</ul>")
            }

            # Directions
            New-UDHtml -Markup "<div class='section-title'>Directions</div>"

            if (-not $steps) {
                New-UDHtml -Markup "<div class='meta'>No steps saved.</div>"
            }
            else {
                $li = foreach ($st in @($steps)) {
                    $s = ($st.Instruction ?? "").Trim()
                    "<li>$([System.Web.HttpUtility]::HtmlEncode($s))</li>"
                }

                New-UDHtml -Markup ("<ol class='steps'>" + ($li -join "") + "</ol>")
            }

            if ($recipe.Notes) {
                New-UDHtml -Markup "<div class='section-title'>Notes</div>"
                New-UDHtml -Markup "<div class='meta'>$([System.Web.HttpUtility]::HtmlEncode($recipe.Notes))</div>"
            }

            # Optional auto-print:
            # New-UDHtml -Markup "<script>setTimeout(() => window.print(), 250);</script>"
        }
    }
}
