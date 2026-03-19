#!/bin/bash
# PreToolUse hook: git commit 직접 사용 차단
# /p-commit 스킬을 통해서만 커밋하도록 강제
#
# 마커 파일 방식:
#   /p-commit 리뷰 통과 → .claude/.commit-approved 생성
#   Hook: git commit 감지 → 마커 있으면 허용 + 삭제, 없으면 차단
#
# stdin: JSON { "tool_input": { "command": "..." } }
# exit 0: 허용
# exit 2: 차단 (stderr가 Claude에게 전달됨)

MARKER_FILE=".claude/.commit-approved"

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null)

# jq 없으면 grep fallback
if [ -z "$COMMAND" ]; then
  COMMAND=$(echo "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"//;s/"$//')
fi

# git commit 패턴 감지
if echo "$COMMAND" | grep -qE '^\s*git\s+commit'; then
  # 마커 파일 존재 → /p-commit 파이프라인에서 호출됨 → 허용
  if [ -f "$MARKER_FILE" ]; then
    rm -f "$MARKER_FILE"
    exit 0
  fi

  echo "직접 git commit은 차단됩니다. /p-commit 스킬을 사용하세요." >&2
  echo "" >&2
  echo "이유: 리뷰 없는 커밋을 구조적으로 방지하기 위한 Hook입니다." >&2
  echo "우회가 필요한 경우 사용자에게 확인하세요." >&2
  exit 2
fi

exit 0
