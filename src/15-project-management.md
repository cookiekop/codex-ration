## Project Management

### Documentation

- Prefer `docs/` for project documentation.
- Keep `README.md` focused on purpose, requirements, setup, build, and links to
  deeper docs.
- Put detailed feature, API, and integration docs under `docs/`.
- Keep `README.md` and `docs/` updated with code changes.

### Automation

- Prefer `scripts/` for repeatable setup, packaging, generation, and
  maintenance tasks.
- Prefer checked-in scripts over manual multi-step instructions.

### Testing

- Prefer a small number of strong, thorough tests under `tests/`; cover code
  with randomized inputs where practical.

### Dependencies

- Prefer `thirdparties/` for vendored dependencies and submodules.
- Make dependency setup and patching script-driven and reproducible.
- Keep dependency patches explicit and source-controlled.

### Data And Artifacts

- Prefer `input/` for local input assets and data.
- Prefer `output/` for generated outputs and artifacts.
- Prefer `.tmp/` for scratch files, experiments, and intermediate caches.
- Keep local inputs and generated outputs out of source control when they are
  large, licensed, machine-specific, or reproducible.

### Repository Hygiene

- Keep generated files and build outputs out of source control.
- Keep `.gitignore` thorough and up to date.
- Never use Git LFS unless explicitly requested.
