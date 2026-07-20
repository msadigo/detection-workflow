#!/usr/bin/env bash
# PreToolUse/PostToolUse hook: blocks writes to sensitive files.
# Reads a Claude Code tool-hook JSON payload from stdin and checks whether
# the target file path looks like a secret (.env, *.key, *.pem, secrets/,
# credentials/). Exits 2 (block) if sensitive, 0 (allow) otherwise.
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

if [[ "$normalized_path" =~ (^|/)\.env(\..+)?$ ]] \
  || [[ "$normalized_path" =~ \.key$ ]] \
  || [[ "$normalized_path" =~ \.pem$ ]] \
  || [[ "$normalized_path" =~ (^|/)secrets/ ]] \
  || [[ "$normalized_path" =~ (^|/)credentials/ ]]; then
  echo "check-sensitive: blocked write to sensitive path: $file_path" >&2
  exit 2
fi

exit 0
