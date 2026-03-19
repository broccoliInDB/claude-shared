---
name: p-commit
description: Auto quality gate + self-correction loop + conventional commit.
argument-hint: [commit description (optional)]
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash, Edit, Write, Agent
---

$ARGUMENTS

> **IMPORTANT**: Write all output in the user's local language. Detect the language from the user's message or system locale and respond accordingly. Commit message subject and body should also be in the user's local language. Only the type and scope (e.g., `feat(scope):`) remain in English for conventional commits compatibility.

## Dynamic Context

Current changes:
!`git diff --stat 2>/dev/null || echo "(no changes)"`

Changed directories:
!`git diff --name-only 2>/dev/null | head -20 || echo "(none)"`

Recent commit style:
!`git log --oneline -5 2>/dev/null || echo "(no commits)"`

## Procedure

This skill runs an automated quality pipeline with a self-correction feedback loop. Do NOT ask for confirmation between steps — run them all sequentially and only stop if a step fails after auto-fix.

### Limits (prevent infinite loops)
- **Quality Gate retry**: max 2 attempts. After 2 failures, record remaining issues and abort commit.
- **Self-Review fix cycle**: max 1 round. After fix, re-run Quality Gate once.
- **Retrospective**: max 2 rule additions/modifications. Record the rest as "unresolved" in MEMORY.md.
- **Overall pipeline**: Be token-conscious and concise. Output results only, no verbose reports.

### Step 1: Identify Changes
1. Use the Dynamic Context above to understand changes (skip manual git diff if already provided).
2. If no changes exist, inform and stop.
3. Stage all relevant files (or use already staged files if present).

### Step 2: Quality Gate

Run the project's quality commands as defined in CLAUDE.md (e.g., typecheck, lint, build, test).

**2a. Type Check**
- Run the project's typecheck command(s).
- If errors found: fix them, then re-run.
- If still failing after fix: report errors and stop.

**2b. Lint + Format**
- Run the project's lint/format commands (auto-fixable — just run and move on).

**2c. Build**
- Run the project's build command.
- If build fails: attempt to fix, re-run. If still failing: report and stop.

**2d. Test**
- Run the project's test command.
- If tests fail: attempt to fix, re-run. If still failing: report and stop.

**Note**: Check CLAUDE.md for the exact commands. If no commands are defined, skip that step and note it.

### Step 3: Code Review (code-reviewer agent)

Use the Agent tool to spawn the `code-reviewer` agent for an independent review.

**Agent invocation:**
```
Agent(code-reviewer): "Review the current staged changes. Analyze git diff --staged results, compare against .claude/rules/ standards, and classify issues as Must Fix / Should Fix / Consider."
```

**Handling review results:**
- **Must Fix**: Fix it immediately and silently. Do not ask.
- **Should Fix**: Fix it immediately and silently. Do not ask.
- **Consider**: Skip — do not fix, do not mention.
- **Repeated pattern detected** flag: Record as rule strengthening candidate in Step 4.

After fixing, re-run the full Quality Gate (Step 2) to verify fixes.

**Fallback when agent is unavailable:**
If the agent call fails, self-review from 3 perspectives:
- Senior Developer: Architecture, type safety, naming, file size
- Senior PM: Scope, completeness, impact on existing features
- Senior QA: Edge cases, error handling, test coverage

### Step 4: Retrospective (self-correction loop)

This step turns mistakes into permanent improvements. It runs AFTER all fixes are applied.

**4a. Analyze what was caught**
Review all issues that were fixed during Steps 2-3:
- What failed in the quality gate?
- What did self-review catch?
- Were there issues that required multiple fix attempts?

**4b. Pattern extraction**
For each issue, ask:
- Is this a new type of mistake, or a repeat of a known pattern?
- Could this have been caught earlier? How?
- Is there an existing rule that should have prevented this?

**4c. Rule update (promotion process)**
- Check `.claude/agent-memory/code-reviewer/MEMORY.md` for patterns with 2+ occurrences.
- 2+ occurrences → Promote to a concrete rule in `.claude/rules/`.
  - **Team-wide patterns** (applicable across projects): Suggest using `/evolve` to promote to claude-shared rules.
  - **Project-specific patterns**: Add directly to the project's `.claude/rules/` files.
- 1 occurrence → Record in agent-memory only (verify on next review).
- If an existing rule was ignored → Strengthen with more specific conditions.
- Do NOT add vague rules. Each rule must specify: what to check, when, and how to verify.

**4d. Rule conflict check**
After adding/updating rules, verify:
- New rule doesn't contradict existing rules
- New rule doesn't duplicate existing rules
- If conflict exists: resolve by keeping the stricter, more specific version

**4e. Unresolved items**
If there are issues identified but not fixed (limit reached, out of scope, requires user decision):
- Record them in MEMORY.md under "Unresolved" section
- These become input for the next session's retrospective
- Do NOT block the commit for these — record and move on

**4f. Skip conditions**
Skip retrospective if:
- Quality gate passed on first try with zero fixes
- All fixes were formatting-only (lint/format auto-fix)

### Step 5: Documentation Update
1. Use the Agent tool to spawn the `doc-checker` agent: "Analyze changes and determine which documentation needs updating."
2. If doc-checker finds items needing updates → Run `/p-doc` to apply them.
3. If `/p-doc` updated documents, include those files in staging.
4. CLAUDE.md updates are outside `/p-doc` scope — if needed, suggest `/p-context` after commit.

**Fallback when agent is unavailable:** Run `/p-doc` directly.

### Step 6: Commit
1. Run `git diff --staged` (or `git diff` if not staged) to analyze final changes.
2. Generate a conventional commit message based on the changes.
3. If rules were updated in Step 4, include those changes in a separate commit.
4. Present the commit message to the user for confirmation.
5. **Create marker file**: Run `touch .claude/.commit-approved` (hook checks this file to allow the commit).
6. Execute the commit upon approval.
7. If commit fails, clean up marker: `rm -f .claude/.commit-approved`.

## Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type Decision Guide
| Type | When to use |
|------|------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting (no logic change) |
| `refactor` | Code restructure (no feature change) |
| `perf` | Performance improvement |
| `test` | Add/update tests |
| `build` | Build config, dependency changes |
| `ci` | CI/CD config changes |
| `chore` | Other changes |

### Scope: Use the most relevant module, feature, or directory name
### Subject: Imperative mood, under 50 chars, no period

## release-please Integration

- `feat:` → minor version bump
- `fix:` → patch version bump
- `feat!:` or `BREAKING CHANGE:` → major version bump

## Commit Splitting

If changes span multiple concerns (e.g., feature + refactor + docs), split into separate commits automatically. Run the full quality gate for each commit.

## Guidelines

- Only ask the user ONE time: to confirm the commit message.
- All quality checks, fixes, and retrospective happen silently and automatically.
- Do not use the `--no-verify` flag.
- If the pipeline passes with no issues on first try, skip retrospective and proceed directly to commit message proposal.
