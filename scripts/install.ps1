param(
    [string]$CodexHome = (Join-Path $HOME ".codex")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$BuildScript = Join-Path $RepoRoot "scripts/build-agents.ps1"
$Source = Join-Path $RepoRoot "dotfile/AGENTS.md"
$Destination = Join-Path $CodexHome "AGENTS.md"
$SkillsDestination = Join-Path $CodexHome "skills"
$SkillInstaller = Join-Path $SkillsDestination ".system/skill-installer/scripts/install-skill-from-github.py"

& $BuildScript

New-Item -ItemType Directory -Force -Path $CodexHome | Out-Null

$expectedTarget = [System.IO.Path]::GetFullPath($Source)
$needsLink = $true
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

if (Test-Path -LiteralPath $Destination) {
    $existing = Get-Item -LiteralPath $Destination -Force
    $isSymlink = [bool]($existing.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
    if ($isSymlink -and $existing.Target) {
        $currentTarget = [System.IO.Path]::GetFullPath([string]$existing.Target)
        if ($currentTarget -eq $expectedTarget) {
            $needsLink = $false
        }
    }
}

if ($needsLink) {
    $probe = Join-Path $CodexHome ".AGENTS.md.symlink-probe-$timestamp"
    try {
        New-Item -ItemType SymbolicLink -Path $probe -Target $Source | Out-Null
    } catch {
        throw "Failed to create temporary symlink in $CodexHome. On Windows, run from an elevated shell or enable Developer Mode. Original AGENTS.md was left unchanged. $($_.Exception.Message)"
    } finally {
        if (Test-Path -LiteralPath $probe) {
            Remove-Item -LiteralPath $probe -Force
        }
    }

    if (Test-Path -LiteralPath $Destination) {
        $backup = "$Destination.backup-$timestamp"
        Move-Item -LiteralPath $Destination -Destination $backup
        Write-Host "Backed up existing AGENTS.md to $backup"
    }
}

if ($needsLink) {
    New-Item -ItemType SymbolicLink -Path $Destination -Target $Source | Out-Null
    Write-Host "Linked $Destination -> $Source"
} else {
    Write-Host "Symlink already current: $Destination"
}

$skillPaths = @()
foreach ($skillName in @("grill-me", "grilling")) {
    if (-not (Test-Path -LiteralPath (Join-Path $SkillsDestination $skillName))) {
        $skillPaths += "skills/productivity/$skillName"
    }
}

if ($skillPaths.Count -gt 0) {
    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        throw "uv is required to install Codex skills. Install uv and rerun this script."
    }
    if (-not (Test-Path -LiteralPath $SkillInstaller)) {
        throw "Codex's built-in skill installer was not found at $SkillInstaller."
    }

    $installerArgs = @(
        "run", "--no-project", "python", $SkillInstaller,
        "--repo", "mattpocock/skills", "--path"
    ) + $skillPaths + @("--dest", $SkillsDestination)
    & uv @installerArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install the grill-me Codex skills."
    }
} else {
    Write-Host "Codex skills already installed: grill-me, grilling"
}
