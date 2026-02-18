# Codex + Claude Code + Gemini CLI Workspace Move/Sync Toolkit

One-command migration setup for AI coding workspaces using **OpenAI Codex CLI**, **Anthropic Claude Code**, and **Google Gemini CLI**.

If you move a workspace folder (for example `Download -> Documents`) or sync it to another machine (Dropbox, external drive, git clone), this toolkit rewires local paths so your AI CLI setup keeps working.

## Search Keywords

Codex CLI workspace migration, Claude Code memory symlink fix, Gemini CLI MCP path update, AI coding assistant setup after folder move, Termux Claude Code setup, Dropbox AI project sync.

## What This Toolkit Fixes

After a workspace move, these are commonly broken:

- Claude Code memory links under `~/.claude/projects/.../memory`
- MCP script paths in workspace `.mcp.json`
- Gemini MCP paths in `~/.gemini/settings.json`
- Gemini trusted folder paths in `~/.gemini/trustedFolders.json`

This project repairs those in one run.

## Who This Is For

- Developers using **Codex CLI**, **Claude Code**, or **Gemini CLI**
- Users running AI coding workflows across multiple devices
- Teams sharing AI project folders via Dropbox/Git
- Termux users on Android who move project folders often

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

## Typical Scenarios

1. Move local workspace to a different folder.
2. Open the same workspace on a second machine.
3. Add a new subproject and restore shared memory links.

Full walkthrough: `docs/MOVE_AND_SYNC_GUIDE.md`

## Included Files

- `setup-workspace.sh` = full setup (Termux/Linux/macOS)
- `setup-workspace.ps1` = full setup (Windows)
- `link-memory.sh` = memory-link-only repair (Termux/Linux/macOS)
- `link-memory.ps1` = memory-link-only repair (Windows)
- `docs/MOVE_AND_SYNC_GUIDE.md` = beginner-friendly guide

## Codex / Claude / Gemini Notes

- **Codex CLI**: no special config needed here, but your workspace paths stay consistent after a move.
- **Claude Code**: memory symlinks are repaired to `workspace/.memory`.
- **Gemini CLI**: MCP/trusted-folder paths are updated to the new workspace location.

## Troubleshooting

- If setup says no Claude project dirs exist, open Claude once from the workspace and rerun.
- If MCP remains broken, confirm `start-browser-mcp.sh` exists in the workspace.
- If Windows symlink creation fails, run PowerShell as Administrator or enable Developer Mode.

## License

MIT
