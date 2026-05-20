# Orchestrator

Codex + OpenCode Go multi-agent setup.

This repository installs a global `opencode-agent` wrapper and a Codex instruction block so Codex can act as the orchestrator while OpenCode Go models handle bounded implementation and review work.

## What This Sets Up

- Codex remains responsible for planning, integration, verification, and final communication.
- OpenCode Go models are used as worker agents.
- Worker agents receive bounded context instead of full conversation history.
- Model routing accounts for request limits.

Default routing:

| Role | Model | Use |
| --- | --- | --- |
| `implement` | `opencode-go/deepseek-v4-flash` | Default implementation and high-volume work |
| `implement-pro` | `opencode-go/deepseek-v4-pro` | Complex implementation and hard bugs |
| `review` | `opencode-go/mimo-v2.5-pro` | Default second-pass review |
| `review-glm` | `opencode-go/glm-5.1` | High-risk targeted review |

See [docs/routing-policy.md](docs/routing-policy.md) for the full policy.

## Prerequisites

1. Codex with a writable `CODEX_HOME`, defaulting to `~/.codex`.
2. OpenCode installed and available as `opencode` on `PATH`.
3. OpenCode Go authenticated in OpenCode.

Check OpenCode authentication:

```bash
opencode providers list
```

You should see an OpenCode Go credential. If not, run:

```bash
opencode providers login
```

Then follow the OpenCode provider login flow.

Confirm the models are available:

```bash
opencode models opencode-go --refresh
```

Expected models include:

```text
opencode-go/deepseek-v4-flash
opencode-go/deepseek-v4-pro
opencode-go/mimo-v2.5-pro
opencode-go/glm-5.1
```

## Install

Clone this repository:

```bash
git clone https://github.com/kastrah/orchestrator.git
cd orchestrator
```

Run the installer:

```bash
./install.sh
```

The installer:

- Copies `bin/opencode-agent` to `~/.codex/bin/opencode-agent`.
- Adds or replaces a marked multi-agent routing block in `~/.codex/AGENTS.md`.

Verify the install:

```bash
./scripts/verify-install.sh
```

## Usage

From any project directory:

```bash
~/.codex/bin/opencode-agent implement "Fix the failing unit test. Report files changed and tests run."
~/.codex/bin/opencode-agent implement-pro "Refactor the shared auth flow. Keep the diff focused."
~/.codex/bin/opencode-agent review "Review the current git diff. Findings only, ordered by severity."
~/.codex/bin/opencode-agent review-glm "Review auth and billing risks in the current git diff. Do not edit files."
```

You can pipe a prompt:

```bash
cat prompt.txt | ~/.codex/bin/opencode-agent implement
```

Use JSON output for automation:

```bash
OPENCODE_AGENT_FORMAT=json ~/.codex/bin/opencode-agent review "Do not edit files. Reply READY."
```

Preview routing without spending model requests:

```bash
~/.codex/bin/opencode-agent implement --dry-run "Do not edit files. Reply READY."
```

## Project Directory Resolution

The wrapper sends OpenCode the current git root as `--dir`. If the current directory is not inside a git repository, it uses the current directory.

Override the directory:

```bash
OPENCODE_AGENT_DIR=/path/to/project ~/.codex/bin/opencode-agent implement "Task prompt"
```

## Updating

Pull the latest repository changes and rerun the installer:

```bash
git pull
./install.sh
```

The installer is safe to rerun. It replaces only the marked block in `~/.codex/AGENTS.md`.

## Uninstall

Remove the wrapper:

```bash
rm -f ~/.codex/bin/opencode-agent
```

Remove the marked block from `~/.codex/AGENTS.md`:

```text
<!-- opencode-agent-routing:start -->
...
<!-- opencode-agent-routing:end -->
```

## Notes

If OpenCode Go model names change, update:

- `bin/opencode-agent`
- `templates/AGENTS.snippet.md`
- `docs/routing-policy.md`
