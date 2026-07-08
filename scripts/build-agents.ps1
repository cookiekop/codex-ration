Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$SourceDir = Join-Path $RepoRoot "src"
$OutputDir = Join-Path $RepoRoot "dotfile"
$OutputFile = Join-Path $OutputDir "AGENTS.md"

if (-not (Test-Path -LiteralPath $SourceDir -PathType Container)) {
    throw "Source directory not found: $SourceDir"
}

$modules = Get-ChildItem -LiteralPath $SourceDir -Filter "*.md" -File |
    Sort-Object Name

if ($modules.Count -eq 0) {
    throw "No AGENTS.md modules found in $SourceDir"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$parts = [System.Collections.Generic.List[string]]::new()
$parts.Add("<!-- This file is generated from src. Edit those modules, then run the build script. -->")
$parts.Add("")

foreach ($module in $modules) {
    $parts.Add((Get-Content -LiteralPath $module.FullName -Raw).Trim())
    $parts.Add("")
}

$content = ($parts -join [Environment]::NewLine).TrimEnd() + [Environment]::NewLine
Set-Content -LiteralPath $OutputFile -Value $content -Encoding UTF8
Write-Host "Generated $OutputFile"
