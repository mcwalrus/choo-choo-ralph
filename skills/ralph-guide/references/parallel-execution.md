# Parallel Ralph Execution

Running multiple Ralph instances simultaneously to accelerate work on independent tasks.

## Why Parallel Execution

When your backlog contains many independent tasks, a single Ralph processes them sequentially. Parallel execution allows multiple Ralphs to claim and work on different tasks concurrently, significantly reducing total completion time.

Key benefits:
- **Faster throughput** - N Ralphs can complete N tasks in the time one Ralph does one
- **Better resource utilization** - Multiple API calls, compilations, and tests run in parallel
- **Natural load balancing** - Faster tasks complete quickly, slower tasks don't block others

## How It Works

Each Ralph instance follows the same loop, but the work-claiming mechanism prevents collisions:

```
Ralph A: bd ready → claims task-001 → implements → commits
Ralph B: bd ready → claims task-002 → implements → commits
Ralph C: bd ready → claims task-003 → implements → commits
```

### Atomic Work Claims

When Ralph calls `bd update <id> --status=in_progress`:
1. Beads atomically updates the issue status
2. Other Ralphs calling `bd ready` no longer see that task
3. The claiming Ralph owns that work until completion or abandonment

This atomic claim mechanism prevents double-pickup - no two Ralphs will work on the same task.

### Molecule Isolation

Each Ralph works on a different molecule root:
- Molecule A might handle authentication features
- Molecule B might handle API endpoints
- Molecule C might handle documentation

Since molecules represent independent work streams, parallel Ralphs don't step on each other.

## Prerequisites

Before running parallel Ralphs:

### 1. Multiple Ready Molecules

Check your queue depth:
```bash
bd ready --assignee ralph
```

If you only have 1-2 ready tasks, parallel execution provides no benefit.

### 2. Independent Work Streams

Beads in parallel execution should:
- Touch different files or directories
- Have no shared dependencies between molecules
- Not require sequential ordering

### 3. Sufficient Resources

Ensure your machine can handle:
- Multiple Claude API connections
- Parallel compilation/test runs
- Concurrent disk I/O

## Running Multiple Instances

### Terminal Approach

Open multiple terminal windows or tmux panes:

```bash
# Terminal 1
./ralph.sh 50

# Terminal 2
./ralph.sh 50

# Terminal 3
./ralph.sh 50
```

Each instance maintains its own conversation context and works independently.

### Background Approach

Run Ralphs as background processes with logged output:

```bash
# Start instances with output logging
./ralph.sh 50 > logs/ralph-1.log 2>&1 &
./ralph.sh 50 > logs/ralph-2.log 2>&1 &
./ralph.sh 50 > logs/ralph-3.log 2>&1 &

# Monitor logs
tail -f logs/ralph-*.log
```

### Screen/Tmux Approach

```bash
# Create named sessions
tmux new-session -d -s ralph1 './ralph.sh 50'
tmux new-session -d -s ralph2 './ralph.sh 50'
tmux new-session -d -s ralph3 './ralph.sh 50'

# Attach to any session to monitor
tmux attach -t ralph1
```

## Monitoring Parallel Ralphs

### Queue Depth

See how much work remains:
```bash
bd ready --assignee ralph
```

When this returns empty, all Ralphs will exit.

### Active Work

See what each Ralph is currently doing:
```bash
bd list --status=in_progress
```

### Overall Progress

Get statistics on completed vs remaining work:
```bash
bd stats
```

### Git Activity

Watch commits rolling in:
```bash
watch -n 5 'git log --oneline -10'
```

## Handling Conflicts

### Git Merge Conflicts

If two Ralphs modify the same file, the second commit may conflict.

**Prevention strategies:**
- Design molecules to touch different parts of the codebase
- Use file-level task granularity (one task = one file or directory)
- Separate feature work from infrastructure work

**Resolution:**
- Ralph should detect merge conflicts during commit
- Mark the task as blocked with conflict details
- Human intervention may be needed for complex conflicts

### Resource Contention

**API Rate Limits:**
- Claude API may rate-limit parallel requests
- Start with 2 instances, scale up if stable
- Consider staggering start times

**Build System Conflicts:**
- Concurrent `bun install` or `npm install` can conflict
- Use lockfiles and let one instance finish before others start major installs

**Test Isolation:**
- Ensure tests don't share mutable state
- Use unique database names or ports per test run

## Best Practices

### Start Conservative

1. Begin with 2 parallel Ralphs
2. Monitor for conflicts or resource issues
3. Scale up to 3-4 if stable
4. Rarely need more than 4-5 on a single machine

### Sync Regularly

Push progress to remote between runs:
```bash
bd sync
```

This ensures:
- Other developers see progress
- Work survives machine failure
- Multiple machines can participate

### Design for Parallelism

When creating molecules:
- Group related changes that touch the same files
- Keep molecules small and focused
- Explicitly document file ownership in molecule descriptions

### Monitor Resource Usage

Watch for:
- CPU/memory spikes from parallel compilations
- Network saturation from API calls
- Disk I/O bottlenecks

```bash
# Quick system check
htop
# or
top -o cpu
```

### Handle Stragglers

If one Ralph gets stuck on a complex task while others idle:
1. Check if the task can be broken down further
2. Consider manual intervention for the stuck task
3. Add blockers to pause the problematic molecule

## Example Parallel Session

```bash
# Check queue
$ bd ready --assignee ralph
MOL-001: Implement user authentication
MOL-002: Add API rate limiting
MOL-003: Create admin dashboard
MOL-004: Write integration tests

# Start 3 Ralphs
$ ./ralph.sh 50 &
$ ./ralph.sh 50 &
$ ./ralph.sh 50 &

# Monitor progress
$ watch -n 10 'bd list --status=in_progress'

# After completion, sync
$ bd sync
```
