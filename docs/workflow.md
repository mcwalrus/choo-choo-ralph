# Complete Workflow Guide

This guide walks you through a complete Choo Choo Ralph session from start to finish. By the end, you will understand how to transform a rough plan into working, tested code while capturing learnings for future sessions.

## Overview

Choo Choo Ralph follows a five-phase workflow:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CHOO CHOO RALPH WORKFLOW                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│   │   PLAN   │───▶│   SPEC   │───▶│   POUR   │───▶│  RALPH   │───▶│ HARVEST  │
│   │          │    │          │    │          │    │          │    │          │
│   │   You    │    │ You + AI │    │    AI    │    │    AI    │    │ You + AI │
│   └──────────┘    └──────────┘    └──────────┘    └──────────┘    └──────────┘
│        │               │               │               │               │
│        ▼               ▼               ▼               ▼               ▼
│   Rough ideas    Structured     Beads tasks     Working code    Captured
│   & goals        task list      ready to run    & commits       learnings
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Step 1: Planning (Your Work)

**This step is entirely on you.** Choo Choo Ralph does not do planning - it executes plans. The quality of your plan directly determines the quality of the output.

### What Planning Looks Like

Planning can take many forms:

- **Bullet points** - Quick notes about what you want to build
- **PRDs (Product Requirements Documents)** - Formal specifications
- **Design documents** - Technical architecture decisions
- **Conversations with an AI** - Interactive brainstorming sessions
- **Sketches and mockups** - Visual representations of the goal
- **Existing issues or tickets** - From your project management tool

The key is having a clear understanding of **what** you want to achieve, not necessarily **how** to achieve it.

### Example Plan: User Authentication

```markdown
# User Authentication Feature

## Goal
Add user authentication to the application.

## Requirements
### User Registration
- Email and password registration
- Email validation (proper format)
- Password requirements: 8+ chars, 1 number, 1 special char
- Duplicate email prevention

### User Login
- Email/password login
- Rate limiting (5 attempts per 15 minutes)
- "Remember me" option (30-day token)
- Session management

### Password Reset
- "Forgot password" flow via email
- Secure reset tokens (expire in 1 hour)

## Constraints
- Use existing PostgreSQL database
- Must work with current Express.js backend
- JWT for session tokens
- bcrypt for password hashing

## Out of Scope
- OAuth/social login (future phase)
- Two-factor authentication (future phase)
```

---

## Step 2: Generate and Review the Spec

### Why Specs?

A spec transforms your rough plan into a structured, reviewable list of tasks:

1. **Clarity** - Forces you to think through the work before starting
2. **Review** - Gives you a chance to catch issues before code is written
3. **Parallelization** - Well-defined tasks can run independently
4. **Progress tracking** - Each task is a measurable unit of work
5. **AI-friendliness** - Structured format that agents understand

### The Spec Format

Specs use a markdown format with XML-like tags for clear boundaries. For complete format specification, see [spec-format.md](./spec-format.md).

### The Review Process (Critical!)

**This is the most important part of the workflow.** A poorly reviewed spec leads to wasted time and incorrect implementations.

1. **Read through each task** - Does it make sense? Is it complete?
2. **Add feedback in `<review>` tags** directly in the spec
3. **Run the spec command again** - The agent reads review tags and updates the spec
4. **Repeat until all review tags are empty**

---

## Step 3: Pour the Spec into Beads

Pouring transforms your reviewed spec tasks into executable Beads issues. Each spec task becomes multiple granular implementation tasks (molecules).

### What Pouring Does

1. Reads your spec file
2. Creates beads for each task
3. Sets up dependencies between beads
4. Assigns the configured formula to each bead
5. Archives the spec file

### Workflow Formula (Recommended)

The default `choo-choo-ralph` formula provides a 4-phase process:

```
bearings → implement → verify → commit
```

- **Bearings**: Agent reads relevant files, understands context
- **Implement**: Agent writes the code
- **Verify**: Agent runs tests, linters, type checks
- **Commit**: Agent commits with descriptive message

### Singular Tasks

Simple beads executed directly without the multi-phase workflow. Good for research, prototyping, or one-off tasks.

---

## Step 4: Run the Ralph Loop

### Starting Ralph

```bash
./ralph.sh              # Default iterations
./ralph.sh 50           # Run up to 50 tasks
./ralph.sh --verbose    # Detailed output
```

### Testing Before a Long Run

```bash
./ralph-once.sh         # Exactly one iteration
```

### What Ralph Does for Each Task

1. **CLAIM TASK** - Finds next ready task and sets status to `in_progress`
2. **BEARINGS PHASE** - Health check and codebase understanding
3. **IMPLEMENT PHASE** - Writes/modifies code
4. **VERIFY PHASE** - Runs tests, type checking, linting
5. **COMMIT PHASE** - Creates descriptive commit and marks task complete
6. **NEXT TASK** - Repeats if more work available and limit not reached

### Parallel Execution

Multiple Ralph instances can run safely in parallel:

```bash
# Terminal 1
./ralph.sh 50

# Terminal 2
./ralph.sh 50
```

Each Ralph claims work atomically - they won't double-pick the same task.

---

## Step 5: Harvest Learnings

### Why Harvest?

During execution, agents capture valuable information:

- **[LEARNING]** - Useful discoveries about the codebase
- **[GAP]** - Missing work or incomplete implementations

Harvesting transforms these comments into permanent improvements: skills, AGENTS.md updates, reference docs, and new gap tasks.

---

## Summary

| Step | Who | Output |
|---|---|---|
| **Plan** | You | Plan document with goals, requirements, constraints |
| **Spec** | You + AI | Structured task list in `.choo-choo-ralph/` |
| **Review** | You | Refined spec with clear, sized tasks |
| **Pour** | AI | Beads tasks ready for execution |
| **Ralph** | AI | Working code with atomic commits |
| **Harvest** | You + AI | Updated skills, docs, AGENTS.md |

### Quick Start Checklist

- [ ] Create a plan document with clear requirements
- [ ] Generate spec from your plan
- [ ] Review spec thoroughly, add `<review>` feedback
- [ ] Iterate on spec until all review tags empty
- [ ] Pour spec to create beads
- [ ] Test with `./ralph-once.sh`
- [ ] Run `./ralph.sh` for full execution
- [ ] Harvest learnings after completion
- [ ] Commit harvested learnings