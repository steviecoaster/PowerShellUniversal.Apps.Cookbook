$browse = New-UDPage -Name "Browse" -Url "/browse" -Content {

    # QueryString is available in PSU Pages
    if (-not $Query) { $Query = @{} }

    $tagFilter = $Query["tag"]
    $search = $Query["q"]
    $favOnly = ($Query["fav"] -eq "1")


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

        .mini-card {
            border-radius: 18px !important;
            border: 1px solid var(--border) !important;
            box-shadow: 0 14px 34px rgba(0,0,0,0.07) !important;
            overflow: hidden;
            background: rgba(255,255,255,0.95) !important;
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

        /* Category Chips Styling */
        .MuiChip-root {
            font-weight: 700 !important;
            font-size: 13px !important;
            height: 36px !important;
            border-radius: 18px !important;
            transition: all 0.2s ease !important;
        }

        .MuiChip-outlined {
            border: 1.5px solid rgba(181, 140, 255, 0.35) !important;
            background: linear-gradient(135deg, rgba(181, 140, 255, 0.06), rgba(142, 107, 255, 0.08)) !important;
            color: #6E4DFF !important;
        }

        .MuiChip-outlined:hover {
            border-color: rgba(181, 140, 255, 0.55) !important;
            background: linear-gradient(135deg, rgba(181, 140, 255, 0.12), rgba(142, 107, 255, 0.16)) !important;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(181, 140, 255, 0.25) !important;
        }

        .MuiChip-colorPrimary {
            border: 1.5px solid rgba(142, 107, 255, 0.60) !important;
            background: linear-gradient(135deg, #8E6BFF, #B58CFF) !important;
            color: white !important;
            box-shadow: 0 4px 14px rgba(142, 107, 255, 0.35) !important;
        }

        .MuiChip-colorPrimary:hover {
            background: linear-gradient(135deg, #7A57E5, #9D72E5) !important;
            transform: translateY(-1px);
            box-shadow: 0 6px 18px rgba(142, 107, 255, 0.45) !important;
        }

        .MuiChip-label {
            padding: 0 14px !important;
        }

        .fav-toggle button {
            border-radius: 999px !important;
            border: 1px solid rgba(181,140,255,0.35) !important;
            background: rgba(181,140,255,0.08) !important;
            color: #6E4DFF !important;
            font-weight: 950 !important;
            text-transform: none !important;
            padding: 8px 14px !important;
        }

        .fav-toggle-on button {
            border-radius: 999px !important;
            border: 1px solid rgba(181,140,255,0.55) !important;
            background: var(--lilac-dark) !important;
            color: white !important;
            font-weight: 950 !important;
            text-transform: none !important;
            padding: 8px 14px !important;
        }

        .muted {
            color: var(--muted) !important;
        }

        .title {
            font-weight: 950 !important;
            color: var(--text) !important;
            line-height: 1.15 !important;
        }

        .statline {
            display: flex;
            gap: 10px;
            margin-top: 8px;
            flex-wrap: wrap;
        }

        .statpill {
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
            user-select: none;
        }

        .card-img {
            width: 100%;
            height: 160px;
            object-fit: cover;
            display: block;
        }

        .card-img-placeholder {
            width: 100%;
            height: 160px;
            background: linear-gradient(120deg, rgba(181,140,255,0.30), rgba(142,107,255,0.12));
        }
"@ -Content {

        New-UDElement -Tag "div" -Attributes @{ className = "page-wrap" } -Content {

            # Header Row
            New-UDStack -Direction row -JustifyContent space-between -AlignItems center -Content {

                New-UDStack -Direction column -Spacing 0 -Content {
                    New-UDTypography -Text "Browse" -Variant overline -Style @{ color = "rgba(36,26,55,0.55)"; fontWeight = "900" }

                    $title = if ($tagFilter) { "Category: $tagFilter" }
                    elseif ($favOnly) { "Favorites" }
                    else { "All Recipes" }

                    New-UDTypography -Text $title -Variant h4 -ClassName "title"

                    if ($search) {
                        New-UDTypography -Text "Search: $search" -Variant body2 -ClassName "muted"
                    }
                }

                New-UDStack -Direction row -Spacing 1 -Content {
                    New-UDButton -Text "Back" -ClassName "btn-ghost" -OnClick { Invoke-UDRedirect -Url "/" }
                    New-UDButton -Text "Add Recipe" -ClassName "btn-primary" -OnClick {
                        Show-RecipeModal -RecipeId 0 -SyncId @("recipeCards", "tagChips")
                    }
                }
            }

            New-UDHtml -Markup "<div style='height:14px;'></div>"

            # Search Bar + Favorites Toggle
            New-UDStack -Direction row -Spacing 1 -AlignItems center -Content {

                New-UDTextbox -Id "browseSearchBox" -Placeholder "Search recipes..." -FullWidth -Value ($search ?? "")

                New-UDButton -Text "Search" -ClassName "btn-primary" -OnClick {
                    $q = (Get-UDElement -Id "browseSearchBox").value
                    $url = Get-BrowseUrl -Tag $tagFilter -Q $q -Fav $favOnly
                    Invoke-UDRedirect -Url $url
                }

                # Favorites toggle
                New-UDButton -Text ($favOnly ? "★ Favorites" : "☆ Favorites") -ClassName ($favOnly ? "fav-toggle-on" : "fav-toggle") -OnClick {
                    $newFav = -not $favOnly
                    $q = (Get-UDElement -Id "browseSearchBox").value
                    $url = Get-BrowseUrl -Tag $tagFilter -Q $q -Fav $newFav
                    Invoke-UDRedirect -Url $url
                }

                if ($search -or $tagFilter -or $favOnly) {
                    New-UDButton -Text "Clear" -ClassName "btn-ghost" -OnClick {
                        Invoke-UDRedirect -Url "/browse"
                    }
                }
            }

            New-UDHtml -Markup "<div style='height:16px;'></div>"

            # Categories / Tag Chips
            New-UDDynamic -Id "tagChips" -Content {

                $tags = Get-Tag -Limit 40

                New-UDTypography -Text "Categories" -Variant h6 -Style @{ fontWeight = "950"; color = "#241A37"; marginBottom = "10px" }

                if (-not $tags) {
                    New-UDTypography -Text "No categories yet — add tags when saving recipes." -Variant body2 -ClassName "muted"
                }
                else {
                    New-UDStack -Direction row -Spacing 1 -Content {

                        if ($tagFilter) {
                            New-UDChip -Label "All" -OnClick {
                                $url = Get-BrowseUrl -Tag $null -Q $search -Fav $favOnly
                                Invoke-UDRedirect -Url $url
                            }
                        }

                        foreach ($t in @($tags)) {
                            $name = $t.Name
                            $count = [int]($t.RecipeCount ?? 0)

                            $selected = ($tagFilter -and $tagFilter -eq $name)

                            New-UDChip -Label "$name ($count)" -Variant ($selected ? "default" : "outlined") -Color ($selected ? "primary" : "default") -OnClick {
                                $url = Get-BrowseUrl -Tag $name -Q $search -Fav $favOnly
                                Invoke-UDRedirect -Url $url
                            }
                        }
                    }
                }
            }

            New-UDHtml -Markup "<div style='height:16px;'></div>"

            # Recipe Cards
            New-UDDynamic -Id "recipeCards" -Content {

                $recipes = if ($tagFilter) {
                    Get-RecipeByTag -TagName $tagFilter
                }
                elseif ($search) {
                    Get-Recipe -Search $search -FavoriteOnly:($favOnly)
                }
                else {
                    Get-Recipe -FavoriteOnly:($favOnly)
                }

                if (-not $recipes) {
                    New-UDCard -ClassName "mini-card" -Content {
                        New-UDTypography -Text "No recipes found." -Variant h6 -Style @{ fontWeight = "950"; color = "#241A37" }
                        New-UDTypography -Text "Try another search, change filters, or add a recipe." -Variant body2 -ClassName "muted"
                    }
                    return
                }

                New-UDGrid -Container -Spacing 2 -Content {

                    foreach ($r in @($recipes)) {

                        $rid = [int]$r.RecipeId
                        $isFav = ([int]($r.IsFavorite ?? 0)) -eq 1

                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 4 -LargeSize 3 -Content {

                            New-UDElement -Tag "div" -Attributes @{ style = @{ position = "relative" } } -Content {

                                New-UDCard -ClassName "mini-card" -Content {

                                    $imgPath = Get-RecipeImagePath -RecipeId $rid
                                    if ($imgPath) {
                                        New-UDImage -Path $imgPath -ClassName "card-img"
                                    }
                                    else {
                                        New-UDElement -Tag "div" -Attributes @{ className = "card-img-placeholder" } -Content { }
                                    }

                                    New-UDElement -Tag "div" -Attributes @{ style = @{ padding = "14px" } } -Content {

                                        New-UDTypography -Text $r.Title -Variant h6 -Style @{
                                            fontWeight = "950"
                                            color      = "#241A37"
                                            margin     = "0"
                                            lineHeight = "1.15"
                                        }

                                        if ($r.Description) {
                                            New-UDTypography -Text $r.Description -Variant body2 -Style @{
                                                marginTop  = "6px"
                                                color      = "rgba(36,26,55,0.72)"
                                                lineHeight = "1.35"
                                            }
                                        }

                                        New-UDElement -Tag "div" -Attributes @{ className = "statline" } -Content {

                                            if (($r.PrepTimeMin ?? 0) -gt 0) {
                                                New-UDHtml -Markup "<span class='statpill'>⏱️ $($r.PrepTimeMin)m</span>"
                                            }
                                            if (($r.CookTimeMin ?? 0) -gt 0) {
                                                New-UDHtml -Markup "<span class='statpill'>🔥 $($r.CookTimeMin)m</span>"
                                            }
                                            if (($r.Servings ?? 0) -gt 0) {
                                                New-UDHtml -Markup "<span class='statpill'>🍽️ $($r.Servings)</span>"
                                            }
                                        }

                                        New-UDHtml -Markup "<div style='height:10px;'></div>"

                                        New-UDStack -Direction row -JustifyContent space-between -AlignItems center -Content {

                                            New-UDButton -Text "View" -ClassName "btn-ghost" -OnClick {
                                                Invoke-UDRedirect -Url "/recipe/$rid"
                                            }

                                            New-UDStack -Direction row -Spacing 1 -Content {

                                                New-UDButton -Text "Edit" -ClassName "btn-ghost" -OnClick {
                                                    Show-RecipeModal -RecipeId $rid -SyncId @("recipeCards", "tagChips")
                                                }

                                                New-UDButton -Text ($isFav ? "★" : "☆") -Variant text -OnClick {
                                                    Set-RecipeFavorite -RecipeId $rid -IsFavorite (-not $isFav)
                                                    Sync-UDElement -Id "recipeCards"
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
