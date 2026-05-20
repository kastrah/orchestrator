#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
install_dir="${CODEX_HOME:-$HOME/.codex}"
bin_dir="$install_dir/bin"
agents_file="$install_dir/AGENTS.md"
wrapper_path="$bin_dir/opencode-agent"

mkdir -p "$bin_dir"
install -m 755 "$repo_root/bin/opencode-agent" "$wrapper_path"

mkdir -p "$install_dir"
touch "$agents_file"

begin_marker="<!-- opencode-agent-routing:start -->"
end_marker="<!-- opencode-agent-routing:end -->"
snippet_file="$(mktemp)"
tmp_file="$(mktemp)"

cat > "$snippet_file" <<'SNIPPET'
<!-- opencode-agent-routing:start -->

## Global Multi-Agent Implementation Workflow

Across projects, Codex is the orchestrator. Codex owns planning, task scoping, integration, verification, and final user communication.

When implementation or second-pass review benefits from another agent, use OpenCode Go workers with bounded task context. Do not give worker agents the full conversation history by default; give them the goal, files in scope, files to avoid, constraints, and expected final report.

Default OpenCode Go routing:

- `implement`: `opencode-go/deepseek-v4-flash` for high-volume small/medium implementation, exploration, test repairs, and cleanup. Approximate limit: 31,650 requests per 5h.
- `implement-pro`: `opencode-go/deepseek-v4-pro` for complex implementation, hard bugs, multi-file refactors, and architecture-sensitive changes. Approximate limit: 3,450 requests per 5h.
- `review`: `opencode-go/mimo-v2.5-pro` for normal second-pass review of meaningful diffs. Approximate limit: 1,290 requests per 5h.
- `review-glm`: `opencode-go/glm-5.1` for high-risk targeted review, especially auth, billing, OCR, data, and security. Approximate limit: 880 requests per 5h.

Use the cheapest capable model first. Do not call premium reviewer agents repeatedly without first inspecting the diff and narrowing the next prompt.

Use the global wrapper by default:

```bash
~/.codex/bin/opencode-agent implement "<bounded implementation task>"
~/.codex/bin/opencode-agent review "<bounded review task>"
```

If the wrapper is unavailable, use direct OpenCode commands:

```bash
opencode run --model opencode-go/deepseek-v4-flash --dir "$PWD" "<bounded implementation task>"
opencode run --model opencode-go/mimo-v2.5-pro --dir "$PWD" "<bounded review task>"
```

Worker final reports should include files changed, what changed, risks or assumptions, and tests run or not run. Codex must review worker output and run appropriate verification before claiming completion.

<!-- opencode-agent-routing:end -->
SNIPPET

if grep -q "$begin_marker" "$agents_file"; then
  awk -v begin="$begin_marker" -v end="$end_marker" '
    $0 == begin { skipping = 1; next }
    $0 == end { skipping = 0; next }
    !skipping { print }
  ' "$agents_file" > "$tmp_file"
  cat "$tmp_file" "$snippet_file" > "$agents_file"
else
  {
    cat "$agents_file"
    if [[ -s "$agents_file" ]]; then
      printf '\n'
    fi
    cat "$snippet_file"
  } > "$tmp_file"
  mv "$tmp_file" "$agents_file"
fi

rm -f "$snippet_file" "$tmp_file"

echo "Installed opencode-agent to $wrapper_path"
echo "Updated Codex instructions at $agents_file"
echo
echo "Next checks:"
echo "  $wrapper_path --help"
echo "  $wrapper_path implement --dry-run \"Do not edit files. Reply READY.\""
echo "  opencode providers list"
