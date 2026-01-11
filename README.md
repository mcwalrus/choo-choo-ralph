# Choo Choo Ralph

A Claude Code plugin for autonomous coding using the Ralph Wiggum technique - simple loops, persistent memory, one task at a time.

## Installation

```bash
claude plugin add mj-meyer/choo-choo-ralph
```

## Commands

| Command | Description |
|---------|-------------|
| `/choo-choo-ralph:install` | Set up Ralph in current project |
| `/choo-choo-ralph:spec` | Generate or refine a spec from your plan |
| `/choo-choo-ralph:pour` | Create beads from approved spec tasks |
| `/choo-choo-ralph:harvest` | Harvest learnings into docs/skills/CLAUDE.md |

## Core Concept

The Ralph Wiggum technique is a deceptively simple approach to autonomous coding:

```
while tasks_remain:
    bead = get_next_ready_bead()
    implement(bead)
    record_progress(bead)
    commit()
```

The key insight is that **simple loops work better than complex orchestration** when the underlying model is capable enough. One task at a time, small focused changes, persistent memory per task.

## Templates

The plugin includes formula templates for running Ralph:

- `choo-choo-ralph.formula.toml` - Main autonomous loop configuration
- `bug-fix.formula.toml` - Bug fixing workflow
- `ralph.sh` / `ralph-once.sh` - Shell scripts for running Ralph

## License

MIT
