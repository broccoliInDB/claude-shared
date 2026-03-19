---
name: p-spec
description: Create a feature spec (PRD) document. Use for designing new features.
argument-hint: [feature name or description]
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

Create a feature spec (PRD) document for: $ARGUMENTS

> **IMPORTANT**: Write all output in the user's local language. Detect the language from the user's message or system locale and respond accordingly.

## Procedure

1. Read CLAUDE.md to understand project context.
2. Create `docs/specs/` directory if it doesn't exist.
3. Check existing specs (`docs/specs/*.md`) for duplicates or related features.
4. If `docs/templates/` contains a spec template, use it. Otherwise, use the default format below.
5. Ask clarifying questions to refine requirements.
6. Write the spec document.

## Intake: Step-by-Step Questions

Collect requirements through **one question at a time**. Each question includes a placeholder example
specific to the feature context (inferred from `$ARGUMENTS`, CLAUDE.md, project description).

### Required Questions (ask one at a time, in order)

Ask these one at a time. Wait for the user's answer before asking the next.

1. **One-line description** — Describe this feature/project in one sentence? (e.g., ...)
2. **Problem to solve** — What pain point does this solve? (e.g., ...)
3. **MVP required features** — What must be in the first version? (e.g., ...)
4. **Tech stack** — Do you have a preferred tech stack? (e.g., ...)
5. **Target users** — Who will use this? (e.g., personal use / public service)

### Optional Questions (presented as a form)

After required questions are done, present optional items as a form. Proceeding without filling these is fine.

```
Fill in any additional info (or press enter to skip):

- **User scenario**: (e.g., ... -> ... -> ...)
- **Exclusions**: (e.g., ...)
- **Data/external dependencies**: (e.g., ...)
```

### Placeholder Rules
- Placeholder examples must be **specific to the feature context**, not generic.
- Infer context from `$ARGUMENTS`, CLAUDE.md, and the project description.
- Examples should be realistic enough that the user can copy-paste and modify.

### After All Questions
- If answers are clear enough, proceed directly to writing the spec.
- If critical ambiguity remains, ask a focused follow-up (only 1).

## Spec Document Format

Write to `docs/specs/{feature-name}.md`.

### Default Template

```markdown
# {Feature Name}

## Overview
- **One-line**: ...
- **Status**: Draft

## Background & Problem
...

## Goals
- ...

## Non-Goals
- ...

## MVP Features
1. ...

## Technical Design
### Architecture
...

### Data Model
...

### Key Decisions
| Decision | Choice | Reason |
|----------|--------|--------|
| ... | ... | ... |

## Acceptance Criteria
- [ ] ...

## Future Considerations
- ...
```

If `docs/templates/spec-template.md` exists in the project, use that template instead.

## Guidelines

- Keep it practical and concise. Don't write excessively long documents.
- Technical design should only go deep enough to set the implementation direction.
- Consider that the user may be a solo developer — focus on content over formality.
- After completion, suggest: "Would you like to create a task plan with `/p-plan`?"
