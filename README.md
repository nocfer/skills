# skills

A small set of agent skills in the [Agent Skills open standard](https://agentskills.io)
(`SKILL.md` directories), so they run across any agent that reads the format —
Claude Code, Cursor (2.4+), Codex CLI, Cline, Gemini CLI, and others.

## Skills

- **distill-reviews** — Harvest the PR-review feedback you *received* on the
  current repo and turn recurring themes into durable auto-memory rules, so the
  agent stops earning the same review comment twice. Runs incrementally via a
  per-project watermark. Invoke with `/distill-reviews`.
- **consistency-review** — A pre-PR review for consistency with the codebase
  (prior art, sibling-pattern divergence, naming, shared-infra blast radius),
  not a bug hunt. Invoke with `/consistency-review`.

## Install

The `skills/*/SKILL.md` directories are the portable core. Install them into
whichever agent you use.

### Any agent — one script

```
git clone https://github.com/nocfer/skills
cd skills
./install.sh          # symlinks each skill into every agent dir found on this machine
./install.sh --all    # also create dirs for agents not yet installed
```

Re-run after `git pull` is not needed — the symlinks point at the checkout, so a
pull updates every agent at once.

### Per agent, by hand

Each agent reads skills from its own directory; symlink or copy `skills/<name>`
into it:

| Agent | Skills directory |
| --- | --- |
| Claude Code | `~/.claude/skills/` |
| Codex CLI | `~/.codex/skills/` |
| Gemini CLI | `~/.gemini/skills/` |
| Cursor (2.4+) | `.cursor/skills/` (per project) |

### Claude Code — as a plugin

Claude Code can also install the whole set as a plugin via its marketplace
wrapper (`.claude-plugin/`):

```
/plugin marketplace add nocfer/skills
/plugin install nocfer-skills@nocfer
```

Then invoke a skill by name, e.g. `/distill-reviews`.

## Requirements

- `distill-reviews` needs the [`gh`](https://cli.github.com) CLI authenticated
  as you, and a project with an agent memory directory.

## Notes on portability

The `SKILL.md` bodies are standard. A couple of frontmatter fields are
Claude-specific and simply ignored elsewhere: `allowed-tools`, and
`context: fork` / `disable-model-invocation` on `consistency-review`. The skills
still work; only Claude acts on those hints.

## License

MIT — see [LICENSE](LICENSE).
