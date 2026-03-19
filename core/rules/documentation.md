# Documentation

## 문서 구조

프로젝트 규모에 따라 문서 구조가 달라진다 (architecture.md의 설계 등급 참조).

### 기본 구조

```
project/
├── docs/
│   ├── specs/        # 기능 스펙 (created by /p-spec)
│   ├── plans/        # 작업 플랜 (created by /p-plan)
│   └── {feature}.md  # 기능 문서
├── README.md         # 개요 + 빠른 시작
└── TODO.md           # 작업 추적
```

### 대규모 프로젝트: 3계층 컨텍스트

```
docs/
├── _context/                    # Level 0: 프로젝트 공통
│   ├── doc-conventions.md       #   문서 규칙
│   ├── architecture.md          #   전체 아키텍처
│   └── templates/               #   문서 템플릿
├── {domain}/                    # Level 1: 도메인별
│   ├── _context/                #   도메인 전용 컨텍스트
│   │   ├── README.md            #     도메인 개요
│   │   ├── architecture.md      #     화면/컴포넌트 구조
│   │   ├── api-reference.md     #     API 스키마
│   │   └── rules.md             #     도메인 규칙
│   └── {feature}/               # Level 2: 기능별
│       ├── PRD.md               #   제품 요구사항
│       ├── SPEC.md              #   기술 스펙
│       └── PLAN.md              #   개발 계획
```

**원칙**: 공통 패턴은 상위 계층에서 참조, 기능별 문서에는 고유 사항만 기술.

## 문서 업데이트

- `/p-doc` 또는 `/p-commit` 사용 시: 자동 판단, 묻지 않고 실행
- 스킬 없이 수동 작업 시: 완료 후 관련 문서 업데이트 필요 여부 확인

## 문서 참조 규칙

- **소스 코드**: `@src/components/Button.tsx`
- **도메인 컨텍스트**: `@docs/{domain}/_context/architecture.md`
- **같은 도메인**: 상대 경로 `./SPEC.md`
- **다른 도메인**: `@docs/{domain}/{feature}/PRD.md`
