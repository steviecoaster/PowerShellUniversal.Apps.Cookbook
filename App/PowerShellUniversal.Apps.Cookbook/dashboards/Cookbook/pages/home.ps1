$homepage = New-UDPage -Name "Home" -Url '/home' -Content {

    Start-Cookbook
    
    New-UDStyle -Style @"
        :root {
            --lilac: #B58CFF;
            --lilac-dark: #8E6BFF;
            --lilac-soft: rgba(181, 140, 255, 0.12);
            --border: rgba(181, 140, 255, 0.20);
            --text: #241A37;
            --muted: rgba(36, 26, 55, 0.70);
            --surface: rgba(255,255,255,0.92);
        }

        .home-wrap {
            padding: 18px;
            background:
                radial-gradient(circle at 20% 0%, rgba(181,140,255,0.14) 0%, transparent 42%),
                radial-gradient(circle at 100% 25%, rgba(181,140,255,0.10) 0%, transparent 45%),
                linear-gradient(180deg, rgba(255,255,255,1) 0%, rgba(250,248,255,1) 100%);
            border-radius: 18px;
        }

        .card {
            border-radius: 16px !important;
            border: 1px solid var(--border) !important;
            box-shadow: 0 10px 24px rgba(0,0,0,0.06) !important;
            background: var(--surface) !important;
        }

        .mini {
            border-radius: 14px !important;
            border: 1px solid rgba(181, 140, 255, 0.18) !important;
            background: rgba(181, 140, 255, 0.06) !important;
            box-shadow: none !important;
            padding: 10px !important;
        }

        .title {
            font-weight: 950;
            color: var(--text);
            margin: 0;
        }

        .subtitle {
            color: var(--muted);
            font-size: 13px;
            margin-top: 4px;
        }

        .section-label {
            text-transform: uppercase;
            letter-spacing: 0.3px;
            font-weight: 900;
            font-size: 12px;
            color: var(--lilac-dark);
            margin-bottom: 2px;
        }

        .section-title {
            font-weight: 950;
            font-size: 18px;
            color: var(--text);
            margin: 0;
        }

        .pill {
            display: inline-block;
            padding: 6px 10px;
            border-radius: 999px;
            border: 1px solid rgba(181, 140, 255, 0.25);
            background: var(--lilac-soft);
            color: var(--lilac-dark);
            font-weight: 900;
            font-size: 12px;
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

        .link {
            color: var(--text);
            font-weight: 950;
            text-decoration: none;
        }

        .link:hover {
            color: var(--lilac-dark);
            text-decoration: underline;
        }

        .icon-btn button {
            border-radius: 12px !important;
            font-weight: 950 !important;
            min-width: 38px !important;
            color: var(--lilac-dark) !important;
            text-transform: none !important;
        }
"@ -Content {

        # ✅ Real wrapper so background contains components (NO dead space issue)
        New-UDElement -Tag "div" -Attributes @{ className = "home-wrap" } -Content {

            # Everything refreshes cleanly via this single Dynamic
            New-UDDynamic -Id "home" -Content {

                # -----------------------------
                # Data
                # -----------------------------
                $stats = Get-RecipeStat

                $favorites = Get-FavoriteRecipe -Limit 5

                $recent = Get-RecentRecipe -Limit 5

                $topTags = Get-Tag

                # -----------------------------
                # HERO CARD
                # -----------------------------
                New-UDCard -ClassName "card" -Content {

                    New-UDGrid -Container -Spacing 2 -Content {

                        # Left: title + pills
                        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 7 -Content {
                            New-UDTypography -Text "Recipe Book" -Variant h4 -ClassName "title"
                            New-UDTypography -Text "Save, favorite, and find recipes fast." -Variant body2 -ClassName "subtitle"

                            New-UDHtml -Markup "<div style='height:10px;'></div>"

                            New-UDStack -Direction row -Spacing 1 -Content {
                                New-UDHtml -Markup "<span class='pill'>⭐ $($stats.FavoriteCount) favorites</span>"
                                New-UDHtml -Markup "<span class='pill'>📚 $($stats.RecipeCount) recipes</span>"
                                New-UDHtml -Markup "<span class='pill'>🏷️ $($stats.TagCount) tags</span>"
                            }
                        }

                        # Right: search + actions
                        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 5 -Content {

                            New-UDStack -Direction column -Spacing 1 -Content {

                                New-UDStack -Direction row -Spacing 1 -Content {
                                    New-UDTextbox -Id "homeSearch" -Placeholder "Search recipes…" -FullWidth
                                    New-UDButton -Text "Search" -ClassName "btn-primary" -OnClick {
                                        $search = (Get-UDElement -Id "homeSearch").Value
                                        if (-not $search) { $search = "" }
                                        $q = [System.Web.HttpUtility]::UrlEncode($search)
                                        Invoke-UDRedirect -Url "/browse?Search=$q"
                                    }
                                }

                                New-UDStack -Direction row -Spacing 1 -Content {

                                    # ✅ Add = Modal
                                    New-UDButton -Text "Add" -ClassName "btn-primary" -OnClick {
                                        Show-RecipeModal
                                    }

                                    New-UDButton -Text "Browse" -ClassName "btn-ghost" -OnClick {
                                        Invoke-UDRedirect -Url "/browse"
                                    }

                                    New-UDButton -Text "Random" -ClassName "btn-ghost" -OnClick {
                                        $random = Invoke-RecipeDbQuery -Query "SELECT RecipeId FROM Recipes ORDER BY RANDOM() LIMIT 1;"
                                        if ($random) {
                                            Invoke-UDRedirect -Url "/recipe/$($random.RecipeId)"
                                        }
                                        else {
                                            Show-UDToast -Message "No recipes yet — add one first!" -Duration 4000
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                New-UDHtml -Markup "<div style='height:14px;'></div>"

                # -----------------------------
                # MAIN GRID
                # -----------------------------
                New-UDGrid -Container -Spacing 2 -Content {

                    # FAVORITES
                    New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -Content {
                        New-UDCard -ClassName "card" -Content {

                            New-UDTypography -Text "Favorites" -Variant body2 -ClassName "section-label"
                            New-UDTypography -Text "Your go-to recipes" -Variant h6 -ClassName "section-title"
                            New-UDHtml -Markup "<div style='height:10px;'></div>"

                            if (-not $favorites) {
                                New-UDTypography -Text "No favorites yet — click ☆ on a recipe to pin it here." -Variant body2 -ClassName "subtitle"
                            }
                            else {
                                New-UDStack -Direction column -Spacing 1 -Content {
                                    foreach ($f in @($favorites)) {
                                        New-UDCard -ClassName "mini" -Content {

                                            New-UDStack -Direction row -JustifyContent space-between -AlignItems center -Content {

                                                New-UDLink -Text $f.Title -Url "/cookbook/recipe/$($f.RecipeId)" -ClassName "link"

                                                New-UDButton -Text "★" -Variant text -ClassName "icon-btn" -OnClick {
                                                    Set-RecipeFavorite -RecipeId $f.RecipeId -IsFavorite:$false
                                                    Sync-UDElement -Id "home"
                                                    Show-UDToast -Message "Removed from favorites" -Duration 2000
                                                }
                                            }

                                            New-UDTypography -Text ("Prep {0}m • Cook {1}m • Serves {2}" -f $f.PrepTimeMin, $f.CookTimeMin, $f.Servings) -Variant body2 -ClassName "subtitle"
                                        }
                                    }
                                }
                            }
                        }
                    }

                    # RECENT
                    New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -Content {
                        New-UDCard -ClassName "card" -Content {

                            New-UDTypography -Text "Recent" -Variant body2 -ClassName "section-label"
                            New-UDTypography -Text "Recently updated" -Variant h6 -ClassName "section-title"
                            New-UDHtml -Markup "<div style='height:10px;'></div>"

                            if (-not $recent) {
                                New-UDTypography -Text "No recipes yet — click Add to make your first one." -Variant body2 -ClassName "subtitle"
                            }
                            else {
                                New-UDStack -Direction column -Spacing 1 -Content {
                                    foreach ($r in @($recent)) {
                                        $star = if ([int]$r.IsFavorite -eq 1) { "★" } else { "☆" }

                                        New-UDCard -ClassName "mini" -Content {

                                            New-UDStack -Direction row -JustifyContent space-between -AlignItems center -Content {

                                                New-UDLink -Text $r.Title -Url "/cookbook/recipe/$($r.RecipeId)" -ClassName "link"

                                                New-UDStack -Direction row -Spacing 1 -AlignItems center -Content {

                                                    # ✅ Favorite toggle (refresh home)
                                                    New-UDButton -Text $star -Variant text -ClassName "icon-btn" -OnClick {
                                                        Switch-RecipeFavorite -RecipeId $r.RecipeId
                                                        Sync-UDElement -Id "home"
                                                    }

                                                    # ✅ Edit = modal (still simple)
                                                    New-UDButton -Text "Edit" -Variant text -ClassName "icon-btn" -OnClick {
                                                        Show-RecipeModal -RecipeId $r.RecipeId
                                                    }
                                                }
                                            }

                                            New-UDTypography -Text ("Prep {0}m • Cook {1}m • Serves {2}" -f $r.PrepTimeMin, $r.CookTimeMin, $r.Servings) -Variant body2 -ClassName "subtitle"
                                        }
                                    }
                                }
                            }
                        }
                    }

                    # TAGS (FULL WIDTH)
                    New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 12 -Content {
                        New-UDCard -ClassName "card" -Content {

                            New-UDTypography -Text "Tags" -Variant body2 -ClassName "section-label"
                            New-UDTypography -Text "Browse by category" -Variant h6 -ClassName "section-title"
                            New-UDHtml -Markup "<div style='height:10px;'></div>"

                            if (-not $topTags) {
                                New-UDTypography -Text "No tags yet — add tags when saving recipes." -Variant body2 -ClassName "subtitle"
                            }
                            else {
                                New-UDStack -Direction row -Spacing 1 -Content {
                                    foreach ($t in @($topTags)) {
                                        $name = $t.Name
                                        $count = [int]($t.RecipeCount ?? 0)
                                        New-UDButton -Text "$name ($count)" -Variant outlined -Style @{
                                            borderRadius  = "999px"
                                            border        = "1px solid rgba(181,140,255,0.35)"
                                            background    = "rgba(181,140,255,0.08)"
                                            color         = "#6E4DFF"
                                            fontWeight    = "900"
                                            textTransform = "none"
                                            padding       = "6px 12px"
                                        } -OnClick {
                                            Invoke-UDRedirect -Url "/browse?tag=$([uri]::EscapeDataString($name))"
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
