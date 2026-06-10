---
name: export-opencode-session
description: Export an opencode session to Markdown for sharing in a GitHub Gist, PR comment, or bug report. Use when asked to share, export, or summarize an opencode session as text or Markdown.
---

# Export opencode Session to Markdown

Export an opencode conversation session to a readable Markdown file suitable
for GitHub Gists, PR comments, bug reports, or any plain-text sharing.

## When to Use

- User wants to share an opencode session without using the built-in cloud `/share` feature
- User wants a Gist-friendly, self-contained Markdown transcript
- User wants to append a collapsible session log to an existing issue or PR comment

## Prerequisites

- opencode must be installed (the session database is read from its data directory)
- Python 3.8+ (no external dependencies — uses only the standard library)
- `gh` (GitHub CLI) for the `publish` subcommand — install from https://cli.github.com/

## Workflow

### 1. List available sessions

```bash
scripts/opencode-export list
```

Shows recent sessions with their IDs and titles. Use this to find the session
you want to export.

### 2. Export to Markdown (stdout or file)

```bash
# Export the most recent session to stdout
scripts/opencode-export export --latest

# Export by session ID (full ID or unique trailing suffix from 'list')
scripts/opencode-export export <session-id>

# Export to a file
scripts/opencode-export export --latest --output session.md
```

### 3. Publish via the GitHub CLI

All `publish` targets require `gh` to be installed and authenticated.

#### Create a Gist

```bash
# Secret Gist (default)
scripts/opencode-export publish --latest --gist

# Public Gist
scripts/opencode-export publish --latest --gist --public
```

Prints the Gist URL to stdout.

#### Post as a new issue/PR comment

```bash
scripts/opencode-export publish --latest --new-comment owner/repo#42
scripts/opencode-export publish --latest --new-comment https://github.com/owner/repo/issues/42
```

#### Append to an existing comment as a `<details>` block

This is the cleanest pattern for a tracking issue: keep the human-written
top comment intact and append a collapsible session transcript below it.

First, find the comment ID. The numeric ID appears in the URL when you hover
over the timestamp of a comment (e.g. `#issuecomment-1234567890`), or fetch
it with `gh`:

```bash
# List comment IDs on an issue
gh api repos/owner/repo/issues/42/comments --jq '.[] | [.id, .user.login, .body[:60]] | @tsv'
```

Then append the session:

```bash
# Auto-detects repo from the current directory
scripts/opencode-export publish --latest --edit-comment 1234567890

# Explicit repo and custom summary line
scripts/opencode-export publish --latest \
  --edit-comment 1234567890 \
  --repo owner/repo \
  --summary "opencode session: fix the auth bug"
```

The result is a `<details>` block appended to the comment body:

```
<details>
<summary>opencode session: fix the auth bug</summary>

# Session title
...full transcript...

</details>
```

Prints the comment URL to stderr when done.

## Output Format

The exported Markdown includes:

- Session title, date, opencode version, model(s) used
- Cost and token summary
- Conversation turns: user turns are introduced with a `---` separator and a
  `**User:**` label; assistant responses follow directly with no label
- Tool calls as collapsed `<details>` blocks with the tool name, duration, and
  truncated input/output (large outputs are trimmed to stay readable)
- Reasoning/thinking blocks in `<details>` blocks
- Assistant errors shown inline as a `> ⚠️` blockquote

The output renders well in GitHub Gist, GitHub issues/PRs, GitLab, and most
Markdown viewers.

## Finding the Database

The script automatically locates the opencode SQLite database using the
standard XDG data directory:

- Linux/macOS: `$XDG_DATA_HOME/opencode/opencode.db` (defaults to
  `~/.local/share/opencode/opencode.db`)

Override with `--db <path>` if needed (e.g. when opencode uses a non-standard
installation channel).
