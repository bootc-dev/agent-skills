---
name: split-commits
description: Split mixed working tree changes into clean, logical commits. Use when you have intermixed changes (features, bugfixes, refactoring) that should be separate commits.
---

# Split Commits

Non-interactive tool for splitting working tree changes into multiple clean
commits. Designed for AI agents that don't have TTY access for `git add -i`.

## Problem

When working on code, changes for different concerns (features, bugfixes,
refactoring) often get intermixed. Creating clean, logical commits requires
splitting these changes, but the standard tools (`git add -i`, `git add -p`)
are interactive and require a TTY.

## Prerequisites

- Python 3.10+
- `jq` (optional, for parsing JSON output)

## Workflow

Use `scripts/git-split-commits` for all operations.

### 1. Identify the topics

Before starting, identify the logical groupings for your changes. Common patterns:
- `feature`, `bugfix`, `refactor`
- `api`, `models`, `tests`
- `feat-X`, `feat-Y`, `cleanup`

### 2. Prepare the session

```bash
scripts/git-split-commits prepare "bugfix" "refactor" "feature"
```

Output (JSON):
```json
{
  "status": "prepared",
  "topics": ["bugfix", "refactor", "feature"],
  "total_hunks": 6,
  "files": ["api.py", "models.py", "utils.py"]
}
```

### 3. Review hunks

View the session status:
```bash
scripts/git-split-commits status
```

View the next unassigned hunk:
```bash
scripts/git-split-commits next
```

The output includes:
- `id`: The hunk identifier
- `file`: Which file this hunk is in
- `old_start`/`new_start`: Line numbers
- `first_context`: First context line (for identification)
- `first_change`: First changed line (shows what's being modified)
- `patch`: The full unified diff for this hunk

### 4. Assign hunks to topics

```bash
scripts/git-split-commits assign 0 bugfix
scripts/git-split-commits assign 1 refactor
scripts/git-split-commits assign 2 feature
# ... repeat for all hunks
```

### 5. Commit in order

Commit topics in logical order (usually: bugfixes first, then refactoring,
then features):

```bash
scripts/git-split-commits commit bugfix "fix: Handle edge case in validation"
scripts/git-split-commits commit refactor "refactor: Rename variables for clarity"
scripts/git-split-commits commit feature "feat: Add new API endpoint"
```

### 6. Verify

```bash
git log --oneline -5
```

## Key Concepts

### Hunk Identification

Each hunk is identified by:
- **ID**: A stable numeric identifier within the session
- **Line numbers**: `old_start` (original) and `new_start` (modified)
- **Fingerprints**: `first_context` and `first_change` for content verification

### Staleness Detection

The tool validates that files haven't been modified externally:
- **Blob hash check**: Compares git blob hashes
- **Line content check**: Verifies context lines still match

If validation fails, you'll need to `reset` and `prepare` again.

### Patch Application

Patches are applied using `git apply --cached`, with `--3way` fallback for
context conflicts. This handles the case where committing topic A shifts line
numbers for topic B's patches.

## Commands Reference

| Command | Description |
|---------|-------------|
| `prepare TOPIC...` | Initialize session with topic names |
| `status` | Show all hunks and topic counts (JSON) |
| `next [ID]` | Show next unassigned hunk, or specific hunk |
| `assign ID TOPIC` | Assign a hunk to a topic |
| `stage TOPIC` | Stage all hunks for a topic (without committing) |
| `commit TOPIC "msg"` | Stage and commit a topic |
| `reset` | Clear the session |

## Tips for AI Agents

1. **Parse JSON output** for programmatic decisions:
   ```bash
   scripts/git-split-commits status | jq '.topic_counts'
   ```

2. **Use fingerprints** to understand hunks without reading full patches:
   ```bash
   scripts/git-split-commits status | jq '.hunks[] | {id, file, first_change}'
   ```

3. **Commit order matters**: Commit independent changes first, dependent
   changes last.

4. **When in doubt, refactor first**: Clean code is easier to add features to.

## Example Session

```bash
# Mixed changes in working tree
$ git diff --stat
 src/api.rs   | 25 +++++++++++++++++++------
 src/utils.rs | 15 +++++++++------
 2 files changed, 28 insertions(+), 12 deletions(-)

# Prepare session
$ scripts/git-split-commits prepare "fix" "feat"
{"status": "prepared", "topics": ["fix", "feat"], "total_hunks": 3, ...}

# Review and assign
$ scripts/git-split-commits next | jq '{id, file, first_change}'
{"id": 0, "file": "src/api.rs", "first_change": "+    // Handle null case"}

$ scripts/git-split-commits assign 0 fix
$ scripts/git-split-commits assign 1 feat
$ scripts/git-split-commits assign 2 fix

# Create clean commits
$ scripts/git-split-commits commit fix "fix: Handle null pointer edge cases"
$ scripts/git-split-commits commit feat "feat: Add batch processing endpoint"

# Verify
$ git log --oneline -2
abc1234 feat: Add batch processing endpoint
def5678 fix: Handle null pointer edge cases
```
