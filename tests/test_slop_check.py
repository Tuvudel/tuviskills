"""design-ui/scripts/slop-check finds the fixture slop and leaves legitimate patterns alone."""
import re
import subprocess
import unittest
from pathlib import Path

repo = Path(__file__).resolve().parents[1]
script = repo / "skills" / "design-ui" / "scripts" / "slop-check"
fixtures = repo / "tests" / "fixtures" / "slop-check"


def run(*args):
    return subprocess.run(["python3", str(script), *map(str, args)], capture_output=True, text=True)


def hits(out):
    return [tuple(m) for m in re.findall(r"^(\S+?):(\d+): \[([\w-]+)\]", out, re.M)]


class SlopCheckTests(unittest.TestCase):
    def test_finds_every_rule_in_slop_fixture(self):
        r = run(fixtures / "slop")
        self.assertEqual(r.returncode, 0, r.stderr)
        found = {(Path(f).name, int(l), rule) for f, l, rule in hits(r.stdout)}
        expected = {
            ("Hero.tsx", 4, "eyebrow"), ("Hero.tsx", 5, "gradient-text"), ("Hero.tsx", 6, "border-shadow"),
            ("Hero.tsx", 6, "emoji"), ("Hero.tsx", 7, "sparkle"), ("Hero.tsx", 9, "card-in-card"),
            ("Hero.tsx", 12, "stat-strip"), ("style.css", 1, "eyebrow"), ("style.css", 2, "gradient-text"),
            ("style.css", 3, "border-shadow"), ("page.html", 2, "eyebrow"),
        }
        self.assertEqual(found, expected, r.stdout)

    def test_legitimate_patterns_are_not_flagged(self):
        r = run(fixtures / "clean")
        self.assertEqual(hits(r.stdout), [], r.stdout)
        self.assertEqual(r.returncode, 0)

    def test_strict_exits_nonzero_only_with_hits(self):
        self.assertEqual(run("--strict", fixtures / "slop").returncode, 1)
        self.assertEqual(run("--strict", fixtures / "clean").returncode, 0)

    def test_rule_filter(self):
        rules = {h[2] for h in hits(run("--rule", "gradient-text", fixtures / "slop").stdout)}
        self.assertEqual(rules, {"gradient-text"})


if __name__ == "__main__":
    unittest.main()
