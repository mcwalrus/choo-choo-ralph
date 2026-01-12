---
name: Ralph Guide
description: Guidance for customizing Ralph workflows, formulas, learning capture, and troubleshooting. Use for questions about Ralph loop, formulas, harvesting learnings, or running multiple Ralphs.
---

# Ralph Guide

Guidance for customizing and operating Choo Choo Ralph.

## Core Concepts

### The Ralph Loop

Ralph is intentionally simple:

```bash
while [ $iteration -lt $MAX_ITERATIONS ]; do
    available=$(bd list --status=open --assignee=ralph --json | jq -r 'length')
    [ "$available" -eq 0 ] && exit 0

    claude --dangerously-skip-permissions --output-format stream-json -p "
      Run bd list --status=open --assignee=ralph to see available tasks.
      Pick one, claim with bd update <id> --status in_progress, then execute.
    " | ./ralph-format.sh  # Pretty-printed output
done
```

Key insights:

- Uses `--status=open` to filter out `in_progress` tasks at the command level
- Multiple Ralphs can run in parallel - each only sees unclaimed work
- Beads provide persistent memory per task
- Simple loops beat complex orchestration

### Formulas

**Formula**: TOML template defining a workflow (steps, dependencies, prompts)
**Molecule**: Instance of a formula (actual beads with real tasks)

Default formula `choo-choo-ralph` has 4 steps:

1. **bearings** - Understand the codebase
2. **implement** - Make changes
3. **verify** - Run tests/types
4. **commit** - Create git commit

List available formulas: `bd formula list`

### Orchestrator Pattern

When Ralph picks up a molecule root:

1. Orchestrator spawns sub-agents for each step
2. Steps execute in dependency order
3. Progress tracked via comments on each bead
4. Orchestrator closes when all steps complete

## Common Tasks

### Viewing Progress

```bash
bd show <root-id>              # See molecule structure
bd ready --assignee ralph      # What's ready for work
bd blocked                     # What's waiting
bd comments <id>               # Read progress notes
```

### Handling Failures

If Ralph gets stuck:

1. Check the bead: `bd show <id>`
2. Read comments for context: `bd comments <id>`
3. Reset if needed: `bd update <id> --status open`
4. Add guidance: `bd comments add <id> "Try X approach"`

### Observing the Loop

Ralph includes formatted output for monitoring:

```bash
./ralph.sh              # Condensed view
./ralph.sh --verbose    # Full commands, more output, token stats
./ralph.sh 10 -v        # 10 iterations with verbose output
```

Normal mode shows tool names and first line of output. Verbose mode adds:
- Full bash commands (wrapped)
- Up to 10 lines of tool output
- Token summary with cache hit percentage

### Running Multiple Ralphs

Multiple instances can run safely:

- Each claims work by setting `in_progress`
- Won't double-pick same task
- Need multiple ready molecules

```bash
# Terminal 1
./ralph.sh

# Terminal 2 (in same project)
./ralph.sh
```

## Error Handling

Ralph has built-in error handling with a key design principle: **steps report back to orchestrator, orchestrator makes state changes**.

### Implementation Errors (Verify Fails)

When verify finds issues with the current implementation:

1. **Small fixes** (typos, minor issues) → Verify fixes inline and re-verifies
2. **Significant issues** → Verify reports `STATUS: FAIL` to orchestrator
3. **Orchestrator handles rework** → Reopens implement step with `[REWORK]` comment
4. **Attempt tracking** → Each failed attempt logged via `[attempt-N]` comments
5. **After 3 failed attempts** → Orchestrator marks epic `[CRITICAL]` and blocks itself

### Health Check Failures (Previous Work Broke Something)

When bearings finds the app is already broken from previous work:

1. **Bearings reports** `STATUS: HEALTH_CHECK_FAILED` to orchestrator
2. **Orchestrator creates a bug bead** via `bug-fix` formula
3. **Current epic is blocked** on the bug bead
4. **Orchestrator exits**
5. **Once fixed**, original epic becomes ready again automatically

The bug bead tracks:
- What's broken and symptoms
- Related epic (found via git log - commits reference bead IDs)
- Learnings to prevent similar bugs

### Blocked Beads

If a task cannot be resolved after 3 attempts:

1. **Orchestrator blocks itself** - `bd update <id> --status blocked`
2. **Loop continues** - blocked beads don't appear in `bd ready`
3. **Other work continues** - parallel tasks aren't affected
4. **No work left** - loop exits naturally when `bd ready` returns empty

To resolve blocked beads manually:
```bash
# Find blocked beads
bd list --status=blocked

# Review what went wrong
bd comments <bead-id>

# Fix the issue and close, or reopen for another attempt
bd close <bead-id> --reason "Fixed manually"
# or
bd reopen <bead-id>
```

## Continuous Learning

Agents capture learnings as they work, building a knowledge base attached to completed tasks.

### How It Works

1. **Sub-agents comment on root bead** when they encounter gotchas, patterns, or errors
2. **Orchestrator synthesizes** at completion and adds `learnings` label if recommendations exist
3. **User runs `/harvest`** to gather learnings and propose documentation artifacts

### Learning Labels

- `learnings` - Bead has recommendations worth harvesting
- `harvested` - Learnings have been processed into artifacts

### Harvesting Learnings

```bash
/choo-choo-ralph:harvest
```

This command:
1. Finds beads with `learnings` label (not yet `harvested`)
2. Enriches learnings with git context via sub-agents
3. Checks existing docs/skills/CLAUDE.md for deduplication
4. Creates a harvest plan for review
5. On approval, creates artifacts and marks beads as `harvested`

Artifact types:
- **Skills** - Patterns that should auto-trigger
- **CLAUDE.md** - Critical project guidance (root or folder-specific)
- **Reference docs** - Technology-specific documentation

## Additional Resources

### Reference Files

- **`references/formula-customization.md`** - Creating custom formulas (includes learning capture)
- **`references/parallel-execution.md`** - Running multiple Ralphs

### Related Commands

- `/choo-choo-ralph:install` - Set up Ralph
- `/choo-choo-ralph:spec` - Generate spec from plan
- `/choo-choo-ralph:pour` - Create beads from spec
- `/choo-choo-ralph:harvest` - Harvest learnings into docs/skills/CLAUDE.md
