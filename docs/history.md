# History — claude-shared는 어떻게 탄생했나

## 배경: 세 프로젝트, 세 가지 접근

claude-shared는 세 개의 실제 프로젝트에서 독립적으로 발전한 Claude Code 사용 패턴을 통합하여 탄생했습니다.

### 1. side (개인 MVP 모노레포)

**시기**: 2026년 초
**특징**: AI를 시니어 개발자 집단으로 정의

side는 개인 MVP 아이디어를 모아두는 모노레포로, Claude Code 활용을 가장 체계적으로 실험한 프로젝트입니다.

**핵심 기여**:
- **스킬 워크플로우**: p-spec → p-plan → 구현 → p-review → p-commit의 완전한 개발 사이클
- **자가학습 시스템**: agent-memory에 패턴을 기록하고, 2회 반복 시 rules로 승격
- **품질 게이트**: Hook으로 직접 `git commit`을 차단하고, /p-commit을 통한 리뷰 강제
- **설계 등급 시스템**: 프로젝트 규모(S/M/L)에 따라 다른 컨벤션 적용
- **스킬 책임 맵**: 스킬 간 경계를 명확히 정의 (한 스킬 = 한 책임)

**발견한 문제**:
- projkit 템플릿과 .claude/ 복사본의 동기화 부담 ("양쪽 동시 수정" 규칙)
- 다른 프로젝트에 같은 규칙을 적용하려면 수동 복사 필요

### 2. hsmoa-app (팀 모바일 앱)

**시기**: 2026년 초
**특징**: 다인 팀 협업 + 체계적 문서화

hsmoa-app은 React Native 기반 대규모 모바일 앱으로, 여러 개발자가 Claude Code를 사용하는 환경에서 문서 체계를 발전시켰습니다.

**핵심 기여**:
- **3계층 컨텍스트**: `_context/`(공통) → `{domain}/_context/` → `{feature}/` 구조
- **PRD/SPEC/PLAN 템플릿**: 실전 검증된 문서 형식과 상태 관리(이모지)
- **문서 정합성 규칙**: PLAN 대시보드 ↔ 디렉토리 트리 ↔ 실제 파일 1:1 일치 강제
- **docs 서브모듈**: 코드와 문서 저장소 분리
- **doc-builder/updater 스킬**: 코드베이스 스캔 기반 자동 문서 생성/갱신

**발견한 문제**:
- 팀원마다 Claude 사용 방식이 달라 결과물 품질 편차
- 서브모듈로 인한 git 충돌 (detached HEAD, 포인터 충돌)
- 좋은 규칙이 발견되어도 다른 프로젝트에 전파할 방법 없음

### 3. dp-data-pipeline (데이터 엔지니어링)

**시기**: 2026년 초
**특징**: 멀티에이전트 + 컨텍스트 격리

dp-data-pipeline은 Python 기반 데이터 파이프라인 프로젝트로, 장기 실행 작업과 멀티에이전트 협업에서의 컨텍스트 관리를 발전시켰습니다.

**핵심 기여**:
- **컨텍스트 격리 프로토콜**: feature별 spec/plan/context 3파일 구조로 세션 간 맥락 유지
- **경로 기반 룰 로딩**: 작업 디렉토리에 따라 관련 규칙만 로드
- **멀티에이전트 규칙**: 서브태스크 분배, 에이전트 간 작업 범위 정의
- **기술 스택별 룰 분리**: common/backend/frontend/airflow/pyspark 구조
- **Phase 기반 실행**: 계획 → 검증 → 구현 → 테스트의 단계별 워크플로우

**발견한 문제**:
- 규칙 파일이 docs/에 있어 Claude Code의 .claude/rules/ 자동 로딩 미활용
- 다른 프로젝트(side, hsmoa)의 스킬/에이전트 시스템 부재

---

## 공통 문제: 공유가 안 된다

세 프로젝트 모두 독립적으로 좋은 패턴을 만들었지만, 서로 공유할 수 없었습니다.

```
side        →  자가학습 시스템이 좋은데, hsmoa에는 없음
hsmoa-app   →  문서 템플릿이 좋은데, side에는 없음
dp-pipeline →  컨텍스트 격리가 좋은데, 둘 다 없음
```

**검토한 공유 방식과 기각 이유**:

| 방식 | 기각 이유 |
|------|----------|
| npm 패키지 (복사) | 복사 순간 drift 시작. sync 수동. 자가발전 경로 없음 |
| git submodule | 충돌의 온상. detached HEAD. 팀원이 init 안 하면 동작 안 함 |
| git worktree + symlink | worktree는 같은 레포 전용. 프로젝트 간 공유 불가 |

---

## 해결: 독립 레포 + OS 심링크

**핵심 통찰**: 공유 파일을 프로젝트 git에 넣으려 하면 안 된다.

