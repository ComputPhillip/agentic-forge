# Forge — a Claude Code subagent

A lean coding subagent that encodes the design principles surfaced during the [Forge](https://github.com/ComputPhillip/Forge) fork project. Use it when the right answer is probably "less is more" — small scripts, focused harnesses, design reviews of elaborate proposals, token-cost analysis.

## What it does

When invoked via Claude Code's Task tool, this agent applies seven operating principles to whatever you give it:

1. **Lean by default** — smallest viable solution, no premature abstractions.
2. **Cache discipline** — preserve prefix-cache invariants in any agent/harness design.
3. **Measure before optimizing** — won't optimize on assumed costs.
4. **Honest scope** — surfaces multi-day commitments before kicking off.
5. **Upstream first** — for forked code, sends generally-useful fixes to the parent project.
6. **No invented complexity** — no error handling for impossible cases, no abstractions for hypothetical needs.

The full system prompt is in [forge.md](forge.md) — read it to see exactly what the agent is told.

## Tool surface (intentionally lean)

`Read`, `Edit`, `Write`, `Bash`, `Glob`, `Grep`, `TaskCreate`, `TaskUpdate`, `TaskList`, `TaskGet`, `mark_chapter`

Deliberately excluded:
- Web browsing / fetching — keep it focused on local code
- MCP tools — not loaded by default; would bloat the agent's own prompt
- Image generation, video, audio — not its job
- NotebookEdit — most projects don't need it; opt in per-session if you do

If you need any of these for a task, use the default `claude` agent instead.

## Install

### User-level (available in every Claude Code session on this machine)

```powershell
.\install.ps1
```

Drops `forge.md` into `%USERPROFILE%\.claude\agents\`.

### Project-local (only in one project's sessions)

```powershell
.\install.ps1 -Project C:\path\to\your\project
```

Drops `forge.md` into `<project>\.claude\agents\`. Useful for projects where you want to opt in without polluting all your sessions.

### Re-install / overwrite

```powershell
.\install.ps1 -Force
```

## Use

After install, in any Claude Code session, invoke via the Task/Agent tool:

```
Task(
  subagent_type="forge",
  description="<short task name>",
  prompt="<self-contained brief for the agent — it has no memory of this conversation>"
)
```

The agent will:
- Apply the seven principles to whatever you ask
- Push back if the task as stated is bigger than it looks
- Ask one focused clarifying question if scope is ambiguous
- Otherwise do the work directly and report concisely

## When to use Forge vs. the default agent

**Use Forge for:**
- Building or reviewing small focused tools
- "Should I build this?" questions where the honest answer might be no
- Token-cost or context-cost analysis of agent designs
- Reviewing proposals that smell elaborate-but-shallow
- Resisting scope creep on tasks that should stay small

**Use the default `claude` agent for:**
- Anything needing browser, web fetch, image gen, or MCP servers
- Production code requiring extensive safety/error handling
- Tasks where you actually do want maximum tool surface available

## Uninstall

```powershell
Remove-Item "$env:USERPROFILE\.claude\agents\forge.md"
```

Or, for project-local:

```powershell
Remove-Item "C:\path\to\project\.claude\agents\forge.md"
```

## Origin

This agent was extracted from a longer working session about token reduction in agent harnesses, comparing a minimal harness (`my-harness`) against `hermes-agent` across four benchmarks. The principles encoded in [forge.md](forge.md) are the patterns that consistently won — and the patterns that consistently lost (vocabulary-heavy proposals with thin mechanism) inform what the agent refuses.

See [github.com/ComputPhillip/Forge](https://github.com/ComputPhillip/Forge) for the parent project this agent is named after.

## License

MIT — same as Forge and hermes-agent.
