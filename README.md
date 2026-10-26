# codex-ration

Personal global Codex guidance, maintained as modular Markdown and installed as
`~/.codex/AGENTS.md`.

This repo intentionally does not manage `~/.codex/config.toml`. Codex config can
contain machine-local project trust paths and other local state, so this project
only manages global guidance and the Herdr configuration below.

The installer also installs Matt Pocock's `grill-me` and companion `grilling`
skills globally for Codex, plus [Herdr](https://herdr.dev/docs/install/) when it
is missing. Linux skill installation uses the pinned `thirdparties/skills`
submodule and works before Codex or `uv` is installed. The Windows installer
currently requires `uv` and Codex's built-in skill installer. Herdr installation requires internet access and `curl` on Linux/macOS
or Windows PowerShell on Windows.

## Layout

- `src/` - source modules for the global guidance file.
- `dotfile/AGENTS.md` - generated file installed into Codex.
- `dotfile/herdr/config.toml` - Herdr config with Nord theme and tmux-style keys.
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
git submodule update --init --recursive
./scripts/install.sh
```

The installer creates `~/.codex` if needed, backs up an existing non-matching
`~/.codex/AGENTS.md`, symlinks it to `dotfile/AGENTS.md` in this repo, and
installs the `grill-me` and `grilling` skills for Codex, and installs Herdr using
its official installer if it is missing. Existing Herdr installations are kept.

It symlinks `dotfile/herdr/config.toml` to Herdr's
[config location](https://herdr.dev/docs/configuration/):

- Linux/macOS: `~/.config/herdr/config.toml`.
- Windows: `%APPDATA%\herdr\config.toml`.

Existing configs or links to other targets are backed up beside the destination
before replacement; correct symlinks are left alone. Edit the repo's config to
update the linked file. On Windows, enable Developer Mode or use an elevated
shell to create symlinks. The config disables onboarding and automatic theme switching,
uses Nord and Herdr toast delivery, hides agent labels on pane borders, and sets
`Ctrl-b` as the prefix with tmux-style tab, split, navigation, zoom, and detach keys.

On Linux/macOS, Herdr defaults to `~/.local/bin` (override with
`HERDR_INSTALL_DIR`). The Bash installer backs up and adds the install directory
to `.profile` and `.bashrc`, so login shells and noninteractive SSH commands can
find Herdr. Existing profile contents are preserved; repeated installs do not
duplicate the PATH entry. Other shells may need their usual PATH configuration.
