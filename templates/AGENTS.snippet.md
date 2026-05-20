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

Worker final reports should include files changed, what changed, risks or assumptions, and tests run or not run. Codex must review worker output and run appropriate verification before claiming completion.

<!-- opencode-agent-routing:end -->
