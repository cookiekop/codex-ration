# codex-ration

Personal global Codex guidance, maintained as modular Markdown and installed as
`~/.codex/AGENTS.md`.

This repo intentionally does not manage `~/.codex/config.toml`. Codex config can
contain machine-local project trust paths and other local state, so this project
only owns durable global guidance.

The installer also installs Matt Pocock's `grill-me` and companion `grilling`
skills globally for Codex. This requires `uv`; no Node.js installation is
needed.

## Layout

- `src/` - source modules for the global guidance file.
- `dotfile/AGENTS.md` - generated file installed into Codex.
- `scripts/build-agents.ps1` - Windows/PowerShell build script.
- `scripts/build-agents.sh` - Bash build script.
- `scripts/install.ps1` - Windows/PowerShell symlink installer.
- `scripts/install.sh` - Bash symlink installer.

## Edit

Edit the Markdown modules in `src/`. Files are concatenated in lexical
order, so numeric prefixes define the installed order.

## Build

PowerShell:

```powershell
.\scripts\build-agents.ps1
```

Bash:

```bash
./scripts/build-agents.sh
```

## Install

PowerShell:

```powershell
.\scripts\install.ps1
```

Bash:

```bash
./scripts/install.sh
```

The installer creates `~/.codex` if needed, backs up an existing non-matching
`~/.codex/AGENTS.md`, symlinks it to `dotfile/AGENTS.md` in this repo, and
installs the `grill-me` and `grilling` skills for Codex.
