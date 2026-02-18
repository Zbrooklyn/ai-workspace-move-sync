# One-command setup after moving/syncing a workspace.
# Usage:
#   .\setup-workspace.ps1 -WorkspacePath "C:\path\to\workspace"
#   .\setup-workspace.ps1
#   .\setup-workspace.ps1 -DryRun

param(
    [string]$WorkspacePath = (Get-Location).Path,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not (Test-Path $WorkspacePath)) {
    Write-Error "Workspace path not found: $WorkspacePath"
    exit 1
}

$WorkspaceDir = (Resolve-Path $WorkspacePath).Path
$WorkspaceName = Split-Path -Leaf $WorkspaceDir
$ProjectMcp = Join-Path $WorkspaceDir ".mcp.json"
$GeminiSettings = Join-Path $env:USERPROFILE ".gemini\settings.json"
$GeminiTrust = Join-Path $env:USERPROFILE ".gemini\trustedFolders.json"

function Load-JsonObject {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        return [pscustomobject]@{}
    }
    $raw = Get-Content -Path $Path -Raw
    if ([string]::IsNullOrWhiteSpace($raw)) {
        return [pscustomobject]@{}
    }
    return ($raw | ConvertFrom-Json)
}

function Save-JsonObject {
    param(
        [string]$Path,
        $Object
    )
    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    $json = $Object | ConvertTo-Json -Depth 50
    Set-Content -Path $Path -Value $json
}

function Ensure-ObjectProperty {
    param(
        $Object,
        [string]$Name
    )
    if (-not $Object.PSObject.Properties[$Name]) {
        $Object | Add-Member -NotePropertyName $Name -NotePropertyValue ([pscustomobject]@{})
    }
    return $Object.PSObject.Properties[$Name].Value
}

function Find-McpScript {
    param([string]$Root)

    $preferred = Join-Path $Root "projects\job_postings\upwork_mcp\start-browser-mcp.sh"
    if (Test-Path $preferred) {
        return $preferred
    }

    $found = Get-ChildItem -Path $Root -Filter "start-browser-mcp.sh" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) {
        return $found.FullName
    }

    return $null
}

$McpScript = Find-McpScript -Root $WorkspaceDir
if ($McpScript) {
    $McpScript = $McpScript.Replace('\\', '/')
}

Write-Host "[1/5] Relinking Claude memory directories..."
if ($DryRun) {
    & (Join-Path $ScriptDir "link-memory.ps1") -WorkspacePath $WorkspaceDir -DryRun
} else {
    & (Join-Path $ScriptDir "link-memory.ps1") -WorkspacePath $WorkspaceDir
}

Write-Host "[2/5] Updating project MCP config (if possible)..."
if ((Test-Path $ProjectMcp) -and $McpScript) {
    $project = Load-JsonObject -Path $ProjectMcp
    $projectServers = Ensure-ObjectProperty -Object $project -Name "mcpServers"
    $projectBrowser = Ensure-ObjectProperty -Object $projectServers -Name "browser"
    $projectBrowser.command = "bash"
    $projectBrowser.args = @($McpScript)
    if ($DryRun) {
        Write-Host "  [dry-run] Would update: $ProjectMcp"
    } else {
        Save-JsonObject -Path $ProjectMcp -Object $project
        Write-Host "  Updated: $ProjectMcp"
    }
} elseif (Test-Path $ProjectMcp) {
    Write-Host "  Skipped: .mcp.json exists but no start-browser-mcp.sh was found under workspace."
} else {
    Write-Host "  Skipped: $ProjectMcp not found."
}

Write-Host "[3/5] Updating Gemini MCP config (if possible)..."
if ((Test-Path $GeminiSettings) -and $McpScript) {
    $gemini = Load-JsonObject -Path $GeminiSettings
    $geminiServers = Ensure-ObjectProperty -Object $gemini -Name "mcpServers"
    $geminiBrowser = Ensure-ObjectProperty -Object $geminiServers -Name "browser"
    $geminiBrowser.command = "bash"
    $geminiBrowser.args = @($McpScript)
    if ($DryRun) {
        Write-Host "  [dry-run] Would update: $GeminiSettings"
    } else {
        Save-JsonObject -Path $GeminiSettings -Object $gemini
        Write-Host "  Updated: $GeminiSettings"
    }
} elseif (Test-Path $GeminiSettings) {
    Write-Host "  Skipped: $GeminiSettings exists but no start-browser-mcp.sh was found under workspace."
} else {
    Write-Host "  Skipped: $GeminiSettings not found."
}

Write-Host "[4/5] Updating Gemini trusted folders..."
$trusted = Load-JsonObject -Path $GeminiTrust
foreach ($prop in @($trusted.PSObject.Properties.Name)) {
    if ($prop -eq $WorkspaceDir) { continue }
    try {
        if ((Test-Path $prop) -and ((Resolve-Path $prop).Path -eq $WorkspaceDir)) {
            $trusted.PSObject.Properties.Remove($prop)
        }
    } catch {
        # Ignore stale entries.
    }
}
if ($trusted.PSObject.Properties[$WorkspaceDir]) {
    $trusted.PSObject.Properties.Remove($WorkspaceDir)
}
$trusted | Add-Member -NotePropertyName $WorkspaceDir -NotePropertyValue "TRUST_FOLDER"
if ($DryRun) {
    Write-Host "  [dry-run] Would update: $GeminiTrust"
} else {
    Save-JsonObject -Path $GeminiTrust -Object $trusted
    Write-Host "  Updated: $GeminiTrust"
}

Write-Host "[5/5] Verifying memory links..."
$ClaudeProjectsDir = Join-Path $env:USERPROFILE ".claude\projects"
if (-not (Test-Path $ClaudeProjectsDir)) {
    Write-Host "  Claude projects directory not found: $ClaudeProjectsDir"
    exit 0
}

$prefix = $WorkspaceDir -replace '^[\\/]', '-' -replace '[\\/: ]', '-' -replace '-{2,}', '-'
if (-not $prefix.StartsWith('-')) {
    $prefix = "-$prefix"
}

$projectDirs = Get-ChildItem -Path $ClaudeProjectsDir -Directory | Where-Object {
    $_.Name -like "$prefix*"
}
if ($projectDirs.Count -eq 0) {
    $projectDirs = Get-ChildItem -Path $ClaudeProjectsDir -Directory | Where-Object {
        $_.Name -match [regex]::Escape($WorkspaceName)
    }
}

if ($projectDirs.Count -eq 0) {
    Write-Host "  No matching Claude project dirs found yet."
    Write-Host "  Start Claude once from $WorkspaceDir, then rerun setup."
    exit 0
}

foreach ($dir in $projectDirs) {
    $memPath = Join-Path $dir.FullName "memory"
    if (-not (Test-Path $memPath)) {
        Write-Host "  [warn] Missing memory path: $memPath"
        continue
    }
    $item = Get-Item -Path $memPath -Force
    $isLink = ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0
    if ($isLink) {
        Write-Host "  [ok] $($dir.Name)\\memory -> $($item.Target)"
    } else {
        Write-Host "  [warn] $($dir.Name)\\memory is not a symlink"
    }
}

Write-Host ""
Write-Host "Workspace setup complete for: $WorkspaceDir"
