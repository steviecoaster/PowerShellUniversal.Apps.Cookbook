function ConvertTo-SqlSafe {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Value
    )

    ($Value ?? "").Replace("'", "''")
}
