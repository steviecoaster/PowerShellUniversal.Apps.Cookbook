function ConvertFrom-TagText {
    [CmdletBinding()]
    param([string]$Text)

    ($Text -split "," | ForEach-Object { $_.Trim() }) | Where-Object { $_ } | Select-Object -Unique
}
