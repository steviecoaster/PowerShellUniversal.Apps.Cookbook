function ConvertFrom-StepText {
    [CmdletBinding()]
    param([string]$Text)

    ($Text -split "`n" | ForEach-Object { $_.Trim() }) | Where-Object { $_ }
}
