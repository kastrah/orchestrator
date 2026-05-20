# Orchestrator Help

## What this is

This repository sets up a global Codex + OpenCode Go multi-agent workflow.
Codex owns planning, integration, and verification. OpenCode Go models
handle bounded implementation and review tasks.

## Normal usage

Talk to Codex normally. After install, Codex reads the routing instructions
in `~/.codex/AGENTS.md` and delegates to the appropriate worker model when
needed.

You do not need to say `implement` or `review` unless you want to force
a specific model.

## Forcing a model

Prefix your message to Codex with the role:

```text
implement <task>
implement-pro <task>
review <task>
review-glm <task>
```

## Direct wrapper usage

```bash
~/.codex/bin/opencode-agent implement "Fix the failing unit test."
~/.codex/bin/opencode-agent review "Review the current git diff."
```

See the README for the full list of roles and options.

## Install

```bash
git clone https://github.com/kastrah/orchestrator.git
cd orchestrator
./install.sh
```

## Verify

```bash
./scripts/verify-install.sh
```

## Troubleshooting

**opencode not found** — run `opencode providers list`. If missing,
install OpenCode from [opencode.ai/docs](https://opencode.ai/docs/).

**Dry-run a wrapper call** to confirm routing without spending a request:

```bash
~/.codex/bin/opencode-agent implement --dry-run "test"
```

## Reference

- [Routing policy](routing-policy.md)
- [Worker prompt templates](worker-prompts.md)
