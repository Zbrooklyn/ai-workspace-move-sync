# Links Claude memory directories for a workspace to workspace\.memory.
# Usage:
#   .\link-memory.ps1 -WorkspacePath "C:\path\to\workspace"
#   .\link-memory.ps1
#   .\link-memory.ps1 -DryRun

param(
    [string]$WorkspacePath = (Get-Location).Path,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $WorkspacePath)) {
    Write-Error "Workspace path not found: $WorkspacePath"
    exit 1
}

$WorkspaceDir = (Resolve-Path $WorkspacePath).Path
$SharedMemory = Join-Path $WorkspaceDir ".memory"
$ClaudeProjectsDir = Join-Path $env:USERPROFILE ".claude" "projects"

if (-not (Test-Path $SharedMemory)) {
    Write-Error "Shared memory directory not found: $SharedMemory"
    exit 1
}

if (-not (Test-Path $ClaudeProjectsDir)) {
    Write-Host "Claude projects directory not found: $ClaudeProjectsDir"
    Write-Host "Run Claude at least once, then rerun."
    exit 1
}

$prefix = $WorkspaceDir -replace '^[\\/]', '-' -replace '[\\/: ]', '-' -replace '-{2,}', '-'
if (-not $prefix.StartsWith('-')) {
    $prefix = "-$prefix"
}

$projectDirs = Get-ChildItem -Path $ClaudeProjectsDir -Directory | Where-Object {
    $_.Name -like "$prefix*"
}

if ($projectDirs.Count -eq 0) {
    $name = Split-Path -Leaf $WorkspaceDir
    $projectDirs = Get-ChildItem -Path $ClaudeProjectsDir -Directory | Where-Object {
        $_.Name -match [regex]::Escape($name)
    }
}

if ($projectDirs.Count -eq 0) {
    Write-Host "No Claude project dirs found for this workspace yet."
    Write-Host "Run Claude once from: $WorkspaceDir"
    exit 0
}

$linked = 0
$updated = 0
$skipped = 0

foreach ($dir in $projectDirs) {
    $memDir = Join-Path $dir.FullName "memory"
    $memItem = Get-Item $memDir -ErrorAction SilentlyContinue

    if ($memItem -and (($memItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0)) {
        $target = $memItem.Target
        if ($target -eq $SharedMemory) {
            $skipped++
            continue
        }

        if ($DryRun) {
            Write-Host "  [dry-run] Would update link: $($dir.Name) -> .memory/"
            $updated++
            continue
        }

        Remove-Item $memDir -Force
        New-Item -ItemType SymbolicLink -Path $memDir -Target $SharedMemory -Force | Out-Null
        Write-Host "  [updated] $($dir.Name) -> .memory/"
        $updated++
        continue
    }

    if (Test-Path $memDir) {
        $hasFiles = (Get-ChildItem $memDir -ErrorAction SilentlyContinue).Count -gt 0
        if ($hasFiles) {
            $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $bakDir = "${memDir}.bak.$stamp"
            if ($DryRun) {
                Write-Host "  [dry-run] Would back up: $memDir -> $bakDir"
            } else {
                Write-Host "  [backup] $memDir -> $bakDir"
                Rename-Item $memDir $bakDir
            }
        } else {
            if ($DryRun) {
                Write-Host "  [dry-run] Would remove empty: $memDir"
            } else {
                Remove-Item $memDir -Force
            }
        }
    }

    if ($DryRun) {
        Write-Host "  [dry-run] Would link: $($dir.Name) -> .memory/"
        $linked++
    } else {
        New-Item -ItemType SymbolicLink -Path $memDir -Target $SharedMemory -Force | Out-Null
        Write-Host "  [linked] $($dir.Name) -> .memory/"
        $linked++
    }
}

Write-Host ""
Write-Host "Done. Linked: $linked, Updated: $updated, Already correct: $skipped"
if ($DryRun) {
    Write-Host "(Dry run - no changes made.)"
}
