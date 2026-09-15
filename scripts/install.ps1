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

function Install-Symlink {
    param([string]$Source, [string]$Destination)

    $parent = Split-Path -Parent $Destination
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    $expectedTarget = [System.IO.Path]::GetFullPath($Source)
    $existing = Get-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
    if ($null -ne $existing) {
        $isSymlink = [bool]($existing.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
        if ($isSymlink -and $existing.Target) {
            $currentTarget = [string]$existing.Target
            if (-not [System.IO.Path]::IsPathRooted($currentTarget)) {
                $currentTarget = Join-Path $parent $currentTarget
            }
            if ([System.IO.Path]::GetFullPath($currentTarget) -eq $expectedTarget) {
                Write-Host "Symlink already current: $Destination"
                return
            }
        }
    }

    $suffix = "$(Get-Date -Format 'yyyyMMdd-HHmmss')-$([guid]::NewGuid())"
    $probe = Join-Path $parent ".symlink-probe-$suffix"
    try {
        New-Item -ItemType SymbolicLink -Path $probe -Target $Source | Out-Null
    } catch {
        throw "Failed to create temporary symlink in $parent. On Windows, run from an elevated shell or enable Developer Mode. Original $Destination was left unchanged. $($_.Exception.Message)"
    } finally {
        if (Test-Path -LiteralPath $probe) {
            Remove-Item -LiteralPath $probe -Force
        }
    }

    if ($null -ne $existing) {
        $backup = "$Destination.backup-$suffix"
        Move-Item -LiteralPath $Destination -Destination $backup
        Write-Host "Backed up $Destination to $backup"
    }
    New-Item -ItemType SymbolicLink -Path $Destination -Target $Source | Out-Null
    Write-Host "Linked $Destination -> $Source"
}

& $BuildScript
Install-Symlink -Source $Source -Destination $Destination

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

$HerdrInstallDir = if ($env:HERDR_INSTALL_DIR) {
    $env:HERDR_INSTALL_DIR
} else {
    Join-Path $env:LOCALAPPDATA "Programs/Herdr/bin"
}
if ((Get-Command herdr -ErrorAction SilentlyContinue) -or
    (Test-Path -LiteralPath (Join-Path $HerdrInstallDir "herdr.exe") -PathType Leaf)) {
    Write-Host "Herdr already installed."
} else {
    $HerdrInstaller = Join-Path ([System.IO.Path]::GetTempPath()) "herdr-install-$([guid]::NewGuid()).ps1"
    try {
        Invoke-WebRequest -Uri "https://herdr.dev/install.ps1" -OutFile $HerdrInstaller -UseBasicParsing
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $HerdrInstaller
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to install Herdr."
        }
    } finally {
        if (Test-Path -LiteralPath $HerdrInstaller) {
            Remove-Item -LiteralPath $HerdrInstaller -Force
        }
    }
}

$HerdrSource = Join-Path $RepoRoot "dotfile/herdr/config.toml"
$HerdrDestination = Join-Path $env:APPDATA "herdr/config.toml"
Install-Symlink -Source $HerdrSource -Destination $HerdrDestination
