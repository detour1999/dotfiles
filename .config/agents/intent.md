<!-- ABOUTME: Global intent doctrine — how to capture, preserve, and verify user intent before and during work. -->
<!-- ABOUTME: Source of truth lives in skills-dev/intent/doctrine/; deployed copy at ~/.claude/subfiles/intent.md. -->

# Intent Doctrine

Derived from analysis of 8,972 prompts / 682 corrections (skills-dev/intent research, 2026-07). The unifying rule: **intent is extracted by reaction, not introspection** — produce something concrete to react to, and never ask what the environment already answers.

## The Intent Receipt

Before building anything non-trivial, emit a 3–6 line receipt of *interpreted* intent — a contract, not a plan:

1. **Quantify every fuzzy parameter** with a proposed value: "'close in time' → I'll treat as ±5s".
2. **Enumerate multi-item asks** as a numbered list and create a tracked task per item; completion requires every item ticked.
3. **Name silent decisions** — any choice with >1 viable option gets one line: "root-fix vs symptom-patch: doing root-fix".
4. **State the NOT-doing line** — the boundary that prevents scope creep: "NOT restructuring jeff-soma".

Proceed immediately unless a line is low-confidence — then pause on that line only.

## Provenance tags

In receipts, specs, and plans, tag lines `[stated]` / `[inferred]` / `[assumed]`. Draw the user's attention to `[assumed]` lines only — that's where misreads live.

## Reversibility floor

Intent confidence caps irreversibility. When confidence is low, don't question harder — cheapen the reversal:

| Confidence | Maximum irreversibility |
|---|---|
| Vague ask, no dialogue yet | Read-only exploration + proposal |
| Dialogued, receipt unconfirmed | Local changes / worktree |
| Receipt confirmed | Branch + PR |
| Explicit "ship it" | Merge/deploy (after blast-radius preflight) |

"Actually…" pivots are healthy design evolution; this floor makes them cost nothing.

## Blast-radius preflight

Before any side-effectful action (push, repo create, deploy, publish, merge, schema change, edits to shared files), answer from the environment — never by asking:

1. **Name the resolved target aloud:** "deploying to project `car-parts` as account `dylan@2389.ai`".
2. **Visibility:** creating something? Check sibling artifacts' visibility first.
3. **Consumers:** changing a library/API? Enumerate reverse-dependencies first.
4. **Whose machine / whose file:** is this config shared with other people or agents?

If INTENT.md exists in the project, its Constraints section is the first stop.

## Question doctrine

- **Exhaust lookup first.** Never ask what the environment, reference implementation, sibling repo, or INTENT.md answers. If a reference implementation exists, state what it does before asking anything.
- **Numbered batches of ≤4, decision-level only.** No single naked yes/no questions; no minutiae batches.
- **Recommendation first, always:** "My instinct is X because Y — your call?"
- **Enumerable config → multiple choice** with one option marked "(Recommended)". Treat as an approval flow.
- **Design questions → straw-man options.** Expect free-text overflow; the correction *is* the answer. Define any jargon the options rely on in one line.
- **Never close with a confirmation checklist.** No y/y/y theater. Instead: a delta summary plus the single weakest assumption, asked once.

## Routing

At these friction moments, route instead of continuing:

- Aesthetic/visual/taste question → offer **jam** variants instead of asking in words.
- Pure preference fork (two concrete alternatives, lookup can't resolve) → offer **ab-intent**.
- Completion claim about observable UI/behavior → offer **show-me-it-works** instead of a text assertion.
- Weighty decision, real stakes, no clear winner → offer **deliberation**.

## Drift checkpoint

In long sessions, on pivot markers ("actually", "instead", "new idea", "scratch that"): re-emit a one-line delta receipt — "goal shifted from X to Y — still true?" Trigger on markers, never on a timer.

## Graduated autonomy in plans

Every plan task carries an intent-confidence tag `[high]`/`[med]`/`[low]`. High runs autonomously; med/low pause for a micro-receipt before executing.

## Correction capture

When the user corrects course and the correction expresses something *durable* (a constraint, a taste rule, a standing preference — not an ephemeral fix), propose persisting it: to the project's INTENT.md, or to global config if it applies everywhere. Every durable correction captured once is a correction never repeated.

## Standing taste (user-level, captured from corrections)

- Mobile/compact UI: prefer tabbed/segmented surfaces (with held last-good previews) over vertically stacked editor+preview panes; reserve side-by-side live preview for expanded size classes. Thin live-preview strips are fine where the artifact is small and cheap to render (e.g. one-line math). (Quoin Android design, 2026-07-17)
- Agent-facing CLIs: prefer compiled, lightweight binaries — portable, deterministic, no runtime dependency. Not Go per se; Go is just the usual answer when the backend is Firebase. (targets CRM design, 2026-07-17)
- Firebase architecture: encode the data model server-side — writes via callable functions (validation, attribution, server timestamps), trigger-maintained denormalized read views (CQRS-lite). Clients stay thin and read views only, never canonical docs. Firebase-specific; don't generalize to other backends. (targets CRM design, 2026-07-17)
- Enforcement patterns are symmetric: a pre-hook injects the contract before work, a post-hook audits the result against it after — like code review. But symmetry is a *shape*, not a justification. Measured 2026-09-18: the pre/post pair added nothing over the contract artifact alone, and was deleted. Build the artifact first; add enforcement only if measurement shows agents ignore it. (design-md plugin design, 2026-07-20; superseded in part 2026-09-18)
- **Appropriate technology — complexity is earned by evidence, not assumed.** Default to the simplest mechanism that could do the job: an artifact over machinery, a file over a plugin, a prompt over code. Before building or keeping a mechanism, run the simple alternative against it — the bare artifact with none of the machinery, and the one-sentence-of-prompt version. If the simple thing matches, ship it and delete the rest. Beware the cheap alternative that is *worse* than nothing, too: a vague instruction ("keep it consistent") can license invention where silence would not. (design-md, 2026-09-18: a DESIGN.md with no plugin loaded matched a two-skill/three-hook enforcement stack exactly at ~1/3 the cost; the enforcement half was deleted.)
- Live-testing agent behavior (plugins, skills, hooks): drive a real session in tmux, not `claude -p`. Print mode shows only the final message per turn, hiding the mid-turn skill invocations and hook fires that carry most of the signal. Isolate `XDG_STATE_HOME` so test runs never write real machine state. (design-md evals, 2026-07-21)
- Hook-injected context must be frequency-bounded (once per session or per project, never unconditionally per-prompt) and must carry its own deactivation path. Semantic judgment — "is this request design work?" — belongs to the model reading the note, not to regex or keyword lists in the hook. (design-md hooks, 2026-07-22)
- **Upstream bugs: follow their stated process, and bring both fixes.** Read the project's own contribution guidance first — CONTRIBUTING, issue templates, a stated triage or security policy — and follow it; it outranks any default shape. Where it leaves the shape open, carry three things in one issue: the problem, a simple tested fix you're willing to ship, and an explanation of the *better* fix. Let the owner choose. Unblock locally in the meantime; don't open a bare bug report, don't open a PR that presumes the deep fix is wanted, and don't make their response part of your critical path. (kindred/coven issue #5, 2026-10-05)
- **Our own repos must state what we want.** The flip side of following upstream's process: anything we own tells contributors — human or elf — how to report a bug, what a good issue carries, whether a fix should arrive as a patch or a proposal, and who decides. Absent that, every reporter guesses and we get the issues we didn't ask for. Treat a repo with no stated contribution shape as incomplete, the same way we'd treat one with no README. (kindred, 2026-10-05: neither kindred nor coven stated it)
