#!/bin/sh
# One-time setup of the skills auto-update on macOS/Linux. Usage: scripts/install-autoupdate.sh [--check|--uninstall]
# Enables scripts/check-update.sh (marker .git/agent-skills/autoupdate) and merges the existing session-start hook
# (hooks/run-hook.cmd session-start <tool>) plus the always-on rule into Codex, Claude Code and Cursor, for each tool
# that is present. Idempotent; keeps other entries; backs up every changed file as <name>.agent-skills-<stamp>.bak.
# Windows: scripts/install-autoupdate.ps1. JSON merging needs python3 (ships with git on macOS via Xcode CLT).
repo=$(cd "$(dirname "$0")/.." && pwd) || exit 1
mode=${1:---install}
case $mode in --install|--check|--uninstall) ;; *) echo "usage: $0 [--check|--uninstall]" >&2; exit 2 ;; esac
command -v python3 >/dev/null 2>&1 || { echo "python3 is required to merge hook JSON" >&2; exit 1; }
present() { [ -d "$HOME/$1" ] || command -v "$2" >/dev/null 2>&1 || { [ -n "$3" ] && command -v "$3" >/dev/null 2>&1; }; }
tools=
present .codex codex && tools="$tools codex"
present .claude claude && tools="$tools claude"
present .cursor cursor cursor-agent && tools="$tools cursor"
exec python3 - "$repo" "$mode" "${CODEX_HOME:-$HOME/.codex}" $tools <<'PY'
import json, re, sys, time
from pathlib import Path
repo, mode, codex_home, *tools = sys.argv[1:]
repo, home, codex_home = Path(repo), Path.home(), Path(codex_home)
marker = repo / '.git' / 'agent-skills' / 'autoupdate'
hook_cmd = f'"{repo}/hooks/run-hook.cmd"'
stamp = time.strftime('%Y%m%dT%H%M%SZ', time.gmtime())
# Same entries and ownership test as install-integrations.ps1, so both installers converge on one definition.
HOOKS = {
    'codex': (codex_home / 'hooks.json', 'SessionStart', {'matcher': 'startup|resume|clear|compact', 'hooks': [{'type': 'command', 'command': f'{hook_cmd} session-start codex', 'timeout': 10}]}),
    'claude': (home / '.claude/settings.json', 'SessionStart', {'matcher': 'startup|clear|compact', 'hooks': [{'type': 'command', 'command': f'{hook_cmd} session-start claude', 'async': False}]}),
    'cursor': (home / '.cursor/hooks.json', 'sessionStart', {'command': f'{hook_cmd} session-start cursor'}),
}
own = lambda e: 'run-hook.cmd' in json.dumps(e) and 'session-start' in json.dumps(e)

def expand(name):
    t = (repo / 'rules' / name).read_text(encoding='utf-8').replace('\r\n', '\n')
    return (t.replace('{{POTETO_MODE}}', f'{repo}/vendor/pstack/skills/poteto-mode/SKILL.md')
             .replace('{{CODEX_ADAPTER}}', f'{repo}/harness/codex.md')
             .replace('{{UPDATE_CHECK}}', f'sh {repo}/scripts/check-update.sh').strip())

def save(path, text):
    if path.exists():
        if path.read_text(encoding='utf-8') == text: return False
        path.with_name(f'{path.name}.agent-skills-{stamp}.bak').write_bytes(path.read_bytes())
    else:
        path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding='utf-8'); return True

def load(path):
    raw = path.read_text(encoding='utf-8') if path.exists() else ''
    try: return json.loads(raw) if raw.strip() else {}
    except ValueError: sys.exit(f'Not valid JSON, fix it by hand first: {path}')

def merge_hook(tool, remove):
    path, event, entry = HOOKS[tool]
    cfg = load(path)
    if tool == 'cursor' and not remove: cfg.setdefault('version', 1)
    hooks = cfg.setdefault('hooks', {})
    kept = [e for e in hooks.get(event, []) if not own(e)]
    if remove:
        if kept: hooks[event] = kept
        else: hooks.pop(event, None)
        if not path.exists(): return False
    else: hooks[event] = kept + [entry]
    return save(path, json.dumps(cfg, indent=2) + '\n')

def block(path, body, remove):
    start, end = '<!-- agent-skills:pstack-default:start -->', '<!-- agent-skills:pstack-default:end -->'
    text = path.read_text(encoding='utf-8').replace('\r\n', '\n') if path.exists() else ''
    pat = re.compile(re.escape(start) + '.*?' + re.escape(end), re.S)
    new = '' if remove else f'{start}\n{body}\n{end}'
    text = pat.sub(lambda m: new, text) if pat.search(text) else (text.rstrip() + '\n\n' + new).lstrip()
    if remove and not path.exists(): return False
    return save(path, text.strip() + '\n')

def cursor_rule(remove):
    path = home / '.cursor/rules/pstack-default.mdc'
    if path.exists() and 'agent-skills:managed' not in path.read_text(encoding='utf-8'):
        print(f'  skipped, a different file exists: {path}'); return False
    if remove:
        if path.exists(): path.unlink(); return True
        return False
    return save(path, expand('pstack-default.mdc') + f'\n<!-- agent-skills:managed (installed from {repo}/rules; edit there) -->\n')

def agents_md():
    o = codex_home / 'AGENTS.override.md'
    return o if o.exists() else codex_home / 'AGENTS.md'

def hook_installed(tool):
    path, event, entry = HOOKS[tool]
    return path.exists() and entry in load(path).get('hooks', {}).get(event, [])

if mode == '--check':
    last = marker.parent / 'last-check'
    print(f"Auto-update: {'enabled' if marker.exists() else 'disabled'}; last remote check: "
          + (time.strftime('%Y-%m-%d %H:%M %Z', time.localtime(last.stat().st_mtime)) if last.exists() else 'never'))
    for t in HOOKS:
        state = ('hook installed' if hook_installed(t) else 'hook missing') if t in tools else 'not detected'
        print(f'  {t}: {state}')
    if 'codex' in tools and hook_installed('codex'):
        print('  codex: trust is not readable from here; if Codex warns at startup, run /hooks once and trust it.')
    sys.exit(0)

remove = mode == '--uninstall'
if remove: marker.unlink(missing_ok=True)
else: marker.parent.mkdir(parents=True, exist_ok=True); marker.touch()
changed = {}
for t in tools:
    changed[t] = merge_hook(t, remove)
    if t == 'codex': block(agents_md(), expand('pstack-default.codex.md'), remove)
    if t == 'claude': block(home / '.claude/CLAUDE.md', expand('pstack-default.md'), remove)
    if t == 'cursor': cursor_rule(remove)
verb = 'removed' if remove else 'installed'
print(f"Auto-update {'disabled' if remove else 'enabled'} for {repo}.")
for t in HOOKS:
    print(f"  {t}: {(verb if changed[t] else 'unchanged') if t in tools else 'not detected, skipped'}")
if 'codex' in tools and not remove:
    print('  Codex /hooks trust: ' + ('NEEDED. Start codex, run /hooks, trust the agent-skills SessionStart hook once.' if changed['codex']
          else 'hook definition unchanged; needed only if you never trusted it (Codex warns at startup).'))
PY
