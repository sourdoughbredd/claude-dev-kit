#!/usr/bin/env bash
# Claude Development Kit — uninstaller
# Removes only the 9 known kit commands from ~/.claude/commands/.
# Leaves backups (and any other files in ~/.claude/commands/) alone.

set -euo pipefail

TARGET_DIR="$HOME/.claude/commands"

if [ ! -d "$TARGET_DIR" ]; then
  echo "Nothing to do: $TARGET_DIR does not exist."
  exit 0
fi

KIT_FILES=(
  "plan-project.md"
  "start-next-chunk.md"
  "finish-chunk.md"
  "status.md"
  "log-decision.md"
  "log-note.md"
  "log-issue.md"
  "audit-plan.md"
  "add-chunk.md"
)

echo "Removing kit commands from $TARGET_DIR:"
REMOVED=0
for f in "${KIT_FILES[@]}"; do
  if [ -f "$TARGET_DIR/$f" ]; then
    rm "$TARGET_DIR/$f"
    echo "  ✓ $f"
    REMOVED=$((REMOVED + 1))
  fi
done

echo ""
if [ "$REMOVED" -eq 0 ]; then
  echo "No kit commands were found in $TARGET_DIR. Nothing removed."
else
  echo "Removed $REMOVED command(s)."
  echo "Backups (if any) remain in $TARGET_DIR/.cdk-backup-*/"
fi
