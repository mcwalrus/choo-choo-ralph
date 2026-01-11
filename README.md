# Choo Choo Ralph

<p align="center">
  <img src="choo-choo-ralph.png" alt="Choo Choo Ralph" width="600">
</p>

**Ship while you sleep. Wake up to commits.**

The dumbest smart way to build apps autonomously - run Claude in a loop with structured workflows and built-in verification. Like Ralph Wiggum: perpetually confused, always making mistakes, but never stopping until it's done.

## What You Get

- **Autonomous coding with verification** - Health checks, tests, and browser automation close the feedback loop
- **Persistent memory per task** - Each task tracks its own history, pick up exactly where you left off
- **Structured workflows** - Bearings → Implement → Verify → Commit (not just "do the thing")
- **Simple outer loop, smart inner workflow** - Ralph's simplicity meets Anthropic's rigor

## The Workflow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   1. Plan   │ ──▶ │  2. Spec    │ ──▶ │  3. Pour    │ ──▶ │  4. Ralph   │ ──▶ │ 5. Harvest  │
│    (you)    │     │  (you + AI) │     │    (AI)     │     │    (AI)     │     │ (you + AI)  │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

1. **Plan** - Write what you want to build (any format)
2. **Spec** - AI transforms it into structured tasks; you review and refine
3. **Pour** - Tasks become beads with workflows (5 beads per task)
4. **Ralph** - The loop runs autonomously until done
5. **Harvest** - Extract learnings into skills, docs, or CLAUDE.md

## Quick Start

```bash
# Install plugin
/plugin marketplace add mj-meyer/choo-choo-ralph
/plugin install choo-choo-ralph@mj-meyer/choo-choo-ralph

# Set up project
/choo-choo-ralph:install

# Write your plan, then generate spec
/choo-choo-ralph:spec @plans/my-feature.md

# Review .choo-choo-ralph/my-feature.spec.md
# Add feedback in <review> tags, run /choo-choo-ralph:spec again
# Repeat until happy

# Pour into beads
/choo-choo-ralph:pour .choo-choo-ralph/my-feature.spec.md

# Start the loop
./ralph.sh

# Or with verbose output to observe what's happening
./ralph.sh --verbose

# After tasks complete, harvest learnings
/choo-choo-ralph:harvest
```

## Observing the Loop

Ralph includes a formatted output display so you can watch what's happening:

```bash
./ralph.sh              # Condensed view - tool names + first line of output
./ralph.sh -v           # Verbose - full commands, more output, token stats
./ralph.sh 10 --verbose # 10 iterations with verbose output
```

**Normal mode:**
```
💭 Let me check for ready tasks
🔧 Bash bd ready --assignee ralph --json
   └─ 📋 Ready work (1 issues with no blockers)
💭 I'll work on the bearings step
🔧 Task [Explore] Get oriented in codebase
   └─ Found 3 relevant files...
✓ Done
```

**Verbose mode adds:**
- 🧠 Thinking blocks (if extended thinking enabled)
- Full bash commands (wrapped nicely)
- Up to 10 lines of tool output
- Full error messages with context
- Token summary: `📊 Total: 12,345 input, 567 output, 89% cache hit`

Verbose mode is great for understanding how Ralph works and improving your prompts/formulas.

Not ready to go fully autonomous? Use `./ralph-once.sh` to run one iteration at a time interactively.

## How It Works

### 5 Beads Per Task

Each task becomes a **molecule** - a workflow of 5 beads:

1. **Orchestrator** - Coordinates the workflow (root bead)
2. **Bearings** - Health check + understand codebase (sub-agent)
3. **Implement** - Make the changes (sub-agent)
4. **Verify** - Run tests, check types, browser verification (sub-agent)
5. **Commit** - Create git commit (inline)

### Sub-Agent Architecture

```
┌──────────────────────────────────────────┐
│            Orchestrator Agent            │
│  (coordinates, doesn't implement)        │
└──────────────────┬───────────────────────┘
                   │
     ┌─────────────┼─────────────┐
     ▼             ▼             ▼
┌─────────┐  ┌──────────┐  ┌─────────┐
│Bearings │  │Implement │  │ Verify  │
│Sub-agent│  │Sub-agent │  │Sub-agent│
└─────────┘  └──────────┘  └─────────┘
```

**Why sub-agents?**

- **Fresh context** - Each sub-agent starts clean, no accumulated cruft
- **Specialized prompts** - Bearings focuses on exploration, verify on testing
- **Objective verification** - The verify agent hasn't seen implementation details
- **Bounded scope** - Each agent does one thing well

