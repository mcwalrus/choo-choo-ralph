# Troubleshooting

## Automatic Error Handling

Ralph handles most failures automatically through built-in retry and recovery mechanisms.

### Verification Failures

1. **Implement step reopened** with `[REWORK]` guidance
2. **`[attempt-N]` comment** tracks the retry count
3. **After 3 failures** → task automatically marked as blocked

### Health Check Failures

1. **Bug-fix bead created automatically**
2. **Current task blocked** on the new bug-fix bead
3. **Bug must be fixed first** before Ralph continues

## Blocked Tasks

```bash
bd list --status=blocked    # List blocked tasks
bd comments <bead-id>       # Review what went wrong
bd update <bead-id> --status open  # Reopen for retry
```

## Common Issues

### Tasks Not Being Picked Up

```bash
bd show <bead-id>                    # Check status and assignee
bd update <bead-id> --assignee ralph # Assign to Ralph
bd update <bead-id> --status open    # Set status
bd dep <bead-id>                     # Check for blockers
```

### Infinite Retry Loop

```bash
bd update <bead-id> --status blocked  # Block manually
bd comments <bead-id>                 # Review all attempts
# Fix underlying issue, then:
bd update <bead-id> --status open     # Reopen when ready
```

### Health Check Always Failing

1. Stop Ralph immediately
2. Run checks manually: `npm test`, `npm run build`, `npm run lint`
3. Fix all failures
4. Resume Ralph

## Debugging Tips

```bash
./ralph-once.sh          # Test single iteration
./ralph.sh -v            # Verbose output
bd comments <bead-id>    # View task history
bd show <root-id>        # Inspect molecule structure
```

## Recovery Procedures

### Partially Completed Pour

1. Check which beads were created: `bd list --assignee=ralph`
2. Fix the issue that caused pour to fail
3. Run pour again

### Starting Over (Re-pouring a Spec)

1. Unarchive the spec: `mv .choo-choo-ralph/archive/spec.md .choo-choo-ralph/`
2. Delete existing beads (IDs in spec's `poured` array)
3. Clear `poured: []` in frontmatter
4. Run pour

### Session Recovery (Mid-task Crash)

```bash
bd list --status=in_progress --assignee=ralph  # Find in-progress task
bd comments <bead-id>                          # Review progress
bd update <bead-id> --status open              # Reopen to retry
```

### Recovering from Git Issues

```bash
git log --oneline -20  # Find bad commits
git revert <commit>    # Revert specific commits
# Update task status to match current state
```