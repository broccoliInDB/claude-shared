# Code Style

## TypeScript

- No `any` type — use `unknown` + type guards
- Always specify function return types (`explicit-function-return-type`)
- Use inline type imports: `import { type X } from '...'` (not `import type`)
- Always type JSON.parse results: `JSON.parse(content) as Config`
- Use optional chaining for nullable values: `?.`
- Use strict boolean expressions — no implicit truthy/falsy checks
- Handle all promises — no floating promises
- Avoid `console.log` in library code (use a logger or remove before commit)

## Naming

- Functions start with verbs: `getUserName`, `createConfig`
- No magic numbers — extract to named constants
- Boolean variables: `is`, `has`, `should` prefix

## Patterns

- Early return to eliminate nested conditionals
- Code should explain intent — clear code over comments
- One function, one responsibility
- Prefer `const` — use `let` only when reassignment is needed

## Formatting

포맷팅 도구(Prettier 등)의 구체적 설정은 프로젝트별로 다르다.
프로젝트 CLAUDE.md 또는 설정 파일을 참고한다.
