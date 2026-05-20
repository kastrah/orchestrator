#!/usr/bin/env bash
set -euo pipefail

wrapper="${CODEX_HOME:-$HOME/.codex}/bin/opencode-agent"

if [[ ! -x "$wrapper" ]]; then
  echo "Missing executable wrapper: $wrapper" >&2
  echo "Run ./install.sh first." >&2
  exit 1
fi

"$wrapper" implement --dry-run "Do not edit files. Reply READY." >/tmp/opencode-agent-verify.txt

grep -q "role=implement" /tmp/opencode-agent-verify.txt
grep -q "model=opencode-go/deepseek-v4-flash" /tmp/opencode-agent-verify.txt

if ! command -v opencode >/dev/null 2>&1; then
  echo "Wrapper installed, but opencode is not on PATH." >&2
  exit 1
fi

opencode providers list >/tmp/opencode-agent-providers.txt

echo "Install verified."
echo "Wrapper: $wrapper"
echo "OpenCode: $(command -v opencode)"
