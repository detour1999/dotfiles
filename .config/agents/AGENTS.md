# Working agreements

Instructions for any coding agent on this machine — Claude Code, Codex, Gemini CLI.
Detailed procedures live in skills, which load on demand. This file holds only what is
true in every session.

## Interaction

- Address me as "Dyl-Dawg".
- Lead with status and results. Skip the preamble.
- Report what didn't work as plainly as what did. A half-finished job described as finished
  costs me more than the failure did.
- Make routine calls yourself and say which call you made. Ask when two readings of the
  request would produce materially different work.

## Safety rails

Hard rules. Claude Code and Codex also enforce them deterministically with a pre-tool hook;
in any other agent they rest on you following them.

- Never run `firebase deploy` without both `--project` and `--account`. Prefer the project's
  deploy script (e.g. `pnpm deploy`) with the flags baked in.
- Never change shared CLI state — `firebase use`, `firebase login:use`, `gcloud config set` —
  without explicit approval. Several agents and projects share this machine, and the wrong
  context can overwrite a production system.
- Never bypass pre-commit hooks. `--no-verify`, `--no-hooks`, `--no-pre-commit-hook` and
  `git commit -n` are off-limits. If hooks fail, fix the cause or ask. My waiting is not a
  reason to bypass a quality gate.
- Before any side-effectful action, name the resolved target out loud: "deploying to project
  `car-parts` as account `dylan@2389.ai`". Answer it from the environment, not by asking me.

## Writing code

- Prefer simple and maintainable over clever or concise. Readability is the primary concern.
- Make the smallest reasonable change. Ask before reimplementing something that exists, and
  before discarding a working implementation to start over.
- Match the style of the surrounding file, even where it differs from the wider convention.
- Stay in scope. Note unrelated problems as issues instead of fixing them inline.
- Start every code file with two `ABOUTME: ` comment lines describing what it does.
- Keep comments evergreen — describe the code as it is, not how it changed. Don't delete a
  comment unless you can show it's false.
- Name things for what they are, never for when they arrived: no `improved`, `new`,
  `enhanced`, `v2`.
- Real data and real APIs. Never build a mock mode, for tests or anything else.

## Testing

- TDD by default: write the failing test before the implementation, then just enough code to
  pass, then refactor. Say which step you're on.
- Test output must be pristine to pass. Never ignore logs — they carry the explanation.

## Tooling

- The shell is **fish**. `export FOO=bar` and `cmd && other` are bash-isms that fail or
  behave differently — use `set -x FOO bar` and `cmd; and other`.
- Prefer mise, uv/uvx, and pnpm.
- Bind dev servers to `0.0.0.0` so other devices on the network can reach them.
- Quote and escape paths.
- I keep hands on dev servers and deploys. Don't start or deploy one without asking.

## Intent

Before non-trivial work, emit a short receipt of interpreted intent: quantify fuzzy
parameters with proposed values, enumerate multi-item asks, name decisions that had more
than one viable option, and state what you are *not* doing. Proceed immediately unless a
line is low-confidence. Full doctrine: `~/.config/agents/intent.md`.

## Getting help

Stop and ask when you're stuck on something I'd be faster at. Say what you already tried.
