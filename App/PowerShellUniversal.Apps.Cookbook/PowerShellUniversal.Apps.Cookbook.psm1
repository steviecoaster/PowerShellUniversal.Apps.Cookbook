# Dot source all public and private functions
$Public  = @( Get-ChildItem -Path (Join-Path $PSScriptRoot 'public'  '*.ps1') -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path (Join-Path $PSScriptRoot 'private' '*.ps1') -ErrorAction SilentlyContinue )

foreach ($import in @($Public + $Private)) {
    try { . $import.FullName }
    catch { Write-Error -Message "Failed to import function $($import.FullName): $($_.Exception.Message)" }
}

# Load Schema.sql from module package
$SchemaPath = Join-Path $PSScriptRoot 'data' 'Schema.sql'
if (-not (Test-Path $SchemaPath)) {
    throw "Schema.sql not found at: $SchemaPath"
}

# Pick a simple, stable data path based on OS
# Windows: $env:ProgramData\Cookbook
# Linux:   $env:HOME/cookbook  (PSU runs under the service user; writable)
if ($IsWindows) {
    $BasePath = Join-Path $env:ProgramData 'Cookbook'
}
elseif ($IsLinux) {
    if (-not $env:HOME) {
        throw "Linux detected but `$env:HOME is not set. Cannot determine cookbook data folder."
    }
    $BasePath = Join-Path $env:HOME 'cookbook'
}
else {
    # Fallback for other platforms
    $BasePath = Join-Path ([System.IO.Path]::GetTempPath()) 'cookbook'
}

# Define stable DB + image folder
$Script:RecipeDbPath    = Join-Path $BasePath 'recipes.db'
$Script:RecipeImageRoot = Join-Path $BasePath 'images'

# Create directories if missing
if (-not (Test-Path $BasePath)) {
    New-Item -Path $BasePath -ItemType Directory -Force | Out-Null
}
if (-not (Test-Path $Script:RecipeImageRoot)) {
    New-Item -Path $Script:RecipeImageRoot -ItemType Directory -Force | Out-Null
}

# Initialize DB + schema (idempotent)
Initialize-RecipeDbFile -Database $Script:RecipeDbPath
Initialize-RecipeDatabase -Schema $SchemaPath -Database $Script:RecipeDbPath
