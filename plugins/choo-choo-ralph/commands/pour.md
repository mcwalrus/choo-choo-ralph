---
description: Create Ralph beads from ready tasks in a spec file or conversation context
argument-hint: [target-tasks] [spec-file] [formula] 
---

# Pour into Beads

## Arguments

<arguments>
  target_tasks = $1  <!-- Optional: target number of implementation tasks -->
  spec_file = $2     <!-- Optional: spec file name or path to pour from --> 
  formula = $3       <!-- Optional: formula name to use (default: auto-detect) -->
</arguments>

Create beads from ready tasks in a spec file, or directly from conversation context.

## Spec File Resolution

When `spec_name` is provided:

- If it's a path (contains `/` or ends in `.md`): use directly
- If it's just a name: look for `.choo-choo-ralph/{spec_name}.spec.md`

When `spec_name` is NOT provided:

1. **Check for existing specs** in `.choo-choo-ralph/*.spec.md`
2. **If exactly one spec exists**: Use that spec automatically
3. **If multiple specs exist**: Ask user which spec to pour using AskUserQuestion
4. **If no specs exist**: Fall back to conversation mode

## Modes

### From Spec File (Recommended)

If spec file is found:

- Parse ready tasks (empty `<review>` tag)
- Skip tasks that need refinement (have content in `<review>` tag)
- Create one molecule per ready task
- Archive spec after pouring all tasks

### From Conversation (Quick Start)

If no spec file provided or found:

1. Extract tasks from conversation context
2. **STOP and use AskUserQuestion** - Do NOT proceed without user confirmation:

   ```
   Question: "No spec file found. How would you like to proceed with these tasks?"
   [List extracted tasks]

   Options:
   - Pour directly - Create beads immediately from these tasks
   - Create spec first (Recommended) - Run /spec for reviewable task breakdown
   - Cancel - Stop without creating anything
   ```

3. **Wait for user response** before taking any action
4. If user chooses "Pour directly": create molecules from extracted tasks
5. If user chooses "Create spec first": run `/choo-choo-ralph:spec` command
6. If user chooses "Cancel": stop and report cancellation

## Workflow Mode Selection

After determining the source (spec file or conversation), ask the user how they want to pour the tasks using **AskUserQuestion**:

```
Question: "How would you like to pour these tasks?"
Header: "Workflow"

Options:
- Use workflow formula (Recommended) - Multi-step workflow with structured phases like health checks, implementation, verification, and commit. Best for production features.
- Create singular tasks - Simple beads executed directly. Good for exploratory work, research, prototyping, or one-off tasks.
```

**If "Use workflow formula"**: Proceed to Formula Selection below.

**If "Create singular tasks"**: Skip Formula Selection entirely and go straight to task breakdown. Tasks will be created with `bd create` instead of `bd mol pour`.

## Formula Selection

**Note:** This section only applies when "Use workflow formula" is chosen above.

1. If `formula` provided, use that formula
2. Otherwise, run `bd formula list`:
   - If only one formula exists, use it automatically
   - If multiple formulas exist, ask user to choose

## Task Granularity (CRITICAL)

**Spec tasks are NOT implementation tasks.** Each spec task must be broken down into multiple granular implementation tasks (molecules).

### The Breakdown Process

1. **Spec tasks** = High-level features/capabilities from the spec
2. **Implementation tasks** = Granular, atomic units of work (molecules)
3. **Formula steps** = Workflow phases within each task (bearings, implement, verify, commit) - these are NOT counted toward task granularity
**Guidelines:**

- *Simplicity and brevity win.* Verbose task descriptions degrade agent determinism. If you can't describe the task in 1-2 sentences, it's probably too coarse. If the description needs a paragraph, split it.

- *Let the spec drive the count.* Don't manufacture sub-tasks to hit a number. If a spec task is already clear and independently verifiable, pour it as one molecule. Split only on natural seams — data model, API layer, UI, infrastructure — not artificially.

**Example:**

- Spec has 10 high-level tasks
- Each spec task breaks down into 5-10 implementation tasks
- Target: 50-100 implementation tasks (molecules)
- Formula steps (6 per molecule) are internal workflow, NOT part of task count.

### What Makes a Good Implementation Task

Each implementation task (molecule) should be a **coherent slice of work**:

- **Cohesive**: All changes belong together logically (e.g., frontend + backend for one feature slice is fine)
- **Testable together**: Can be verified as a unit - the changes make sense to test together
- **Complete slice**: Delivers a piece of functionality, not just a layer or file change
- **Reasonable scope**: Not so big it's hard to review, not so small it's wasteful

**TOO GRANULAR (bad):**

- "Install package X" then "Install package Y" then "Install package Z" as separate tasks
- "Update users.ts" then "Update users.test.ts" then "Update users.types.ts" as separate tasks
- Breaking apart changes that only make sense together

**TOO COARSE (bad):**

- "Build entire authentication system" (frontend + backend + infrastructure + tests all in one)
- Combining unrelated features into one task
- Tasks that would take hours to review

**JUST RIGHT:**

- "Add login form with validation" - includes component, styles, validation logic, tested together
- "Implement login API endpoint" - includes route, controller, validation, tests for that endpoint
- "Add password reset flow" - frontend + backend for this specific slice, can be tested end-to-end

**Key question:** Can this slice be implemented, committed, and tested as one coherent unit? If yes, it's the right size.

## Process

1. **Determine source**: Spec file or conversation
2. **Select workflow mode**: Ask user (see "Workflow Mode Selection" above):
   - If "Use workflow formula": proceed to step 3
   - If "Create singular tasks": skip to step 4 (no formula needed)
