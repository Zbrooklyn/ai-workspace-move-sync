# Move and Sync Guide for Codex CLI, Claude Code, and Gemini CLI

This guide is for the moments when your workspace path changes and things start failing quietly.

Use it after:

- moving your workspace (example: `Download -> Documents`)
- opening the same workspace on another computer
- syncing with Dropbox/Git and using a different local path

## Quick Recovery (Recommended)

Run the full setup once.

### Termux / Linux / macOS

```bash
cd /path/to/ai-workspace-move-sync
bash setup-workspace.sh /path/to/workspace
```

### Windows (PowerShell)

```powershell
cd C:\path\to\ai-workspace-move-sync
.\setup-workspace.ps1 -WorkspacePath "C:\path\to\workspace"
```

If you skip `WORKSPACE_PATH`, the script uses your current directory.

What this command does:

1. Relinks Claude memory directories to `workspace/.memory`
2. Updates workspace `.mcp.json` browser MCP path (if present)
3. Updates `~/.gemini/settings.json` browser MCP path (if present)
4. Updates `~/.gemini/trustedFolders.json`
5. Verifies Claude memory links

## Scenario 1: Moved Folder on the Same Device

Example: you moved `AiProjectsMaster` from `Download` to `Documents`.

1. Move the workspace to the new location.
2. Run the setup command with the new absolute path.
3. Reopen Codex/Claude/Gemini.
4. If prompted, rerun setup once more after opening Claude from the workspace root.

### Example (Termux / Linux / macOS)

```bash
bash setup-workspace.sh /new/path/to/AiProjectsMaster
```

### Example (Windows)

```powershell
.\setup-workspace.ps1 -WorkspacePath "C:\Users\you\Documents\AiProjectsMaster"
```

## Scenario 2: Synced to Another Computer (Dropbox/Git)

1. Let sync fully finish.
2. Confirm the workspace includes `.memory/` and project files.
3. Run setup on that computer using that computer's local path.
4. If Claude reports no matching project directories, open Claude once from workspace root and rerun setup.

### Example (Windows + Dropbox)

```powershell
.\setup-workspace.ps1 -WorkspacePath "C:\Users\you\Dropbox\AiProjectsMaster"
```

## Scenario 3: Only Claude Memory Is Broken

If MCP and trusted folder settings are already fine, run the memory-only script.

### Termux / Linux / macOS

```bash
bash link-memory.sh /path/to/workspace
```

### Windows

```powershell
.\link-memory.ps1 -WorkspacePath "C:\path\to\workspace"
```

## What Syncs vs What Is Local

Syncs with Git/Dropbox:

- Workspace files and code
- `.memory/*.md`
- These setup scripts and docs

Always local to each machine:

- `~/.claude/projects/.../memory` symlink targets
- `~/.gemini/settings.json`
- `~/.gemini/trustedFolders.json`

That is why setup must be run on each machine after move/sync.

## Safety Notes

When repairing Claude memory links, if a real `memory` directory already exists and has files, the scripts back it up first:

- Backup naming format: `memory.bak.YYYYMMDD_HHMMSS`

## Troubleshooting

### "Workspace path not found"

Use a real absolute path and verify the folder exists.

### "Shared memory directory not found"

Create `workspace/.memory` (or restore it from sync), then rerun.

### "No Claude project dirs found for this workspace yet"

Open Claude once from workspace root, then rerun setup.

### MCP path still looks wrong

Make sure `start-browser-mcp.sh` exists somewhere under the workspace.

### Windows symlink permission error

Run PowerShell as Administrator or enable Developer Mode.
