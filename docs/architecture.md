# Architecture — 설계 결정과 근거

## 핵심 설계 원칙

### 1. 프로젝트 git 밖에 존재한다

```
~/.claude-team/          ← claude-shared (독립 레포)
project/.claude/         ← 심링크 + 프로젝트 고유 파일
```

**왜**: 공유 파일을 프로젝트 git 안에 넣으면 (submodule, copy, worktree) 반드시 동기화 문제가 생깁니다.
밖에 두면 프로젝트 git이 공유 파일의 존재를 모르므로 충돌이 구조적으로 불가능합니다.

### 2. core + modules 분리

```
core/       → 모든 프로젝트에 적용 (행동 규칙, 워크플로우, 품질)
modules/    → 프로젝트 유형별 선택 (frontend, backend, security)
```

**왜**: CLI 도구와 풀스택 웹앱이 같은 frontend 규칙을 쓸 필요 없습니다.
core는 "AI가 어떻게 일하는가"이고, modules는 "어떤 기술로 일하는가"입니다.

### 3. 심링크 = shared- 접두사 + gitignore

```
.claude/rules/
├── shared-behavior.md      → ~/.claude-team/core/rules/behavior.md  (심링크, gitignored)
├── shared-frontend.md      → ~/.claude-team/modules/frontend/...    (심링크, gitignored)
└── project-api-rules.md    ← 프로젝트 고유 (실제 파일, git 추적)
```

**왜**: `shared-` 접두사로 공유/고유를 구분하고, `.gitignore`에 `shared-*` 패턴 한 줄만 추가합니다.
Claude Code는 `.claude/rules/`의 모든 `.md`를 읽으므로, 심링크든 실제 파일이든 동일하게 동작합니다.

### 4. 자가발전은 PR을 통한다

```
프로젝트에서 패턴 발견 → /evolve → claude-shared에 PR → 팀 리뷰 → 머지 → 전파
```

**왜**: 자동으로 rules를 수정하면 위험합니다. PR을 통하면:
- 팀이 리뷰할 수 있음
- 변경 이력이 남음
- 실수를 되돌릴 수 있음
- 여러 프로젝트에서 온 제안을 조율할 수 있음

---

## 디렉토리 구조 결정

### core/rules/ — 어떤 규칙이 core인가

**기준**: 기술 스택과 무관하게, Claude Code를 사용하는 모든 프로젝트에 해당하는 규칙.

| 파일 | core인 이유 |
|------|-------------|
| behavior.md | AI의 역할과 판단 방식. 모든 프로젝트에 적용 |
| git-workflow.md | 커밋 컨벤션. 언어/프레임워크 무관 |
| quality-checklist.md | 커밋 전 체크리스트. 범용 |
| documentation.md | 문서 구조. 범용 |
| doc-conventions.md | 문서 작성 규칙. 범용 |
| testing.md | 테스트 전략. 범용 (세부 도구는 프로젝트별) |
| architecture.md | 설계 등급 시스템. 범용 |
| code-style.md | TypeScript 공통 규칙. 범용 (포맷팅은 프로젝트별) |
| skill-design.md | 스킬 관리 메타 규칙. claude-shared 자체에 필요 |
| multi-agent.md | 에이전트 협업 규칙. 범용 |

### modules/ — 왜 이 네 가지인가

| 모듈 | 대상 프로젝트 |
|------|-------------|
| frontend/ | React, Next.js, Vue 등 UI가 있는 프로젝트 |
| backend/ | API, DB가 있는 프로젝트 |
| infrastructure/ | 배포, CI/CD가 있는 프로젝트 |
| security/ | 인증, 인가가 있는 프로젝트 |

새 모듈 추가는 자유입니다: `modules/data-engineering/`, `modules/mobile/` 등.

### templates/ — 복사본, 심링크 아님

**왜 심링크가 아닌가**: 템플릿은 프로젝트에 복사한 뒤 수정하는 파일입니다.
PRD.template.md를 복사해서 PRD.md를 만든 뒤, 프로젝트에 맞게 내용을 채웁니다.
원본이 바뀌어도 이미 작성한 PRD.md가 바뀌면 안 됩니다.

---

## 심링크 구조 상세

