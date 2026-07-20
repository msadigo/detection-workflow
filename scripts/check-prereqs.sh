#!/usr/bin/env bash
# SessionStart hook: warns to stderr if required prerequisites are missing.
# Checks presence on PATH *and* that the binary actually runs, since Windows
# App Execution Aliases can put a non-functional stub on PATH (e.g. a
# python3 shim that just prompts to install from the Microsoft Store).
set -u

missing=()

check() {
  local name="$1"
  if ! command -v "$name" >/dev/null 2>&1; then
    missing+=("$name")
  elif ! "$name" --version >/dev/null 2>&1; then
    missing+=("$name")
  fi
}

check jq
check python3

if [ "${#missing[@]}" -gt 0 ]; then
  echo "check-prereqs: missing or non-functional prerequisites: ${missing[*]}" >&2
  echo "check-prereqs: some hooks in this project depend on these tools." >&2
fi

exit 0
