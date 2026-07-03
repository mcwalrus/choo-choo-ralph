---
name: install
description: Install Choo Choo Ralph into the current project. Use when the user asks to install, set up, or bootstrap Choo Choo Ralph / the Ralph autonomous coding workflow.
---

# Install Choo Choo Ralph

Set up the Ralph autonomous coding workflow in this project.

## Pre-requisites Check

1. **Check beads CLI**: Run `bd --version`
   - If not installed: "Please install beads first. See: https://github.com/steveyegge/beads"

2. **Check pi CLI**: Run `pi --version`
   - If not installed: Warn user they'll need it to run Ralph

3. **Check jq**: Run `jq --version`
   - If not installed: "Please install jq for JSON parsing. See: https://jqlang.github.io/jq/"

4. **Initialize beads**: If `.beads/` doesn't exist, run `bd init`

## Check for Existing Files

Before installing, check which files already exist:
- `./ralph.sh`
- `./ralph-once.sh`
- `./ralph-format.sh`
- `./ralph-observe.sh`
- `.beads/formulas/choo-choo-ralph.formula.toml`
- `.beads/formulas/bug-fix.formula.toml`

**If ANY files exist**: Use AskUserQuestion to ask user for each existing file whether to:
- Skip (keep existing)
- Overwrite (replace with new version)

**If NO files exist**: Proceed directly to installation.

## Installation Steps

Use Bash `cp` commands for fast file copying (NOT Read/Write tools).

This skill's templates live in a `templates/` directory next to this
SKILL.md file. Resolve that directory from this skill's location (given to
you in context as this file's path) and use it as `$SKILL_DIR` below:

```bash
SKILL_DIR="$(dirname "<path to this SKILL.md>")"
```

1. **Copy shell scripts** to project root (if not skipped):
   ```bash
   cp "${SKILL_DIR}/templates/ralph.sh" ./ralph.sh
   cp "${SKILL_DIR}/templates/ralph-once.sh" ./ralph-once.sh
   cp "${SKILL_DIR}/templates/ralph-format.sh" ./ralph-format.sh
   cp "${SKILL_DIR}/templates/ralph-observe.sh" ./ralph-observe.sh
   chmod +x ralph.sh ralph-once.sh ralph-format.sh ralph-observe.sh
   ```

2. **Set up formulas directory**:
   ```bash
   mkdir -p .beads/formulas
   cp "${SKILL_DIR}/templates/choo-choo-ralph.formula.toml" .beads/formulas/
   cp "${SKILL_DIR}/templates/bug-fix.formula.toml" .beads/formulas/
   ```

3. **Create spec directory**:
   ```bash
   mkdir -p .choo-choo-ralph
   ```

4. **Verify installation**:
   - Confirm all files exist
   - Run `bd formula list` to verify both formulas are registered (choo-choo-ralph and bug-fix)

## Recommended Plugins

1. **Check dev-browser plugin**: Check your available skills for `dev-browser`
   - If not available, recommend installing it for browser-based smoke tests and UI verification
   - GitHub: https://github.com/SawyerHood/dev-browser
   - This plugin is used by the bearings step (smoke test) and verify step (UI verification)

## Output

Report what was installed (and what was skipped if applicable):

- Scripts: ralph.sh, ralph-once.sh, ralph-format.sh, ralph-observe.sh
- Formulas: .beads/formulas/choo-choo-ralph.formula.toml, .beads/formulas/bug-fix.formula.toml
- Spec directory: .choo-choo-ralph/

Explain next steps:

1. Use `/spec` to generate a spec from your plan
2. Review and approve features in the spec
3. Use `/pour` to create beads
4. Run `./ralph.sh` to start the autonomous loop (or `./ralph-observe.sh` for human-in-the-loop mode)
