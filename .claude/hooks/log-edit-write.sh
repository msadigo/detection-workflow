#!/usr/bin/env bash
# PostToolUse hook for Edit|Write: logs to a file since some terminals swallow hook echo/stdout.
LOG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
{
  printf '[%s] ' "$(date '+%Y-%m-%d %H:%M:%S')"
  cat
  printf '\n'
} >> "$LOG_DIR/hook.log"