3. **Select formula** (workflow formula mode only): Use provided, auto-select, or prompt
4. **Parse spec tasks**: Extract high-level tasks from source
5. **Break down into implementation tasks** (CRITICAL):
   - Each spec task → multiple granular implementation tasks
   - Target 5-10 implementation tasks per spec task
   - Each implementation task = one molecule (or singular task)
6. **Read spec frontmatter variables** (workflow formula mode only): Extract optional fields for formula variables:
   - `auto_discovery` (default: `false`) - Enable auto task creation from gaps
   - `auto_learnings` (default: `false`) - Enable auto skill creation from learnings
7. **Generate test steps**: Create granular test steps for each implementation task
8. **Confirm with user** (AskUserQuestion):

   Present a summary and let user choose:

   **For workflow formula mode:**
   ```
   "Ready to pour tasks from spec."

   Spec tasks: 27
   Implementation tasks: ~135 (after breakdown)
   Formula: choo-choo-ralph (6 workflow steps each)

   Options:
   - Pour all tasks (Recommended) - Proceed with pouring
   - Show task overview first - Review all tasks before pouring
   - Cancel - Stop without pouring
   ```

   **For singular task mode:**
   ```
   "Ready to pour singular tasks from spec."

   Spec tasks: 27
   Implementation tasks: ~135 (after breakdown)
   Mode: Singular tasks (direct execution, no workflow steps)

   Options:
   - Pour all tasks (Recommended) - Proceed with pouring
   - Show task overview first - Review all tasks before pouring
   - Cancel - Stop without pouring
   ```

   **If "Show task overview first":**
   - Save full breakdown to `.choo-choo-ralph/pour-preview.md`

   **If "Pour all tasks":** Continue to step 9

9. **Pour tasks**:

   > **⚠️ CRITICAL: Assignee Requirement**
   > ALL poured tasks MUST include `--assignee ralph`.

   **For workflow formula mode**, for each implementation task:
   ```bash
   bd --no-daemon mol pour <FORMULA_NAME> \
     --var title="<TASK_TITLE>" \
     --var task="<TASK_DESCRIPTION>" \
     --var category="<TASK_CATEGORY>" \
     --var auto_discovery="<SPEC_AUTO_DISCOVERY>" \
     --var auto_learnings="<SPEC_AUTO_LEARNINGS>" \
     --assignee ralph
   ```

   Notes for formula mode:
   - Use `bd mol pour` (not `bd formula pour`)
   - Use `--var` for variables (not `--set`)
   - `<TASK_DESCRIPTION>` should include the generated test steps
   - **Capture the root bead ID** from each `bd mol pour` output

   **For singular task mode**, for each implementation task:
   ```bash
   bd --no-daemon create "<TASK_TITLE>" \
     --description "<TASK_DESCRIPTION_WITH_TEMPLATE>" \
     --assignee ralph \
     --labels "<TASK_CATEGORY>"
   ```

   ### Singular Task Description Template

   ```markdown
   ## Task
   <TASK_DESCRIPTION>

   ## Test Steps
   <TASK_TEST_STEPS>

   ## Execution
   Execute this task directly. When complete:
   1. Add a summary comment: `bd comments add <your-id> "[summary] <what was done>"`
   2. Close the bead: `bd close <your-id>`

   ## Capturing Gaps
   If you discover missing work that's clearly needed:
   ```bash
   bd comments add <your-id> "[GAP] <title> - <description>"
   ```

   ## Capturing Learnings
   If you encounter something noteworthy:
   ```bash
   bd comments add <your-id> "[LEARNING] <description>"
   ```
   ```

10. **Set priority on each root bead**:
    - Run: `bd update <bead-id> --priority <TASK_PRIORITY>`
    - Priority values: 0-4 (0=critical, 1=high, 2=medium, 3=low, 4=backlog)

11. **Verify assignees** (REQUIRED):
    - For each bead ID, run: `bd show <bead-id>` and check the Assignee field
    - Fix any missing assignees: `bd update <bead-id> --assignee ralph`
    - Report: "Verified N tasks assigned to ralph (fixed M)"

12. **Update spec frontmatter**: Update the `poured` array with created bead IDs

13. **Archive spec**: Move spec to `.choo-choo-ralph/archive/` after all tasks poured

## Error Recovery

If `bd mol pour` or `bd create` fails mid-way:

1. **Identify failed task**: Note which task failed and the error message
2. **Rollback partial state**: Delete any orphaned beads: `bd delete <partial-bead-id>`
3. **Report to user**: List successful tasks, identify failure, suggest fix
4. **Resume option**: User fixes the issue, then runs pour again

## Spec Archiving

After successfully pouring **all ready tasks** from a spec:

1. **Create archive directory** if needed: `.choo-choo-ralph/archive/`
2. **Move the spec file** to archive
3. **Report**: "Spec archived to .choo-choo-ralph/archive/my-feature.spec.md"

## Handling Review Comments

If tasks have content in `<review>` tags, use **AskUserQuestion**:

```
"Some tasks have review comments that haven't been processed."

Options:
- Run /spec first (Recommended) - Process review feedback before pouring
- Ignore and pour all - Pour tasks as-is, ignoring review comments
- Cancel - Stop and let me review the spec manually
```

## Output

**For workflow formula mode:**
- N tasks poured using <FORMULA_NAME> formula
- Root bead IDs for each
- Command to start: `./ralph.sh`

**For singular task mode:**
- N singular tasks created
- Bead IDs for each
- Command to start: `./ralph.sh`