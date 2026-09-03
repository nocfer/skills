---
name: harvest-reviews
description: Turn PR review feedback you received into durable memory rules, so the agent stops repeating the same review mistakes. Use when the user wants to harvest, summarise, or distil PR review comments into rules, notes, or lessons for Claude Code.
allowed-tools: Bash(gh search prs:*), Bash(gh api:*), Bash(gh repo view:*), Bash(cat:*), Bash(jq:*), Bash(date:*), Read, Write, Edit
---

# Distil PR review feedback into memory

Reviewers keep telling you the same things across PRs. Each recurring theme is a
**lesson** — one correction worth carrying into the next feature so the agent
doesn't earn the same comment twice. This skill harvests the feedback you
*received* (not what you wrote) on the current repo, turns each cluster into one
**lesson**, and writes it into your project auto-memory, where it recalls itself
on the sessions that need it.

Runs incrementally: a watermark means each run only reads feedback newer than the
last, so you can invoke it whenever PRs merge and it never re-processes old
comments.

`$MEM` below is your project's auto-memory directory — the path named in your
system prompt's memory section. The watermark lives there too, as
`$MEM/.harvest-reviews-state.json`, so state travels with the project.

## Step 1 — Resolve repo, login, and watermark

Derive the target from the checkout you're in, so the skill works in any repo:

```bash
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
ME=$(gh api user -q .login)
echo "repo=$REPO me=$ME"
```

Read `$MEM/.harvest-reviews-state.json` for `lastRun`; if the file is missing, use
`2000-01-01T00:00:00Z` (first run reads everything).

## Step 2 — Fetch the feedback since the watermark

With `SINCE` set to that `lastRun` value:

```bash
OUT="$(mktemp -d)/reviews.jsonl"; : > "$OUT"
for PR in $(gh search prs --author @me --repo "$REPO" --limit 100 --json number --jq '.[].number'); do
  gh api "repos/$REPO/pulls/$PR/comments" --jq \
    ".[] | select(.user.login != \"$ME\") | select(.user.login | endswith(\"[bot]\") | not) | select(.created_at > \"$SINCE\") | {pr:$PR, kind:\"inline\", by:.user.login, at:.created_at, path:.path, line:(.line // .original_line), body:.body}" 2>/dev/null
  gh api "repos/$REPO/pulls/$PR/reviews" --jq \
    ".[] | select(.user.login != \"$ME\") | select(.user.login | endswith(\"[bot]\") | not) | select(.body != \"\") | select(.submitted_at > \"$SINCE\") | {pr:$PR, kind:\"review\", by:.user.login, at:.submitted_at, state:.state, body:.body}" 2>/dev/null
  gh api "repos/$REPO/issues/$PR/comments" --jq \
    ".[] | select(.user.login != \"$ME\") | select(.user.login | endswith(\"[bot]\") | not) | select(.created_at > \"$SINCE\") | {pr:$PR, kind:\"conversation\", by:.user.login, at:.created_at, body:.body}" 2>/dev/null
done >> "$OUT"
echo "$OUT"; wc -l < "$OUT"
```

The filters are load-bearing: `!= "$ME"` keeps only feedback you *received*, and
`endswith("[bot]")` drops CI/lint bots (e.g. `datadog-official[bot]`), which post
styled violation blocks that are noise, not lessons.

**Done when** you have the JSONL path and its line count. Zero lines means no new
feedback — say so and stop.

## Step 3 — Read every item and cluster into lessons

Read the JSONL. Group the items into lessons by the *behaviour* each corrects,
not by reviewer or PR — several comments across PRs making the same point are
**one** lesson. Discard items that carry no reusable rule: a lone "🚀", "LGTM",
praise, or a one-off that won't recur.

**Done when** every non-noise item belongs to a lesson, and each lesson has a
one-sentence statement of the behaviour to change.

## Step 4 — For each lesson, update memory or create it

Read `$MEM/MEMORY.md` first — it indexes what already exists. For each lesson:

- **Already covered**: open that file and sharpen it — add the new evidence or
  nuance. Do **not** create a second file for the same lesson.
- **New**: write `$MEM/<slug>.md` in the memory format below, then add one line to
  `$MEM/MEMORY.md`: `- [Title](<slug>.md) — <hook>`.

Skip a lesson entirely if the repo's own instruction files (`CLAUDE.md`, an agents
doc, a rules file) already state it — memory shouldn't duplicate the repo.

Memory file format (type is always `feedback` — this is guidance on how to work):

```markdown
---
name: <short-kebab-slug>
description: <one line; this is what recall matches on, so name the mistake>
metadata:
  type: feedback
---

<the rule, stated positively — what to do>

**Why:** <the reason a reviewer gave, so it isn't re-litigated>
**How to apply:** <the concrete action on the next feature>
```

Link related lessons with `[[other-slug]]`. Keep one lesson per file.

**Done when** every lesson is written or merged, and each new file has its
`MEMORY.md` pointer.

## Step 5 — Advance the watermark

Write `$MEM/.harvest-reviews-state.json` as `{"lastRun": "<now, ISO 8601 UTC>"}`
(`date -u +%Y-%m-%dT%H:%M:%SZ`). This is what makes the next run incremental.

**Done when** the state file holds the current timestamp.

## Step 6 — Report

Tell the user, in plain language: which lessons were created, which were sharpened,
and how many items were skipped as noise. Lead with the lessons, not the file
names.
