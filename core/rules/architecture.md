# Architecture

## Design Scale (설계 등급)

프로젝트 규모에 따라 설계 방식을 결정한다. 프로젝트 CLAUDE.md에 등급을 선언한다.

```markdown
## 패키지 개요
- **설계 등급**: S | M | L
```

### 등급 기준

| 등급 | 기준 | 예시 |
|------|------|------|
| **S (Simple)** | 파일 10개 이하, 단일 기능 | 유틸 라이브러리, 스크립트 |
| **M (Medium)** | 파일 10~30개, 기능 2~5개 | CLI 도구, 단일 목적 앱 |
| **L (Large)** | 파일 30개+, 기능 5개+, 외부 연동 | 풀스택 웹앱, 모바일 앱 |

### 등급별 적용 요약

|  | S | M | L |
|--|---|---|---|
| **구조** | flat | 역할 기반 | 도메인 기반 |
| **테스트** | 핵심만 | 유닛 + 통합 | 유닛 + 통합 + E2E |
| **에러 처리** | try-catch | 에러 타입 분류 | 계층별 전략 |
| **문서** | README만 | README + spec | README + spec + plan + CLAUDE.md |

### 등급 판단 원칙
- 시작 시 등급 선언, 이후 규모가 커지면 **승급 가능**
- S에서 L 컨벤션을 적용하면 오버엔지니어링
- L에서 S 컨벤션을 유지하면 스케일 문제
- 승급 시 구조 마이그레이션 계획 먼저 수립

## General Rules

Split files when they exceed 300 lines.

## Separation of Concerns

- Entry points handle routing only — no business logic
- Messages/text go in separate modules (i18n)
- Config values go in constants or config files
- Related logic stays in the same file

## Modularity

- Extract reusable logic into separate files
- Consider dependency injection for testability
- No circular dependencies
- New files must integrate into the codebase — no orphan files

## No Over-Engineering

- Only implement what's requested — no speculative design
- No helpers/utilities/abstractions for one-time operations
- Three similar lines beat a premature abstraction
- No error handling for impossible scenarios

## Phase-Based Implementation

복잡한 작업 시:

### Phase 1: Planning (No Code)
- 코드 작성 전 plan 생성 또는 업데이트
- 구현을 3~5개의 작은 단계로 분리
- 계획 수립 후 사용자 승인 없이 코드 작성 금지

### Phase 2: Execution (Task by Task)
- 체크리스트를 하나씩 수행
- 한 번에 하나의 파일/함수만 수정
- 수정 후 즉시 테스트 수행

### Phase 3: Completion
- context.md에 완료된 내용 요약 기록 (장기 작업 시)
- plan의 해당 단계를 완료 처리
- 다음 단계 진행 전 spec 요구사항 위반 여부 검토
