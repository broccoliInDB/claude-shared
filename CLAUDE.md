# claude-shared

AI 작업 규칙, 스킬, 에이전트를 팀과 프로젝트 간 공유하기 위한 독립 레포.

## 구조

```
claude-shared/
├── core/           # 모든 프로젝트에 적용되는 핵심 규칙/스킬
│   ├── rules/      # AI 행동 규칙
│   ├── skills/     # 워크플로우 스킬
│   ├── agents/     # 서브에이전트 정의
│   ├── hooks/      # 자동화 훅
│   └── agent-memory/
├── modules/        # 프로젝트 유형별 선택 모듈
│   ├── frontend/
│   ├── backend/
│   ├── infrastructure/
│   └── security/
├── templates/      # 새 프로젝트용 템플릿
│   ├── docs/       # PRD/SPEC/PLAN 템플릿
│   └── project/    # CLAUDE.md, settings.json 템플릿
├── bin/            # CLI 도구
└── docs/           # 이 레포 자체 문서
```

## 사용법

```bash
# 글로벌 clone (1회)
git clone <repo-url> ~/.claude-team

# 프로젝트에서 연결
~/.claude-team/bin/link.sh
~/.claude-team/bin/link.sh --modules frontend,backend
```

## 규칙

- core/ 파일 수정 시 모든 연결 프로젝트에 즉시 반영됨 (심링크)
- 프로젝트 고유 규칙은 프로젝트 `.claude/rules/`에 직접 작성
- 이 레포의 CLAUDE.md는 claude-shared 개발용 컨텍스트