```
~/.claude-team/                      ← 독립 레포 (프로젝트 밖)
     │
     │  ln -s (OS 심링크)
     ▼
project/.claude/rules/shared-*      ← gitignored 심링크
```

이 구조의 특성:
- **git 충돌 불가능**: 프로젝트 git이 공유 파일의 존재를 모름
- **drift 불가능**: 복사가 아니라 같은 파일을 가리킴
- **즉시 반영**: `git pull` 한 번이면 모든 프로젝트에 전파
- **자가발전 가능**: 프로젝트에서 발견한 패턴 → PR → 머지 → 전체 전파

---

## 통합 과정: 무엇을 어디서 가져왔나

### core/rules/ (모든 프로젝트 공통)

| 규칙 | 출처 | 변경사항 |
|------|------|---------|
| behavior.md | side | AI 역할 정의. 거의 그대로 |
| git-workflow.md | side | Conventional Commits. 그대로 |
| quality-checklist.md | side | 품질 게이트. 그대로 |
| documentation.md | side + hsmoa | side 구조 + hsmoa 3계층 컨텍스트 통합 |
| doc-conventions.md | hsmoa | 문서 상태 관리, 메타 정보, 정합성 규칙 |
| testing.md | side | 테스트 피라미드. 그대로 |
| architecture.md | side | Design Scale에서 프로젝트 고유 예시 제거, 일반화 |
| code-style.md | side | TypeScript 범용 규칙만 유지, Prettier 설정 제거 |
| skill-design.md | side | 스킬 책임 맵. claude-shared 구조에 맞게 조정 |
| multi-agent.md | dp-pipeline | 멀티에이전트 규칙, 컨텍스트 격리 프로토콜 |

### core/skills/ (워크플로우)

| 스킬 | 출처 | 변경사항 |
|------|------|---------|
| p-commit | side | 품질 게이트 + 리뷰 + 회고. 그대로 |
| p-review | side | 3인 관점 코드리뷰. 그대로 |
| p-doc | side + hsmoa | side의 문서 판단 + hsmoa의 doc-updater 통합 |
| p-spec | side + hsmoa | side의 스펙 작성 + hsmoa의 doc-builder 템플릿 통합 |
| p-plan | side | 플랜 작성. hsmoa 템플릿 반영 |
| p-context | side | CLAUDE.md 업데이트. 그대로 |
| p-status | side | 상태 표시. 그대로 |
| p-help | side | 도움말. claude-shared 구조에 맞게 조정 |
| evolve | **신규** | 자가발전 스킬. 패턴 감지 → PR 생성 |

### core/agents/

| 에이전트 | 출처 | 변경사항 |
|---------|------|---------|
| code-reviewer.md | side | 그대로 |
| doc-checker.md | side | 그대로 |

### core/hooks/

| 훅 | 출처 | 변경사항 |
|----|------|---------|
| check-commit.sh | side | 그대로 |
| auto-format.sh | side | 포맷터 경로를 설정 가능하게 변경 |
| restore-context.sh | side | 그대로 |

### modules/ (선택 모듈)

| 모듈 | 출처 | 변경사항 |
|------|------|---------|
| frontend/ | side | React/Next.js 규칙 분리 |
| backend/ | side | API/DB 규칙 분리 |
| infrastructure/ | side | 배포/CI 규칙 분리 |
| security/ | side | 보안 규칙 분리 |

### templates/

| 템플릿 | 출처 |
|--------|------|
| PRD.template.md | hsmoa |
| SPEC.template.md | hsmoa |
| PLAN.template.md | hsmoa |
| plan-detail.template.md | hsmoa |
| settings.json | side (일반화) |
| CLAUDE.md | side + dp-pipeline (컨텍스트 로딩 패턴) |

---

## 버려진 것과 이유

| 항목 | 출처 | 이유 |
|------|------|------|
| changelog 템플릿 (release-please) | side/projkit | 빌드 도구 영역. projkit에 남김 |
| docs-push/pull 스킬 | hsmoa | 서브모듈 전용. claude-shared는 서브모듈 사용 안 함 |
| farm-policy 스킬 | hsmoa | 프로젝트 고유 |
| de-task-mgmt 스킬 (Notion 연동) | dp-pipeline | 프로젝트 고유 |
| airflow MCP 커맨드 | dp-pipeline | 프로젝트 고유 |
| Prettier/ESLint 설정 | side | 빌드 도구 영역. projkit에 남김 |

---

## 타임라인

| 시기 | 이벤트 |
|------|--------|
| 2026년 초 | side, hsmoa-app, dp-pipeline 각각 Claude Code 활용 시작 |
| 2026-03-19 | 세 프로젝트의 패턴 비교 분석 |
| 2026-03-19 | 공유 방식 검토 (npm, submodule, worktree) → 독립 레포 + 심링크 결정 |
| 2026-03-19 | claude-shared 레포 생성, 초기 구조 구축 |
