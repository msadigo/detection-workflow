#!/usr/bin/env bash
# PostToolUse hook: validates detection rule YAML files under rules/.
# Reads a Claude Code tool-hook JSON payload from stdin, checks whether the
# written file is a YAML rule, and if so validates its required fields.
set -u

payload="$(cat)"

# jq isn't installed on this machine, so extract file_path with Node instead.
file_path="$(printf '%s' "$payload" | node -e '
let data = "";
process.stdin.on("data", c => data += c);
process.stdin.on("end", () => {
  try {
    const o = JSON.parse(data);
    const fp = (o.tool_input && o.tool_input.file_path) || o.file_path || "";
    process.stdout.write(fp);
  } catch (e) {
    process.exit(1);
  }
});
')"

if [ -z "$file_path" ]; then
  exit 0
fi

# Normalize backslashes to forward slashes for the path check.
normalized_path="$(printf '%s' "$file_path" | tr '\\' '/')"

# Only validate YAML files living under a rules/ directory.
if ! [[ "$normalized_path" =~ (^|/)rules/.*\.(yml|yaml)$ ]]; then
  exit 0
fi

if [ ! -f "$file_path" ]; then
  echo "validate-rule: file not found: $file_path" >&2
  exit 2
fi

validation_output="$(python -c '
import sys
import yaml

path = sys.argv[1]

try:
    with open(path, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f)
except yaml.YAMLError as e:
    print(f"invalid YAML: {e}")
    sys.exit(1)
except OSError as e:
    print(f"could not read file: {e}")
    sys.exit(1)

if not isinstance(data, dict):
    print("rule must be a YAML mapping at the top level")
    sys.exit(1)

errors = []

title = data.get("title")
if not title or not isinstance(title, str):
    errors.append("missing or empty required field: title")

description = data.get("description")
if not description or not isinstance(description, str):
    errors.append("missing or empty required field: description")

tags = data.get("tags")
if not tags or not isinstance(tags, list):
    errors.append("missing or empty required field: tags")
elif not any(isinstance(t, str) and t.lower().startswith("attack.t") for t in tags):
    errors.append("tags must include at least one MITRE ATT&CK technique tag (e.g. attack.t1059)")

if errors:
    for e in errors:
        print(e)
    sys.exit(1)

print("rule is valid")
sys.exit(0)
' "$file_path" 2>&1)"
validation_status=$?

if [ "$validation_status" -ne 0 ]; then
  echo "validate-rule: $file_path is invalid:" >&2
  while IFS= read -r line; do
    echo "  - $line" >&2
  done <<< "$validation_output"
  exit 2
fi

echo "validate-rule: $file_path is valid ($validation_output)" >&2
exit 2
