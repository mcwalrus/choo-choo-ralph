---
name: harvest
description: Harvest learnings and gaps from completed Choo Choo Ralph tasks into docs, skills, or AGENTS.md. Use when running /choo-choo-ralph:harvest or extracting knowledge from completed work.
---

# Harvest Learnings and Gaps

Extract valuable learnings from completed Ralph tasks and propose documentation artifacts. Also review identified gaps and create tasks for approved ones.

## Overview

Agents accumulate learnings as they work (gotchas, patterns, recommendations). They also identify gaps - missing functionality, incomplete implementations, or areas needing improvement. This command:

1. Gathers learnings and gaps from completed beads
2. Enriches them with git context
3. Proposes documentation artifacts for learnings
4. Proposes tasks for approved gaps
5. Creates a plan for user review
6. On approval, creates the artifacts, pours gap tasks, and archives the plan

## Mode Detection

1. **No harvest plan exists** - Gather learnings and create new plan
2. **Plan exists with review comments** - Refine plan based on comments
3. **Plan exists, no comments** - Ask: regenerate or proceed to create artifacts?

## Mode 1: Gather Learnings and Gaps

### Step 1: Query Beads with Learnings and Gaps

Find beads that have learning recommendations but haven't been harvested:

```bash
bd list --label learnings --json | jq '[.[] | select(.labels | index("learnings-harvested") | not)]'
```

Find beads that have identified gaps but haven't been processed:

```bash
bd list --label gaps --json | jq '[.[] | select(.labels | index("gaps-harvested") | not)]'
```

If no beads found in either query, report "No unharvested learnings or gaps found" and exit.

### Step 2: Enrich with Git Context

For each learning or gap bead:

1. **Get the bead's commit references** - Check comments for commit hashes or search git log:
   ```bash
   git log --grep="<bead-id>" --oneline
   ```
2. **Analyze modified files** - What files were touched? What patterns emerged?
3. **Read the comments** - Parse `[bearings]`, `[implement]`, `[verify]`, `[summary]` comments
4. **Form enriched summary** - Combine learning/gap with file context

### Step 3: Check Existing Documentation

1. **AGENTS.md files** - Root and folder-specific:
   ```bash
   find . -name "AGENTS.md" 2>/dev/null
   ```

2. **Skills** - Check for existing skills in `.agents/skills/` or `.pi/skills/`

3. **Docs folder** - Check for reference documentation:
   ```bash
   ls -la docs/ 2>/dev/null || echo "No docs directory"
   ```

### Step 4: Deduplicate and Categorize

Group similar learnings and determine the best artifact type:

| Learning Type | Artifact | Location |
|---|---|---|
| Technology pattern | Reference doc | `docs/<tech>.md` |
| Repeated workflow | Skill | `.agents/skills/<pattern>/SKILL.md` |
| Critical project guidance | Root AGENTS.md | `AGENTS.md` |
| Folder-specific pattern | Folder AGENTS.md | `<folder>/AGENTS.md` |

### Step 5: Generate Harvest Plan

Create `.choo-choo-ralph/harvest-plan.md` with proposed artifacts and gaps for review.

## Mode 2: Refine Plan Based on Comments

When plan exists and has review comments, process feedback and regenerate.

## Mode 3: Plan Exists, No Comments

Ask user:
- A) Regenerate plan
- B) Proceed to create artifacts and pour approved gaps
- C) Cancel

## Creating Artifacts and Processing Gaps

### For Each Approved Artifact

1. **Skills** (in `.agents/skills/` or `.pi/skills/`):
   - Create directory with `SKILL.md` file following the Agent Skills standard

2. **AGENTS.md** updates:
   - If root: Append to or create `AGENTS.md`
   - If folder: Create `<folder>/AGENTS.md`

3. **Reference Docs**:
   - Create `docs/<name>.md`

### For Each Approved Gap

1. Pour new task using the choo-choo-ralph formula:
   ```bash
   bd mol pour choo-choo-ralph --var title="<gap title>" --var task="<gap description>" --assignee ralph
   ```

2. Link to source bead with a comment

### After Creating Artifacts

1. Mark beads with learnings label as `learnings-harvested`
2. Mark beads with gaps label as `gaps-harvested`
3. Archive the harvest plan to `.choo-choo-ralph/archive/`
4. Report summary of created artifacts and processed gaps