"""End-to-end tests for scripts/check-update.{sh,ps1}, the session-start hook wiring, and install-autoupdate.sh.

Each test builds a bare "remote", a clone with the auto-update enabled, and drives one scenario. The .ps1 variant
runs when pwsh (PowerShell 7) is on PATH; it is the same script Windows PowerShell 5.1 runs.
"""
import json, os, shutil, subprocess, tempfile, time, unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PWSH = shutil.which("pwsh") or shutil.which("powershell")


def git(cwd, *args):
    return subprocess.run(["git", "-C", str(cwd), *args], check=True, capture_output=True, text=True).stdout.strip()


class Fixture:
    def __init__(self, tmp):
        self.tmp = Path(tmp)
        self.remote, self.clone, self.other = self.tmp / "remote.git", self.tmp / "clone", self.tmp / "other"
        subprocess.run(["git", "init", "-q", "--bare", "-b", "main", str(self.remote)], check=True)
        subprocess.run(["git", "clone", "-q", str(self.remote), str(self.other)], check=True, capture_output=True)
        self.ident(self.other)
        (self.other / "scripts").mkdir()
        for f in ("check-update.sh", "check-update.ps1"):
            shutil.copy(ROOT / "scripts" / f, self.other / "scripts" / f)
        self.commit(self.other, "README.md", "v1")
        git(self.other, "push", "-q", "origin", "HEAD:main")
        subprocess.run(["git", "clone", "-q", str(self.remote), str(self.clone)], check=True, capture_output=True)
        self.ident(self.clone)
        (self.clone / ".git" / "agent-skills").mkdir()
        (self.clone / ".git" / "agent-skills" / "autoupdate").touch()
        # Local-only skill folders listed in .git/info/exclude, plus a stray untracked file: both must survive.
        (self.clone / ".git" / "info" / "exclude").write_text("cloudflare-*/\n")
        (self.clone / "cloudflare-workers").mkdir()
        (self.clone / "cloudflare-workers" / "SKILL.md").write_text("local")
        (self.clone / "scratch.txt").write_text("untracked")
        self.post_marker = self.tmp / "post-sync-ran"

    @staticmethod
    def ident(repo):
        git(repo, "config", "user.name", "t"); git(repo, "config", "user.email", "t@example.com")

    def commit(self, repo, name, text):
        (repo / name).write_text(text)
        git(repo, "add", "-A"); git(repo, "commit", "-qm", text)
        return git(repo, "rev-parse", "HEAD")

    def push_upstream(self, text="v2"):
        sha = self.commit(self.other, "README.md", text)
        git(self.other, "push", "-q", "origin", "HEAD:main")
        return sha

    def head(self):
        return git(self.clone, "rev-parse", "HEAD")


class CheckUpdateBase:
    shell = None

    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.f = Fixture(self._tmp.name)

    def tearDown(self):
        self._tmp.cleanup()

    def run_check(self, interval="0"):
        env = dict(os.environ, AGENT_SKILLS_CHECK_INTERVAL_MIN=interval, AGENT_SKILLS_POST_SYNC=f"touch {self.f.post_marker}")
        script = self.f.clone / "scripts" / ("check-update.sh" if self.shell == "sh" else "check-update.ps1")
        cmd = ["sh", str(script)] if self.shell == "sh" else [PWSH, "-NoProfile", "-File", str(script)]
        start = time.monotonic()
        p = subprocess.run(cmd, env=env, capture_output=True, text=True, timeout=30)
        self.elapsed = time.monotonic() - start
        self.assertEqual(p.returncode, 0, p.stderr)
        return p.stdout.strip()

    def assert_local_files_kept(self):
        self.assertTrue((self.f.clone / "cloudflare-workers" / "SKILL.md").is_file())
        self.assertTrue((self.f.clone / "scratch.txt").is_file())

    def test_up_to_date_is_silent(self):
        self.assertEqual(self.run_check(), "")

    def test_disabled_is_silent(self):
        (self.f.clone / ".git" / "agent-skills" / "autoupdate").unlink()
        new = self.f.push_upstream()
        self.assertEqual(self.run_check(), "")
        self.assertNotEqual(self.f.head(), new)

    def test_behind_and_clean_fast_forwards_and_syncs(self):
        new = self.f.push_upstream()
        self.assertEqual(self.run_check(), f"Skills auto-updated to {new[:7]}.")
        self.assertEqual(self.f.head(), new)
        self.assertTrue(self.f.post_marker.exists())
        self.assert_local_files_kept()

    def test_behind_and_dirty_reports_and_keeps_edits(self):
        old = self.f.head()
        new = self.f.push_upstream()
        (self.f.clone / "README.md").write_text("local edit")
        out = self.run_check()
        self.assertIn(f"Skills are out of date (local {old[:7]}, latest {new[:7]})", out)
        self.assertIn("commit local edits first", out)
        self.assertEqual(len(out.splitlines()), 1)
        self.assertEqual(self.f.head(), old)
        self.assertEqual((self.f.clone / "README.md").read_text(), "local edit")
        self.assertFalse(self.f.post_marker.exists())

    def test_diverged_reports_and_keeps_local_commit(self):
        local = self.f.commit(self.f.clone, "local.md", "mine")
        new = self.f.push_upstream()
        out = self.run_check()
        self.assertIn(f"(local {local[:7]}, latest {new[:7]})", out)
        self.assertIn("diverged", out)
        self.assertEqual(self.f.head(), local)
        self.assert_local_files_kept()

    def test_local_ahead_is_silent(self):
        self.f.commit(self.f.clone, "local.md", "mine")
        self.assertEqual(self.run_check(), "")

    def test_offline_is_silent(self):
        git(self.f.clone, "remote", "set-url", "origin", str(self.f.tmp / "missing.git"))
        self.assertEqual(self.run_check(), "")

    def test_unreachable_host_is_silent_and_bounded(self):
        git(self.f.clone, "remote", "set-url", "origin", "http://10.255.255.1/x.git")
        self.assertEqual(self.run_check(), "")
        self.assertLess(self.elapsed, 8)

    def test_throttled_skips_remote_until_due(self):
        self.assertEqual(self.run_check(interval="240"), "")
        new = self.f.push_upstream()
        self.assertEqual(self.run_check(interval="240"), "")
        self.assertNotEqual(self.f.head(), new)
        self.assertEqual(self.run_check(interval="0"), f"Skills auto-updated to {new[:7]}.")


