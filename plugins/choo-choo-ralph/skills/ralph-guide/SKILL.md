---
name: ralph-guide
description: Guidance for customizing Ralph workflows, formulas, learning capture, and troubleshooting. Use for questions about Ralph loop, formulas, harvesting learnings, or running multiple Ralphs.
---

# Ralph Guide

Quick reference for operating Choo Choo Ralph across all workflow phases.

## The Workflow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   1. Plan   │ ──▶ │  2. Spec    │ ──▶ │  3. Pour    │ ──▶ │  4. Ralph   │ ──▶ │ 5. Harvest  │
│    (you)    │     │  (you + AI) │     │    (AI)     │     │    (AI)     │     │ (you + AI)  │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

1. **Plan** - Write what you want to build (this is on you)
2. **Spec** - AI transforms it into structured tasks; you review and refine
3. **Pour** - Tasks become beads (workflow or singular)
4. **Ralph** - The loop runs autonomously until done
5. **Harvest** - Extract learnings into skills, docs, or AGENTS.md

See the docs directory for the complete guide.

## Prerequisites & Safety

**Required:**
- [Choo Choo Ralph](https://github.com/mj-meyer/choo-choo-ralph) - Autonomous coding harness
- [Beads](https://github.com/steveyegge/beads) - Git-backed issue tracker (`bd` command)
- [jq](https://jqlang.github.io/jq/) - JSON parsing

**Safety:** Ralph runs with full system access (pi has no permission popups by design). Run in a container or VM, especially for untrusted codebases.

## Install

The install command sets up local copies you can customize:

| File | Purpose |
|------|---------|
| `./ralph.sh` | Main loop script |
| `./ralph-once.sh` | Single iteration (for testing) |
| `./ralph-format.sh` | Output formatting |
| `.beads/formulas/choo-choo-ralph.formula.toml` | Standard workflow formula |
| `.beads/formulas/bug-fix.formula.toml` | Bug fix workflow formula |
| `.choo-choo-ralph/` | Spec file directory |

## Spec Phase

### Generate a Spec

Specs are stored at `.choo-choo-ralph/{spec-name}.spec.md`

### Spec Format

Tasks use XML-like tags with a review workflow:

```xml
<task id="add-login-form" priority="1" category="functional">
  <title>Add Login Form Component</title>
  <description>Create a reusable login form...</description>
  <steps>
    1. Create LoginForm component
    2. Add validation
  </steps>
  <test_steps>
    1. Verify form renders
    2. Test validation
  </test_steps>
  <review></review>  <!-- Empty = ready to pour -->
</task>
```

### Review Process

1. **Add feedback** in `<review>` tags
2. **Run spec again** - AI processes feedback
3. **Repeat** until all `<review>` tags are empty

See `docs/spec-format.md` for complete format reference.

## Pour Phase

### What Happens

1. Tasks created as beads in `.beads/issues/`
2. Spec's `poured` array updated with bead IDs
3. Spec archived to `.choo-choo-ralph/archive/`
4. Tasks ready for Ralph

## Ralph Loop

### Running Ralph

```bash
./ralph.sh              # Default iterations
./ralph.sh 50           # Run up to 50 tasks
./ralph.sh --verbose    # Detailed output
./ralph.sh 20 -v        # 20 iterations, verbose
```

Test before a long run:
```bash
./ralph-once.sh         # Exactly one iteration
```

### How It Works

```bash
while [ $iteration -lt $MAX_ITERATIONS ]; do
    available=$(bd ready --assignee=ralph --json | jq -r 'length')
    [ "$available" -eq 0 ] && exit 0

    pi --mode json -p "
      Run bd ready --assignee=ralph to see available tasks.
      Pick one, claim with bd update <id> --status in_progress, then execute.
    " | ./ralph-format.sh
done
```

Key insights:
- Uses `bd ready` to find unclaimed work
- Multiple Ralphs can run in parallel - each only sees unclaimed work
- Beads provide persistent memory per task

### Core Concepts

**Formula**: TOML template defining a workflow (steps, dependencies, prompts)
**Molecule**: Instance of a formula (actual beads with real tasks)

Default `choo-choo-ralph` formula has 4 steps:
1. **bearings** - Health check and codebase understanding
2. **implement** - Make changes
3. **verify** - Run tests/types
4. **commit** - Create git commit

**Orchestrator Pattern**: When Ralph picks up a molecule root:
1. Executes each step in dependency order
2. Steps execute according to their assignee type (subagent or inline)
3. Progress tracked via comments
4. Closes when all steps complete

### Viewing Progress

```bash
bd show <root-id>              # See molecule structure
bd ready --assignee ralph      # What's ready for work
bd blocked                     # What's waiting
bd comments <id>               # Read progress notes
bd list --status in_progress   # Currently active tasks
```

### Running Multiple Ralphs

Multiple instances run safely in parallel - each claims work by setting `in_progress`.

## Error Handling

### Verification Failures

1. Small fixes → Verify fixes inline and re-verifies
2. Significant issues → Reports `STATUS: FAIL` to orchestrator
3. After 3 failures → Molecule marked blocked

### Health Check Failures

1. Bearings reports `STATUS: HEALTH_CHECK_FAILED`
2. Orchestrator creates bug bead via `bug-fix` formula
3. Current molecule blocked on the bug bead

## Harvest Phase

### Capturing Learnings

Agents capture insights using comment tags:
- **[LEARNING]** - Useful discoveries (patterns, gotchas, conventions)
- **[GAP]** - Missing work or incomplete implementations

**Artifact types:**
- **Skills** - Patterns that should auto-trigger
- **AGENTS.md** - Critical project guidance
- **Reference docs** - Technology-specific documentation
- **Gap tasks** - New beads for approved gaps

### Labels

| Label | Meaning |
|-------|---------|
| `learnings` | Bead has recommendations worth harvesting |
| `learnings-harvested` | Learnings have been processed |
| `gaps` | Contains identified gaps |
| `gaps-harvested` | Gaps have been processed |

## Customization

All installed files are yours to modify.

### Shell Scripts

**ralph.sh customization points:**
- `MAX_ITERATIONS=100` - Default iteration limit
- The prompt passed to `pi --mode json -p` - Add project-specific guidance

### Formulas

Edit `.beads/formulas/choo-choo-ralph.formula.toml`:
- Add/remove steps
- Modify step prompts
- Change assignee patterns
- Add conditional steps

### Assignee Conventions

| Prefix | Execution |
|--------|-----------|
| `ralph` | Picked up by Ralph loop |
| `ralph-subagent-*` | Executed as separate task (beads molecule step) |
| `ralph-inline-*` | Executed by orchestrator directly |

## Troubleshooting

### Common Issues

**Tasks not being picked up:**
```bash
bd show <bead-id>                    # Check status and assignee
bd update <bead-id> --assignee ralph # Assign to Ralph
bd update <bead-id> --status open    # Set status
bd dep <bead-id>                     # Check for blockers
```

### Recovery Procedures

**Session recovery (mid-task crash):**
```bash
bd list --status=in_progress --assignee=ralph  # Find in-progress task
bd comments <bead-id>                          # Review progress
bd update <bead-id> --status open              # Reopen to retry
```

### Debugging

```bash
./ralph-once.sh          # Test single iteration
./ralph.sh -v            # Verbose output
bd comments <bead-id>    # View task history
bd show <root-id>        # Inspect molecule structure
```

## Documentation

- **`docs/workflow.md`** - Complete workflow guide
- **`docs/spec-format.md`** - Spec file format reference
- **`docs/commands.md`** - All commands with examples
- **`docs/formulas.md`** - Formula reference and customization
- **`docs/customization.md`** - Customizing Ralph for your project
- **`docs/troubleshooting.md`** - Common issues and solutions

### Commands

| Command | Purpose |
|---------|---------|
| `/choo-choo-ralph:install` | Set up Ralph in project |
| `/choo-choo-ralph:spec` | Generate/refine spec from plan |
| `/choo-choo-ralph:pour` | Create beads from spec |
| `/choo-choo-ralph:harvest` | Extract learnings |
| `./ralph.sh` | Run Ralph loop |
| `./ralph-once.sh` | Run single task |