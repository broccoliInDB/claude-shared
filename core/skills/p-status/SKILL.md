---
name: p-status
description: Show current work status — plans in progress, recent commits, TODOs.
argument-hint:
allowed-tools: Read, Grep, Glob, Bash
---

Show the current work status for this project.

> **IMPORTANT**: Write all output in the user's local language. Detect the language from the user's message or system locale and respond accordingly.

## Procedure

1. **Check active plans** — Read `docs/plans/*.md` and identify in-progress work.
2. **Check TODOs** — If `TODO.md` exists, show pending items.
3. **Recent commits** — Show last 5 commits with `git log --oneline -5`.
4. **Uncommitted changes** — Run `git status --short` to show pending changes.
5. **Summarize** — Provide a brief status overview.

## Output Format

```
## Current Status

### In Progress
- [plan name]: [current phase/status]

### Recent Commits
- abc1234 feat: ...
- def5678 fix: ...

### Uncommitted Changes
- M src/foo.ts
- A src/bar.ts

### TODOs
- [ ] Task 1
- [ ] Task 2
```

## Guidelines

- Keep it concise — this is a quick status check, not a detailed report.
- If no plans exist, suggest: "No active plans. Start with `/p-spec` to design a feature."
- If no uncommitted changes, say "Working tree clean."