class CheckUpdateShTests(CheckUpdateBase, unittest.TestCase):
    shell = "sh"


@unittest.skipUnless(PWSH, "PowerShell not installed")
class CheckUpdatePs1Tests(CheckUpdateBase, unittest.TestCase):
    shell = "pwsh"


class SessionStartHookTests(unittest.TestCase):
    def run_hook(self, env):
        p = subprocess.run(["bash", str(ROOT / "hooks" / "session-start"), "codex"], env=env, capture_output=True, text=True, timeout=30)
        self.assertEqual(p.returncode, 0, p.stderr)
        return json.loads(p.stdout)["hookSpecificOutput"]["additionalContext"]

    def test_context_names_the_hook_and_expands_the_fallback(self):
        ctx = self.run_hook(dict(os.environ, AGENT_SKILLS_CHECK_INTERVAL_MIN="100000"))
        self.assertIn("injected by the agent-skills session-start hook", ctx)
        self.assertIn(f"sh {ROOT}/scripts/check-update.sh", ctx)
        self.assertNotIn("{{", ctx)


class InstallAutoupdateShTests(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.home = Path(self._tmp.name)
        self.repo = self.home / "agent-skills"
        shutil.copytree(ROOT, self.repo, ignore=shutil.ignore_patterns("archive", "skills", "vendor", ".local"))
        (self.repo / "vendor").mkdir()
        for d in (".codex", ".claude", ".cursor"):
            (self.home / d).mkdir()
        self.other_hook = {"matcher": "startup", "hooks": [{"type": "command", "command": "echo mine"}]}
        (self.home / ".claude" / "settings.json").write_text(json.dumps({"model": "x", "hooks": {"SessionStart": [self.other_hook]}}))
        (self.home / ".codex" / "AGENTS.md").write_text("# my rules\n")

    def tearDown(self):
        self._tmp.cleanup()

    def run_installer(self, *args):
        env = dict(os.environ, HOME=str(self.home), PATH="/usr/bin:/bin")
        env.pop("CODEX_HOME", None)
        p = subprocess.run(["sh", str(self.repo / "scripts" / "install-autoupdate.sh"), *args], env=env, capture_output=True, text=True)
        self.assertEqual(p.returncode, 0, p.stderr)
        return p.stdout

    def settings(self):
        return json.loads((self.home / ".claude" / "settings.json").read_text())

    def test_install_merges_is_idempotent_and_uninstalls(self):
        out = self.run_installer()
        self.assertIn("Codex /hooks trust: NEEDED", out)
        s = self.settings()
        self.assertEqual(s["model"], "x")
        self.assertEqual(s["hooks"]["SessionStart"][0], self.other_hook)
        self.assertEqual(len(s["hooks"]["SessionStart"]), 2)
        self.assertTrue((self.repo / ".git" / "agent-skills" / "autoupdate").exists())
        codex = json.loads((self.home / ".codex" / "hooks.json").read_text())["hooks"]["SessionStart"][0]
        self.assertEqual(codex["hooks"][0]["command"], f'"{self.repo}/hooks/run-hook.cmd" session-start codex')
        agents = (self.home / ".codex" / "AGENTS.md").read_text()
        self.assertTrue(agents.startswith("# my rules"))
        self.assertIn(f"sh {self.repo}/scripts/check-update.sh", agents)
        cursor = json.loads((self.home / ".cursor" / "hooks.json").read_text())
        self.assertEqual(cursor["version"], 1)

        snapshot = {p: p.read_text() for p in self.home.rglob("*.json")}
        again = self.run_installer()
        self.assertIn("hook definition unchanged", again)
        self.assertEqual(snapshot, {p: p.read_text() for p in self.home.rglob("*.json") if p in snapshot})
        self.assertIn("codex: hook installed", self.run_installer("--check"))

        self.run_installer("--uninstall")
        self.assertEqual(self.settings()["hooks"]["SessionStart"], [self.other_hook])
        self.assertFalse((self.repo / ".git" / "agent-skills" / "autoupdate").exists())
        self.assertEqual((self.home / ".codex" / "AGENTS.md").read_text(), "# my rules\n")
        self.assertFalse((self.home / ".cursor" / "rules" / "pstack-default.mdc").exists())

    def test_absent_tools_are_skipped(self):
        shutil.rmtree(self.home / ".cursor")
        out = self.run_installer()
        self.assertIn("cursor: not detected, skipped", out)
        self.assertFalse((self.home / ".cursor").exists())


if __name__ == "__main__":
    unittest.main()
