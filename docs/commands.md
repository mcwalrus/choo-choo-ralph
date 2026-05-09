# Commands Reference

Complete reference for all Choo Choo Ralph commands with options and examples.

## /choo-choo-ralph:install

Set up Choo Choo Ralph in your project by copying local, customizable files.

### Usage

```
/choo-choo-ralph:install
```

### What It Does

1. **Checks prerequisites** - Verifies bd (beads), pi, and jq are installed
2. **Initializes beads** - Runs `bd init` if .beads directory doesn't exist
3. **Copies shell scripts** - ralph.sh, ralph-once.sh, ralph-format.sh to project root
4. **Copies formulas** - choo-choo-ralph and bug-fix formula templates to `.beads/formulas/`
5. **Creates spec directory** - .choo-choo-ralph/ for spec files

### Files Created

| File | Purpose |
|------|---------|
| `./ralph.sh` | Main loop script - runs tasks until done or limit reached |
| `./ralph-once.sh` | Single task script - test one iteration before a long run |
| `./ralph-format.sh` | Output formatting - controls how Ralph's progress displays |
| `.beads/formulas/choo-choo-ralph.formula.toml` | Standard workflow formula (bearings → implement → verify → commit) |
| `.beads/formulas/bug-fix.formula.toml` | Bug fix workflow formula (diagnose → fix → verify → commit) |
| `.choo-choo-ralph/` | Directory for spec files |

---

## /choo-choo-ralph:spec

Generate or refine a spec file from a plan or conversation context.

### Usage

```
/choo-choo-ralph:spec [source-file] [spec-name]
```

### Arguments

| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `source-file` | No | Conversation context | Path to plan file |
| `spec-name` | No | Auto-detected | Name for the spec file |

### Examples

```
/choo-choo-ralph:spec docs/feature-plan.md auth-system
/choo-choo-ralph:spec
```

---

## /choo-choo-ralph:pour

Convert spec tasks into beads (issues) for Ralph to work on.

### Usage

```
/choo-choo-ralph:pour [target-tasks] [spec-file] [formula]
```

### Arguments

| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `target-tasks` | No | Project-size based | Number of tasks to create |
| `spec-file` | No | Most recent spec | Path to spec file |
| `formula` | No | Interactive prompt | Formula to use |

### Examples

```
/choo-choo-ralph:pour
/choo-choo-ralph:pour 5
/choo-choo-ralph:pour 8 .choo-choo-ralph/auth-system.spec.md choo-choo-ralph
```

---

## /choo-choo-ralph:harvest

Extract learnings from completed tasks into documentation, skills, or AGENTS.md.

### Usage

```
/choo-choo-ralph:harvest
```

### What It Creates

| Output Type | Description |
|-------------|-------------|
| **Skills** | New skill files for reusable patterns |
| **AGENTS.md updates** | Project-specific guidance |
| **Reference docs** | Documentation for complex implementations |
| **Gap tasks** | New beads for approved gaps |

---

## BD Commands Reference

### View Tasks

```bash
bd ready --assignee ralph              # Ready tasks
bd show <bead-id>                      # Task details
bd comments <bead-id>                  # Task history
bd list --status=open --assignee=ralph # Open tasks
bd list --status=blocked               # Blocked tasks
```

### Manual Intervention

```bash
bd update <bead-id> --status open      # Reopen task
bd update <bead-id> --status blocked   # Block task
bd close <bead-id> --reason "Done"     # Close task
bd update <bead-id> --assignee ralph   # Reassign
bd update <bead-id> --priority high    # Update priority
```

### Formulas

```bash
bd formula list                        # List formulas
bd mol pour choo-choo-ralph \
  --var title="Title" \
  --var task="Description" \
  --assignee ralph                      # Create task manually
```

### Dependencies

```bash
bd dep add <bead-id> --blocks <other>  # Add dependency
bd dep remove <bead-id> --blocks <x>   # Remove dependency
bd show <bead-id> --deps               # View dependencies
```

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `/choo-choo-ralph:install` | Set up Ralph in project |
| `/choo-choo-ralph:spec` | Generate/refine spec file |
| `/choo-choo-ralph:pour` | Create beads from spec |
| `/choo-choo-ralph:harvest` | Extract learnings |
| `./ralph.sh` | Run Ralph loop |
| `./ralph-once.sh` | Run single task |
| `bd ready --assignee ralph` | See queued tasks |
| `bd show <id>` | View task details |