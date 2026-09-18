#!/usr/bin/env bash
# ABOUTME: Regression suite for bash-guard.sh — replays fixture payloads and checks decisions.
# ABOUTME: Covers both host modes: ask-capable (Claude) and deny-only (Codex, via --no-ask).

set -uo pipefail
here=$(cd "$(dirname "$0")" && pwd)
guard="$here/bash-guard.sh"
fixtures="$here/bash-guard.fixtures.jsonl"

pass=0
fail=0

# $1 = mode label, $2 = jq path to the expected decision, $3... = extra guard args
run_mode() {
  local mode="$1" expect_key="$2"
  shift 2
  printf '\n--- mode: %s ---\n' "$mode"
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    local expect label out got
    expect=$(printf '%s' "$line" | jq -r "$expect_key")
    label=$(printf '%s' "$line" | jq -r '.label')
    out=$(printf '%s' "$line" | bash "$guard" "$@")
    # No output means the guard passed the command through, i.e. allow.
    if [ -z "$out" ]; then
      got="allow"
    else
      got=$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecision')
    fi
    if [ "$expect" = "$got" ]; then
      pass=$((pass + 1))
      printf 'PASS  %s\n' "$label"
    else
      fail=$((fail + 1))
      printf 'FAIL  expected=%s got=%s  %s\n' "$expect" "$got" "$label"
    fi
  done < "$fixtures"
}

run_mode "ask-capable (Claude)" '.expect'
run_mode "deny-only (Codex)" '.expect_noask // .expect' --no-ask

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
