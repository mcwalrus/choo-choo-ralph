#!/usr/bin/env bash
set -e

# Choo Choo Ralph - Observer mode (human-in-the-loop)
# Usage: ./ralph-observe.sh [max_iterations] [--verbose|-v] [--auto-approve-after=N]
#
# Pauses before each iteration for human review. Use this when starting out
# with Ralph to build confidence before switching to fully autonomous mode.
#
# Controls:
#   y / Enter  - approve and run iteration
#   n          - skip this iteration (recheck for new work next time)
#   q          - quit observer loop
#   s          - switch to auto mode now (skip remaining confirmations)

MAX_ITERATIONS=100
VERBOSE_FLAG=""
AUTO_APPROVE_AFTER=0  # 0 = never auto-approve

# Parse arguments
for arg in "$@"; do
  case "$arg" in
  --verbose | -v)
    VERBOSE_FLAG="--verbose"
    ;;
  --auto-approve-after=*)
    AUTO_APPROVE_AFTER="${arg#*=}"
    ;;
  [0-9]*)
    MAX_ITERATIONS="$arg"
    ;;
  esac
done

iteration=0
consecutive_successes=0
auto_mode=false

echo "Starting Ralph observer loop (max $MAX_ITERATIONS iterations)"
if [[ $AUTO_APPROVE_AFTER -gt 0 ]]; then
  echo "Auto-approve after $AUTO_APPROVE_AFTER consecutive successes"
fi
echo "Controls: [y/Enter] approve  [n] skip  [q] quit  [s] switch to auto"
echo ""

while [ $iteration -lt $MAX_ITERATIONS ]; do
  echo ""
  echo "=== Iteration $((iteration + 1)) ==="
  echo "---"

  # Check if any ready work is available
  available=$(bd ready --assignee=ralph -n 100 --json 2>/dev/null | jq -r 'length')

  if [ "$available" -eq 0 ]; then
    echo "No ready work available. Done."
    exit 0
  fi

  echo "$available ready task(s) available"

  # Show what's ready
  echo ""
  bd ready --assignee=ralph -n 5 --sort=priority 2>/dev/null || true
  echo ""

  # Ask for approval unless in auto mode
  if ! $auto_mode; then
    while true; do
      printf "Run iteration? [y/N/q/s]: "
      read -r response </dev/tty
      case "${response,,}" in
        y | "")
          break
          ;;
        n)
          echo "Skipping iteration."
          ((iteration++)) || true
          continue 2
          ;;
        q)
          echo "Quitting observer loop."
          exit 0
          ;;
        s)
          echo "Switching to auto mode."
          auto_mode=true
          break
          ;;
        *)
          echo "Please enter y, n, q, or s."
          ;;
      esac
    done
  fi

  # Run one Ralph iteration
  claude --dangerously-skip-permissions --output-format stream-json --verbose -p "
Run \`bd ready --assignee=ralph -n 100 --sort=priority\` to see available tasks.

Also run \`bd list --status=in_progress --assignee=ralph\` to see what tasks other Ralph agents are currently working on.

Decide which task to work on next. Selection criteria:
1. Priority - higher priority tasks are more important
2. Avoid conflicts - if other Ralph agents have tasks in_progress, you MUST pick a completely different epic. Do NOT work on any task that is a child, parent, or sibling of an in-progress task. Stay away from the entire epic tree that another Ralph is working on.
3. If all high-priority epics are being worked on by other Ralphs, pick a lower-priority epic that is completely unrelated

Pick ONE task, claim it with \`bd update <id> --status in_progress\`, then execute it according to its description.

One iteration = complete the task AND all its child tasks (if any).

IMPORTANT: After the task and all children are done (or if blocked), EXIT immediately. Do NOT pick up another top-level task. The outer loop will handle the next iteration.
" 2>&1 | "$(dirname "$0")/ralph-format.sh" $VERBOSE_FLAG && iteration_ok=true || iteration_ok=false

  ((iteration++)) || true

  # Post-iteration status
  echo ""
  echo "--- Post-iteration status ---"
  bd stats 2>/dev/null || true

  # Track consecutive successes for auto-approve graduation
  if $iteration_ok; then
    ((consecutive_successes++)) || true
    echo "Consecutive successes: $consecutive_successes"

    if [[ $AUTO_APPROVE_AFTER -gt 0 && $consecutive_successes -ge $AUTO_APPROVE_AFTER ]] && ! $auto_mode; then
      echo ""
      echo "Reached $AUTO_APPROVE_AFTER consecutive successes — switching to auto mode."
      auto_mode=true
    fi
  else
    consecutive_successes=0
  fi
done

echo ""
echo "Reached max iterations ($MAX_ITERATIONS)"
