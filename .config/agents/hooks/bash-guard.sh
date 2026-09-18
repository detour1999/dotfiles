#!/usr/bin/env bash
# ABOUTME: PreToolUse guard for Bash — stops quality-gate bypasses and unscoped Firebase/GCP context changes.
# ABOUTME: Reads the hook JSON on stdin and emits a PreToolUse permission decision on stdout.

set -uo pipefail

# Claude Code's PreToolUse accepts allow/ask/deny. Codex accepts deny only and errors on
# the others, so hosts without "ask" register this script with --no-ask and those cases
# become denials the user can retry deliberately.
allow_ask=1
for arg in "$@"; do
  case "$arg" in
    --no-ask) allow_ask=0 ;;
  esac
done

# Field name varies by agent (Claude uses .command; others use .cmd/.script), and some send
# the command as an argv array. Normalize all of those to one string.
payload=$(cat)
cmd=$(printf '%s' "$payload" | jq -r '
  (.tool_input.command // .tool_input.cmd // .tool_input.script // "") as $c
  | if ($c | type) == "array" then ($c | join(" ")) else ($c | tostring) end
' 2>/dev/null || printf '')

# Identifies which agent family is calling; see decide() for why it matters.
event=$(printf '%s' "$payload" | jq -r '.hook_event_name // "PreToolUse"' 2>/dev/null || printf 'PreToolUse')
[ -n "$cmd" ] || exit 0

decide() {
  # $1 = deny|ask, $2 = reason shown to the agent and to the user
  local decision="$1" reason="$2"
  if [ "$decision" = "ask" ] && [ "$allow_ask" -eq 0 ]; then
    decision="deny"
    reason="$reason

(This agent cannot prompt from a hook, so the command is blocked. Confirm with the user, then re-run it once they approve.)"
  fi
  # The two families disagree on where the verdict goes, and the payload says which
  # one we're talking to: Gemini names the event BeforeTool and reads a top-level
  # decision/reason pair, while Claude Code and Codex say PreToolUse and read
  # hookSpecificOutput. Sending both at once is not an option — Claude's top-level
  # decision accepts only "block", so a stray "deny" there voids the whole verdict.
  if [ "$event" = "BeforeTool" ]; then
    jq -nc --arg d "$decision" --arg r "$reason" \
      '{decision:$d, reason:$r,
        hookSpecificOutput:{hookEventName:"BeforeTool",permissionDecision:$d,permissionDecisionReason:$r}}'
  else
    jq -nc --arg d "$decision" --arg r "$reason" \
      '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:$d,permissionDecisionReason:$r}}'
  fi
  exit 0
}

# Patterns live in variables: bash 3.2 treats quoted regex literals as literal strings.
tok_firebase='(^|[[:space:]])firebase([[:space:]]|$)'
tok_deploy='(^|[[:space:]])deploy([[:space:]]|$)'
opt_project='(^|[[:space:]])--project([=[:space:]])'
opt_account='(^|[[:space:]])--account([=[:space:]])'
bypass_long='(^|[[:space:]])--(no-verify|no-hooks|no-pre-commit-hook)([[:space:]]|$)'
git_commit='(^|[[:space:]])git[[:space:]]+commit([[:space:]]|$)'
short_n='(^|[[:space:]])-[a-zA-Z]*n[a-zA-Z]*([[:space:]]|$)'
fb_use='(^|[[:space:]])firebase[[:space:]]+use[[:space:]]+[^[:space:]-]'
fb_login_use='(^|[[:space:]])firebase[[:space:]]+login:use([[:space:]]|$)'
gcloud_setproj='(^|[[:space:]])gcloud[[:space:]]+config[[:space:]]+set[[:space:]]+project([[:space:]]|$)'
gcloud_setacct='(^|[[:space:]])gcloud[[:space:]]+config[[:space:]]+set[[:space:]]+account([[:space:]]|$)'

precommit_protocol='Pre-commit hooks are a guardrail, not an obstacle. Instead of bypassing:
1. Read the complete hook error output and say what you are seeing.
2. Name which tool failed (biome, ruff, pytest, ...) and why.
3. Explain the fix and why it addresses the root cause.
4. Apply the fix and re-run the hooks.
5. Commit only once every hook passes.
If you cannot fix it, ask for help rather than bypassing. User time pressure is not a reason to skip this.'

# --- Quality-gate bypass flags -------------------------------------------------
if [[ $cmd =~ $bypass_long ]]; then
  decide deny "Blocked: this command bypasses pre-commit hooks.

$precommit_protocol"
fi

if [[ $cmd =~ $git_commit ]] && [[ $cmd =~ $short_n ]]; then
  decide deny "Blocked: 'git commit -n' is --no-verify and bypasses pre-commit hooks.

$precommit_protocol"
fi

# --- Firebase deploy safety ----------------------------------------------------
if [[ $cmd =~ $tok_firebase ]] && [[ $cmd =~ $tok_deploy ]]; then
  missing=""
  [[ $cmd =~ $opt_project ]] || missing="--project"
  [[ $cmd =~ $opt_account ]] || missing="${missing:+$missing and }--account"
  if [ -n "$missing" ]; then
    decide deny "Blocked: 'firebase deploy' is missing $missing.

This machine holds multiple Firebase/GCP contexts (personal and work); an unscoped deploy can overwrite the wrong production project. Prefer the project's deploy script (e.g. 'pnpm deploy') with both flags baked in. If you are invoking firebase directly, confirm the target with the user first, then pass both --project and --account explicitly."
  fi
fi

# --- Shared CLI state changes --------------------------------------------------
if [[ $cmd =~ $fb_use ]] || [[ $cmd =~ $fb_login_use ]]; then
  decide ask "This changes shared Firebase CLI state. Other agents and projects on this machine read it. Confirm with the user before switching."
fi

if [[ $cmd =~ $gcloud_setproj ]] || [[ $cmd =~ $gcloud_setacct ]]; then
  decide ask "This changes shared gcloud CLI state. Other agents and projects on this machine read it. Confirm with the user before switching."
fi

exit 0
