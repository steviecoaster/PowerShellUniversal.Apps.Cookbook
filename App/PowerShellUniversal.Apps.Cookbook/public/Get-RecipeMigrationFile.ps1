function Get-RecipeMigrationFile {
    [CmdletBinding()]
    param()

    $migrationRoot = Join-Path $PSScriptRoot "..\data\migrations"
    $migrationRoot = [System.IO.Path]::GetFullPath($migrationRoot)

    if (-not (Test-Path $migrationRoot)) {
        return @()
    }

    # Expect files like 001.sql, 002.sql, 003.sql
    $files = Get-ChildItem -Path $migrationRoot -Filter "*.sql" -File |
        Where-Object { $_.BaseName -match '^\d{3,}$' } |
        Sort-Object { [int]$_.BaseName }

    $files
}
