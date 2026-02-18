#!/data/data/com.termux/files/usr/bin/bash
# Link Claude memory directories for a workspace to workspace/.memory.
# Usage:
#   bash link-memory.sh /path/to/workspace
#   bash link-memory.sh                 # uses current directory

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: bash link-memory.sh [WORKSPACE_PATH]

Links all matching ~/.claude/projects/*/memory directories for the workspace
into WORKSPACE_PATH/.memory.
USAGE
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

WORKSPACE_INPUT="${1:-$PWD}"
if [ ! -d "$WORKSPACE_INPUT" ]; then
  echo "Workspace path not found: $WORKSPACE_INPUT"
  exit 1
fi

WORKSPACE_DIR="$(cd "$WORKSPACE_INPUT" && pwd -P)"
SHARED_MEMORY="$WORKSPACE_DIR/.memory"
PROJECTS_DIR="$HOME/.claude/projects"

sanitize_path() {
  printf '%s' "$1" | sed 's#^/#-#; s#[/ :\\]#-#g; s#-\{2,\}#-#g'
}

PREFIX="$(sanitize_path "$WORKSPACE_DIR")"

if [ ! -d "$SHARED_MEMORY" ]; then
  echo "Shared memory directory not found: $SHARED_MEMORY"
  echo "Create $SHARED_MEMORY first, then rerun."
  exit 1
fi

if [ ! -d "$PROJECTS_DIR" ]; then
  echo "Claude projects directory not found: $PROJECTS_DIR"
  echo "Run Claude at least once, then rerun."
  exit 1
fi

linked=0
updated=0
skipped=0
found=0

for dir in "$PROJECTS_DIR/$PREFIX"*; do
  [ -d "$dir" ] || continue
  found=$((found + 1))
  mem="$dir/memory"

  if [ -L "$mem" ]; then
    target="$(readlink "$mem" 2>/dev/null || true)"
    if [ "$target" = "$SHARED_MEMORY" ]; then
      skipped=$((skipped + 1))
      continue
    fi

    rm -f "$mem"
    ln -s "$SHARED_MEMORY" "$mem"
    echo "Updated link: $(basename "$dir") -> .memory/"
    updated=$((updated + 1))
    continue
  fi

  if [ -d "$mem" ]; then
    if [ "$(ls -A "$mem" 2>/dev/null)" ]; then
      bak="${mem}.bak.$(date +%Y%m%d_%H%M%S)"
      echo "Backing up: $mem -> $bak"
      mv "$mem" "$bak"
    else
      rmdir "$mem"
    fi
  fi

  ln -s "$SHARED_MEMORY" "$mem"
  echo "Linked: $(basename "$dir") -> .memory/"
  linked=$((linked + 1))
done

if [ "$found" -eq 0 ]; then
  echo "No Claude project dirs found for this workspace yet."
  echo "Run Claude once from: $WORKSPACE_DIR"
  exit 0
fi

echo "Done. Linked: $linked, Updated: $updated, Already correct: $skipped"
