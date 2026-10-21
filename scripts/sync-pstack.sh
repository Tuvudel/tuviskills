#!/usr/bin/env bash
# Vendor cursor/plugins/pstack, unmodified, into vendor/pstack/.
# Usage: scripts/sync-pstack.sh [<commit-sha>|main]   (default: main)
#        scripts/sync-pstack.sh --check                 (offline: vendor/pstack matches the recorded tree)
# Records the commit, the upstream tree id of pstack/, and the plugin version in vendor/pstack.lock.
# Never edit vendor/pstack by hand: put overrides in rules/ or harness/ instead.
set -euo pipefail
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dest="$repo/vendor/pstack"
lock="$repo/vendor/pstack.lock"
upstream="https://github.com/cursor/plugins.git"

tree_of_vendor() {
  # Git tree id of the working copy of vendor/pstack, computed with a scratch index.
  local idx; idx="$(mktemp)"; rm -f "$idx"
  GIT_INDEX_FILE="$idx" git -C "$repo" add -f -A -- vendor/pstack
  GIT_INDEX_FILE="$idx" git -C "$repo" write-tree --prefix=vendor/pstack/
  rm -f "$idx"
}

if [ "${1:-}" = "--check" ]; then
  want="$(sed -n 's/^tree=//p' "$lock")"
  have="$(tree_of_vendor)"
  if [ "$want" != "$have" ]; then
    echo "vendor/pstack differs from upstream tree $want (got $have). Re-run scripts/sync-pstack.sh $(sed -n 's/^commit=//p' "$lock")." >&2
    exit 1
  fi
  echo "vendor/pstack matches upstream $(sed -n 's/^commit=//p' "$lock") (pstack $(sed -n 's/^version=//p' "$lock"))."
  exit 0
fi

ref="${1:-main}"
work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
git -C "$work" init -q
git -C "$work" remote add origin "$upstream"
git -C "$work" sparse-checkout set --no-cone /pstack/ >/dev/null
git -C "$work" fetch -q --depth 1 --filter=blob:none origin "$ref"
git -C "$work" checkout -q FETCH_HEAD
sha="$(git -C "$work" rev-parse HEAD)"
tree="$(git -C "$work" rev-parse HEAD:pstack)"
version="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' "$work/pstack/plugin.json")"
mkdir -p "$dest"
if command -v rsync >/dev/null; then
  rsync -a --delete --exclude .git "$work/pstack/" "$dest/"
else
  rm -rf "$dest" && cp -a "$work/pstack" "$dest"
fi
printf 'source=%s\npath=pstack\ncommit=%s\ntree=%s\nversion=%s\n' "$upstream" "$sha" "$tree" "$version" > "$lock"
# Keep the UPSTREAM.md pstack row in sync with the lock.
python3 - "$repo/UPSTREAM.md" "$sha" "$version" <<'PY'
import re, sys
path, sha, version = sys.argv[1:]
text = open(path, encoding='utf-8').read()
text = re.sub(r'(<!-- pstack-pin -->).*?(<!-- /pstack-pin -->)', r'\g<1>%s, pstack %s\g<2>' % (sha[:7], version), text)
open(path, 'w', encoding='utf-8').write(text)
PY
"$0" --check
echo "Vendored pstack $version at $sha. Review with: git -C \"$repo\" status vendor/"
