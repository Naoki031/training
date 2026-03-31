#!/bin/bash
# PostToolUse(Bash) — create sentinel file when lint runs successfully
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null)

if echo "$COMMAND" | grep -qE "lint|lint-fix"; then
  touch /tmp/claude-attendance-lint-ok
fi
exit 0
