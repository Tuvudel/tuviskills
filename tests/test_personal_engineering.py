import os
import subprocess
import tempfile
import unittest
from pathlib import Path

repo = Path(__file__).resolve().parents[1]
script = repo / "install-personal-engineering.ps1"
scratch = repo / ".local" / "personal-engineering-tests"
scratch.mkdir(parents=True, exist_ok=True)
shell = "powershell.exe"
start = "<!-- agent-skills:personal-engineering:start -->"
end = "<!-- agent-skills:personal-engineering:end -->"


class PersonalEngineeringInstallerTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="personal-policy-", dir=scratch)
        self.root = Path(self.temporary.name).resolve()
        assert self.root.is_relative_to(scratch)
        self.profile = self.root / "profile"
        self.codex = self.profile / ".codex"
        self.codex.mkdir(parents=True)
        self.target = self.codex / "AGENTS.md"
        self.backups = self.root / "backups"
        self.original = "## Writing style\r\nKeep literal prose. Preserve עברית.\r\n".encode("utf-8")
        self.target.write_bytes(self.original)

    def tearDown(self):
        self.temporary.cleanup()

    def run_installer(self, *flags, expected=0, use_profile=True, environment=None):
        command = [
            shell, "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(script),
            "-BackupRoot", str(self.backups),
        ]
        if use_profile:
            command.extend(["-UserProfilePath", str(self.profile)])
        command.extend(flags)
        result = subprocess.run(command, capture_output=True, text=True, env=environment)
        self.assertEqual(result.returncode, expected, result.stdout + result.stderr)
        return result

    def test_preserves_guidance_and_backups_original(self):
        self.run_installer()
        self.assertTrue(self.target.read_bytes().startswith(self.original))
        text = self.target.read_text(encoding="utf-8")
        self.assertEqual(text.count(start), 1)
        self.assertIn("engineering-companion", text)
        self.assertIn("resume", text)
        self.assertEqual(len(list(self.backups.glob("*.md"))), 1)
        self.assertEqual(next(self.backups.glob("*.md")).read_bytes(), self.original)

    def test_repeated_install_is_idempotent(self):
        self.run_installer()
        before = self.target.read_bytes()
        count = len(list(self.backups.iterdir()))
        self.run_installer()
        self.assertEqual(self.target.read_bytes(), before)
        self.assertEqual(len(list(self.backups.iterdir())), count)

    def test_whatif_does_not_write_target_or_backups(self):
        self.run_installer("-WhatIf")
        self.assertEqual(self.target.read_bytes(), self.original)
        self.assertFalse(self.backups.exists())

    def test_updates_existing_block_preserving_other_changes(self):
        fixture = self.original + f"\n{start}\nOld rule.\n{end}\n## Another rule\nKeep this.\n".encode()
        self.target.write_bytes(fixture)
        self.run_installer()
        after = self.target.read_bytes()
        self.assertTrue(after.startswith(self.original))
        self.assertIn(b"## Another rule\nKeep this.\n", after)
        self.assertNotIn(b"Old rule.", after)
        self.assertEqual(after.decode().count(start), 1)

    def test_nonempty_override_is_active_target(self):
        override = self.codex / "AGENTS.override.md"
        override.write_text("## Override\nKeep this active.\n", encoding="utf-8")
        self.run_installer()
        self.assertIn("engineering-companion", override.read_text(encoding="utf-8"))
        self.assertEqual(self.target.read_bytes(), self.original)

    def test_remove_only_managed_block(self):
        self.run_installer()
        with self.target.open("ab") as output:
            output.write(b"\n## Later rule\nPreserve this too.\n")
        self.run_installer("-Remove")
        after = self.target.read_bytes()
        self.assertTrue(after.startswith(self.original))
        self.assertIn(b"## Later rule\nPreserve this too.\n", after)
        self.assertNotIn(start.encode(), after)
        self.assertNotIn(end.encode(), after)

    def test_broken_marker_refuses_mutation(self):
        fixture = self.original + f"\n{start}\nIncomplete block.\n".encode()
        self.target.write_bytes(fixture)
        self.run_installer(expected=1)
        self.assertEqual(self.target.read_bytes(), fixture)
        self.assertFalse(self.backups.exists())

    def test_missing_guidance_file_is_created(self):
        self.target.unlink()
        self.run_installer()
        self.assertIn("engineering-companion", self.target.read_text(encoding="utf-8"))
        self.assertFalse(self.backups.exists())

    def test_empty_guidance_file_is_supported(self):
        self.target.write_bytes(b"")
        self.run_installer()
        self.assertIn("engineering-companion", self.target.read_text(encoding="utf-8"))
        self.assertEqual(next(self.backups.glob("*.md")).read_bytes(), b"")

    def test_active_codex_home_is_respected(self):
        custom_home = self.root / "custom-codex-home"
        custom_home.mkdir()
        custom_target = custom_home / "AGENTS.md"
        custom_target.write_bytes(b"## Active custom guidance\n")
        environment = os.environ.copy()
        environment.update(USERPROFILE=str(self.profile), CODEX_HOME=str(custom_home))
        self.run_installer(use_profile=False, environment=environment)
        self.assertIn("engineering-companion", custom_target.read_text(encoding="utf-8"))
        self.assertEqual(self.target.read_bytes(), self.original)

    def test_explicit_profile_isolated_from_active_codex_home(self):
        custom_home = self.root / "custom-codex-home"
        custom_home.mkdir()
        custom_target = custom_home / "AGENTS.md"
        custom_target.write_bytes(b"## Active custom guidance\n")
        environment = os.environ.copy()
        environment.update(USERPROFILE=str(self.profile), CODEX_HOME=str(custom_home))
        self.run_installer(environment=environment)
        self.assertIn("engineering-companion", self.target.read_text(encoding="utf-8"))
        self.assertEqual(custom_target.read_bytes(), b"## Active custom guidance\n")


if __name__ == "__main__":
    unittest.main(verbosity=2)
