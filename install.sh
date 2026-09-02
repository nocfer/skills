#!/usr/bin/env bash
# Symlink every skill in ./skills into each agent's skills directory.
# Symlinks (not copies) so `git pull` in this checkout updates all agents at once.
#
#   ./install.sh          only agents already present on this machine
#   ./install.sh --all    also create dirs for agents not yet installed
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/skills" && pwd)"
ALL="${1:-}"

# Global (user-level) agent skills dirs. Cursor is per-project, handled below.
TARGETS=(
  "$HOME/.claude/skills"
  "$HOME/.codex/skills"
  "$HOME/.gemini/skills"
  "$HOME/.openclaw/skills"
)

link_into() {
  local dest="$1"
  mkdir -p "$dest"
  local skill name
  for skill in "$SRC"/*/; do
    name="$(basename "$skill")"
    ln -sfn "$skill" "$dest/$name"
    echo "  linked $dest/$name"
  done
}

installed_any=0
for dest in "${TARGETS[@]}"; do
  parent="$(dirname "$dest")"          # e.g. ~/.claude
  if [ -d "$parent" ] || [ "$ALL" = "--all" ]; then
    echo "$(basename "$parent"):"
    link_into "$dest"
    installed_any=1
  fi
done

if [ "$installed_any" -eq 0 ]; then
  echo "No agent directories found. Re-run with --all to create them anyway."
fi

echo
echo "Cursor is per-project. Inside a project run:"
echo "  mkdir -p .cursor/skills && for s in \"$SRC\"/*/; do ln -sfn \"\$s\" \".cursor/skills/\$(basename \"\$s\")\"; done"
