# Formula Customization Reference

This reference covers creating custom formulas for Choo Choo Ralph. Formulas define reusable workflow templates that the Ralph orchestrator uses to structure task execution.

## Formula Structure

Formulas use TOML format with a standard structure:

```toml
formula = "formula-name"
description = """
Orchestrator prompt that guides Ralph through the workflow.
This is the system prompt Ralph uses when executing this formula.
"""
version = "1.0.0"
type = "proto"

[vars]
title = "Task title placeholder"
task = "Task description placeholder"

[[steps]]
id = "step-1"
title = "{{title}} - Step 1"
assignee = "ralph-subagent-worker"
needs = []
description = """
Instructions for this step.
"""

[[steps]]
id = "step-2"
title = "{{title}} - Step 2"
assignee = "ralph-subagent-verifier"
needs = ["step-1"]
description = """
Instructions for this step.
"""
```

## Required for Ralph Compatibility

### Root Level Requirements

| Field | Required | Description |
|-------|----------|-------------|
| `formula` | Yes | Unique identifier for the formula |
| `description` | Yes | Orchestrator prompt (see below) |
| `version` | No | Semantic version string |
| `type` | No | Usually "proto" for templates |
| `vars.title` | Yes | Placeholder for task title |
| `vars.task` | Yes | Placeholder for task description |

### Step Requirements

Each step must include:

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique step identifier within formula |
| `title` | Yes | Step title, should include `{{title}}` |
| `assignee` | Yes | Who executes this step (see conventions) |
| `needs` | Yes | Array of step IDs this step depends on |
| `description` | Yes | Self-contained instructions for the step |

## Assignee Conventions

The `assignee` field determines how Ralph executes each step:

### `ralph`

The root orchestrator. Set via `--assignee` at pour time:

```bash
bd pour my-formula --assignee ralph --set title="My Task" --set task="Do something"
```

Use for the main coordination step if your formula has one.

### `ralph-subagent-*`

Steps spawned as Task sub-agents. These run in separate Claude sessions:

- `ralph-subagent-implementer` - For implementation work
- `ralph-subagent-reviewer` - For code review
- `ralph-subagent-tester` - For test writing
- `ralph-subagent-researcher` - For research tasks

Sub-agents are isolated and can run in parallel if their `needs` allow.

### `ralph-inline-*`

Steps executed by the orchestrator directly without spawning a sub-agent:

- `ralph-inline-validator` - Quick validation checks
- `ralph-inline-committer` - Git commit operations
- `ralph-inline-coordinator` - Coordination between steps

Use inline steps for lightweight operations that don't need full agent context.

## Orchestrator Prompt Design

The `description` field at the root level is the orchestrator prompt. Include these sections:

```toml
description = """
## Role
You are Ralph, an autonomous coding agent executing a {{formula}} workflow.

## Task Context
Title: {{title}}
Description: {{task}}

## Workflow Overview
Brief description of what this formula accomplishes and the general flow.

## Execution Guidelines
- How to handle step transitions
- When to mark steps complete
- Error handling expectations

## Completion Criteria
What constitutes successful completion of the entire workflow.

## Notes
Any formula-specific guidance or constraints.
"""
```

### Key Sections

1. **Role**: Establish Ralph's identity and the workflow type
2. **Task Context**: Reference the vars so Ralph knows what to build
3. **Workflow Overview**: High-level understanding of the formula
4. **Execution Guidelines**: Behavioral expectations
5. **Completion Criteria**: Clear success conditions

## Step Description Design

Each step's `description` should be self-contained:

```toml
[[steps]]
id = "implement"
title = "{{title}} - Implementation"
assignee = "ralph-subagent-implementer"
needs = []
description = """
## Objective
Implement the feature described in the parent task.

## Context
You are implementing: {{task}}

## Requirements
1. Follow existing code patterns
2. Add appropriate error handling
3. Include inline documentation

## Deliverables
- Working implementation
- No type errors
- Passes existing tests

## Completion
Mark complete when implementation compiles and tests pass.
"""
```

### Best Practices

- Include objective, context, requirements, deliverables, and completion criteria
- Reference `{{title}}` and `{{task}}` where relevant
- Be specific about what "done" looks like
- Avoid dependencies on external context not in the description

## Example Formulas

### Minimal 2-Step (Implement + Verify)

