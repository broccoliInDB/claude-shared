---
name: evolve
description: Promote a repeated pattern from agent-memory to a team rule via PR in claude-shared.
argument-hint: [pattern description]
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

$ARGUMENTS

> **IMPORTANT**: Write all output in the user's local language. Detect the language from the user's message or system locale and respond accordingly.

## Purpose

Detect repeated patterns in agent-memory and promote them to permanent team rules in the claude-shared repository. This closes the feedback loop: mistakes caught in reviews become rules that prevent future mistakes across all projects.

## Procedure

### Step 1: Identify Pattern to Promote

**If `$ARGUMENTS` is provided:**
- Use the given pattern description as the target.
- Search `.claude/agent-memory/` to find supporting evidence (occurrences, context).

**If no arguments:**
- Read `.claude/agent-memory/code-reviewer/MEMORY.md`.
- Find patterns with 2+ recorded occurrences.
- List candidates and let the user pick one.
- If no patterns meet the threshold, inform and stop.

### Step 2: Validate the Pattern

Before promoting, verify:
1. **Specificity**: The pattern is concrete, not vague. It specifies what to check, when, and how to verify.
2. **Repeatability**: It occurred in 2+ separate reviews (not just 2 instances in one review).
3. **No conflict**: It doesn't contradict existing rules in `~/.claude-team/core/rules/`.
4. **No duplicate**: It isn't already covered by an existing rule.

If validation fails, explain why and suggest refinement.

### Step 3: Determine Target Location

Decide where the rule belongs:
- Check existing rule files in `~/.claude-team/core/rules/` for the best fit.
- If the pattern fits an existing rule file (e.g., `code-style.md`, `architecture.md`), add it there.
- If it requires a new category, create a new rule file in `~/.claude-team/core/rules/`.
- If it's module-specific (e.g., frontend-only, backend-only), place it in `~/.claude-team/modules/`.

### Step 4: Create Branch and Apply Change

1. Navigate to `~/.claude-team/` (the claude-shared local clone).
2. Ensure the repo is on the latest main: `git checkout main && git pull`.
3. Create a branch: `git checkout -b evolve/{pattern-name}`.
4. Add or update the rule in the appropriate file.
5. Stage and commit:
   ```
   feat(rules): add {pattern-name} rule

   Promoted from agent-memory after {N} occurrences across reviews.
   Pattern: {brief description}
   ```

### Step 5: Create Pull Request

1. Push the branch: `git push -u origin evolve/{pattern-name}`.
2. Create a PR using `gh pr create`:
   - Title: `feat(rules): {pattern-name}`
   - Body: Include the pattern description, evidence (occurrence count, example contexts), and the rule text.
3. Report the PR URL to the user.

### Step 6: Clean Up Agent Memory

After the PR is created (not merged):
- Mark the pattern in MEMORY.md as "promoted" with a link to the PR.
- Do NOT remove it from MEMORY.md — it stays as reference until the PR is merged.

## Rule Quality Standards

Every promoted rule must include:
- **What**: Exactly what to check or enforce
- **When**: In which situations this rule applies
- **How to verify**: How to confirm compliance (command, visual check, etc.)
- **Example**: At least one concrete good/bad example

```markdown
### Rule: {Name}
- **What**: ...
- **When**: ...
- **Verify**: ...
- **Example**:
  ```
  // Bad
  ...
  // Good
  ...
  ```
```

## Guidelines

- One PR per pattern. Do not batch multiple patterns into one PR.
- If the pattern is project-specific (not team-wide), add it to the project's `.claude/rules/` instead and inform the user.
- Don't promote trivial patterns (formatting, style that linters handle).
- When in doubt about whether a pattern is team-wide, ask the user.
