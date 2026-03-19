---
name: p-help
description: Show available skills and usage guide.
argument-hint: [skill name for details]
allowed-tools: Read, Glob
---

Show available skills and how to use them.

> **IMPORTANT**: Write all output in the user's local language. Detect the language from the user's message or system locale and respond accordingly.

## Procedure

1. If `$ARGUMENTS` is provided, show detailed help for that specific skill.
2. Otherwise, list all available skills.

## Skill Categories

### Project Skills (from claude-shared)

These skills are installed in `.claude/skills/` via claude-shared:

| Skill | Description | Usage |
|-------|-------------|-------|
| `/p-spec` | Create feature spec (PRD) | `/p-spec [feature name]` |
| `/p-plan` | Create task plan from spec | `/p-plan [spec name]` |
| `/p-doc` | Analyze changes and update docs (README, TODO, specs) | `/p-doc` |
| `/p-context` | Update CLAUDE.md with learnings | `/p-context` |
| `/p-review` | Code review (3 senior perspectives) | `/p-review` |
| `/p-commit` | Quality gate + docs update + conventional commit | `/p-commit` |
| `/p-status` | Show current work status | `/p-status` |
| `/p-help` | Show this help | `/p-help [skill]` |
| `/evolve` | Promote repeated patterns to team rules via PR | `/evolve [pattern]` |

### Development Workflow

```
/p-spec -> /p-plan -> implement -> /p-review -> /p-commit(/p-doc included) -> /p-context
```

1. **`/p-spec`** — Design the feature, define scope and acceptance criteria.
2. **`/p-plan`** — Break spec into phases and tasks.
3. **Implement** — Code the feature phase by phase.
4. **`/p-review`** — Self-review before committing.
5. **`/p-commit`** — Run quality checks and create conventional commit.
6. **`/p-context`** — Update CLAUDE.md with new patterns/architecture.
7. **`/evolve`** — Promote repeated patterns from agent-memory to team rules.

### Built-in Commands

Claude Code also has built-in commands (not skills):

| Command | Description |
|---------|-------------|
| `/help` | Claude Code help (different from this skill) |
| `/clear` | Clear conversation |
| `/compact` | Compact conversation history |
| `/config` | Open config |
| `/cost` | Show token usage |
| `/doctor` | Health check |
| `/init` | Initialize CLAUDE.md |
| `/memory` | Edit CLAUDE.md |
| `/review` | Review a PR (built-in) |

## Output Format

When listing skills, use a simple table. When showing details for a specific skill, read and summarize its SKILL.md file from `.claude/skills/{name}/SKILL.md`.
