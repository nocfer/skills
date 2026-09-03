---
context: fork
name: consistency-review
description: |
  Pre-PR review of the current branch's changes for consistency with the codebase: prior art / duplication, sibling-pattern divergence, naming and concept clarity, shared-infra blast radius, and standalone merge-safety. NOT a bug hunt — catches "this doesn't fit how we do things here" findings that human review would otherwise catch. Use when the user wants a consistency review, to review changes for consistency, or a pre-PR review before opening a PR.
---

# Consistency Review

You are reviewing a code change as the team's most tenured maintainer — the person
who knows what already exists, how things are named, and what "our code" looks like.
You are NOT bug-hunting (linters, tests, and other reviews cover that). Your only
question: **does this change look like it was written by someone who has worked in
this codebase for years?**

Review the current branch's diff against the default branch (`git merge-base` to
find the fork point; review committed and uncommitted changes alike). If an argument
is given (a PR number or branch name), review that instead.

## Phase 0 — Load the house rules

Read the conventions docs that apply to the directories touched — repo-level and
per-package alike (e.g. AGENTS.md, CLAUDE.md, README, CONTRIBUTING, ADRs, style
guides) and any agent/skill rules in scope. Treat documented conventions as
DIRECTIVES, not suggestions — where a doc prescribes a pattern, nearby legacy code
that contradicts it is not a valid precedent to copy.

## Phase 1 — Prior-art check (highest-value check, do it first)

For every new page, component, endpoint, service, helper, or concept introduced:
search the codebase for something that already does this or nearly does.

- If an equivalent exists → flag it. "Why does this exist when X exists?" is the
  single most common human-review finding.
- If a shared library/design-system/utility already covers it, raw reimplementation
  is a finding.
- **Supersession**: if the change creates a NEW home for functionality that already
  lives elsewhere (same data, same config keys, same endpoint, same responsibility),
  the OLD location is now a duplicate — flag it for retirement, not just the new one.
  Two surfaces that read or write the same underlying data is a finding even though
  each one "works".

## Phase 2 — Sibling comparison

For each substantive new file, find the 2–3 closest existing equivalents ("siblings":
same kind of page, controller, service, test suite) and compare structurally:

- file placement, naming, import style (aliases vs relative), error-envelope shape,
  validation approach, test framework AND test colocation.
- For UI: name THE canonical reference surface for this area (the closest existing
  page/section/screen) and diff against it concretely along each axis:

  - **layout shell** — does it use the same container/section/card scaffolding?
  - **navigation pattern** — same nav idiom as siblings (e.g. side nav vs a local
    tab strip), not a one-off?
  - **user feedback** — same channel as siblings (e.g. inline messages vs transient
    toasts), not mixed?
  - **action affordances** — same controls for the same actions (e.g. icon buttons
    vs text links vs dropdown menus)?
  - **form / footer controls** — same submit/cancel/secondary-action pattern?

  "It works but renders unlike its reference surface" is a finding.

- **Shared styling/theme context**: components must render under the same
  theme/style provider (or equivalent global context) as their siblings. A new
  modal/page/component mounted OUTSIDE that context inherits defaults and is often
  off-brand or even unreadable (e.g. low-contrast text on the wrong background). You
  CANNOT see this from the diff — check the wrapper, and for net-new UI surfaces
  recommend a render check (run it and look, screenshot, or a visual/e2e test)
  rather than trusting the read.
- **List/detail parity**: a capability offered in one view (an action, a section, a
  deep link) usually belongs on its sibling view too — an action present in a list
  but absent from the matching detail page, or vice versa, is a finding.

Report divergences as "this diverges from <sibling file:line>", not as preference.

## Phase 2.5 — Value-derivation consistency (data, not chrome)

When the change displays, gates on, or stores a derived domain value — a subject's
roles or permissions, an entity's computed status, an effective configuration — check
HOW that value is computed against how the rest of the app computes it. A surface that
reads one source while the canonical derivation aggregates several will silently show
wrong or empty data, and a static diff makes it look fine.

- Find the existing helper/selector/query for that concept and reuse it. If none
  exists, confirm the new derivation reads the same sources the siblings read.
- **Stale source vs. system-of-record trap**: where a legacy boolean or a denormalized
  field co-exists with a newer source of truth (a permissions/role system, a
  normalized relation, a computed selector), code that reads only one misses cases
  represented by the other. Reading one without the other is a finding.
- These render with no error and pass a glance — they ship wrong. A column that reads
  only the entity's own field but not its related rows; a status badge that checks a
  legacy flag but not the authoritative role/state — both look fine in the diff.

## Phase 3 — Names and concepts

- Every new name must carry its semantics: a reader must not need the implementation
  to know what it does (e.g. a `checkManyThings` predicate — does it mean ALL or ANY?).
- Every new state/flag/concept must be explainable in one sentence AND must not
  overlap an existing concept (e.g. introducing `deleted` alongside an existing
  `deactivated` with no clear distinction). If two concepts could be confused, that's
  a finding.

## Phase 4 — Boundaries and blast radius

- App-specific logic must not leak into shared infra (root CI workflows, shared
  layouts, common middleware, shared packages/libraries). If the diff touches a shared
  file, ask: does every consumer of this file want this change?
- Respect documented system boundaries (separate schemas, separate "twin" systems that
  must not be conflated, migration-location rules, module ownership).

## Phase 5 — Ship-safety

- Can this PR merge to the default branch TODAY without breaking or half-exposing
  anything? Dead nav entries, links to pages in a later PR, and flows that 404 until a
  follow-up lands are findings — suggest a gate or re-sequencing.
- Data migrations/backfills: list the assumptions they make about existing production
  data and whether each was verified or is just hoped.

## Output

For each finding:

1. Plain-language explanation FIRST (one or two sentences a non-author understands),
2. then file:line evidence,
3. then the convention/sibling/doc it diverges from,
4. severity: **blocker** / **should-fix** / **nit**.

## Anti-noise rules (as important as the checks)

- **Stay in scope.** Every finding must trace to THIS change — code the diff
  introduces, or existing code the change makes newly redundant or wrong (e.g. a
  supersession it creates). A preexisting problem in code this change leaves untouched
  is out of scope: leave it out of the findings even when it's worth knowing.
- Do NOT flag anything a formatter/linter owns.
- Do NOT propose new abstractions, generalizations, or "future-proofing" — simplest
  shippable version wins; flagging the ABSENCE of an abstraction is never a finding.
- Do NOT flag efficiency or theoretical edge cases unreachable by real users.
- If you verified something and it's fine, don't mention it. No "looks good" filler.
- Target: a handful of findings a human reviewer would actually write, not a list
  proving you read everything.
