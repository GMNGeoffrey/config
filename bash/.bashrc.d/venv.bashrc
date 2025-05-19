function venv() {
  # Defaults to empty, which ends up pointing to just '.venv' in the current
  # directory.
  local name="${1:-}"
  # accept either foo or foo.venv
  name="${name%.venv}"
  python3 -m venv "${name}.venv"
}

function activate() {
  # Defaults to empty, which ends up pointing to just '.venv' in the current
  # directory.
  local name="${1:-}"
  # accept either foo or foo.venv
  name="${name%.venv}"
  source "${name}.venv/bin/activate"
}

