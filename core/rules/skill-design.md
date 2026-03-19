# Skill Design

## Principle

Each skill has ONE responsibility. No overlap. No ambiguity.

## Skill Responsibility Map

스킬 추가/변경 시 반드시 이 맵을 확인하고 업데이트한다.

| Skill | Single Responsibility | Does NOT do |
|-------|----------------------|-------------|
| `/p-spec` | 사전 기능 스펙 작성 | 플랜, 구현, 문서 현행화 |
| `/p-plan` | 사전 작업 플랜 작성 | 스펙, 구현, 문서 현행화 |
| `/p-doc` | 변경 기반 문서 현행화 (README, TODO, 사후 spec/plan) | CLAUDE.md 수정 |
| `/p-context` | CLAUDE.md 업데이트 | README, TODO, spec, plan |
| `/p-review` | 코드 리뷰 (3인 관점) | 수정 실행, 커밋 |
| `/p-commit` | 품질 게이트 + 커밋 | 문서 판단 (→ `/p-doc`에 위임) |
| `/p-status` | 현재 작업 상태 표시 | 수정, 판단 |
| `/p-help` | 스킬 목록 및 사용법 안내 | 실행 |
| `/evolve` | 패턴 감지 → 팀 규칙 승격 PR | 직접 규칙 수정 |

## Dependency Map

```
/p-commit
├── calls /p-doc (문서 현행화)
└── references /p-context (커밋 후 안내만)

/p-doc
├── references /p-spec format (사후 스펙 포맷)
└── references /p-plan format (사후 플랜 포맷)

/evolve
└── reads agent-memory → creates PR in claude-shared
```

## Rules for Adding/Modifying Skills

### 1. 추가 전 체크

- [ ] 기존 스킬과 책임이 겹치지 않는가?
- [ ] 이 기능이 기존 스킬의 확장으로 가능하지 않은가?
- [ ] "Does NOT do" 경계가 명확한가?

### 2. 추가 시 필수

- [ ] 이 파일의 Responsibility Map에 행 추가
- [ ] 영향받는 기존 스킬의 "Does NOT do" 업데이트
- [ ] Dependency Map 업데이트 (호출/참조 관계)
- [ ] `/p-help`의 스킬 목록 업데이트

### 3. 변경 시 필수

- [ ] 변경이 다른 스킬의 경계를 침범하지 않는가?
- [ ] Responsibility Map이 변경 후에도 정확한가?
- [ ] 호출하는 쪽 / 호출받는 쪽 양방향 확인

### 4. 경계 충돌 시

두 스킬의 책임이 겹치면:
1. 하나에 통합하거나
2. 경계를 더 좁게 재정의

**절대 "둘 다 할 수 있음"으로 두지 않는다.**

## 정본 관리

claude-shared 레포가 유일한 정본이다.
프로젝트의 `.claude/skills/shared-*`는 심링크이므로 별도 동기화가 필요 없다.
