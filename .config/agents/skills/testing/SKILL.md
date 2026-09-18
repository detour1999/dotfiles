---
name: testing
description: Use when writing tests, adding coverage, validating a feature, or deciding what to test. Covers the TDD loop, test quality standards, the no-mocks rule, and how to scale test depth to the size of a change.
---

# Testing conventions

## The loop

1. Write a failing test that defines the behavior you want.
2. Run it and confirm it fails for the reason you expect.
3. Write the minimum code to make it pass.
4. Run it and confirm it passes.
5. Refactor while keeping it green.

Say which step you're on as you go. If an implementation already exists without tests, write
the tests before changing it.

## Standards

- Tests cover the behavior being implemented, not the implementation's shape.
- Real data, real APIs, real dependencies. Never build a mock mode — not for tests, not for
  convenience, not temporarily.
- Test output must be pristine to pass. Never ignore logs or system output; they carry the
  information that explains the failure.
- If a code path is *supposed* to log an error, capture that output and assert on it.
- Match the surrounding suite's structure and naming.

## Scaling depth to the change

A behavior change earns a test. A refactor earns the existing suite staying green. A new
surface earns coverage at whatever layers it actually spans.

Unit, integration, and end-to-end are all in scope for a project. If you're about to conclude
that a layer doesn't apply here, say so out loud and let me decide — don't skip it silently
and don't mark it "not applicable" on your own.