```toml
formula = "quick-fix"
description = """
## Role
You are Ralph executing a quick fix workflow.

## Task
{{title}}: {{task}}

## Workflow
1. Implement the fix
2. Verify it works

Complete when the fix is verified and committed.
"""
version = "1.0.0"
type = "proto"

[vars]
title = "Quick Fix"
task = "Fix the issue"

[[steps]]
id = "implement"
title = "{{title}} - Implement"
assignee = "ralph-subagent-implementer"
needs = []
description = """
## Objective
Implement the fix for: {{task}}

## Requirements
- Make minimal changes
- Ensure no regressions
- Run type checker

## Completion
Done when fix is implemented and types check.
"""

[[steps]]
id = "verify"
title = "{{title}} - Verify"
assignee = "ralph-inline-validator"
needs = ["implement"]
description = """
## Objective
Verify the fix works correctly.

## Checks
1. Run tests: `bun test`
2. Type check: `bun typecheck`
3. Manual verification if applicable

## Completion
Done when all checks pass. Commit the changes.
"""
```

### Research Formula (No Commit)

```toml
formula = "research"
description = """
## Role
You are Ralph conducting research.

## Task
{{title}}: {{task}}

## Workflow
1. Investigate the topic
2. Document findings

This is a research-only workflow. Do not make code changes.
"""
version = "1.0.0"
type = "proto"

[vars]
title = "Research Task"
task = "Research the topic"

[[steps]]
id = "investigate"
title = "{{title}} - Investigate"
assignee = "ralph-subagent-researcher"
needs = []
description = """
## Objective
Research: {{task}}

## Approach
1. Search the codebase for relevant patterns
2. Review documentation
3. Identify key findings

## Deliverables
Add findings as comments to this issue.

## Constraints
- Read-only: do not modify code
- Focus on understanding, not implementation
"""

[[steps]]
id = "summarize"
title = "{{title}} - Summarize"
assignee = "ralph-inline-coordinator"
needs = ["investigate"]
description = """
## Objective
Compile research findings into actionable summary.

## Output
Add a final comment with:
- Key findings
- Recommendations
- Next steps

Mark the research task complete.
"""
```

### Full Feature 6-Step

```toml
formula = "feature-complete"
description = """
## Role
You are Ralph implementing a complete feature with full verification.

## Task
{{title}}: {{task}}

## Workflow
1. Analyze requirements
2. Design solution
3. Implement feature
4. Write tests
5. Review code
6. Final verification

Commit after implementation and tests pass.
"""
version = "1.0.0"
type = "proto"

[vars]
title = "Feature"
task = "Implement the feature"

[[steps]]
id = "analyze"
title = "{{title}} - Analyze"
assignee = "ralph-subagent-researcher"
needs = []
description = """
## Objective
Analyze requirements for: {{task}}

## Deliverables
- Identify affected files
- Note existing patterns to follow
- List potential challenges

Add analysis as comment to this issue.
"""

[[steps]]
id = "design"
title = "{{title}} - Design"
assignee = "ralph-subagent-researcher"
needs = ["analyze"]
description = """
## Objective
Design the solution approach.

## Deliverables
- High-level approach
- Key interfaces/types
- Integration points

Add design notes as comment.
"""

[[steps]]
id = "implement"
title = "{{title}} - Implement"
assignee = "ralph-subagent-implementer"
needs = ["design"]
description = """
## Objective
Implement: {{task}}

## Requirements
- Follow the design from previous step
- Match existing code patterns
- Include error handling
- Add JSDoc comments

## Completion
Done when implementation compiles without errors.
"""

[[steps]]
id = "test"
title = "{{title}} - Test"
assignee = "ralph-subagent-tester"
needs = ["implement"]
description = """
## Objective
Write tests for the new feature.

## Requirements
- Unit tests for new functions
- Integration tests if applicable
- Edge case coverage

## Completion
Done when tests are written and passing.
"""

[[steps]]
id = "review"
title = "{{title}} - Review"
assignee = "ralph-subagent-reviewer"
needs = ["test"]
description = """
## Objective
Review the implementation and tests.

## Checklist
- [ ] Code follows project conventions
- [ ] Error handling is appropriate
- [ ] Tests cover main scenarios
- [ ] No obvious issues

## Output
Add review comments. Request changes if needed.
"""

[[steps]]
id = "verify"
title = "{{title}} - Verify"
assignee = "ralph-inline-validator"
needs = ["review"]
description = """
## Objective
Final verification and commit.

## Checks
1. `bun typecheck` passes
2. `bun test` passes
3. `bun build` succeeds

## Completion
Commit with message referencing the task ID.
Mark the feature complete.
"""
```

## Adding Learning Capture

Custom formulas should include learning capture so agents can document patterns, gotchas, and recommendations for future work. This creates a persistent knowledge base attached to completed tasks.

### How It Works

1. **Sub-agents comment on the root bead** when they encounter something noteworthy
2. **Orchestrator synthesizes** learnings before closing
3. **Users review later** and extract valuable patterns into skills or CLAUDE.md

