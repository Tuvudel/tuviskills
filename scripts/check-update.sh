#!/bin/sh
# Session-start update check for this skills repo. Output is for the agent: nothing when up to date,
# at most one line otherwise. Never blocks (5 s network cap), never resets, stashes, deletes or forces.
# Runs only when enabled by scripts/install-autoupdate.sh (marker .git/agent-skills/autoupdate).
# Env (tests): AGENT_SKILLS_CHECK_INTERVAL_MIN (default 240), AGENT_SKILLS_POST_SYNC (command run after a pull).
repo=$(cd "$(dirname "$0")/.." && pwd) || exit 0
state="$repo/.git/agent-skills"
[ -f "$state/autoupdate" ] || exit 0
interval=${AGENT_SKILLS_CHECK_INTERVAL_MIN:-240}
[ -n "$(find "$state/last-check" -mmin "-$interval" 2>/dev/null)" ] && exit 0
: > "$state/last-check" 2>/dev/null
export GIT_TERMINAL_PROMPT=0 GCM_INTERACTIVE=never
g() { git -C "$repo" "$@"; }

# Run git in the background and give up after 5 s.
bounded() {
  out="$state/net.out"
  git -C "$repo" "$@" > "$out" 2>/dev/null &
  pid=$!; i=0
  while kill -0 "$pid" 2>/dev/null; do
    [ "$i" -ge 50 ] && { kill "$pid" 2>/dev/null; return 1; }
    sleep 0.1; i=$((i + 1))
  done
  wait "$pid"
}

if [ -d /home/box/agent-data/workflows ]; then post="$repo/scripts/sync-box --apply"; sync="git -C $repo pull --ff-only && $post"
else post=; sync="git -C $repo pull --ff-only"; fi
post=${AGENT_SKILLS_POST_SYNC-$post}

bounded ls-remote origin refs/heads/main || exit 0
remote=$(cut -f1 "$state/net.out"); [ -n "$remote" ] || exit 0
local_=$(g rev-parse HEAD 2>/dev/null) || exit 0
[ "$remote" = "$local_" ] && exit 0
g merge-base --is-ancestor "$remote" HEAD 2>/dev/null && exit 0
short() { printf %.7s "$1"; }
stale="Skills are out of date (local $(short "$local_"), latest $(short "$remote")): run \`$sync\` before relying on skills"

if [ "$(g symbolic-ref -q --short HEAD)" != main ]; then echo "$stale (checkout is not on main)."; exit 0; fi
if [ -n "$(g status --porcelain --untracked-files=no)" ]; then echo "$stale (commit local edits first; not auto-updated)."; exit 0; fi
bounded fetch -q origin main || exit 0
if ! g merge-base --is-ancestor HEAD FETCH_HEAD; then echo "$stale (local and remote diverged; not auto-updated)."; exit 0; fi
g merge -q --ff-only FETCH_HEAD >/dev/null 2>&1 || { echo "$stale (fast-forward failed; not auto-updated)."; exit 0; }
if [ -n "$post" ] && ! sh -c "$post" >/dev/null 2>&1; then echo "Skills pulled to $(short "$remote") but \`$post\` failed: run it before relying on skills."; exit 0; fi
echo "Skills auto-updated to $(short "$remote")."
