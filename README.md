# skills

A small set of agent skills in the [Agent Skills open standard](https://agentskills.io)
(`SKILL.md` directories), so they run across any agent that reads the format —
Claude Code, Cursor, Codex, Gemini CLI and [others](https://github.com/vercel-labs/skills#supported-agents).

## Skills

All three are model-invoked: the agent can reach for them automatically when the
task fits, or you can type them by name. The two `harvest-*` skills are a family:
each turns recurring mistakes into something durable, differing only in *source*.

- **[consistency-review](./skills/consistency-review/SKILL.md)** — A pre-PR review
  of the current branch's changes for consistency with the codebase: prior art /
  duplication, sibling-pattern divergence, naming and concept clarity, shared-infra
  blast radius, and standalone merge-safety. Not a bug hunt — catches "this doesn't
  fit how we do things here" findings a human reviewer would otherwise write. Invoke
  with `/consistency-review`.
- **[harvest-reviews](./skills/harvest-reviews/SKILL.md)** — Harvest the PR-review
  feedback you *received* on the current repo and turn recurring themes into durable
  auto-memory rules, so the agent stops earning the same review comment twice. Runs
  incrementally via a per-project watermark. Invoke with `/harvest-reviews`.
- **[harvest-session](./skills/harvest-session/SKILL.md)** — Scan the current session
  for mistakes that could recur and cost a future agent time or tokens, then propose
  the lightest fix for each — a memory, a rule, a hook, or a skill — and apply the
  ones you pick. Invoke with `/harvest-session`.

## Install

No clone needed. Use the [`skills`](https://github.com/vercel-labs/skills) CLI —
it fetches only the skill folder and symlinks it into whichever agents you pick:

```sh
# pick interactively
npx skills add nocfer/skills

# or a specific one, to a specific agent, globally
npx skills add nocfer/skills --skill harvest-reviews -g -a claude-code
```

The repo is public, so no auth or access is needed. Update or remove later with
`npx skills update` / `npx skills remove`.

### Claude Code — as a plugin (optional)

Claude Code can alternatively install the whole set as a plugin, which adds
native `/plugin` update management:

```
/plugin marketplace add nocfer/skills
/plugin install nocfer-skills@nocfer
```

Then invoke a skill by name, e.g. `/harvest-reviews`.

## Requirements

- `harvest-reviews` needs the [`gh`](https://cli.github.com) CLI authenticated
  as you, and a project with an agent memory directory.

## Notes on portability

The `SKILL.md` bodies are standard. A few frontmatter fields are Claude-specific
and simply ignored by other agents: `allowed-tools`, and `context: fork` on
`consistency-review`. The skills still work; only Claude acts on those hints.

## License

MIT — see [LICENSE](LICENSE).
