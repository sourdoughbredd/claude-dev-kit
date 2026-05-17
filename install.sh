#!/usr/bin/env bash
# Claude Development Kit — installer
# Copies the kit's slash commands into ~/.claude/commands/ so they're available
# in every Claude Code session on this machine.
#
# Idempotent: re-run after `git pull` to update. Existing files of the same
# name are backed up to ~/.claude/commands/.cdk-backup-<timestamp>/ before
# being overwritten.

set -euo pipefail

# Resolve the kit's commands/ directory relative to this script
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
KIT_COMMANDS="$SCRIPT_DIR/commands"
TARGET_DIR="$HOME/.claude/commands"
VERSION="$(cat "$SCRIPT_DIR/VERSION")"

if [ ! -d "$KIT_COMMANDS" ]; then
  echo "Error: $KIT_COMMANDS does not exist. Run this script from inside the claude-dev-kit repo." >&2
  exit 1
fi

# Ensure target exists
mkdir -p "$TARGET_DIR"

echo "Claude Development Kit v$VERSION"
echo "Target: $TARGET_DIR"
echo ""

# List of kit commands we manage. Hardcoded so uninstall.sh can mirror it exactly.
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

# Check what needs backing up
BACKUP_DIR=""
NEEDS_BACKUP=0
for f in "${KIT_FILES[@]}"; do
  if [ -f "$TARGET_DIR/$f" ]; then
    NEEDS_BACKUP=1
    break
  fi
done

if [ "$NEEDS_BACKUP" -eq 1 ]; then
  BACKUP_DIR="$TARGET_DIR/.cdk-backup-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$BACKUP_DIR"
  echo "Backing up existing commands to:"
  echo "  $BACKUP_DIR"
  for f in "${KIT_FILES[@]}"; do
    if [ -f "$TARGET_DIR/$f" ]; then
      cp "$TARGET_DIR/$f" "$BACKUP_DIR/$f"
    fi
  done
  echo ""
fi

echo "Installing ${#KIT_FILES[@]} commands:"
for f in "${KIT_FILES[@]}"; do
  if [ ! -f "$KIT_COMMANDS/$f" ]; then
    echo "  ✗ $f (missing in kit; skipping)"
    continue
  fi
  cp "$KIT_COMMANDS/$f" "$TARGET_DIR/$f"
  echo "  ✓ $f"
done

echo ""
echo "Done. Run /plan-project in any Claude Code session to scaffold a new project,"
echo "or /start-next-chunk to resume work on an existing one."
