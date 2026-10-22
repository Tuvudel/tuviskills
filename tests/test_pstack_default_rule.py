"""The always-on pstack rule must carry the same text in every host's file."""
import re
import unittest
from pathlib import Path

rules = Path(__file__).resolve().parents[1] / "rules"


class PstackDefaultRuleTests(unittest.TestCase):
    def setUp(self):
        self.body = (rules / "pstack-default.md").read_text(encoding="utf-8").strip()

    def test_body_names_poteto_mode_placeholder(self):
        self.assertIn("{{POTETO_MODE}}", self.body)

    def test_body_carries_update_check_fallback(self):
        self.assertIn("{{UPDATE_CHECK}}", self.body)

    def test_cursor_rule_is_always_applied_and_identical(self):
        text = (rules / "pstack-default.mdc").read_text(encoding="utf-8")
        front, rest = re.match(r"---\n(.*?)\n---\n(.*)", text, re.S).groups()
        self.assertIn("alwaysApply: true", front)
        self.assertEqual(rest.strip(), self.body)

    def test_codex_snippet_is_body_plus_adapter(self):
        text = (rules / "pstack-default.codex.md").read_text(encoding="utf-8").strip()
        self.assertTrue(text.startswith(self.body))
        self.assertIn("{{CODEX_ADAPTER}}", text)

    def test_grokbot_text_is_body_with_box_path(self):
        text = "\n".join(l for l in (rules / "pstack-default.grokbot.txt").read_text(encoding="utf-8").splitlines() if not l.startswith("# Grok Bot-specific")).strip()
        self.assertEqual(text, self.body.replace("{{POTETO_MODE}}", "/home/box/agent-data/workflows/poteto-mode/SKILL.md").replace("{{UPDATE_CHECK}}", "sh /workspace/as/scripts/check-update.sh"))


if __name__ == "__main__":
    unittest.main()
