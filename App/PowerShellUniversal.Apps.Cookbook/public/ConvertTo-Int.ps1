function ConvertTo-Int {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [int]$Default = 0
    )

    try {
        if ($null -eq $Value -or $Value -eq "") { return $Default }
        [int]$Value
    }
    catch { $Default }
}
