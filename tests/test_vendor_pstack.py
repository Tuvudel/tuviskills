"""vendor/pstack must stay byte-identical to the upstream tree recorded in vendor/pstack.lock."""
import subprocess
import unittest
from pathlib import Path

repo = Path(__file__).resolve().parents[1]


class VendorPstackTests(unittest.TestCase):
    def test_vendor_matches_recorded_upstream_tree(self):
        result = subprocess.run(["bash", str(repo / "scripts" / "sync-pstack.sh"), "--check"],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr or result.stdout)

    def test_lock_records_commit_tree_and_version(self):
        lock = dict(line.split("=", 1) for line in (repo / "vendor" / "pstack.lock").read_text().split())
        self.assertRegex(lock["commit"], r"^[0-9a-f]{40}$")
        self.assertRegex(lock["tree"], r"^[0-9a-f]{40}$")
        self.assertIn(lock["commit"][:7], (repo / "UPSTREAM.md").read_text(encoding="utf-8"))

    def test_skill_library_is_valid(self):
        result = subprocess.run(["python3", str(repo / "scripts" / "check-skills")], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stdout)


if __name__ == "__main__":
    unittest.main()
