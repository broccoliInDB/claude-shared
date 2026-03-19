#!/bin/bash
# claude-shared 원라이너 설치 스크립트
#
# 사용법:
#   bash <(curl -sL https://raw.githubusercontent.com/broccoliInDB/claude-shared/main/bin/setup.sh)
#
# 하는 일:
#   1. ~/.claude-team에 clone (이미 있으면 pull)
#   2. 현재 프로젝트에 link (프로젝트 디렉토리에서 실행한 경우)
#   3. 프로젝트 타입 감지 → 모듈 추천

set -euo pipefail

REPO_URL="https://github.com/broccoliInDB/claude-shared.git"
INSTALL_DIR="$HOME/.claude-team"

# 색상
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}claude-shared${NC} setup"
echo "════════════════════════════"
echo ""

# --- Step 1: Clone or Update ---

if [ -d "$INSTALL_DIR" ]; then
  echo -e "${BLUE}[1/3]${NC} ~/.claude-team 이미 존재 → 업데이트 중..."
  git -C "$INSTALL_DIR" pull --quiet 2>/dev/null || echo -e "  ${YELLOW}pull 실패 (오프라인?). 기존 버전 사용.${NC}"
else
  echo -e "${BLUE}[1/3]${NC} ~/.claude-team 설치 중..."

  # SSH clone 시도, 실패하면 HTTPS
  if git clone --quiet "$REPO_URL" "$INSTALL_DIR" 2>/dev/null; then
    echo -e "  ${GREEN}완료${NC}"
  elif git clone --quiet "https://github.com/broccoliInDB/claude-shared.git" "$INSTALL_DIR" 2>/dev/null; then
    echo -e "  ${GREEN}완료${NC} (HTTPS)"
  else
    echo -e "  ${RED}실패${NC}: git clone이 안 됩니다."
    echo "  수동으로 실행하세요: git clone $REPO_URL ~/.claude-team"
    exit 1
  fi
fi

echo ""

# --- Step 2: 프로젝트 감지 ---

PROJECT_DIR="$(pwd)"

# .git이 있는지 확인 → 프로젝트 디렉토리인지 판단
if [ ! -d "$PROJECT_DIR/.git" ]; then
  echo -e "${BLUE}[2/3]${NC} 프로젝트 디렉토리가 아닙니다 (git 레포 아님)"
  echo "  프로젝트에서 연결하려면:"
  echo -e "  ${BOLD}cd your-project && ~/.claude-team/bin/link.sh${NC}"
  echo ""
  echo -e "${GREEN}설치 완료!${NC}"
  exit 0
fi

echo -e "${BLUE}[2/3]${NC} 프로젝트 감지: ${BOLD}$(basename "$PROJECT_DIR")${NC}"

# 프로젝트 타입 감지 → 모듈 추천
MODULES=""
DETECTED=""

# React / React Native / Next.js → frontend
if [ -f "package.json" ]; then
  if grep -qE '"react-native"|"expo"' package.json 2>/dev/null; then
    DETECTED="React Native"
    MODULES="frontend"
  elif grep -qE '"next"|"react"' package.json 2>/dev/null; then
    DETECTED="React/Next.js"
    MODULES="frontend"
  elif grep -qE '"vue"|"nuxt"' package.json 2>/dev/null; then
    DETECTED="Vue/Nuxt"
    MODULES="frontend"
  fi
fi

# API / DB 존재 → backend
if [ -d "src/api" ] || [ -d "api" ] || [ -d "src/server" ] || [ -f "prisma/schema.prisma" ] || grep -qE '"express"|"fastify"|"supabase"|"prisma"' package.json 2>/dev/null; then
  if [ -n "$MODULES" ]; then
    MODULES="$MODULES,backend"
  else
    MODULES="backend"
  fi
  DETECTED="${DETECTED:+$DETECTED + }Backend"
fi

# Python 프로젝트
if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ] || [ -f "setup.py" ]; then
  DETECTED="${DETECTED:+$DETECTED + }Python"
fi

# CI/CD 존재 → infrastructure
if [ -d ".github/workflows" ] || [ -f "vercel.json" ] || [ -f "netlify.toml" ] || [ -f "Dockerfile" ]; then
  if [ -n "$MODULES" ]; then
    MODULES="$MODULES,infrastructure"
  else
    MODULES="infrastructure"
  fi
fi

# 인증 존재 → security
if grep -rqE 'supabase.*auth|next-auth|passport|jsonwebtoken|bcrypt' package.json 2>/dev/null || [ -d "src/auth" ]; then
  if [ -n "$MODULES" ]; then
    MODULES="$MODULES,security"
  else
    MODULES="security"
  fi
fi

if [ -n "$DETECTED" ]; then
  echo -e "  감지: ${GREEN}$DETECTED${NC}"
fi

if [ -n "$MODULES" ]; then
  echo -e "  추천 모듈: ${GREEN}$MODULES${NC}"
fi

echo ""

# --- Step 3: Link ---

echo -e "${BLUE}[3/3]${NC} 프로젝트에 연결 중..."
echo ""

if [ -n "$MODULES" ]; then
  "$INSTALL_DIR/bin/link.sh" --modules "$MODULES"
else
  "$INSTALL_DIR/bin/link.sh"
fi

echo ""
echo "════════════════════════════"
echo ""
echo -e "${GREEN}${BOLD}설치 완료!${NC}"
echo ""
echo -e "  ${BOLD}주요 스킬:${NC}"
echo "  /p-commit    품질 게이트 + 코드리뷰 + 커밋"
echo "  /p-review    독립 코드리뷰"
echo "  /p-spec      기능 스펙(PRD) 작성"
echo "  /p-plan      작업 플랜 작성"
echo "  /p-help      전체 스킬 목록"
echo "  /evolve      반복 패턴 → 팀 규칙 승격"
echo ""
echo -e "  ${BOLD}다음 단계:${NC}"
echo "  1. Claude Code를 열면 규칙이 자동 적용됩니다"
echo "  2. 개인 규칙 추가: .claude/rules/my-rules.md 생성"
echo "  3. 규칙 업데이트: cd ~/.claude-team && git pull"
echo ""
