---
name: firebase
description: Use when working on a Firebase project — Cloud Functions, Firestore, security rules, hosting, or deploys. Covers the server-side data model, function layout and naming, REST conventions, and deploy safety.
---

# Firebase conventions

## Architecture

Encode the data model server-side. Writes go through callable functions that own validation,
attribution, and server timestamps. Triggers maintain denormalized read views (CQRS-lite).
Clients stay thin and read from those views, never from canonical docs.

This is Firebase-specific — it does not generalize to other backends.

## Cloud Functions

Python, v2 API, one file per function, named for what it does (`AddUser.py`,
`EditMessage.py`). Organize by how the function is invoked:

- `hooks/` — HTTP functions (`@https_fn.on_request`) for API endpoints
- `triggers/` — event-driven (`@firestore_fn.on_document_*`, `@auth_fn.on_*`)
- `callables/` — callable functions (`@https_fn.on_call`) for direct SDK calls
- `scheduled/` — cron (`@scheduler_fn.on_schedule`)
- `lib/` — shared utilities and business logic
- `tests/` — mirrors the function directory structure

Every function gets tests.

## Hosting

- Every endpoint maps explicitly to an https function.
- REST URIs: `/api/v1/user`, `/api/v1/user/{user_id}`. Never put the HTTP verb in the URI.
- User-facing interfaces: Next.js on Firebase, TypeScript and Tailwind. See the `css` skill.

## Deploys

Deploy through the project's script (e.g. `pnpm deploy`) with `--project` and `--account`
baked in. Never invoke `firebase deploy` without both flags, and never switch Firebase or
gcloud context without asking — this machine holds several personal and work contexts, and a
misdirected deploy can overwrite production. A `PreToolUse` hook enforces both.

Before deploying, state the resolved target out loud: which project, which account.
