#!/bin/bash
# claude-shared link tool
# 프로젝트의 .claude/ 디렉토리에 claude-shared의 심링크를 생성합니다.
#
# 사용법:
#   ~/.claude-team/bin/link.sh                          # core만 연결
#   ~/.claude-team/bin/link.sh --modules frontend,backend  # core + 모듈 연결
#   ~/.claude-team/bin/link.sh --unlink                 # 심링크 제거
#   ~/.claude-team/bin/link.sh --status                 # 연결 상태 확인

set -euo pipefail

# claude-shared 루트 경로 (이 스크립트의 상위 디렉토리)
SHARED_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ROOT="$(pwd)"
CLAUDE_DIR="$PROJECT_ROOT/.claude"
PREFIX="shared-"

# 색상
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- 함수 ---

print_header() {
  echo -e "${BLUE}claude-shared${NC} link tool"
  echo "─────────────────────────────"
}

ensure_dir() {
  mkdir -p "$1"
}

create_symlink() {
  local source="$1"
  local target="$2"

  if [ -L "$target" ]; then
    # 이미 심링크 → 경로가 같으면 스킵, 다르면 재생성
    local current
    current=$(readlink "$target")
    if [ "$current" = "$source" ]; then
      return 0
    fi
    rm -f "$target"
  elif [ -e "$target" ]; then
    echo -e "  ${YELLOW}skip${NC} $(basename "$target") (실제 파일이 이미 존재)"
    return 0
  fi

  ln -sf "$source" "$target"
  echo -e "  ${GREEN}link${NC} $(basename "$target")"
}

link_rules() {
  local source_dir="$1"
  local target_dir="$CLAUDE_DIR/rules"
  ensure_dir "$target_dir"

  for file in "$source_dir"/*.md; do
    [ -f "$file" ] || continue
    local name
    name=$(basename "$file")
    create_symlink "$file" "$target_dir/${PREFIX}${name}"
  done
}

link_skills() {
  local source_dir="$1"
  local target_dir="$CLAUDE_DIR/skills"
  ensure_dir "$target_dir"

  for skill_dir in "$source_dir"/*/; do
    [ -d "$skill_dir" ] || continue
    local name
    name=$(basename "$skill_dir")
    local target="$target_dir/${PREFIX}${name}"
    ensure_dir "$target"

    for file in "$skill_dir"*; do
      [ -f "$file" ] || continue
      create_symlink "$file" "$target/$(basename "$file")"
    done
  done
}

link_agents() {
  local source_dir="$1"
  local target_dir="$CLAUDE_DIR/agents"
  ensure_dir "$target_dir"

  for file in "$source_dir"/*.md; do
    [ -f "$file" ] || continue
    local name
    name=$(basename "$file")
    create_symlink "$file" "$target_dir/${PREFIX}${name}"
  done
}

link_hooks() {
  local source_dir="$1"
  local target_dir="$CLAUDE_DIR/hooks"
  ensure_dir "$target_dir"

  for file in "$source_dir"/*.sh; do
    [ -f "$file" ] || continue
    local name
    name=$(basename "$file")
    create_symlink "$file" "$target_dir/${PREFIX}${name}"
  done
}

setup_agent_memory() {
  local source_dir="$SHARED_ROOT/core/agent-memory"
  local target_dir="$CLAUDE_DIR/agent-memory"

  # agent-memory는 심링크가 아니라 복사 (프로젝트별로 다른 내용이 축적되므로)
  for mem_dir in "$source_dir"/*/; do
    [ -d "$mem_dir" ] || continue
    local name
    name=$(basename "$mem_dir")
    local target="$target_dir/$name"

    if [ -d "$target" ]; then
      echo -e "  ${YELLOW}skip${NC} agent-memory/$name (이미 존재)"
      continue
    fi

    ensure_dir "$target"
    cp "$mem_dir"* "$target/" 2>/dev/null || true
    echo -e "  ${GREEN}copy${NC} agent-memory/$name (초기 템플릿)"
  done
}

update_gitignore() {
  local gitignore="$PROJECT_ROOT/.gitignore"
  local patterns=(
    "# claude-shared symlinks"
    ".claude/rules/shared-*"
    ".claude/skills/shared-*"
    ".claude/agents/shared-*"
    ".claude/hooks/shared-*"
  )

  # .gitignore가 없으면 생성
  [ -f "$gitignore" ] || touch "$gitignore"

  # 이미 패턴이 있는지 확인
  if grep -q "claude-shared symlinks" "$gitignore" 2>/dev/null; then
    echo -e "  ${YELLOW}skip${NC} .gitignore (이미 설정됨)"
    return 0
  fi

  echo "" >> "$gitignore"
  for pattern in "${patterns[@]}"; do
    echo "$pattern" >> "$gitignore"
  done
  echo -e "  ${GREEN}update${NC} .gitignore"
}

