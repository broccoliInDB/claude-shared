---
name: p-plan
description: Create a task plan. Breaks down specs into phases and tasks.
argument-hint: [feature name or spec reference]
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

Create a task plan for: $ARGUMENTS

> **IMPORTANT**: Write all output in the user's local language. Detect the language from the user's message or system locale and respond accordingly.

## Procedure

1. Read CLAUDE.md to understand project context.
2. Find and read the related spec in `docs/specs/`.
3. Check existing plans (`docs/plans/*.md`) for overlapping work.
4. Explore the current codebase to assess impact scope.
5. If `docs/templates/plan-template.md` exists, use it. Otherwise, use the default format below.
6. Write the task plan.

## If No Spec Exists

- Inform the user and ask if they'd like to write a spec first with `/p-spec`.
- If they want to proceed directly, gather brief requirements through conversation.

## Task Decomposition Principles

Break down tasks from a senior fullstack developer's perspective:

1. **Dependencies**: Identify what must be done first
2. **Task size**: Each task should be completable in 1-2 hours
3. **Testability**: Each step should have verifiable outcomes
4. **Risk first**: Validate uncertain parts (external APIs, new tech) early
5. **Incremental integration**: Maintain working state at each step, not big-bang

## Plan Document Format

Write to `docs/plans/{feature-name}.md`.

### Default Template

```markdown
# {Feature Name} — Task Plan

**Spec**: docs/specs/{feature-name}.md
**Created**: YYYY-MM-DD
**Status**: In Progress

## Overview
Brief summary of what this plan covers.

## Phase 1: {Phase Name}
> Goal: ...

- [ ] Task 1.1: ...
- [ ] Task 1.2: ...
- [ ] Task 1.3: ...

**Verification**: How to confirm this phase is complete.

## Phase 2: {Phase Name}
> Goal: ...

- [ ] Task 2.1: ...
- [ ] Task 2.2: ...

**Verification**: ...

## Risks & Mitigations
| Risk | Impact | Mitigation |
|------|--------|------------|
| ... | ... | ... |

## Notes
- ...
```

If `docs/templates/plan-template.md` exists in the project, use that template instead.

## Guidelines

- Explore the actual codebase before writing. Don't guess file paths.
- Each Phase should be independently committable.
- After completion, suggest: "Ready to start Phase 1?"
- Update the plan document when the plan changes during implementation.
