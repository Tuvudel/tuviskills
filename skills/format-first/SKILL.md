---
name: format-first
description: Pre-feature formatting workflow to prevent mixed logic/formatting commits and keep git blame clean
---

# Format-First Workflow

Prevents mixed logic/formatting commits by formatting files **before** starting feature work.

## When to Use

Activate when:
- Starting a new feature that will modify existing files
- Files you're about to edit have inconsistent formatting
- You want to ensure clean git history and blame

## The Workflow

### Step 1: Check Current Formatting

Before touching any code, check if files are consistently formatted:

```bash
# Check a few files you'll be editing
git diff --check
```

Look for:
- Mixed indentation (tabs vs spaces, 2-space vs 4-space)
- Inconsistent line endings (CRLF vs LF)
- Trailing whitespace
- Missing final newlines

### Step 2: Format First (If Needed)

If formatting is inconsistent:

```bash
# Format specific directory or files you'll be working on
prettier --write "path/to/directory/**/*.{js,ts,html,css}"

# OR format specific files
prettier --write src/file1.js src/file2.js

# Check what changed
git diff --stat
```

**Critical:** Only format files you're about to work on, not the entire repo.

### Step 3: Commit Formatting Only

```bash
# Stage formatted files
git add path/to/directory/

# Commit with clear message
git commit -m "chore: format [directory/component] files (prettier)

Prepare files for upcoming feature work.
No logic changes."

# Get the commit hash
git log -1 --format="%H"
```

### Step 4: Add to .git-blame-ignore-revs

```bash
# If file doesn't exist, create it
touch .git-blame-ignore-revs

# Add the formatting commit hash
echo "<commit-hash> # Format [directory] files ($(date +%Y-%m-%d))" >> .git-blame-ignore-revs

# Configure git to use it (one-time setup)
git config blame.ignoreRevsFile .git-blame-ignore-revs
```

### Step 5: NOW Start Feature Work

With clean formatting, all your commits will be logic-only.

## Quick Decision Tree

```
Are you about to edit existing files?
├─ Yes → Check formatting consistency
│  ├─ Inconsistent → Format first (Steps 2-4), then feature
│  └─ Consistent → Proceed with feature
└─ No (new files only) → Proceed with feature
```

## Common Scenarios

### Scenario 1: Small Feature, Few Files

You're adding a function to 2-3 files:

1. Open the files
2. Check if they look consistently formatted
3. If not: format → commit → proceed
4. If yes: proceed directly

### Scenario 2: Large Feature, Many Files

You're refactoring a whole module:

1. Identify all files you'll touch
2. Format entire directory: `prettier --write module/**/*`
3. Commit formatting
4. Start feature work in small, logical commits

### Scenario 3: Emergency Hotfix

You need to fix a bug NOW:

- Skip formatting, just fix the bug
- Commit with message noting mixed formatting: `fix: [bug] (includes minor formatting)`
- Do NOT add to .git-blame-ignore-revs

## Setup: Project-Wide Formatting Config

Create `.prettierrc` for consistency:

```json
{
  "semi": true,
  "singleQuote": false,
  "tabWidth": 2,
  "useTabs": false,
  "trailingComma": "es5",
  "printWidth": 80,
  "endOfLine": "lf"
}
```

Create `.editorconfig` for editor consistency:

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.{js,ts,jsx,tsx,html,css,json,yml,yaml}]
indent_style = space
indent_size = 2
```

## Anti-Patterns (Don't Do This)

**❌ Format entire repo before starting work**
- Creates massive diff, hard to review
- Pollutes history even in unrelated areas

**❌ Format during feature work**
- Mixes logic and formatting in same commit
- Hard to separate later

**❌ Skip formatting "to save time"**
- Creates technical debt
- Next person deals with mixed commits

**✅ Format only what you touch, before you touch it**

## Troubleshooting

**Q: My editor auto-formats on save, mixing changes**
A: After formatting commit, editor's auto-format should be a no-op

**Q: What if I forgot to format first?**
A: Use `git add -p` to separate logic/formatting hunks, or accept mixed commit

**Q: Should I format files I'm not changing?**
A: No. Only format files you'll be editing.

## Integration with git-diff-hygiene

This skill **prevents** issues that git-diff-hygiene **detects**:

- Format-first (this skill) → prevents mixed commits
- Git-diff-hygiene → detects and helps fix existing mixed commits

Use both together for clean git history.
