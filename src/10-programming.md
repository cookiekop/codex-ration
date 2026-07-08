## Programming

### Python

- Prefer `uv` for Python environments and dependency management.
- Prefer `[project.scripts]` in `pyproject.toml` for Python CLI entry points.
- Prefer explicit Python type annotations for variables when they improve
  readability.
- Prefer shape comments or annotations for tensors and arrays, especially
  `np.ndarray` and `torch.Tensor`.
- Prefer `pytest` configured in `pyproject.toml`, verified with
  `uv run pytest`; include CLI smoke tests for `[project.scripts]` entry
  points.

### C/C++

- Prefer CMake for C/C++ project structure.
- Prefer `samples/` for runnable examples and entry points.
- Prefer `build/` for compile output.
- Prefer lowercase `snake_case` files and folders unless the project has an
  established different convention.
- Prefer lowercase names for local variables and parameters.
- Prefer leading underscore members for private/internal C++ storage unless the
  project has an established different convention.
- Prefer GoogleTest for C/C++ test cases, integrated through CMake.
- Prefer an explicit boundary between public API and private implementation.
- Keep build, install, and packaging rules aligned with that boundary.
