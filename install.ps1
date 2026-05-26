# Install the Forge agent into Claude Code's user-level agents directory.
#
# Default location on Windows: %USERPROFILE%\.claude\agents\
# After install, the agent is invokable in any Claude Code session via:
#     Task(subagent_type="forge", description="...", prompt="...")
#
# Usage:
#   .\install.ps1                  # install to user-level (~/.claude/agents)
#   .\install.ps1 -Project <path>  # install to a project-local .claude/agents
#   .\install.ps1 -Force           # overwrite if already present
#
# This script does NOT modify Claude Code config — it only drops the agent
# definition file. Claude Code discovers agents in those directories
# automatically the next time a session starts.

[CmdletBinding()]
param(
    [string]$Project = "",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$source = Join-Path $PSScriptRoot "forge.md"
if (-not (Test-Path $source)) {
    Write-Error "forge.md not found at $source. Run this from the Forge_Agent directory."
    exit 1
}

if ($Project) {
    $projectPath = Resolve-Path $Project -ErrorAction Stop
    $destDir = Join-Path $projectPath ".claude\agents"
    $scope = "project-local ($projectPath)"
} else {
    $destDir = Join-Path $env:USERPROFILE ".claude\agents"
    $scope = "user-level (all projects on this machine)"
}

New-Item -ItemType Directory -Force -Path $destDir | Out-Null

$destFile = Join-Path $destDir "forge.md"
if ((Test-Path $destFile) -and -not $Force) {
    Write-Output "Already installed at $destFile"
    Write-Output "Re-run with -Force to overwrite, or delete the file first."
    exit 0
}

Copy-Item $source -Destination $destFile -Force
Write-Output "Installed Forge agent: $destFile"
Write-Output "Scope: $scope"
Write-Output ""
Write-Output "To use in Claude Code, invoke via the Task/Agent tool with:"
Write-Output "    subagent_type: forge"
Write-Output ""
Write-Output "The agent will be discoverable in any Claude Code session started"
Write-Output "after this install (running sessions need to be restarted)."