### Built-in Verification

Agents must verify their work. The bearings step runs health checks before implementing, and the verify step tests everything after:

- Type checking, test suite, linting
- Browser verification using [dev-browser](https://github.com/SawyerHood/dev-browser) - actually navigate and test like a user
- Screenshots saved for reference

### Continuous Learning

Agents capture learnings as they work, building a knowledge base attached to completed tasks:

- **Sub-agents comment on the root bead** when they encounter gotchas, patterns, or errors
- **Orchestrator synthesizes** at completion, recommending skills or CLAUDE.md updates
- **You review later** and decide what to extract

Example learnings from a completed task:
```
[bearings] This codebase uses barrel exports - always import from index.ts
[implement] shadcn Button requires forwardRef when wrapping
[verify] Tests require VITE_API_URL env var or they silently skip
[summary] Recommendation: Consider skill for shadcn component patterns
```

Run `/choo-choo-ralph:harvest` to gather learnings and propose documentation artifacts (skills, CLAUDE.md updates, reference docs).

## Why This Approach

### The Ralph Wiggum Technique

Originated by [Geoffrey Huntley](https://ghuntley.com/ralph/), Ralph is a deceptively simple approach: run an AI coding agent in a loop until a task is done. The name comes from Ralph Wiggum of The Simpsons - perpetually confused, always making mistakes, but never stopping.

[Matt Pocock's guide](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum) documents practical patterns that emerged from combining Ralph with Anthropic's research - using JSON PRDs for task lists, progress tracking, and verification steps.

The key insight: **the outer loop should be simple**. Don't build complex orchestration to manage the loop itself.

### Anthropic's Research on Long-Running Agents

[Anthropic's research](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) provides critical guidance:

- **Get your bearings first** - Before implementing, understand the codebase state
- **Small, atomic tasks** - Break work into granular pieces (~200 tasks for a full app)
- **Test steps per task** - Each task needs 4-5 verifiable steps
- **Verification before new work** - Always confirm the app is healthy first

### Why I Built This

The JSON/PRD approach works, but has limitations:

| Aspect | JSON/Markdown PRD | Beads |
|--------|-------------------|-------|
| **History** | Single progress.txt file | Comments per task, full audit trail |
| **Dependencies** | None | First-class support with `bd dep add` |
| **State** | Manual tracking | Automatic status management |
| **Resume** | Parse files, guess state | `bd ready` shows exactly what's next |
| **Workflows** | Fixed steps | Customizable formulas per task type |
| **Context** | Grows unbounded | Each task has its own bounded context |

Choo Choo Ralph combines Ralph's simple outer loop with Anthropic's structured inner workflow. [Beads](https://github.com/beads-project/beads) provides the task management - each bead contains its own history, so context stays bounded.

### Claude Code's Ralph Plugin

Claude Code includes an official Ralph plugin, but it lacks detailed guidance on setup. Choo Choo Ralph is designed specifically for full-stack development with structured workflows and verification.

## Customization

### Formulas

Formulas are TOML templates that define workflows:

```toml
formula = "quick-fix"
description = "Fast bug fix workflow"

[[steps]]
id = "fix"
title = "Fix the bug"
assignee = "ralph-subagent-fix"
description = """
Fix the bug described in the task.
Run tests to verify.
"""

[[steps]]
id = "commit"
title = "Commit fix"
assignee = "ralph-inline-commit"
needs = ["fix"]
```

Create custom formulas for planning, bug triage, code review, documentation - anything that fits "look at repo, do something, commit."

See `skills/ralph-guide/references/formula-customization.md` for the full guide, including how to add learning capture to your custom formulas.

### Assignee Conventions

- `ralph` - Root molecules, picked up by the main loop
- `ralph-subagent-*` - Steps executed by spawned sub-agents
- `ralph-inline-*` - Steps executed by the orchestrator directly

## Further Reading

**Ralph Technique**
- [ghuntley.com/ralph](https://ghuntley.com/ralph/) - The original Ralph philosophy
- [Matt Pocock's Ralph Guide](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum) - Practical tips

**Anthropic Research**
- [Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) - Two-agent pattern, verification

**Tools**
- [Beads](https://github.com/beads-project/beads) - Git-backed issue tracker with molecules
- [dev-browser](https://github.com/SawyerHood/dev-browser) - Browser automation for Claude Code
- [Claude Code](https://claude.com/claude-code) - Anthropic's CLI for agentic coding

## License

MIT
