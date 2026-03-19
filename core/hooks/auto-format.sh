#!/bin/bash
# PostToolUse hook: 파일 수정 후 자동 포맷
# Edit/Write 도구 사용 후 프로젝트의 포맷터로 자동 포맷
#
# stdin: JSON { "tool_input": { "file_path": "..." } }
# exit 0: 항상 (포맷 실패해도 차단하지 않음)

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null)

# jq 없으면 grep fallback
if [ -z "$FILE" ]; then
  FILE=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"//;s/"$//')
fi

# 파일이 없거나 존재하지 않으면 스킵
if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  exit 0
fi

# 포맷 대상 확장자만
case "$FILE" in
  *.ts|*.tsx|*.js|*.jsx|*.json|*.md|*.css|*.html|*.py)
    # prettier가 있으면 사용, 없으면 스킵
    if command -v npx >/dev/null 2>&1 && npx prettier --version >/dev/null 2>&1; then
      npx prettier --write "$FILE" 2>/dev/null
    fi
    ;;
esac

exit 0
