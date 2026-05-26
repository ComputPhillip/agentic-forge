# Forge — a Claude Code subagent that ships less, faster

> A drop-in Claude Code subagent for token-efficient AI coding. Encodes six operating principles that, in a head-to-head benchmark, produced **50% fewer tool calls** and **60% less wall time** than the default Claude Code agent on the same task. 142 lines of markdown. No code to install, no model to swap, no framework to learn.

```powershell
git clone https://github.com/ComputPhillip/agentic-forge
cd agentic-forge && .\install.ps1
# Restart Claude Code, then:
# Task(subagent_type="forge", description="...", prompt="...")
```

---

## What is Forge?

Forge is a [Claude Code subagent](https://docs.claude.com/en/docs/claude-code/sub-agents) — a markdown file Claude Code loads at session startup that defines a specialized AI agent with its own system prompt and restricted tool surface. When you invoke `subagent_type="forge"` from any Claude Code Task call, Claude Code spawns a fresh conversation governed by Forge's six principles.

It is **not**:
- A new model — it uses whatever Claude model your Claude Code session is configured for (Sonnet, Opus, Haiku)
- A framework — there's no Python package, no SDK, no runtime
- A fork of Claude Code — it's a config file in the standard agents directory
- A replacement for the default agent — it's a focused alternative for narrow tasks

It **is**:
- 142 lines of markdown (one frontmatter block, one system prompt) in `~/.claude/agents/forge.md`
- A restricted tool surface (11 tools — no web, no MCP, no image gen, no notebook editor)
- A set of opinionated defaults that bias the model toward shipping less code, faster

---

## Why it exists

The default Claude Code agent is built for **maximum capability** — broad tool surface, exhaustive iteration, generous verification. That's the right default for hard, open-ended problems. For *narrow, self-contained coding tasks* it spends tokens on caution, abstraction, and refactoring the task didn't ask for.

Forge was distilled from a longer project comparing a minimal AI agent harness ([my-harness](https://github.com/ComputPhillip)) against a maximalist one ([hermes-agent](https://github.com/NousResearch/hermes-agent)) across four benchmarks measuring token cost, tool call count, and code quality. The patterns that consistently produced leaner output became the principles encoded here.

---

## Head-to-head benchmark

Both agents received the same prompt: *"Build a simple, complete, playable Python game in a single file."*

| Metric | Default Claude Code agent | Forge | Delta |
|---|---:|---:|---:|
| Total tokens | 29,659 | 25,336 | **−15%** |
| Tool calls | 10 | 5 | **−50%** |
| Wall time | 144 s | 58 s | **−60%** |
| Lines of code | 132 | 92 | **−30%** |
| Bytes written | 3,778 | 2,445 | **−35%** |
| Top-level functions | 4 | 2 | **−50%** |
| Final game | Playable number-guessing game | Playable number-guessing game | **equivalent** |

Both shipped a working game. Forge shipped equivalent functionality with substantially less of everything. The Forge agent also explicitly skipped a distraction (the parent session's task list), surfacing the "no invented complexity" principle in its own response — *"Task list is unrelated to this one-shot ask, ignoring."*

This is a single-task benchmark on a narrow ask. Results on broad, multi-day projects requiring iteration would differ — and Forge isn't the right tool for those.

---

## When to use Forge

**Forge is the right call for:**
- Building small, focused scripts or single-file tools
- Reviewing AI agent or harness designs for unnecessary complexity
- Token cost or context budget analysis of LLM workflows
- Resisting scope creep on tasks that should stay small
- "Should I build this?" questions where the honest answer might be *no*
- Prototyping where you want a working artifact fast, not a perfect one
- Code review with a "what can we delete?" lens

**Use the default Claude Code agent instead for:**
- Anything requiring web browsing, web search, image generation, or MCP server tools (Forge doesn't have those)
- Production code requiring exhaustive error handling and edge-case coverage
- Open-ended research or exploration where maximum tool surface matters
- Tasks where extensive verification (full test suites, integration testing) is the right default

---

## How it actually works

A Claude Code subagent is a markdown file with YAML frontmatter that Claude Code discovers on session startup. The frontmatter declares the agent's name, description, and allowed tools. The body becomes the agent's system prompt, prepended to Claude Code's standard base prompt.

When you invoke `Task(subagent_type="forge", ...)`:

1. Claude Code looks up `forge` in its agent registry
2. Spawns a fresh Claude API conversation with its own context
3. Builds the system prompt: Claude Code's base prompt + Forge's 880-token body
4. Filters the tool surface to the 11 tools Forge declares (Read, Edit, Write, Bash, Glob, Grep, plus task-tracking)
5. Sends your `prompt` parameter as the user message
6. Runs the conversation to completion (multiple LLM round-trips for tool calls)
7. Returns the final response to the parent session

The behavior change is purely from the concentrated instructions in the system prompt plus the structurally restricted tool surface. No external tooling, no model fine-tuning, no runtime magic.

---

## The six operating principles

These are the entire behavior change. Read [forge.md](forge.md) for the agent's exact prompt.

1. **Lean by default.** Smallest viable solution. Three similar lines beats a premature abstraction.
2. **Cache discipline.** Never break the LLM prefix cache by injecting per-turn variable content into stable system prompts.
3. **Measure before optimizing.** Refuses to optimize on assumed costs. If you can't measure, say so.
4. **Honest scope.** Surface multi-day commitments before kicking off. A clean v0.1 beats a broken v1.
5. **Upstream first.** For forked code, ask whether the change belongs in the parent project. Most fixes do.
6. **No invented complexity.** No error handling for impossible cases. No abstractions for hypothetical future needs. No comments that restate code.

---

## Install

### User-level (available in every Claude Code session)

```powershell
git clone https://github.com/ComputPhillip/agentic-forge
cd agentic-forge
.\install.ps1
```

Drops `forge.md` into `%USERPROFILE%\.claude\agents\` on Windows (`~/.claude/agents/` on macOS/Linux).

### Project-local (only in one project)

```powershell
.\install.ps1 -Project C:\path\to\project
```

Drops `forge.md` into `<project>\.claude\agents\`.

### Reinstall

```powershell
.\install.ps1 -Force
```

After install, **restart Claude Code** — agents are discovered at session startup, not loaded dynamically.

---

## Usage

In any Claude Code session after install:

```
Task(
  subagent_type="forge",
  description="<short task label>",
  prompt="<self-contained brief — Forge has no memory of the parent conversation>"
)
```

The `prompt` must be self-contained. Forge runs in a fresh conversation and sees nothing from the parent session except this prompt.

Good prompts to try:
- *"Review this agent design proposal and apply your skepticism test: [proposal]"*
- *"Build a minimal token-cost benchmark for X. Push back if scope is unclear."*
- *"Should I add feature Y to my agent harness? Measure first, then advise."*
- *"This task feels multi-day. Tell me honestly before I commit, then propose the smallest version that actually delivers value."*
- *"Refactor this file to remove invented complexity. Don't add new abstractions."*

---

## FAQ

**Is this just a system prompt and a tool restriction?**
Yes. The behavior change comes from concentrated instructions in the system prompt + the restricted tool surface. No external tooling, no SDK, no runtime.

**Does it cost more or less than the default Claude Code agent?**
Less on narrow tasks — the benchmark showed ~15% fewer tokens and ~50% fewer tool calls. For tasks requiring tools Forge restricts (web fetch, image generation, MCP servers), Forge can't run at all — use the default agent.

**Will it work with my Claude Code setup?**
Yes if your Claude Code supports subagents. The install script drops a markdown file into the standard agents directory. No changes to Claude Code itself, no plugins, no extensions.

**Does it work with Claude Opus / Sonnet / Haiku?**
Yes. Forge has no `model:` field in its frontmatter, so it inherits whatever model the parent Claude Code session is using.

**Can I customize the principles?**
Yes. Edit `forge.md` (the body, not the frontmatter unless you also want to change the tool surface) and reinstall. The body of the file is the agent's system prompt.

**Why these principles and not others?**
They're the patterns that survived empirical testing across four benchmark runs comparing minimal vs maximalist AI agent harnesses. The companion [Forge fork](https://github.com/ComputPhillip/Forge) documents the underlying research.

**What does the name mean?**
Forge is named after the [Forge](https://github.com/ComputPhillip/Forge) fork of hermes-agent — the parent project where the principles were developed and benchmarked.

**Can I publish my own subagent like this?**
Yes — that's what Claude Code subagents are designed for. Use `forge.md` as a template, adjust the frontmatter and body to your needs, and publish to GitHub the same way.

---

## Related projects

- **[Forge](https://github.com/ComputPhillip/Forge)** — community fork of [hermes-agent](https://github.com/NousResearch/hermes-agent) where the design principles encoded here were developed and benchmarked.
- **[hermes-agent](https://github.com/NousResearch/hermes-agent)** — Nous Research's self-improving AI agent, the upstream project Forge was forked from.
- **[Claude Code](https://docs.claude.com/en/docs/claude-code/overview)** — Anthropic's official AI coding assistant. Forge is a subagent for this platform.

---

## Keywords

`claude code` `claude code subagent` `claude code agent` `ai coding agent` `agentic ai` `llm agent` `agent design` `agent framework` `token efficiency` `token reduction` `prompt engineering` `lean agent` `minimal agent` `agent template` `claude code extension` `ai agent template` `coding agent` `agent definition` `subagent template`

---

## License

MIT — see [LICENSE](LICENSE). Same as Forge and hermes-agent.
