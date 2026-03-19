---
name: p-doc
description: Analyze changes and update project documentation (README, TODO, specs, plans). For CLAUDE.md, use /p-context instead.
argument-hint: [description of what changed (optional)]
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

$ARGUMENTS

> **IMPORTANT**: Write all output in the user's local language. Detect the language from the user's message or system locale and respond accordingly.

## Purpose

Analyze changes during or after work, and update project documentation accordingly.
Fill documentation gaps for work done without the formal workflow (`/p-spec` -> `/p-plan`).

## Scope

Documents this skill manages:
- **README.md** — Reflect usage, structure, and command changes
- **TODO.md** — Check completed items, add new items
- **docs/specs/** — Write post-hoc specs for spec-worthy features done without prior spec
- **docs/plans/** — Write post-hoc plans when needed

Documents this skill does **NOT** manage:
- **CLAUDE.md** — Managed by `/p-context`

## Procedure

### Step 1: Analyze Changes

1. Run `git diff` and `git status` to understand current changes.
2. If the work is already committed, check recent commit logs.
3. Determine the scope and nature of changes.

### Step 2: Context Awareness

Check for project-specific documentation structure:
1. If `docs/_context/` exists, read it to understand domain-specific documentation conventions.
2. If `docs/templates/` exists, use those templates for new documents.
3. If neither exists, use the default formats below.

### Step 3: Documentation Impact Assessment

Determine which documents are affected based on changes:

| Change Type | Document Action |
|-------------|-----------------|
| New command/option added | Update README |
| Feature completed | Check TODO |
| New task discovered | Add to TODO |
| New feature built without spec | Write post-hoc spec |
| Structure/file changes | Update README structure section |
| Changes to existing spec's feature | Sync that spec |

### Step 4: Spec-Worthy Assessment

Write a post-hoc spec if 2+ of the following apply:
- New user-facing feature (command, API, UI)
- Structural changes spanning 3+ files
- Interface changes affecting other features
- Design decisions worth recording for future reference

### Step 5: Write/Update Documents

- **Existing documents**: Read and apply changes.
- **Post-hoc specs**: Use `/p-spec` format but write in past/present tense (recording results, not plans).
- **Post-hoc plans**: Only when needed. Use `/p-plan` format.

### Step 6: Report

Briefly report the list of updated documents and key changes.

## Post-hoc Spec Format

Post-hoc specs are distinguished from pre-hoc specs with a header:

```markdown
---
type: post-hoc
created: YYYY-MM-DD
---
```

The rest follows the spec template format from `/p-spec`.
However, "Goals/Background" is written in past tense, and "Acceptance Criteria" reflects current implementation state.

## Guidelines

- Keep documentation concise. Excessive docs become a maintenance burden.
- If no updates are needed, finish with "No documentation updates needed."
- Make decisions autonomously without asking. Report results only.
