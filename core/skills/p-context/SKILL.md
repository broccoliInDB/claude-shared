---
name: p-context
description: Progressively update CLAUDE.md with project structure changes, architecture decisions, and coding patterns.
argument-hint: [content to reflect (optional)]
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

$ARGUMENTS

> **IMPORTANT**: Write all output in the user's local language. Detect the language from the user's message or system locale and respond accordingly.

## Purpose

Progressively enhance the project's CLAUDE.md so Claude better understands the project and works more consistently.

## Procedure

1. Read the current CLAUDE.md.
2. Assess the current project state:
   - Check directory structure
   - Check key config files (tsconfig, eslint, prettier, etc.)
   - Review recent code changes
3. Check `docs/specs/` and `docs/plans/` to understand project direction.
4. Propose updates to the user.
5. Apply updates upon approval.

## What to Update

If `/p-context` is run without specific arguments, look for items that are missing or outdated in CLAUDE.md:

- **Project structure**: New modules, directory changes
- **Architecture decisions (ADR)**: Tech choices, pattern decisions, tradeoffs
- **Coding patterns**: Recurring patterns, error handling, state management
- **Development workflow**: Build/test/deploy procedures, branch strategy
- **Claude work guide**: Things to watch for, common mistake prevention

## Update Principles

1. **Respect existing content**: Only modify/supplement, don't delete arbitrarily
2. **Stay concise**: Keep it focused, no verbose explanations
3. **Practicality first**: Only include what Claude would actually reference
4. **Verified only**: Check actual code before writing (no guessing)
5. **Under 200 lines**: Move details to separate docs and link

## Guidelines

- Show the user a before/after diff and get confirmation.
- Don't include one-time task details (current in-progress work, etc.).
- After updating, inform: "This context will be used in future sessions."
