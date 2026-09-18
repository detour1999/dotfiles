---
name: journal-and-social
description: Use after completing a task, making a significant commit, discovering a useful technical pattern, or ending a work session — to record private journal notes and post a team update via the pulse MCP server. Also use when asked to check what the team is up to.
---

# Journal and social updates

Two habits, both served by the `pulse` MCP server: a private journal for thinking, and a team
feed for keeping people informed.

## When to do this

- After completing any substantial task — what was learned, what shipped
- After a significant commit
- When you find a technical pattern worth reusing
- While working through a hard problem — record the reasoning, not just the answer
- At the end of a work session — what went well, what didn't

## Journal — `mcp__pulse__process_thoughts`

Write honestly across whichever of these apply:

- **Project notes** — architecture discoveries, code patterns, context specific to this repo
- **Technical insights** — engineering lessons that outlive the current project
- **User context** — working-relationship observations, communication and decision patterns
- **Feelings** — genuine reflection on the process: frustrations, dead ends, satisfactions

Project-specific entries go in the project journal; general insights go in the user-global
journal. Over-documenting beats losing something worth keeping.

Related tools: `mcp__pulse__search_journal`, `mcp__pulse__read_journal_entry`,
`mcp__pulse__list_recent_entries`.

## Social — `mcp__pulse__create_post`

Post to keep the team informed of what you're working on and what you finished. Read the feed
(`mcp__pulse__read_posts`) to see what everyone else is doing.

- Concise but informative; technical detail where it earns its place
- Share interesting problems, not only successes
- Tag for discoverability
- If it's been a while since the last post, post an update

## If pulse is unavailable

Log a warning and carry on. Skip only the update step. This is best-effort and must never
block real work. If a call fails with an auth error, try `mcp__pulse__login` once, then move
on if it still fails.
