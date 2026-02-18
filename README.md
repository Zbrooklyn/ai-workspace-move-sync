# AI Workspace Continuity Engine for Codex, Claude Code, and Gemini CLI

A high-impact migration toolkit for **OpenAI Codex CLI**, **Anthropic Claude Code**, and **Google Gemini CLI**.

Move your workspace anywhere, run one command, and recover critical local wiring fast: memory links, MCP paths, and trusted-folder paths.

## Why This Feels New

Most migration fixes are tool-by-tool and manual.
This project acts as a single continuity layer across three major AI coding CLIs.

Result: after a folder move or device sync, your setup is recoverable in minutes instead of a long checklist.

## What Makes It Valuable

- One setup flow for Codex + Claude + Gemini environments
- Cross-platform scripts: Termux/Linux/macOS + Windows PowerShell
- Practical fix for real breakpoints after moves/syncs
- Beginner-friendly documentation for non-technical users

## Search Keywords

Codex CLI workspace migration, Claude Code memory symlink fix, Gemini CLI MCP path update, AI coding assistant setup after folder move, Termux Claude Code setup, Dropbox AI project sync, AI workspace continuity.

## Before vs After

Before:
- AI tools point to stale paths
- Claude memory stops syncing across subprojects
- Gemini MCP and trust settings break after relocation
- Multi-device setup becomes fragile

After:
- Workspace paths rewired with one command
- Claude shared memory links repaired
- Gemini MCP/trusted-folder paths updated
- Codex/Claude/Gemini workflows recover quickly

## What This Toolkit Fixes

After a workspace move, these are commonly broken:

- Claude Code memory links under `~/.claude/projects/.../memory`
- MCP script paths in workspace `.mcp.json`
- Gemini MCP paths in `~/.gemini/settings.json`
- Gemini trusted folder paths in `~/.gemini/trustedFolders.json`

This toolkit repairs those in one run.

## Who This Is For

- Developers using **Codex CLI**, **Claude Code**, or **Gemini CLI**
- Teams sharing AI project folders via Dropbox/Git
- Users running AI coding workflows across multiple devices
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

- **Codex CLI**: path continuity improves project stability after moves.
- **Claude Code**: memory symlinks are repaired to `workspace/.memory`.
- **Gemini CLI**: MCP and trusted-folder paths are rewritten to the current workspace location.

## Troubleshooting

- If setup says no Claude project dirs exist, open Claude once from the workspace and rerun.
- If MCP remains broken, confirm `start-browser-mcp.sh` exists in the workspace.
- If Windows symlink creation fails, run PowerShell as Administrator or enable Developer Mode.

## License

MIT
