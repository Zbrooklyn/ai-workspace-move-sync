# AI Workspace Move + Sync Toolkit

One-command setup for moving AI coding workspaces across folders/devices while keeping shared memory working.

This toolkit is designed for Claude Code and Gemini CLI users who keep project memory in a workspace folder (for example `.memory/`) and need to rewire local machine paths after a move or Dropbox sync.

## What It Solves

After moving a workspace, these usually break:

- Claude memory symlinks under `~/.claude/projects/.../memory`
- MCP script paths in `.mcp.json`
- Gemini MCP paths in `~/.gemini/settings.json`
- Trusted folder paths in `~/.gemini/trustedFolders.json`

This project fixes those automatically.

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

## Files

- `setup-workspace.sh` / `setup-workspace.ps1` = full one-command setup
- `link-memory.sh` / `link-memory.ps1` = memory symlink only
- `docs/MOVE_AND_SYNC_GUIDE.md` = beginner step-by-step guide

## Detailed Guide

Use: `docs/MOVE_AND_SYNC_GUIDE.md`

## Notes

- Run once per device after a move/sync.
- If Claude project dirs do not exist yet, open Claude from the workspace once, then rerun.
- On Windows, symlink creation may require Administrator PowerShell or Developer Mode.

## License

MIT
