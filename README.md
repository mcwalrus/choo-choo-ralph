# Choo Choo Ralph

<p align="center">
  <img src="choo-choo-ralph.png" alt="Choo Choo Ralph" width="100%">
</p>

![License](https://img.shields.io/badge/license-MIT-blue)
![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-purple)

<p align="center">
  <a href="#quick-start">Quick Start</a> •
  <a href="#how-it-works">How It Works</a> •
  <a href="#pour-modes">Pour Modes</a> •
  <a href="#compounding-knowledge">Compounding Knowledge</a> •
  <a href="#customization">Customization</a> •
  <a href="#further-reading">Further Reading</a>
</p>

<p align="center"><em>Relentless like a train. Persistent like Ralph Wiggum. Ships code while you sleep.</em></p>

---

## The Idea

Most autonomous coding setups fall into two traps:

1. **Too simple** - Run Claude in a loop, hope for the best, watch it spiral when something breaks
2. **Too complex** - Build elaborate orchestration that's harder to debug than the code it writes

Choo Choo Ralph is neither. The outer loop is dead simple. The workflow inside each task is structured and verified. Each task remembers its own history across sessions.

**The thesis**: Simple loop + smart workflow + persistent memory = autonomous coding that actually works.

### What We Don't Do

Planning. Your planning process is yours - downloading repos, grepping through code, iterating with different AI agents, writing markdown docs that evolve through discussion. That's creative, messy work that can't be captured in a command.

### What We Do

Take your plan - however rough or polished - and turn it into something an autonomous agent can execute reliably:

1. **Spec** - Structure your plan into reviewable tasks with test steps
2. **Pour** - Break those into granular, atomic units of work
3. **Run** - Execute them one by one with verification
4. **Learn** - Capture what the agents discover along the way

## What You Get

- **Verified, not vibes** - Health checks before implementing, tests and browser verification after
- **Bounded context** - Each task tracks its own history via [Beads](https://github.com/steveyegge/beads), no context window bloat
- **Structured phases** - Bearings → Implement → Verify → Commit (not just "do the thing")
- **Compounding knowledge** - Agents capture learnings as they work; [harvest](#compounding-knowledge) them into skills and docs that make future sessions smarter
- **Pick up where you left off** - Tasks persist across sessions, crashes, and context resets

## The Workflow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   1. Plan   │ ──▶ │  2. Spec    │ ──▶ │  3. Pour    │ ──▶ │  4. Ralph   │ ──▶ │ 5. Harvest  │
│    (you)    │     │  (you + AI) │     │    (AI)     │     │    (AI)     │     │ (you + AI)  │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

1. **Plan** - Write what you want to build *(this is on you - we don't do planning)*
2. **Spec** - AI transforms it into structured tasks; you review and refine
3. **Pour** - Tasks become beads ([workflow](#workflow-formula-recommended) or [singular](#singular-tasks))
4. **Ralph** - The loop runs autonomously until done
5. **Harvest** - Extract learnings into skills, docs, or CLAUDE.md

## Why "Choo Choo Ralph"?

**Choo Choo** - Like a train with carts. Each cart is a containerized block of work - self-contained, carrying its own context and history. The train keeps moving forward, cart after cart, toward your destination.

**Ralph** - Named after the [Ralph Wiggum technique](https://ghuntley.com/ralph/): run an AI in a loop until it's done. Simple, relentless, surprisingly effective. Ralph makes mistakes, gets confused, but never stops trying.

## Prerequisites

- [Claude Code](https://claude.com/claude-code) - Anthropic's CLI
- [Beads](https://github.com/steveyegge/beads) - Git-backed issue tracker (`bd` command)
- [jq](https://jqlang.github.io/jq/) - JSON parsing

**Recommended:**
- [dev-browser](https://github.com/SawyerHood/dev-browser) - Browser automation for UI verification

---

## Quick Start

<details>
<summary>⚠️ <strong>Safety Warning</strong> - Read before running</summary>

Ralph runs Claude with `--dangerously-skip-permissions`, which allows it to execute commands without confirmation. This is powerful but risky.

**We strongly recommend:**
- Run in a **Docker container** or **VM**
- Use a machine that doesn't have your life's work on it
- Start with small, low-risk tasks until you trust the setup
- Review the formulas and scripts before running

By using this project, you accept full responsibility for any consequences.

</details>

```bash
# Install plugin
/plugin marketplace add mj-meyer/choo-choo-ralph
/plugin install choo-choo-ralph@choo-choo-ralph

# Set up project
/choo-choo-ralph:install

# Write your plan, then generate spec
/choo-choo-ralph:spec plans/my-feature.md

# Review .choo-choo-ralph/my-feature.spec.md
# Add feedback in <review> tags, run /choo-choo-ralph:spec again
# Repeat until happy

# Pour into beads (auto-detects spec file)
/choo-choo-ralph:pour

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

### Test Before You Sleep

Not ready to go fully autonomous? Use `./ralph-once.sh` to run a single iteration interactively:

```bash
./ralph-once.sh  # Run one iteration, then stop
```

This is the best way to:
- **Test your setup** before letting Ralph run overnight
- **Optimize prompts** - see exactly what the agents do and refine the formulas
- **Debug issues** - step through one task at a time
- **Build trust** - watch Ralph complete a few tasks before going hands-off

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

- **Sub-agents add comments** on the root bead when they encounter gotchas, patterns, or missing work
- **Comments use tags** - `[LEARNING]` for knowledge, `[GAP]` for follow-up work
- **You harvest later** and decide what to extract into skills or docs

Example comments from a completed task:
```
[LEARNING] This codebase uses barrel exports - always import from index.ts
[LEARNING] shadcn Button requires forwardRef when wrapping
[GAP] Auth middleware - needs rate limiting for login endpoint
```

Run `/choo-choo-ralph:harvest` to gather learnings and propose documentation artifacts (skills, CLAUDE.md updates, reference docs).

---

## Pour Modes

When you run `/pour`, you'll be asked how to pour your tasks:

### Workflow Formula (Recommended)

Multi-step workflow with structured phases:
- **choo-choo-ralph** - bearings → implement → verify → commit
- **bug-fix** - diagnose → fix → verify → commit

Best for production features where you want health checks, verification, and structured commits.

### Singular Tasks

Simple beads executed directly without workflow steps. Good for:
- **Research** - Explore codebase, investigate options
- **Exploratory development** - Quick prototyping
- **One-off tasks** - When you just need things done

> [!NOTE]
> Singular tasks still capture learnings and gaps. Each task includes instructions to add `[GAP]` and `[LEARNING]` comments. This means even exploratory work feeds back into the compounding learning system - the only difference is no structured verification phases.

---

## Compounding Knowledge

Every task teaches your agents something. The question is: do you capture it?

```
Iteration 1: Write code → Discover patterns → Capture as comments
Iteration 2: Write code → Learn from previous → Capture new insights
Iteration 3: Harvest learnings → Create skills/docs → Future agents are smarter
Iteration 4: New agent benefits from skills → Works faster → Discovers more
...repeat...
```

**The flywheel:**
1. **Code** - Each task produces working, tested, committed code
2. **Memory** - Agents capture gaps and learnings as comments on beads
3. **Harvest** - You extract valuable patterns into skills, CLAUDE.md, docs
4. **Compound** - Future iterations benefit from accumulated knowledge
5. **Repeat** - The system gets smarter with every session

This isn't just "AI writes code in a loop" - it's a **learning system** that improves itself over time. The beads aren't just task tracking; they're a persistent memory that survives context windows and sessions.

### The Harvest Cycle

After a session, run `/choo-choo-ralph:harvest` to:
1. Gather learnings from completed tasks
2. Propose documentation artifacts (skills, CLAUDE.md, docs)
3. Review and approve what makes sense
4. Future agents benefit from accumulated knowledge

**The result:** Each session makes your agents smarter. They learn YOUR codebase, YOUR patterns, YOUR conventions. Over time, they need less guidance and make fewer mistakes.

<details>
<summary>Experimental: Auto-Learning</summary>

Set `auto_discovery: true` or `auto_learnings: true` in spec frontmatter for automatic processing:
- Gaps automatically become new tasks
- Learnings automatically become skills or CLAUDE.md updates

Riskier but interesting for experimentation. Manual harvest is recommended until you trust the output.

</details>

---

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

Choo Choo Ralph combines Ralph's simple outer loop with Anthropic's structured inner workflow. [Beads](https://github.com/steveyegge/beads) provides the task management - each bead contains its own history, so context stays bounded.

### Claude Code's Ralph Plugin

Claude Code includes an official Ralph plugin, but it lacks detailed guidance on setup. Choo Choo Ralph is designed specifically for full-stack development with structured workflows and verification.

---

## Commands Reference

### /choo-choo-ralph:install
Set up Ralph in your project. No arguments.

### /choo-choo-ralph:spec [source-file] [spec-name]
Generate or refine a spec file.
- `source-file` - Path to plan file (optional)
- `spec-name` - Name for the spec (optional, auto-detected)

### /choo-choo-ralph:pour [target-tasks] [spec-file] [formula]
Convert spec tasks into beads.
- `target-tasks` - Target number of implementation tasks (optional)
- `spec-file` - Spec to pour (optional, auto-detected)
- `formula` - Formula name (optional, only used if workflow mode selected)

> [!TIP]
> You'll be asked to choose between "workflow formula" or "singular tasks" mode.

### /choo-choo-ralph:harvest
Extract learnings from completed tasks into documentation. No arguments.

---

## Useful BD Commands

```bash
# See what's ready for Ralph
bd ready --assignee ralph

# Check a specific task
bd show <bead-id>
bd comments <bead-id>

# Manual intervention
bd update <bead-id> --status open     # Reopen a task
bd update <bead-id> --status blocked  # Block a task
bd close <bead-id> --reason "..."     # Close manually

# List by status
bd list --status=open --assignee=ralph
bd list --status=blocked

# Formulas
bd formula list
bd mol pour choo-choo-ralph --var title="..." --var task="..."
```

---

## Error Handling

### Automatic Retries

If verification fails, Ralph automatically:
1. Reopens the implement step with `[REWORK]` guidance
2. Tracks attempts via `[attempt-N]` comments
3. After 3 failed attempts, marks the task as `blocked`

### Blocked Tasks

Blocked tasks require human intervention:
```bash
bd list --status=blocked           # See blocked tasks
bd comments <bead-id>              # Read what went wrong
bd update <bead-id> --status open  # Reopen after fixing
```

### Health Check Failures

If bearings detects broken state (failed tests, crashed server):
1. Creates a bug-fix bead automatically
2. Blocks the current task on the bug
3. Bug must be fixed before original task continues

---

## Bug Fix Workflow

A separate `bug-fix` formula handles bugs discovered during work:

1. **Diagnose** - Reproduce and identify root cause
2. **Fix** - Make minimal targeted fix
3. **Verify** - Confirm bug is gone, all tests pass
4. **Commit** - Create fix commit with reference

Created automatically when health checks fail, or manually:
```bash
bd mol pour bug-fix --var title="Fix broken tests" --var task="Tests failing after auth changes" --assignee ralph
```

---

## Customization

Choo Choo Ralph is a **starting point**, not a prescription. Everything lives in your project so you can change it:

- **Formulas** (`.beads/formulas/`) - The workflow templates
- **Shell scripts** (`ralph.sh`, etc.) - The loop behavior
- **Specs** (`.choo-choo-ralph/`) - Your planning process

The defaults work for most people. But project-to-project, you might want:
- Different verification steps (E2E tests, security scans, performance checks)
- Simpler workflows for certain task types
- Domain-specific formulas (data-pipeline, ML-training, docs-only)
- Custom learning capture for your team's style

**Fork it, hack it, make it yours.**

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

Pour a formula with variables:
```bash
bd mol pour my-formula --var title="Task title" --var task="Task description" --assignee ralph
```

Create custom formulas for planning, bug triage, code review, documentation - anything that fits "look at repo, do something, commit."

See `skills/ralph-guide/references/formula-customization.md` for the full guide, including how to add learning capture to your custom formulas.

### Assignee Conventions

- `ralph` - Root molecules, picked up by the main loop
- `ralph-subagent-*` - Steps executed by spawned sub-agents
- `ralph-inline-*` - Steps executed by the orchestrator directly

### Labels

Ralph uses these labels for workflow:
- `ralph-step` - All workflow steps
- `bearings`, `implement`, `verify`, `commit` - Step types
- `learnings` - Bead has learnings to harvest
- `learnings-harvested` - Learnings have been extracted
- `gaps` - Bead identified gaps/follow-up work
- `gaps-harvested` - Gaps have been processed

---

## Further Reading

**Ralph Technique**
- [ghuntley.com/ralph](https://ghuntley.com/ralph/) - The original Ralph philosophy
- [Matt Pocock's Ralph Guide](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum) - Practical tips

**Anthropic Research**
- [Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) - Two-agent pattern, verification

**Tools**
- [Beads](https://github.com/steveyegge/beads) - Git-backed issue tracker with molecules
- [dev-browser](https://github.com/SawyerHood/dev-browser) - Browser automation for Claude Code
- [Claude Code](https://claude.com/claude-code) - Anthropic's CLI for agentic coding

## License

MIT
