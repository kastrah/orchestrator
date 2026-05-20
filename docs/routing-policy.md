# Routing Policy

The goal is to keep Codex as the accountable orchestrator while using OpenCode Go models as bounded workers.

## Model Roles

| Role | Model | Approximate request limit per 5h | Default use |
| --- | --- | ---: | --- |
| `implement` | `opencode-go/deepseek-v4-flash` | 31,650 | High-volume implementation, small/medium edits, simple bug fixes, tests |
| `implement-pro` | `opencode-go/deepseek-v4-pro` | 3,450 | Complex implementation, hard bugs, multi-file refactors |
| `review` | `opencode-go/mimo-v2.5-pro` | 1,290 | Default second reviewer for meaningful diffs |
| `review-glm` | `opencode-go/glm-5.1` | 880 | High-risk targeted review |

## Escalation Rules

Use `implement` first unless the task is clearly complex.

Escalate to `implement-pro` when:

- The change spans several modules.
- The bug requires deep reasoning.
- The task affects architecture or shared contracts.
- The first implementation attempt produces a weak or incomplete diff.

Use `review` when:

- The diff is meaningful enough to warrant second-pass review.
- The code touches user-facing behavior.
- The implementation was done by a worker agent.

Use `review-glm` sparingly when:

- The change touches auth, billing, OCR, data access, security, or migrations.
- The default review is inconclusive.
- The risk of a regression is higher than the cost of a premium review call.

## Prompt Shape

Implementation prompts should include:

- Goal
- Files in scope
- Files to avoid
- Constraints
- Verification commands to consider
- Expected final report format

Review prompts should ask for findings only, ordered by severity. Reviewers should not rewrite code unless explicitly asked.

## Accountability

Codex must inspect worker output and run verification before claiming completion. Worker reports are useful input, not proof.
