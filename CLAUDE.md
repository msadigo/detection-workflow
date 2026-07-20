# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Status

This repository is currently empty — no source code, configuration, or documentation has been added yet.

This file is a placeholder. Once the project takes shape (build tooling, source layout, tests, etc.), update this file with:
- Build, lint, and test commands (including how to run a single test)
- High-level architecture and structure notes

## Notes

- `costThreshold` (e.g. `warningAt`/`hardLimit`) is **not** a real Claude Code
  setting. Anthropic's `settings.json` schema has no such key, so adding it
  would sit inertly with no enforcement — don't assume budget limits are
  being applied just because such keys appear in a settings file.
