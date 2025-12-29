function Invoke-UniversalSQLiteQuery {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Query
    )

    $sqlite = if ($IsLinux) { '/usr/bin/sqlite3' } else { 'sqlite3' }

    if ($IsLinux -and -not (Test-Path $sqlite)) {
        throw "sqlite3 not found at $sqlite. Install sqlite3 or update Invoke-UniversalSQLiteQuery."
    }

    if (-not $IsLinux -and -not (Get-Command sqlite3 -ErrorAction SilentlyContinue)) {
        throw "sqlite3 command not found. Please install SQLite."
    }

    if (-not (Test-Path $Path)) {
        throw "Database file not found: $Path"
    }

    $dbPath = Resolve-Path $Path | Select-Object -ExpandProperty Path

    # ✅ Only foreign keys. journal_mode outputs 'wal' and pollutes output.
    $cmd = 'PRAGMA foreign_keys = ON;'

    $output = $Query | & $sqlite $dbPath -cmd $cmd -json - 2>&1

    if ($LASTEXITCODE -ne 0) {
        throw "SQLite query failed: $output"
    }

    if ($output) {
        try {
            return ($output | ConvertFrom-Json)
        }
        catch {
            $csvOutput = $Query | & $sqlite $dbPath -cmd $cmd -csv -header - 2>&1
            if ($LASTEXITCODE -eq 0 -and $csvOutput) {
                try { return ($csvOutput | ConvertFrom-Csv) } catch { return $csvOutput }
            }
            return $output
        }
    }

    return $null
}
