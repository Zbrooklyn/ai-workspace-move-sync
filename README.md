# AI Workspace Move + Sync Toolkit (Codex CLI, Claude Code, Gemini CLI)

If you have ever moved your AI project folder and suddenly had half your setup break, this project is for you.

It gives you one setup command to repair the path wiring that commonly breaks after:

- moving folders (for example `Download -> Documents`)
- syncing to Dropbox or another machine
- opening the same workspace from a different absolute path

## What It Fixes

In one run, the toolkit repairs:

- Claude Code memory links in `~/.claude/projects/.../memory`
- workspace `.mcp.json` browser MCP script path (when present)
- Gemini MCP path in `~/.gemini/settings.json` (when present)
- Gemini trust entry in `~/.gemini/trustedFolders.json`

It also verifies Claude memory links so you can confirm the repair worked.

## Why People Use It

Most fixes online are tool-by-tool checklists.
This project handles Codex, Claude, and Gemini together so recovery is fast and repeatable.

## Quick Start

### Termux / Linux / macOS

```bash
cd /path/to/ai-workspace-move-sync
bash setup-workspace.sh /path/to/your/workspace
```

### Windows (PowerShell)

```powershell
cd C:\path\to\ai-workspace-move-sync
.\setup-workspace.ps1 -WorkspacePath "C:\path\to\your\workspace"
```

If you do not pass a workspace path, the script uses your current directory.

## Common Scenarios

1. You moved the workspace on the same device.
2. You synced the workspace to another computer (Dropbox/Git copy).
3. You added a new subproject and only memory links need repair.

Full step-by-step guide:
- `docs/MOVE_AND_SYNC_GUIDE.md`

## Included Files

- `setup-workspace.sh` - full setup for Termux/Linux/macOS
- `setup-workspace.ps1` - full setup for Windows
- `link-memory.sh` - memory-link-only repair for Termux/Linux/macOS
- `link-memory.ps1` - memory-link-only repair for Windows
- `docs/MOVE_AND_SYNC_GUIDE.md` - beginner-friendly scenario guide

## Notes by Tool

- **Codex CLI**: works best when your workspace path is stable and consistent.
- **Claude Code**: this script repairs the memory symlink targets to `workspace/.memory`.
- **Gemini CLI**: this script rewrites MCP/trusted-folder paths to the workspace's current location.

## Troubleshooting

- No Claude project directories found:
  open Claude once from the workspace root, then run setup again.
- MCP still broken:
  confirm `start-browser-mcp.sh` exists somewhere under the workspace.
- Windows symlink errors:
  run PowerShell as Administrator or enable Developer Mode.

## Search Terms

Codex CLI workspace migration, Claude Code memory symlink fix, Gemini CLI MCP path update, Dropbox AI workspace sync, AI workspace continuity.

## License

MIT