### Step-Level Learning Instructions

Add a "Learnings" section to each step's description:

```toml
[[steps]]
id = "implement"
title = "{{title}} - Implement"
assignee = "ralph-subagent-implementer"
needs = ["analyze"]
description = """
## Objective
Implement: {{task}}

## Requirements
- Follow existing patterns
- Add error handling
- Include tests

## Output
Add a comment to THIS bead summarizing what was changed.

## Learnings (if applicable)
If you encountered something noteworthy, add a comment to the ROOT/PARENT bead:
- An error you struggled with and how you fixed it
- A pattern you had to follow that wasn't documented
- A library/component usage gotcha future agents should know
- Something that might warrant a skill (e.g., "always use X when doing Y")

Use: `bd comments add <root-id> "[implement] <your learning>"`

Only add learnings for non-obvious issues. Routine work doesn't need a learning comment.

## Completion
Done when implementation compiles and tests pass.
"""
```

### What Each Step Should Capture

| Step Type | Learning Focus |
|-----------|---------------|
| Research/Analysis | Codebase patterns, conventions, missing docs |
| Implementation | Errors and fixes, undocumented patterns, library gotchas |
| Testing/Verification | Test failure patterns, verification gotchas, common errors |
| Review | Code quality issues, architectural concerns |

### Orchestrator Synthesis

Add synthesis instructions to the orchestrator's completion section:

```toml
description = """
...

## Completion
When all steps are closed:

1. **Review learning comments** - Check for `[step-name]` comments on your bead
2. **Synthesize patterns** - If learnings were added, consider:
   - Do they reveal a pattern that should be documented?
   - Is there a recurring issue that warrants a skill?
   - Should something be added to CLAUDE.md?
3. **Add summary comment**:
   `bd comments add <your-id> "[summary] Completed: <what>. Patterns noted: <if any>. Recommendation: <if warranted>"`
4. **Close yourself** with `bd close <your-id>`

### Learning Synthesis Guidelines
- Multiple steps report similar issues → likely warrants documentation
- CLAUDE.md should have mentioned something → note "Consider adding to CLAUDE.md: ..."
- Pattern keeps appearing → note "Consider creating skill for: ..."
- Don't force learnings - many tasks are routine with nothing noteworthy
- Only add the `learnings` label if you have actual recommendations

### Learnings Label for Harvesting
If the summary includes recommendations, add a label so the bead can be harvested later:
```
bd label add <your-id> learnings
```
This enables `/choo-choo-ralph:harvest` to find beads with valuable learnings.
After learnings are harvested into artifacts, the `harvested` label is added automatically.
"""
```

### Tiered Learning Outputs

Learnings accumulate at different levels:

| Tier | Location | When to Use |
|------|----------|-------------|
| 1 | Bead comments | Always - per-task context |
| 2 | Project learnings file | Patterns specific to this project |
| 3 | Skills | Reusable patterns that auto-trigger |
| 4 | CLAUDE.md | Critical project-wide guidance only |

The orchestrator recommends tiers 2-4; humans decide what to actually extract.

### Example Learning Comments

After a task completes, the root bead might have comments like:

```
[bearings] This codebase uses barrel exports - always import from index.ts not individual files
[implement] shadcn Button requires forwardRef when wrapping - took 3 attempts to figure out
[verify] Tests require VITE_API_URL env var or they silently skip API tests
[summary] Completed: Add user settings page. Patterns: shadcn component wrapping. Recommendation: Consider skill for shadcn component patterns.
```

Users can later run `bd comments <epic-id>` on completed epics and have an agent analyze for patterns worth extracting.

## Adding Error Handling

Custom formulas should include error handling to gracefully manage failures. The key design principle is: **steps report back to orchestrator, orchestrator makes state changes**.

### Design Principle: Steps Report, Orchestrator Acts

Child steps should NOT modify bead status for other beads. Instead:
1. Steps perform their work and document findings
2. Steps report results back to orchestrator (PASS/FAIL/etc.)
3. Orchestrator decides and executes state changes
4. This keeps control centralized and predictable

### Type 1: Step Verification Failures

Verify step should report results, not make state changes:

```toml
[[steps]]
id = "verify"
title = "{{title}} - Verify"
assignee = "ralph-subagent-verify"
needs = ["implement"]
description = """
## Output to Orchestrator

**If all checks pass**:
```
STATUS: PASS
TYPES: pass
TESTS: pass
```

**If checks fail (significant issues)**:
```
STATUS: FAIL
ISSUE: <what's wrong>
SUGGESTION: <what implement should try differently>
```

Do NOT reopen the implement step yourself - that's the orchestrator's job.
"""
```

### Type 2: Orchestrator Handles Retries

