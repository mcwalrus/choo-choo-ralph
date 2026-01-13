#!/usr/bin/env bash
set -e

# Choo Choo Ralph - Autonomous coding loop
# Usage: ./ralph.sh [max_iterations] [--verbose|-v]

MAX_ITERATIONS=100
VERBOSE_FLAG=""

# Parse arguments
for arg in "$@"; do
  case "$arg" in
  --verbose | -v)
    VERBOSE_FLAG="--verbose"
    ;;
  [0-9]*)
    MAX_ITERATIONS="$arg"
    ;;
  esac
done
iteration=0

echo "Starting Ralph loop (max $MAX_ITERATIONS iterations)"

while [ $iteration -lt $MAX_ITERATIONS ]; do
  echo ""
  echo "=== Iteration $((iteration + 1)) ==="
  echo "---"

  # Check if any ready work is available (no blockers, not in_progress by another agent)
  available=$(bd ready --assignee=ralph -n 100 --json 2>/dev/null | jq -r 'length')

  if [ "$available" -eq 0 ]; then
    echo "No ready work available. Done."
    exit 0
  fi

  echo "$available ready task(s) available"
  echo ""

  # Let Claude see available work, pick one, claim it, and execute
  claude --dangerously-skip-permissions --output-format stream-json --verbose -p "
Run \`bd ready --assignee=ralph -n 100 --sort=priority\` to see available tasks.

Decide which task to work on next. This should be the one YOU decide has the highest priority - not necessarily the first in the list.

Pick ONE task, claim it with \`bd update <id> --status in_progress\`, then execute it according to its description.

One iteration = complete the task AND all its child tasks (if any).

IMPORTANT: After the task and all children are done (or if blocked), EXIT immediately. Do NOT pick up another top-level task. The outer loop will handle the next iteration.
" 2>&1 | "$(dirname "$0")/ralph-format.sh" $VERBOSE_FLAG || true

  ((iteration++)) || true
done

echo ""
echo "Reached max iterations ($MAX_ITERATIONS)"
