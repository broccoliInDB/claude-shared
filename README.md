# claude-shared

팀과 프로젝트 간 공유하는 Claude Code 규칙, 스킬, 에이전트 시스템.

## 왜 만들었나

AI 코딩 도구를 팀에서 쓰면 사람마다 사용 방식이 다르고, 좋은 패턴이 발견되어도 공유가 안 됩니다.
claude-shared는 이 문제를 해결합니다:

- **일관성**: 팀 전체가 같은 규칙으로 AI를 사용
- **전파**: 한 명이 개선하면 모든 프로젝트에 즉시 반영
- **자가발전**: AI가 반복 패턴을 감지하고 규칙으로 승격 제안

## 빠른 시작

```bash
# 1. 글로벌 clone (머신당 1회)
git clone git@github.com:broccoliInDB/claude-shared.git ~/.claude-team

# 2. 프로젝트에서 연결
cd your-project
~/.claude-team/bin/link.sh

# 3. 프론트엔드/백엔드 모듈도 필요하면
~/.claude-team/bin/link.sh --modules frontend,backend,security
```

끝. Claude Code를 열면 규칙이 적용되어 있습니다.

## 구조

```
claude-shared/
├── core/              # 모든 프로젝트 공통
│   ├── rules/         #   AI 행동, 품질, 커밋, 테스트 규칙
│   ├── skills/        #   워크플로우 (commit, review, spec, plan...)
│   ├── agents/        #   코드리뷰어, 문서체커
│   ├── hooks/         #   커밋 강제, 자동 포맷
│   └── agent-memory/  #   자가학습 기록
│
├── modules/           # 프로젝트 유형별 선택
│   ├── frontend/      #   React, Next.js 규칙
│   ├── backend/       #   API, DB 규칙
│   ├── infrastructure/#   배포, CI/CD 규칙
│   └── security/      #   인증, 보안 규칙
│
├── templates/         # 새 프로젝트 참고용
│   ├── docs/          #   PRD, SPEC, PLAN 템플릿
│   └── project/       #   CLAUDE.md, settings.json 템플릿
│
├── bin/               # CLI 도구
│   └── link.sh        #   심링크 연결 스크립트
│
└── docs/              # 이 프로젝트 문서
    ├── history.md     #   탄생 배경과 설계 과정
    ├── architecture.md#   설계 결정과 근거
    └── roadmap.md     #   발전 방향
```

## 핵심 개념

### 심링크 기반 공유

프로젝트 git에 공유 파일을 넣지 않습니다. OS 심링크로 연결만 합니다.

```
~/.claude-team/core/rules/behavior.md     (실제 파일, 이 레포)
        ↓ symlink
project/.claude/rules/shared-behavior.md  (심링크, gitignored)
```

- 충돌 불가능 (프로젝트 git이 모르는 파일)
- drift 불가능 (복사가 아니라 같은 파일)
- 업데이트: `cd ~/.claude-team && git pull` → 모든 프로젝트에 즉시 반영

### 자가발전 루프

```
프로젝트 작업 → AI가 패턴 발견 → agent-memory에 기록
→ 2회 반복 감지 → /evolve로 PR 생성 → 팀 리뷰
→ 머지 → git pull → 모든 프로젝트에 전파
```

### core + modules

모든 프로젝트에 적용할 규칙은 `core/`에, 특정 유형에만 필요한 규칙은 `modules/`에.
프로젝트 고유 규칙은 프로젝트의 `.claude/rules/`에 직접 작성합니다.

## 프로젝트 고유 규칙 오버라이드

공유 규칙과 다른 컨벤션이 필요하면 프로젝트에 오버라이드 파일을 만듭니다:

```markdown
# .claude/rules/project-overrides.md

## code-style 예외
- 이 프로젝트는 탭을 사용합니다 (shared-code-style.md와 다름)
- 이유: 기존 코드베이스 통일
```

Claude Code는 `.claude/rules/`의 모든 `.md`를 읽으므로, 구체적인 프로젝트 규칙이 일반적인 공유 규칙보다 우선합니다.

## 업데이트

```bash
cd ~/.claude-team
git pull
```

모든 연결 프로젝트에 즉시 반영됩니다. sync 명령이나 재설치가 필요 없습니다.

## 기여

규칙 개선, 새 스킬 추가, 버그 수정 모두 PR로 받습니다.
자세한 내용은 [docs/architecture.md](docs/architecture.md)를 참고하세요.

## 라이선스

MIT
