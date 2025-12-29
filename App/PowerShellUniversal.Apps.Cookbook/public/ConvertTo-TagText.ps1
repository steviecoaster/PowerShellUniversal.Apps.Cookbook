function ConvertTo-TagText {
    [CmdletBinding()]
    param([array]$Tags)

    (@($Tags) | ForEach-Object { $_.Name ?? $_ }) -join ", "
}
