    function ConvertTo-StepText {
    [CmdletBinding()]
    param([array]$Steps)

    (@($Steps) | ForEach-Object { $_.Instruction ?? $_ }) -join "`n"
}