unlink_all() {
  echo -e "${YELLOW}Removing claude-shared symlinks...${NC}"

  find "$CLAUDE_DIR" -type l -name "${PREFIX}*" -delete 2>/dev/null || true

  # 빈 shared- 디렉토리 정리
  find "$CLAUDE_DIR/skills" -type d -name "${PREFIX}*" -empty -delete 2>/dev/null || true

  echo -e "${GREEN}Done.${NC} 심링크가 제거되었습니다."
  echo "agent-memory/는 프로젝트 데이터이므로 유지합니다."
}

show_status() {
  echo -e "${BLUE}연결 상태${NC}"
  echo ""

  local count=0
  if [ -d "$CLAUDE_DIR" ]; then
    while IFS= read -r -d '' link; do
      local target
      target=$(readlink "$link")
      local name
      name=$(basename "$link")
      if [ -e "$target" ]; then
        echo -e "  ${GREEN}✓${NC} $name → $target"
      else
        echo -e "  ${RED}✗${NC} $name → $target (broken)"
      fi
      ((count++))
    done < <(find "$CLAUDE_DIR" -type l -name "${PREFIX}*" -print0 2>/dev/null)
  fi

  if [ "$count" -eq 0 ]; then
    echo "  연결된 심링크가 없습니다."
    echo "  실행: ~/.claude-team/bin/link.sh"
  else
    echo ""
    echo "  총 ${count}개 심링크 연결됨"
  fi
}

# --- 메인 ---

print_header

# 인자 파싱
MODULES=""
ACTION="link"

while [[ $# -gt 0 ]]; do
  case $1 in
    --modules)
      MODULES="$2"
      shift 2
      ;;
    --unlink)
      ACTION="unlink"
      shift
      ;;
    --status)
      ACTION="status"
      shift
      ;;
    --help|-h)
      echo ""
      echo "사용법:"
      echo "  link.sh                          core만 연결"
      echo "  link.sh --modules frontend,backend  core + 모듈 연결"
      echo "  link.sh --unlink                 심링크 제거"
      echo "  link.sh --status                 연결 상태 확인"
      echo ""
      echo "사용 가능한 모듈:"
      for mod_dir in "$SHARED_ROOT"/modules/*/; do
        [ -d "$mod_dir" ] && echo "  - $(basename "$mod_dir")"
      done
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

case $ACTION in
  unlink)
    unlink_all
    exit 0
    ;;
  status)
    show_status
    exit 0
    ;;
esac

# claude-shared 존재 확인
if [ ! -d "$SHARED_ROOT/core" ]; then
  echo -e "${RED}Error: claude-shared를 찾을 수 없습니다.${NC}"
  echo "먼저 clone하세요: git clone <repo> ~/.claude-team"
  exit 1
fi

echo ""
echo -e "${GREEN}Core 연결 중...${NC}"

# Core 연결
echo "rules:"
link_rules "$SHARED_ROOT/core/rules"

echo "skills:"
link_skills "$SHARED_ROOT/core/skills"

echo "agents:"
link_agents "$SHARED_ROOT/core/agents"

echo "hooks:"
link_hooks "$SHARED_ROOT/core/hooks"

echo "agent-memory:"
setup_agent_memory

# Modules 연결
if [ -n "$MODULES" ]; then
  echo ""
  echo -e "${GREEN}Modules 연결 중...${NC}"

  IFS=',' read -ra MOD_LIST <<< "$MODULES"
  for mod in "${MOD_LIST[@]}"; do
    mod=$(echo "$mod" | xargs) # trim whitespace
    local_mod_dir="$SHARED_ROOT/modules/$mod"

    if [ ! -d "$local_mod_dir" ]; then
      echo -e "  ${RED}error${NC} module '$mod' 없음"
      continue
    fi

    echo "$mod:"
    # 모듈 내 rules 연결
    if [ -d "$local_mod_dir/rules" ]; then
      link_rules "$local_mod_dir/rules"
    fi
    # 모듈 내 skills 연결 (있으면)
    if [ -d "$local_mod_dir/skills" ]; then
      link_skills "$local_mod_dir/skills"
    fi
  done
fi

# .gitignore 업데이트
echo ""
echo "gitignore:"
update_gitignore

echo ""
echo -e "${GREEN}완료!${NC} Claude Code를 열면 규칙이 적용됩니다."
echo ""
echo "업데이트: cd ~/.claude-team && git pull"
echo "상태 확인: ~/.claude-team/bin/link.sh --status"
