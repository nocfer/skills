# nocfer-skills

A small set of [Claude Code](https://docs.claude.com/en/docs/claude-code) skills,
packaged as an installable plugin.

## Skills

- **distill-reviews** — Harvest the PR-review feedback you *received* on the
  current repo and turn recurring themes into durable auto-memory rules, so the
  agent stops earning the same review comment twice. Runs incrementally via a
  per-project watermark. Invoke with `/distill-reviews`.
- **consistency-review** — A pre-PR review for consistency with the codebase
  (prior art, sibling-pattern divergence, naming, shared-infra blast radius),
  not a bug hunt. Invoke with `/consistency-review`.

## Install

```
/plugin marketplace add nocfer/claude-skills
/plugin install nocfer-skills@nocfer
```

Then invoke a skill by name, e.g. `/distill-reviews`.

## Requirements

- `distill-reviews` needs the [`gh`](https://cli.github.com) CLI authenticated
  as you, and a project with a Claude Code memory directory.

## License

MIT — see [LICENSE](LICENSE).
