#!/data/data/com.termux/files/usr/bin/bash
# One-command setup after moving/syncing a workspace.
# Usage:
#   bash setup-workspace.sh /path/to/workspace
#   bash setup-workspace.sh                  # uses current directory

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: bash setup-workspace.sh [WORKSPACE_PATH]

Runs migration wiring for a workspace:
- relinks Claude memory to WORKSPACE_PATH/.memory
- updates .mcp.json browser path (if file and MCP script exist)
- updates ~/.gemini/settings.json browser path (if file and MCP script exist)
- adds WORKSPACE_PATH to ~/.gemini/trustedFolders.json
- verifies memory symlinks
USAGE
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
WORKSPACE_INPUT="${1:-$PWD}"

if [ ! -d "$WORKSPACE_INPUT" ]; then
  echo "Workspace path not found: $WORKSPACE_INPUT"
  exit 1
fi

WORKSPACE_DIR="$(cd "$WORKSPACE_INPUT" && pwd -P)"
WORKSPACE_NAME="$(basename "$WORKSPACE_DIR")"
PROJECT_MCP="$WORKSPACE_DIR/.mcp.json"
GEMINI_SETTINGS="$HOME/.gemini/settings.json"
GEMINI_TRUST="$HOME/.gemini/trustedFolders.json"

sanitize_path() {
  printf '%s' "$1" | sed 's#^/#-#; s#[/ :\\]#-#g; s#-\{2,\}#-#g'
}

find_mcp_script() {
  local preferred
  local found

  preferred="$WORKSPACE_DIR/projects/job_postings/upwork_mcp/start-browser-mcp.sh"
  if [ -f "$preferred" ]; then
    printf '%s\n' "$preferred"
    return 0
  fi

  found="$(find "$WORKSPACE_DIR" -maxdepth 8 -type f -name 'start-browser-mcp.sh' 2>/dev/null | head -n 1 || true)"
  printf '%s\n' "$found"
}

MCP_SCRIPT="$(find_mcp_script)"
PREFIX="$(sanitize_path "$WORKSPACE_DIR")"

echo "[1/5] Relinking Claude memory directories..."
bash "$SCRIPT_DIR/link-memory.sh" "$WORKSPACE_DIR"

echo "[2/5] Updating project MCP config (if possible)..."
if [ -f "$PROJECT_MCP" ] && [ -n "$MCP_SCRIPT" ]; then
  python3 - "$PROJECT_MCP" "$MCP_SCRIPT" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
target = sys.argv[2]

try:
    data = json.loads(path.read_text() or "{}")
except json.JSONDecodeError:
    data = {}

servers = data.setdefault("mcpServers", {})
browser = servers.setdefault("browser", {})
browser["command"] = "bash"
browser["args"] = [target]

path.write_text(json.dumps(data, indent=2) + "\n")
print(f"Updated: {path}")
PY
elif [ -f "$PROJECT_MCP" ]; then
  echo "Skipped: .mcp.json exists but no start-browser-mcp.sh was found under workspace."
else
  echo "Skipped: $PROJECT_MCP not found."
fi

echo "[3/5] Updating Gemini MCP config (if possible)..."
if [ -f "$GEMINI_SETTINGS" ] && [ -n "$MCP_SCRIPT" ]; then
  python3 - "$GEMINI_SETTINGS" "$MCP_SCRIPT" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
target = sys.argv[2]

try:
    data = json.loads(path.read_text() or "{}")
except json.JSONDecodeError:
    data = {}

servers = data.setdefault("mcpServers", {})
browser = servers.setdefault("browser", {})
browser["command"] = "bash"
browser["args"] = [target]

path.write_text(json.dumps(data, indent=2) + "\n")
print(f"Updated: {path}")
PY
elif [ -f "$GEMINI_SETTINGS" ]; then
  echo "Skipped: $GEMINI_SETTINGS exists but no start-browser-mcp.sh was found under workspace."
else
  echo "Skipped: $GEMINI_SETTINGS not found."
fi

echo "[4/5] Updating Gemini trusted folders..."
python3 - "$GEMINI_TRUST" "$WORKSPACE_DIR" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
workspace = sys.argv[2]
workspace_real = pathlib.Path(workspace).resolve()

data = {}
if path.exists():
    try:
        loaded = json.loads(path.read_text() or "{}")
        if isinstance(loaded, dict):
            data = loaded
    except json.JSONDecodeError:
        data = {}

for key in list(data.keys()):
    try:
        if pathlib.Path(key).expanduser().resolve() == workspace_real and key != workspace:
            data.pop(key, None)
    except Exception:
        continue

data[workspace] = "TRUST_FOLDER"
path.parent.mkdir(parents=True, exist_ok=True)
path.write_text(json.dumps(data, indent=2) + "\n")
print(f"Updated: {path}")
PY

echo "[5/5] Verifying memory links..."
ls -la "$HOME/.claude/projects/$PREFIX"*/memory 2>/dev/null || \
  echo "No matching Claude project entries yet. Start Claude in $WORKSPACE_NAME and rerun."

echo ""
echo "Workspace setup complete for: $WORKSPACE_DIR"
