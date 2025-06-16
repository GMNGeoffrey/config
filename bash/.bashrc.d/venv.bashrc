function normalize_venv_name {
  # Defaults to empty, which ends up pointing to just '.venv' in the current
  # directory.
  local name="${1:-}"
  name="${name%.venv/}"
  name="${name%.venv}"
  echo "${name}.venv"
}

function venv() {
  local name="$(normalize_venv_name "$1")"
  python3 -m venv "${name}"
}

function activate() {
  local name="$(normalize_venv_name "$1")"
  source "${name}/bin/activate"
}

