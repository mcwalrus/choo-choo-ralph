#!/usr/bin/env bash
set -euo pipefail

# Copy plugin payload (commands, skills, templates) from this repo into the
# local Claude marketplace checkout. Hidden names (.*) and *.sh are skipped.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO_ROOT/plugins/choo-choo-ralph"
DEST="${CHOO_CHOO_MARKETPLACE_PLUGIN:-$HOME/.claude/plugins/marketplaces/choo-choo-ralph/plugins/choo-choo-ralph}"

RSYNC=(rsync -a --exclude='.*' --exclude='*.sh')

for dir in commands skills templates; do
  if [[ ! -d "$SRC/$dir" ]]; then
    echo "skip: missing $SRC/$dir" >&2
    continue
  fi
  echo "sync $dir/ -> $DEST/$dir/"
  mkdir -p "$DEST/$dir"
  "${RSYNC[@]}" "$SRC/$dir/" "$DEST/$dir/"
done

echo "done: $DEST"
