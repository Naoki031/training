#!/bin/bash
# Stop hook — enforce lint verification before finishing if source files were modified
INPUT=$(cat)

# Guard: prevent infinite loop if hook already blocked once this turn
STOP_ACTIVE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('stop_hook_active', False))" 2>/dev/null)
if [ "$STOP_ACTIVE" = "True" ]; then
  exit 0
fi

# If lint sentinel exists, lint was already run — allow stop
if [ -f /tmp/claude-attendance-lint-ok ]; then
  exit 0
fi

# Check if any .ts or .vue files differ from HEAD (modified but not committed)
cd /Users/trucnguyen/Documents/projects/training
MODIFIED=$(git diff --name-only HEAD 2>/dev/null | grep -E "\.(ts|vue)$" | head -5)
STAGED=$(git diff --name-only --cached 2>/dev/null | grep -E "\.(ts|vue)$" | head -5)
UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | grep -E "\.(ts|vue)$" | grep "^sources/" | head -3)
ALL_MODIFIED="${MODIFIED}${STAGED}${UNTRACKED}"

if [ -n "$ALL_MODIFIED" ]; then
  printf '{"decision":"block","reason":"TypeScript/Vue files were modified but lint has not run. Execute: make api-lint-fix && make client-lint-fix — then I will finish."}'
  exit 0
fi

exit 0
