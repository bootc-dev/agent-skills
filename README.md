# Reusable AI agent skills for the bootc-dev organization.

Skills are defined using the [Agent Skills](https://agentskills.io/) format.
Each skill is a directory containing a `SKILL.md` file with instructions
for AI agents.

At the current time, these skills are not intended for use outside
of the organization.

## Available Skills

- **[diff-quiz](diff-quiz/SKILL.md)** — Generate a quiz to verify human
  understanding of code changes. Helps ensure that developers using AI tools
  understand the code they're submitting. Supports easy, medium, and hard
  difficulty levels.

- **[perform-forge-review](perform-forge-review/SKILL.md)** — Create AI-assisted
  code reviews on GitHub, GitLab, or Forgejo. Builds review comments in a local
  file for human inspection before submitting as a pending/draft review.
