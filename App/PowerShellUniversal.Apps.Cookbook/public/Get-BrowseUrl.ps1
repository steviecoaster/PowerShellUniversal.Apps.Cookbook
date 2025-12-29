 function Get-BrowseUrl {
        param(
            [string]$Tag,
            [string]$Q,
            [bool]$Fav
        )

        $parts = @()
        if ($Tag) { $parts += "tag=$([uri]::EscapeDataString($Tag))" }
        if ($Q) { $parts += "q=$([uri]::EscapeDataString($Q))" }
        if ($Fav) { $parts += "fav=1" }

        if ($parts.Count -gt 0) {
            return "/browse?$($parts -join '&')"
        }

        "/browse"
    }