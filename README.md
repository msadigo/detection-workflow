# detection-workflow

Detection rule authoring workflow with automated validation via Claude Code hooks.

## Prerequisites

- [Git Bash](https://git-scm.com/downloads) (or another `bash` on your `PATH`) — hooks run as bash scripts
- [Node.js](https://nodejs.org/) — used to parse hook JSON payloads (no `jq` dependency)
- [Python 3](https://www.python.org/) with [PyYAML](https://pypi.org/project/PyYAML/) installed:

  ```sh
  pip install pyyaml
  ```

## Setup

1. Clone the repo:

   ```sh
   git clone https://github.com/msadigo/detection-workflow.git
   cd detection-workflow
   ```

2. Open the project in Claude Code. The validation hook in `.claude/settings.json`
   is picked up automatically — no extra configuration needed.

3. (Optional) Verify the validation script works standalone:

   ```sh
   echo '{"tool_input":{"file_path":"rules/example.yaml"}}' | bash scripts/validate-rule.sh
   ```

## Writing detection rules

Detection rules live under `rules/` as YAML files (`.yml` or `.yaml`). Each rule
must define:

- `title` — non-empty string
- `description` — non-empty string
- `tags` — a list containing at least one MITRE ATT&CK technique tag
  (e.g. `attack.t1059.001`)

Example:

```yaml
title: Suspicious PowerShell Encoded Command
description: Detects execution of PowerShell with base64-encoded command arguments.
tags:
  - attack.t1059.001
  - attack.execution
```

Whenever Claude Code writes or edits a file under `rules/`, a `PostToolUse` hook
(`scripts/validate-rule.sh`) automatically checks it against these requirements
and reports errors or success back to Claude.

## Repo layout

```
.claude/
  hooks/log-edit-write.sh   # logs every Edit/Write tool call to .claude/hook.log
  settings.json             # hook configuration (checked in, shared by the team)
  settings.local.json       # personal overrides (gitignored)
scripts/
  validate-rule.sh          # validates rules/*.yaml files (title, description, ATT&CK tag)
rules/                      # detection rules (created as you add them)
```
