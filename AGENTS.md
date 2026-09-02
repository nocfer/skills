# AGENTS.md

This repository is a package of **agent skills** in the [Agent Skills open
standard](https://agentskills.io): one directory per skill under `skills/`, each
with a `SKILL.md`. The format is read natively by Claude Code, Cursor (2.4+),
Codex CLI, Cline, Gemini CLI and other agents.

## Layout

- `skills/<name>/SKILL.md` — the portable skills. This is the source of truth,
  and all the `skills` CLI (`npx skills add nocfer/skills`) needs.
- `.claude-plugin/` — an optional Claude Code plugin/marketplace wrapper, so
  Claude users can alternatively install the set with `/plugin`. It does not make
  the repo Claude-only.

## Working in this repo

- Keep each skill a self-contained `skills/<name>/` directory. When adding one,
  also add its path to the `skills` array in `.claude-plugin/plugin.json`.
- Keep `SKILL.md` frontmatter to the standard's two required fields (`name`,
  `description`) plus body. Claude-specific hints (`allowed-tools`,
  `context: fork`, `disable-model-invocation`) are fine — other agents ignore
  them — but don't rely on them for correctness.
- Bump `version` in `.claude-plugin/plugin.json` on a release.

## Install

See `README.md`. Short version: `npx skills add nocfer/skills`, or for Claude
Code `/plugin marketplace add nocfer/skills` then
`/plugin install nocfer-skills@nocfer`.