The orchestrator handles state changes based on step reports:

```toml
description = """
## Handling Verify Results

If verify reports FAIL:
1. Check attempt count (count `[attempt-N]` comments)
2. If < 3 attempts:
   - Add attempt comment: `bd comments add <your-id> "[attempt-N] FAIL: <reason>"`
   - Reopen implement step: `bd update <implement-step-id> --status open`
   - Add guidance: `bd comments add <implement-step-id> "[REWORK] <what to fix>"`
   - Loop back to wait for implement
3. If >= 3 attempts: Execute blocking logic

### If 3+ Attempts Failed

1. **Add critical comment**:
   ```bash
   bd comments add <your-id> "[CRITICAL] Failed after 3 attempts. Requires human review."
   ```

2. **Block yourself**:
   ```bash
   bd update <your-id> --status blocked
   ```

3. **Exit** - The blocked bead won't appear in `bd ready`, loop continues with other work.
"""
```

### Type 3: Health Check Failures

Health check step reports, orchestrator creates bug beads:

```toml
# In health check step:
[[steps]]
id = "bearings"
description = """
## Output to Orchestrator

**If health checks failed**:
```
STATUS: HEALTH_CHECK_FAILED
FAILURE: <what failed>
ERROR: <error message>
RELATED_EPIC: <bead-id from git log if found>
```

Do NOT create bug beads yourself - that's the orchestrator's job.
"""

# In orchestrator:
description = """
## Handling Bearings Results

If bearings reports HEALTH_CHECK_FAILED:
1. Check for existing bug beads: `bd list --type=bug --status=open`
2. If no existing bug covers this, create one:
   ```bash
   bd pour bug-fix --assignee ralph --set title="..." --set task="..."
   ```
3. Block current epic: `bd dep add <your-id> <bug-id>`
4. Move to open: `bd update <your-id> --status open`
5. Exit
"""
```

### Type 4: Blocking After Repeated Failures

For critical failures that can't be resolved:

```toml
description = """
## If 3+ Attempts Failed

1. **Add critical comment**:
   ```bash
   bd comments add <your-id> "[CRITICAL] Cannot resolve. Requires human intervention."
   ```

2. **Block yourself**:
   ```bash
   bd update <your-id> --status blocked
   ```

3. **Exit**
"""
```

Blocked beads don't stop the loop - they just become invisible to `bd ready`. This allows parallel work to continue.

### Error Handling Summary

| Error Type | Who Reports | Who Acts | Action |
|------------|-------------|----------|--------|
| Minor issue | Verify | Verify | Fix inline |
| Major issue | Verify (FAIL) | Orchestrator | Reopen implement |
| 3+ failed attempts | Orchestrator | Orchestrator | Block self, exit |
| Health check failure | Bearings | Orchestrator | Create bug bead |
| Unresolvable bug | Orchestrator | Orchestrator | Block self, exit |

## Testing Your Formula

### 1. Pour a Test Task

```bash
bd pour my-formula \
  --assignee ralph \
  --set title="Test My Formula" \
  --set task="Verify the formula works correctly"
```

### 2. Verify the Molecule Structure

```bash
# List created issues
bd list --status open

# Check the parent task
bd show <parent-id>

# Check step dependencies
bd show <step-id>
```

### 3. Run a Dry Test

Execute Ralph on the test task to verify the workflow:

```bash
./ralph.sh 1  # Run one iteration
```

### 4. Check Step Execution

```bash
# View comments for progress
bd comments <step-id>

# Check status updates
bd show <step-id> --json | jq '.status'
```

### 5. Clean Up

```bash
bd delete <parent-id>  # Deletes parent and all steps
```

## Common Issues

| Problem | Cause | Solution |
|---------|-------|----------|
| Steps not found by Ralph | Missing `needs` array | Ensure every step has `needs = []` or valid dependencies |
| Variables not substituted | Typo in var reference | Check that `{{title}}` and `{{task}}` match exactly |
| Sub-agent not spawned | Wrong assignee prefix | Use `ralph-subagent-*` for Task tool spawning |
| Circular dependency error | Steps depend on each other | Review `needs` arrays for cycles |
| Step marked complete prematurely | Vague completion criteria | Add explicit "Completion" section to description |
| Orchestrator confused about flow | Missing workflow overview | Add clear "Workflow" section to root description |
| Steps run out of order | Missing dependencies | Add appropriate step IDs to `needs` arrays |
| Formula not found | Wrong formula name | Check `formula` field matches pour command |
| Vars not set at pour time | Missing `--set` flags | Always set required vars: `--set title="..." --set task="..."` |
| Sub-agent lacks context | Description not self-contained | Include all necessary context in step description |
