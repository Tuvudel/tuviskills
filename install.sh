#!/bin/sh
# Install the skills on macOS/Linux by symlinking each skill folder.
# Usage: ./install.sh [--claude] [--dry-run] [--uninstall]
#   ~/.agents/skills  read by Codex, Cursor and Grok Build (always)
#   ~/.claude/skills  read by Claude Code (with --claude)
# Links personal skills (skills/) and vendored pstack skills (vendor/pstack/skills/).
# Idempotent. Never overwrites a folder it did not create; skips it and says so.
# --uninstall removes only the links that point into this repo.
# Optional extras: scripts/install-autoupdate.sh (session-start hook and always-on rule).
set -eu
repo=$(cd "$(dirname "$0")" && pwd)
claude=0; dry=0; un=0
for a in "$@"; do
  case $a in --claude) claude=1 ;; --dry-run) dry=1 ;; --uninstall) un=1 ;; *) echo "usage: $0 [--claude] [--dry-run] [--uninstall]" >&2; exit 2 ;; esac
done
targets="$HOME/.agents/skills"
[ "$claude" = 1 ] && targets="$targets $HOME/.claude/skills"
if [ "$un" = 1 ]; then
  for t in "$HOME/.agents/skills" "$HOME/.claude/skills"; do
    n=0
    for dst in "$t"/*; do
      [ -L "$dst" ] || continue
      case $(readlink "$dst") in "$repo"/*) ;; *) continue ;; esac
      [ "$dry" = 1 ] && echo "remove $dst" || rm "$dst"
      n=$((n + 1))
    done
    echo "$t: $n links removed"
  done
  exit 0
fi
for t in $targets; do
  [ "$dry" = 1 ] || mkdir -p "$t"
  n=0; skipped=0
  for src in "$repo"/skills/*/ "$repo"/vendor/pstack/skills/*/; do
    [ -f "$src/SKILL.md" ] || continue
    src=${src%/}; name=$(basename "$src"); dst="$t/$name"
    if [ -L "$dst" ]; then
      [ "$(readlink "$dst")" = "$src" ] && { n=$((n + 1)); continue; }
      case $(readlink "$dst") in "$repo"/*) ;; *) echo "skip $dst (links elsewhere)"; skipped=$((skipped + 1)); continue ;; esac
    elif [ -e "$dst" ]; then echo "skip $dst (exists, not ours)"; skipped=$((skipped + 1)); continue
    fi
    [ "$dry" = 1 ] && echo "link $dst -> $src" || ln -sfn "$src" "$dst"
    n=$((n + 1))
  done
  echo "$t: $n skills linked, $skipped skipped"
done
