# Move and Sync Guide (Beginner Friendly)

This guide covers 3 common cases:

1. Move workspace on the same device (for example Download -> Documents)
2. Sync workspace to another computer (Dropbox)
3. Add new subprojects and keep shared memory linked

## Quick Rule

After any move/sync, run setup once:

- Termux / Linux / macOS:

```bash
bash setup-workspace.sh /path/to/workspace
```

- Windows:

```powershell
.\setup-workspace.ps1 -WorkspacePath "C:\path\to\workspace"
```

## Scenario 1: Same Device Move

### Termux / Linux / macOS

1. Move your workspace folder.
2. Run setup:

```bash
cd /path/to/ai-workspace-move-sync
bash setup-workspace.sh /new/path/to/workspace
```

3. Verify:

```bash
ls -la ~/.claude/projects/*workspace*/* 2>/dev/null
```

## Scenario 2: Dropbox to Another Computer

### Windows

1. Wait for Dropbox sync to finish.
2. Run setup:

```powershell
cd C:\path\to\ai-workspace-move-sync
.\setup-workspace.ps1 -WorkspacePath "C:\Users\<you>\Dropbox\YourWorkspace"
```

3. If symlink errors appear, rerun in Administrator PowerShell or enable Developer Mode.

## Scenario 3: New Subproject Added Later

If memory is not shared in a new subproject, run linker only:

- Termux / Linux / macOS:

```bash
bash link-memory.sh /path/to/workspace
```

- Windows:

```powershell
.\link-memory.ps1 -WorkspacePath "C:\path\to\workspace"
```

## Troubleshooting

### "No Claude project dirs found for this workspace yet"

Open Claude once from the target workspace, then rerun setup.

### MCP path still wrong

Make sure `start-browser-mcp.sh` exists somewhere inside your workspace. Then rerun setup.

### Memory still not shared

Run the `link-memory` script directly and check output for backup/link errors.
