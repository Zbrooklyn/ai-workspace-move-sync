# Codex + Claude Code + Gemini CLI Move and Sync Guide (Beginner Friendly)

This is the practical playbook for restoring AI workspace continuity after folder moves and device syncs.

Supported workflows:

1. **OpenAI Codex CLI** workspace continuity
2. **Anthropic Claude Code** memory-link repair
3. **Google Gemini CLI** MCP/trust path repair

## Why This Guide Matters

When a workspace path changes, AI tools often fail in silent and frustrating ways.
This guide gives you a fast recovery path with copy-paste commands.

## When To Use This

Use this guide when:

- You move a project folder (example: `Download -> Documents`)
- You open the workspace on a second machine (Dropbox/Git copy)
- AI tools stop finding memory, MCP scripts, or trusted folders

## One Command Rule

Run setup once after any move/sync.

### Termux / Linux / macOS

```bash
bash setup-workspace.sh /path/to/workspace
```

### Windows (PowerShell)

```powershell
.\setup-workspace.ps1 -WorkspacePath "C:\path\to\workspace"
```

## Scenario 1: Move Workspace On The Same Device

### Steps (Termux / Linux / macOS)

1. Move workspace to the new folder.
2. Run:

```bash
cd /path/to/ai-workspace-move-sync
bash setup-workspace.sh /new/path/to/workspace
```

3. If prompted, restart CLI sessions.

### Expected Result

- Claude memory links point to the new `workspace/.memory`
- Gemini MCP/trust paths reflect the new location
- Codex/Claude/Gemini sessions run from the new path cleanly

## Scenario 2: Dropbox Sync To Another Computer

### Steps (Windows)

1. Wait for Dropbox to finish syncing.
2. Run:

```powershell
cd C:\path\to\ai-workspace-move-sync
.\setup-workspace.ps1 -WorkspacePath "C:\Users\<you>\Dropbox\YourWorkspace"
```

3. If symlink permission errors occur, rerun in Administrator PowerShell or enable Developer Mode.

### Expected Result

- New machine has correct local path wiring
- Claude shared memory works
- Gemini MCP/trust entries target the local Dropbox path

## Scenario 3: New Subproject Added Later

If only memory linking is broken for a new subproject, use the linker only.

### Termux / Linux / macOS

```bash
bash link-memory.sh /path/to/workspace
```

### Windows

```powershell
.\link-memory.ps1 -WorkspacePath "C:\path\to\workspace"
```

## What Syncs vs What Is Local

### Syncs with Git/Dropbox

- Workspace files and code
- `.memory/*.md`
- Workspace docs and scripts

### Device-Local (rewired by this toolkit)

- `~/.claude/projects/.../memory` symlinks
- `~/.gemini/settings.json` path entries
- `~/.gemini/trustedFolders.json` path entries

## Tool-Specific Notes

### Codex CLI

Codex usually works once workspace paths are consistent. This toolkit helps keep path-based project continuity stable after folder moves.

### Claude Code

The most common issue is broken or stale memory links in `~/.claude/projects/.../memory`.
This toolkit repairs those links to `workspace/.memory`.

### Gemini CLI

The most common issue is old MCP/trusted paths pointing to the previous folder.
This toolkit rewrites those paths to the current workspace location.

## Troubleshooting

### "No Claude project dirs found for this workspace yet"

Open Claude once from the workspace root, then rerun setup.

### MCP path still wrong

Check that `start-browser-mcp.sh` exists in the workspace, then rerun setup.

### Memory still not shared

Run `link-memory` directly and review output for backup/symlink errors.
