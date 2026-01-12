---
description: Generate or refine a spec file for Choo Choo Ralph from your plan
argument-hint: [spec-name?] [source-file?]
---

# Generate or Refine Spec

This command has smart behavior based on the current state:

## Spec File Naming

Specs are stored as `.choo-choo-ralph/<name>.spec.md`. Each project can have multiple specs.

### When `{{name}}` is provided:

- Use that name directly: `.choo-choo-ralph/{{name}}.spec.md`
- If file exists, enter refinement mode (Mode 2 or 3)
- If file doesn't exist, create new spec (Mode 1)

### When `{{name}}` is NOT provided:

1. **Check for existing specs** in `.choo-choo-ralph/*.spec.md`
2. **If exactly one spec exists**: Use that spec (refinement mode)
3. **If multiple specs exist**: Ask user which spec to work with
4. **If no specs exist**: Generate a suggested name based on:
   - The plan content or conversation context
   - Use kebab-case, descriptive, short (e.g., `user-auth`, `dark-mode`, `api-refactor`)
   - Use **AskUserQuestion** to confirm or let user provide alternative:
     ```
     "I'll create a new spec. Suggested name: 'user-authentication'"
     Options:
     - Use suggested name
     - [Other - user provides custom name]
     ```

## Mode Detection

1. **No spec exists (or new name)** → Generate new spec from plan/conversation
2. **Spec exists with review comments** → Refine spec based on comments
3. **Spec exists, no comments** → Ask: regenerate from scratch or continue with existing?

## Mode 1: Generate New Spec

When the target spec file doesn't exist:

- Accept plan from conversation context or file path ({{source}})
- Invoke `/choo-choo-ralph:spec-generation` skill for format guidance
- **Get current date** by running `date +%Y-%m-%d` bash command for the frontmatter `created` field
- Generate at `.choo-choo-ralph/<name>.spec.md`

## Mode 2: Refine Based on Comments (Review Loop)

When spec exists and has non-empty `<review>` tags:

1. **Parse existing spec** with all review comments
2. **Process comments** - understand requested changes:
   - "Split this into smaller tasks"
   - "Add more detail about X"
   - "Combine with task Y"
   - "Remove this, not needed"
   - Comments from other AI agents
3. **Regenerate affected tasks** based on feedback
4. **Clear review tags** after processing (empty tags remain for future comments)

This enables the review loop:

```
spec → user reviews → adds comments → spec → reviews → ... → pour
```

## Mode 3: Spec Exists, No Comments

When spec exists but all `<review>` tags are empty:

- Ask user: "Existing spec found. Would you like to:"
  - A) Start fresh (regenerate from plan)
  - B) Continue reviewing (open spec for editing)
  - C) Proceed to pour (tasks are ready)

## Review Comment Format

Users (or other AI agents) can add comments in review tags:

```xml
<task id="auth" priority="1" category="functional">
  <title>User Authentication</title>
  <description>...</description>
  <steps>...</steps>
  <review>
    Split this into separate login and registration tasks.
    Also add password reset as a third task.
  </review>
</task>
```

After refinement, review tags are **cleared** (not marked processed):

```xml
<review></review>
```

## Iteration Tracking

The spec tracks how many times it's been refined via the frontmatter:

```yaml
---
title: "My Feature"
created: 2026-01-11
poured: []
iteration: 3
---
<project_specification>
  <project_name>...</project_name>
  ...
</project_specification>
```

- `iteration: 1` - Initial generation
- `iteration: 2` - First refinement
- `iteration: 3` - Second refinement
- etc.

This provides useful context about how much the spec has evolved and is queryable.

## Output

**For new spec:**

- Location of generated spec file
- Number of tasks extracted
- Instructions for reviewing
- Next step: review, add comments, run spec again or pour

**For refined spec:**

- Summary of changes made
- Number of tasks added/modified/removed
- Next step: review changes, add more comments or pour
