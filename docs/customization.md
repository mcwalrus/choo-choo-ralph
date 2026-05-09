# Customization Guide

When you install Choo Choo Ralph, you get local copies of shell scripts and formulas in your project. These aren't just configuration—they're yours to modify.

## Why Local Copies?

Different projects have different needs:

- A React app needs UI verification steps; a CLI tool doesn't
- One codebase might need more explicit prompts in the bearings phase
- A legacy project might require extra health checks before implementation
- Some teams want verbose commit messages; others prefer terse

The project provides working defaults, but you control the actual workflow.

## What Gets Installed

| File | Purpose |
|------|---------|
| `./ralph.sh` | Main loop script |
| `./ralph-once.sh` | Single iteration script |
| `./ralph-format.sh` | Output formatting |
| `.beads/formulas/choo-choo-ralph.formula.toml` | Standard workflow formula |
| `.beads/formulas/bug-fix.formula.toml` | Bug fix workflow formula |
| `.choo-choo-ralph/` | Spec file directory |

---

## Shell Scripts

### ralph.sh

The main loop that runs Ralph until tasks are done or a limit is reached.

**Key customization points:**

```bash
# Default iteration limit
MAX_ITERATIONS=100

# The prompt the agent receives
pi --mode json -p "
Run \`bd ready --assignee=ralph -n 100 --sort=priority\` to see available tasks.
..."
```

**Common customizations:**

| What | How |
|------|-----|
| Change default iterations | Edit `MAX_ITERATIONS=100` |
| Different task sorting | Change `--sort=priority` to `--sort=created` |
| Limit visible tasks | Change `-n 100` to `-n 10` |
| Add logging | Add `echo` statements or redirect output |
| Change the prompt | Edit the text passed to `pi -p` |

**Example: Add pre-run health check**

```bash
# Add before the while loop
echo "Running pre-flight health check..."
npm test --silent || { echo "Tests failing, aborting"; exit 1; }
```

### ralph-once.sh

Runs exactly one iteration. Same structure as `ralph.sh` but without the loop.

### ralph-format.sh

Parses the agent's JSON output stream and formats it for the terminal.

**Key customization points:**

```bash
# Colors
BLUE='\033[34m'
GREEN='\033[32m'
# ... etc
```

**Common customizations:**

| What | How |
|------|-----|
| Change colors | Edit the color definitions |
| Show more/less output | Adjust truncation limits |
| Hide certain tools | Add `continue` in the case statement |

---

## Formulas

Formulas define the multi-step workflow Ralph follows. See [Formula Reference](./formulas.md) for complete documentation.

### Quick Overview

The default `choo-choo-ralph.formula.toml` defines:

```
bearings → implement → verify → commit
```

### Common Formula Customizations

**Adjust the bearings health check:**

```toml
# Edit the bearings step description in the formula file
description = """
# BEARINGS PHASE
## STEP 1: Health Check (MANDATORY)
1. **Run test suite** - Execute existing tests
2. **Run type checking** - If applicable
"""
```

**Add a code review step:**

```toml
[[steps]]
id = "review"
title = "Self-review {{title}}"
assignee = "ralph-subagent-review"
labels = ["ralph-step", "review"]
needs = ["implement"]
description = """
Review the implementation for quality and completeness.
"""
```

### Creating Custom Formulas

Create `.beads/formulas/quick-task.formula.toml`:

```toml
formula = "quick-task"
description = """
# Quick Task: {{title}}
{{task}}
## Instructions
1. Make the change described above
2. Run basic verification (tests, types)
3. Commit and close this bead
"""
version = 1
[vars]
title = ""
task = ""
```

Pour manually:
```bash
bd mol pour quick-task --var title="Fix typo" --var task="Fix 'teh' to 'the'" --assignee ralph
```

---

## Spec Directory

```
.choo-choo-ralph/
├── my-feature.spec.md      # Active spec files
├── archive/                # Completed specs
│   └── old-feature.spec.md
├── screenshots/            # UI verification screenshots
└── pour-preview.md         # Preview before pouring
```

---

## Tips

1. **Start with defaults** - Run a few tasks before customizing
2. **Make small changes** - One modification at a time
3. **Test with ralph-once.sh** - Verify changes work before long runs
4. **Keep a changelog** - Note what you changed and why
5. **Check formulas.md** - Deep dive on formula customization