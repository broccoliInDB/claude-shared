---
name: p-review
description: Review code changes before committing. Spawns code-reviewer agent in isolated context.
argument-hint: [focus area (optional)]
disable-model-invocation: true
context: fork
agent: code-reviewer
allowed-tools: Read, Grep, Glob, Bash
---

$ARGUMENTS

> **IMPORTANT**: Write all output in the user's local language. Detect the language from the user's message or system locale and respond accordingly.

## Dynamic Context

Changes:
!`git diff --stat 2>/dev/null || echo "(no changes)"`

Changed directories:
!`git diff --name-only 2>/dev/null | head -20 || echo "(none)"`

## Purpose

Review current code changes using the code-reviewer agent in an isolated (forked) context. This removes author bias — the reviewer has no access to the conversation where the code was written.

## Procedure

1. Use the Dynamic Context above to understand changes.
2. Read `.claude/rules/` to understand project standards.
3. Read `.claude/agent-memory/code-reviewer/MEMORY.md` for previously discovered patterns.
4. Read the project's CLAUDE.md for project-specific rules.
5. Review changes from all perspectives defined in the code-reviewer agent.
6. Present findings organized by severity: **Must Fix**, **Should Fix**, **Consider**.
7. If no issues found, confirm the code is ready to commit.
8. Update MEMORY.md if new patterns are discovered.

## Output Format

```
## Review Results

**Change scope**: S/M/L (file count, lines changed)

### Must Fix (blocking — must be resolved)
- `file:line` issue description [rule: rule-name]

### Should Fix (recommended — fix in this round)
- `file:line` issue description

### Consider (informational)
- `file:line` improvement suggestion

### Repeated Patterns
- (patterns also found in previous reviews are flagged here)

### Verdict: READY / NEEDS WORK
```

## Guidelines

- Be specific. Point to exact files and lines.
- Don't nitpick formatting — that's what linters and auto-format hooks are for.
- Focus on logic, architecture, and maintainability.
- If changes look good, say so. Don't fabricate issues.
- After review, suggest: "Run `/p-commit` to commit" or "Fix the issues above first."
