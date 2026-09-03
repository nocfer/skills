---
name: harvest-session
description: Scan this session's history for mistakes that could recur and cost a future agent time or tokens, then propose the right fix for each — a memory, a rule, a hook, or a skill. Use when the user wants lessons learned from the conversation, a session retrospective, or to capture what went wrong so it doesn't happen again.
allowed-tools: Read, Write, Edit, Grep, Bash(date:*)
---

# Harvest lessons from this session

A mistake the agent made this session is only worth capturing if it can **recur**
— hit a *future* session the same way and burn the same time or tokens. Each such
mistake is a **lesson**. This skill reads back over the current conversation,
keeps the lessons that will recur, and proposes the lightest remedy that actually
prevents each one. It proposes; it writes nothing until you pick.

For lessons that come specifically from **PR review comments you received**, use
`harvest-reviews` instead — it harvests that source incrementally and always lands
in memory. This skill covers the *session* and chooses across all remedy types.

`$MEM` below is your project's auto-memory directory — the path named in your
system prompt's memory section.

## Step 1 — Collect the session's mistakes

Read back over this conversation and list every point where the agent went wrong.
The reliable signals:

- The user corrected the agent — "no", "actually", "don't", a restated fact.
- A command failed and was re-run with a fix — especially the *same class* of
  failure more than once.
- Wasted legwork — read the wrong file or directory, searched the wrong place,
  reached for the wrong tool.
- A permission denial that forced rework.
- An assumption the agent acted on that later turned out false.
- A clarifying question whose answer was already knowable from the repo.

**Done when** every wrong turn in the session is on the list, each in one plain
sentence.

## Step 2 — Apply the recurrence gate

Drop every item that cannot recur: a one-off fumble specific to this one task, a
typo, a mistake that only existed because of this session's particular state. Keep
only the **structural** ones — about the repo, the tooling, the workflow, or the
user's standing preferences — because those are the ones the next session repeats.

**Done when** every surviving item is one that would plausibly hit a fresh session
on this project.

## Step 3 — Drop what's already captured

Read `$MEM/MEMORY.md`, then check the repo's own instruction files (`CLAUDE.md`,
`.claude/rules/`, any agents doc). For each surviving lesson:

- Already stated somewhere — drop it, unless this session adds real nuance, in
  which case mark it "sharpen <where>" rather than "new".
- Not stated anywhere — carry it forward as "new".

**Done when** every lesson is tagged new, sharpen, or dropped, with no lesson that
merely restates something the project already says.

## Step 4 — Choose a remedy for each lesson

Match each lesson to the **lightest** remedy that prevents the recurrence. A hook
*enforces*, memory and rules *remind*, a skill *encodes a procedure* — so reach
for a hook only when a reminder would plausibly be forgotten.

| When the fix is… | Remedy | Where |
| --- | --- | --- |
| a mechanical action that must happen every time, where forgetting is likely | **hook** | `settings.json`, authored via the `update-config` skill |
| a repeatable multi-step procedure | **skill** | a new `.claude/skills/<name>/SKILL.md` |
| a convention every session on this repo must follow unconditionally | **rule** | `.claude/rules/<name>.md`, referenced from `CLAUDE.md` |
| a fact or working preference to recall when it's relevant | **memory** | `$MEM/<slug>.md` + a `MEMORY.md` pointer |

**Done when** each lesson names one remedy and its target location.

## Step 5 — Report and wait for the pick

Show the user a compact summary — one row per lesson — and stop. Lead with the
mistake in plain language, not file names.

```
Lesson (what went wrong)        | Why it recurs / what it cost | Proposed remedy
```

Then ask which to apply. Write nothing yet.

**Done when** the summary is shown and the user has chosen which lessons to act on.

## Step 6 — Apply the chosen remedies

For each lesson the user approved, and only those:

- **memory** — write `$MEM/<slug>.md` in the format below, then add one line to
  `$MEM/MEMORY.md`: `- [Title](<slug>.md) — <hook>`. To sharpen, edit the existing
  file instead of adding a second.
- **rule** — write `.claude/rules/<name>.md` and add a reference to it from
  `CLAUDE.md` if one isn't there.
- **hook** — invoke the `update-config` skill to author it; the harness runs
  hooks, so they can't live in memory or a rule.
- **skill** — invoke `writing-great-skills` and build it there rather than here.

Memory file format (pick `type` by what the lesson is — `feedback` for how-to-work
guidance, `project`/`reference`/`user` otherwise):

```markdown
---
name: <short-kebab-slug>
description: <one line; recall matches on this, so name the mistake>
metadata:
  type: feedback
---

<the lesson, stated positively — what to do next time>

**Why:** <the reason, so it isn't re-litigated>
**How to apply:** <the concrete action on the next session>
```

Link related lessons with `[[other-slug]]`. Keep one lesson per file.

**Done when** every approved lesson is written or routed to its skill, each new
memory has its `MEMORY.md` pointer, and the user is told in plain language what
landed where.
