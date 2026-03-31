#!/bin/bash
# SessionStart hook — inject git context so Claude doesn't waste a tool call on git status
cd /Users/trucnguyen/Documents/projects/training

BRANCH=$(git branch --show-current 2>/dev/null)
LAST_COMMIT=$(git log --oneline -1 2>/dev/null)
MODIFIED=$(git status --short 2>/dev/null | grep -E "\.(ts|vue|json)$" | head -10)

echo "### Auto-loaded Git Context"
echo "Branch: ${BRANCH:-unknown}"
echo "Last commit: ${LAST_COMMIT:-none}"
if [ -n "$MODIFIED" ]; then
  echo "Uncommitted changes:"
  echo "$MODIFIED"
else
  echo "Working tree: clean"
fi
