# Quality Checklist

## Before Completing Any Task

코드 수정 후 프로젝트의 품질 검증 명령을 실행한다.
구체적 명령은 프로젝트 CLAUDE.md에 정의되어 있다.

일반적인 체크 순서:
1. 타입 체크
2. 린트
3. 빌드
4. 테스트

## Impact Check

| Check | How |
|-------|-----|
| No type errors | typecheck 통과 |
| Build succeeds | build 통과 |
| Existing tests pass | test 전체 통과 |
| New feature has tests | 새 기능에 테스트 존재 |

## Watch For

- Modifying shared functions: verify all callers
- Changing interfaces: update implementations and call sites
- Splitting files: verify all import/export paths
- Changing dependencies: sync lockfile

## Commit Rule

**커밋은 반드시 `/p-commit` 스킬로 수행한다. 직접 `git commit` 금지.**

- 사용자가 "커밋해줘", "커밋", "commit" 등 커밋을 요청하면 → `/p-commit` 실행
- `/p-commit`이 실패하거나 사용 불가능한 경우에만 아래 폴백 규칙 적용

### 폴백: 수동 커밋 시 필수 단계

1. 변경사항 전체를 읽고 분석
2. **Must Fix** / **Should Fix** / **Consider** 로 분류
3. Must Fix가 있으면 커밋하지 않는다 — 수정 후 재리뷰
4. 리뷰 결과를 사용자에게 보여준 뒤 커밋 진행

> 어떤 경로(스킬, 수동, 폴백)로 커밋하든 리뷰 단계를 건너뛸 수 없다.

## Self-Review

Before committing, check:

- No mixed concerns in a single file
- No file exceeds 300 lines
- No business logic in entry points
- No hardcoded text/messages in code
- No feature without tests
