---
name: spec-generation
description: Generate structured spec files for Choo Choo Ralph. Use when running /choo-choo-ralph:spec or creating task breakdowns.
---

# Spec Generation

Generate structured specification files for Choo Choo Ralph.

**IMPORTANT: NEVER add `<?xml version="1.0"...?>` to spec files. These are markdown files, NOT XML files. Start directly with `<project_specification>`.**

## Critical Format Rules

1. **YAML frontmatter required** - Every spec starts with `---` frontmatter block
2. **NO XML DECLARATION** - NEVER include `<?xml ...?>` - this breaks the spec
3. **File is markdown with XML-like tags** - Not a true XML file
4. **Empty review tags** - Use `<review></review>` not self-closing
5. **After frontmatter** - First XML line must be `<project_specification>`

## YAML Frontmatter

Every spec file MUST start with YAML frontmatter:

```yaml
---
title: "Project or Feature Name"
created: 2026-01-11
poured: []
iteration: 1
auto_discovery: false
auto_learnings: false
---
```

Fields:
- **title**: Human-readable name for the spec (matches `<project_name>`)
- **created**: Date created (use `date +%Y-%m-%d` bash command for accuracy)
- **poured**: Array of root bead IDs created when `/pour` runs (starts empty)
- **iteration**: Refinement count (1 = initial, increments on each `/spec` refinement)
- **auto_discovery**: (optional, default: `false`) Enable auto task creation from discovered gaps during implementation
- **auto_learnings**: (optional, default: `false`) Enable auto skill creation from learnings captured during implementation

## Core Principles

1. **Flexible scale**: Same format works for one feature or entire applications
2. **Human-reviewable**: Easy to read and edit in any text editor
3. **Machine-parseable**: Clear structure for automated processing

## Spec Format

The spec uses YAML frontmatter followed by XML-like tags in markdown for clarity and editability.

```markdown
---
title: "Project or Feature Name"
created: 2026-01-11
poured: []
iteration: 1
auto_discovery: false
auto_learnings: false
---
<project_specification>
<project_name>Project or Feature Name</project_name>

  <overview>
    Brief description of what we're building.
    Context and goals.
  </overview>

  <!-- Context from codebase/tech research (populated by /spec command) -->
  <context>
    <existing_patterns>
      - Patterns found in the existing codebase to follow
      - e.g., "Authentication follows pattern in src/auth/"
    </existing_patterns>
    <integration_points>
      - Files/services this feature will integrate with
      - e.g., "Extends UserService in src/services/user.ts"
    </integration_points>
    <new_technologies>
      - Research notes for technologies not in codebase
      - e.g., "Stripe: Use stripe-node SDK, webhook verification required"
    </new_technologies>
    <conventions>
      - Coding conventions discovered in codebase
      - e.g., "Tests colocated with source files (*.test.ts)"
    </conventions>
  </context>

  <!-- Optional: For greenfield projects -->
  <technology_stack>
    <frontend>React, Tailwind</frontend>
    <backend>Node.js, SQLite</backend>
  </technology_stack>

  <!-- Core content: Tasks to implement -->
  <tasks>
    <task id="task-1" priority="1" category="infrastructure">
      <title>Setup Project Foundation</title>
      <description>
        Initialize the project structure with required dependencies.
      </description>
      <steps>
        - Create directory structure
        - Initialize package.json
        - Install core dependencies
        - Set up build configuration
      </steps>
      <test_steps>
        1. Run install command - verify no errors
        2. Run build command - verify successful build
        3. Run dev server - verify it starts without errors
      </test_steps>
      <review>
        <!-- Review comments here -->
      </review>
    </task>

    <task id="task-2" priority="2" category="functional">
      <title>Implement Core Feature</title>
      <description>
        Build the main functionality.
      </description>
      <steps>
        - Create component structure
        - Implement business logic
        - Add error handling
        - Write tests
      </steps>
      <test_steps>
        1. Navigate to the feature location
        2. Perform the main user action
        3. Verify expected behavior occurs
        4. Check for errors
        5. Test edge cases
      </test_steps>
      <review></review>
    </task>

  </tasks>

  <!-- Optional: Success criteria -->
  <success_criteria>
    - Feature works as described
    - Tests pass
    - No regressions
  </success_criteria>
</project_specification>
```

## Scaling the Format

### Simple Feature (1-3 tasks)

```markdown
---
title: "Dark Mode Toggle"
created: 2026-01-11
poured: []
iteration: 1
auto_discovery: false
auto_learnings: false
---
<project_specification>
  <project_name>Dark Mode Toggle</project_name>
  <overview>Add dark mode to settings page.</overview>
  <tasks>
    <task id="dark-mode" priority="2" category="functional">
      <title>Implement Dark Mode Toggle</title>
      <description>Add toggle, persist to localStorage, apply theme.</description>
      <steps>
        - Add toggle to settings
        - Create theme context
        - Persist preference
        - Update CSS variables
      </steps>
      <test_steps>
        1. Navigate to settings page
        2. Click the dark mode toggle
        3. Verify theme changes to dark
        4. Refresh the page
        5. Verify dark mode preference persisted
      </test_steps>
      <review></review>
    </task>
  </tasks>
</project_specification>
```

### Full Application (30+ tasks)

Include technology_stack, database_schema, api_endpoints, implementation_steps sections.

## Task State

Task state is determined by the `<review>` tag:

| State | How to identify | Action |
|---|---|---|
| **Needs refinement** | `<review>` tag has content | Run `/spec` again to process feedback |
| **Ready to pour** | `<review>` tag is empty | Can be poured into beads |
| **Rejected** | Task deleted from spec | N/A |

## Priority Levels

| Priority | Meaning |
|---|---|
| 0 | Critical - do first |
| 1 | High |
| 2 | Medium (default) |
| 3 | Low |
| 4 | Backlog |

## Category Types

| Category | Description |
|---|---|
| `functional` | Core features, business logic |
| `style` | Visual polish, animations, UI tweaks |
| `infrastructure` | Build, deploy, tooling, project setup |
| `documentation` | README, comments, docs |

## Test Steps

The `<test_steps>` section in the spec provides **integration-level test guidance** for the feature as a whole. When the spec is poured into beads, the pour process generates granular test steps for each individual bead.

## Context Section

The `<context>` section provides research findings about the codebase and technologies:

| Section | Purpose | Example |
|---------|---------|---------|
| `existing_patterns` | Code patterns to follow | "Components use shadcn/ui conventions" |
| `integration_points` | Files/services to integrate with | "Extends UserService in src/services/user.ts" |
| `new_technologies` | Research notes for new tech | "Stripe: Use webhook verification for security" |
| `conventions` | Naming, testing, style conventions | "Tests colocated with source (*.test.ts)" |