### link.sh가 하는 일

```bash
# 1. .claude/rules/ 디렉토리 확인/생성
# 2. core/rules/*.md → .claude/rules/shared-*.md 심링크
# 3. core/skills/* → .claude/skills/shared-* 심링크
# 4. core/agents/*.md → .claude/agents/shared-*.md 심링크
# 5. core/hooks/*.sh → .claude/hooks/shared-*.sh 심링크
# 6. --modules 옵션이 있으면 modules/{name}/rules/*.md도 심링크
# 7. .gitignore에 shared-* 패턴 추가 (없으면)
```

### 심링크 네이밍 규칙

```
원본: ~/.claude-team/core/rules/behavior.md
심링크: .claude/rules/shared-behavior.md

원본: ~/.claude-team/modules/frontend/rules/frontend.md
심링크: .claude/rules/shared-frontend.md

원본: ~/.claude-team/core/skills/p-commit/SKILL.md
심링크: .claude/skills/shared-p-commit/SKILL.md
```

`shared-` 접두사가 있으면 공유, 없으면 프로젝트 고유.

### 프로젝트 고유 파일과의 공존

```
.claude/rules/
├── shared-behavior.md       (심링크 → claude-shared)
├── shared-code-style.md     (심링크 → claude-shared)
├── shared-frontend.md       (심링크 → claude-shared)
├── my-api-rules.md          (프로젝트 고유, git 추적)
└── overrides.md             (공유 규칙 예외, git 추적)
```

Claude Code는 모든 `.md`를 동등하게 읽습니다. 충돌 시 더 구체적인 규칙이 우선합니다.

---

## 자가발전 메커니즘

### agent-memory → rules 승격 경로

```
1. 프로젝트 작업 중 AI가 패턴 발견
   → .claude/agent-memory/code-reviewer/MEMORY.md에 기록

2. 같은 패턴이 2회 반복 감지
   → AI가 "팀 규칙으로 승격할까요?" 제안

3. 사용자 승인 → /evolve 스킬 실행
   → ~/.claude-team/에서 브랜치 생성
   → 규칙 파일 추가/수정
   → PR 생성 (gh pr create)

4. 팀 리뷰 → 머지
   → git pull → 모든 프로젝트에 전파
```

### 왜 agent-memory는 프로젝트 로컬인가

agent-memory는 특정 프로젝트에서 발견한 패턴입니다.
프로젝트 A에서 발견한 패턴이 프로젝트 B에도 해당하는지는 사람이 판단해야 합니다.
그래서 agent-memory는 프로젝트 로컬에 두고, 승격은 PR을 통합니다.

다만 MEMORY.md의 **구조(템플릿)**는 claude-shared에서 제공합니다.

---

## 회사 적용 시 fork 구조

```
개인: broccoliInDB/claude-shared (origin)
회사: company/claude-shared       (fork)

개인 → 회사: PR로 기여
회사 → 개인: upstream pull로 받음
퇴사 시: remote 제거, 각자 발전
```

회사 fork에 회사 고유 규칙을 추가해도 개인 원본에는 영향 없습니다.

---

## 기각한 대안들

### npm 패키지로 배포

파일을 복사하므로 drift가 필연적입니다. `sync` 명령으로 해결하려 하면:
- 로컬 수정과 원본 업데이트 충돌 처리 필요
- hash 비교, merge 전략 등 복잡도 증가
- 결국 패키지 매니저를 재발명하게 됨

### git submodule

프로젝트 git 안에 포함되므로:
- 서브모듈 포인터가 커밋에 포함 → 여러 사람이 update하면 충돌
- `git clone` 시 `--recurse-submodules` 필수 (잊기 쉬움)
- detached HEAD 자주 발생
- hsmoa-app의 docs 서브모듈에서 이미 이 문제를 경험

### git worktree + symlink

worktree는 같은 레포의 다른 브랜치를 체크아웃하는 기능입니다.
프로젝트 레포에 `claude-config` 브랜치를 만들면:
- 각 프로젝트 레포에 config 브랜치가 따로 존재 → 동기화 수동
- 프로젝트 레포에 코드와 무관한 브랜치가 섞임
- 결국 "각 프로젝트에 복사한 브랜치"와 같음
