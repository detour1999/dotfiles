#!/usr/bin/env bash
# ABOUTME: Regression suite for bash-guard.sh — replays fixture payloads and checks decisions.
# ABOUTME: Covers all three host families and asserts the verdict lands in the right field.

set -uo pipefail
here=$(cd "$(dirname "$0")" && pwd)
guard="$here/bash-guard.sh"
fixtures="$here/bash-guard.fixtures.jsonl"

pass=0
fail=0

# $1 = mode label, $2 = jq path to expected decision, $3 = jq filter applied to the
# payload (use "." for none), $4... = extra guard args
run_mode() {
  local mode="$1" expect_key="$2" mutate="$3"
  shift 3
  printf '\n--- mode: %s ---\n' "$mode"
  local line expect label out got payload
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    expect=$(printf '%s' "$line" | jq -r "$expect_key")
    label=$(printf '%s' "$line" | jq -r '.label')
    payload=$(printf '%s' "$line" | jq -c "$mutate")
    out=$(printf '%s' "$payload" | bash "$guard" "$@")
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

run_mode "ask-capable (Claude)"  '.expect'                 '.'
run_mode "deny-only (Codex)"     '.expect_noask // .expect' '.'          --no-ask
run_mode "gemini (BeforeTool)"   '.expect'                 '.hook_event_name = "BeforeTool"'

# Shape assertions: the verdict has to land in the field each host actually reads.
printf '\n--- output shape ---\n'
shape_check() {
  local label="$1" payload="$2" jqpath="$3" want="$4" got
  got=$(printf '%s' "$payload" | bash "$guard" | jq -r "$jqpath")
  if [ "$got" = "$want" ]; then
    pass=$((pass + 1))
    printf 'PASS  %s\n' "$label"
  else
    fail=$((fail + 1))
    printf 'FAIL  expected=%s got=%s  %s\n' "$want" "$got" "$label"
  fi
}
blocked='{"tool_input":{"command":"git commit --no-verify"}}'
gblocked='{"hook_event_name":"BeforeTool","tool_input":{"command":"git commit --no-verify"}}'
# Claude rejects a top-level decision of "deny" (it only accepts "block") and then
# ignores the whole verdict, so it must be absent for the PreToolUse family.
shape_check "PreToolUse omits top-level decision" "$blocked"  '.decision // "absent"'              "absent"
shape_check "PreToolUse sets permissionDecision"  "$blocked"  '.hookSpecificOutput.permissionDecision' "deny"
shape_check "BeforeTool sets top-level decision"  "$gblocked" '.decision'                          "deny"
shape_check "BeforeTool sets top-level reason"    "$gblocked" '(.reason | length > 0)'             "true"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
