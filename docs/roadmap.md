# Roadmap — 발전 방향

## Phase 1: Foundation (현재)

초기 구조 구축. 세 프로젝트의 검증된 패턴을 통합.

- [x] 레포 생성 및 구조 설계
- [x] core/rules 통합 (side + hsmoa + dp-pipeline)
- [x] core/skills 통합 (side 스킬 + hsmoa 문서 스킬)
- [x] core/agents, hooks, agent-memory 이전
- [x] modules/ 분리 (frontend, backend, infrastructure, security)
- [x] templates/ 이전 (hsmoa PRD/SPEC/PLAN)
- [x] bin/link.sh CLI 도구
- [x] 문서 (README, history, architecture, roadmap)

## Phase 2: side + hsmoa-app 적용

실제 프로젝트에 연결하여 검증.

- [ ] side에서 기존 .claude/rules를 claude-shared 심링크로 교체
- [ ] side의 projkit에서 Claude 관련 템플릿 제거 (빌드 도구만 남김)
- [ ] hsmoa-app에 연결, 팀원 온보딩 테스트
- [ ] dp-data-pipeline에 연결
- [ ] 실사용 피드백 수집 및 반영

## Phase 3: 자가발전 시스템 고도화

- [ ] /evolve 스킬 실전 테스트 (패턴 감지 → PR 자동 생성)
- [ ] agent-memory 승격 기준 정교화 (2회? 3회? 프로젝트 수?)
- [ ] 팀 차원 학습 기록 (team-learnings.md) 구조 확립
- [ ] 규칙 효과 측정 (규칙 추가 전후 코드 품질 변화 추적)

## Phase 4: 모듈 확장

프로젝트 유형이 늘어남에 따라 모듈 추가.

- [ ] modules/mobile/ (React Native 규칙)
- [ ] modules/data-engineering/ (dp-pipeline의 airflow, pyspark 규칙)
- [ ] modules/python/ (Python 코드 스타일, 타입 힌트)
- [ ] modules/monorepo/ (pnpm workspace, turborepo 규칙)

## Phase 5: 회사 적용

- [ ] 회사 org에 fork 생성
- [ ] 회사 고유 모듈 추가 (modules/company-specific/)
- [ ] 팀 온보딩 가이드 작성
- [ ] fork 간 upstream sync 워크플로우 정립

## Phase 6: MCP + 도구 통합

- [ ] Serena MCP 통합 가이드 (심볼 단위 코드 탐색)
- [ ] Sequential Thinking 활용 패턴 (복잡한 판단 구조화)
- [ ] Playwright E2E + 스크린샷 자동 캡처 연동
- [ ] 추천 MCP 서버 목록 및 설정 템플릿

## Phase 7: 커뮤니티

- [ ] npm publish (설치형 CLI)
- [ ] 다른 팀/조직에서도 fork하여 사용할 수 있는 가이드
- [ ] 규칙/스킬 마켓플레이스 개념 검토

---

## 원칙

- 각 Phase는 이전 Phase가 안정화된 후 시작
- Phase 2를 빨리 끝내는 것이 가장 중요 (실사용 검증)
- 새 모듈/스킬 추가는 실제 필요가 발생했을 때만
- 과도한 추상화보다 실용적 해결 우선
