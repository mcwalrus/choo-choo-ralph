#!/usr/bin/env bash
set -euo pipefail

# Sync plugin payload (commands, skills, templates) from this repo into the
# local pi agent directory. Hidden names (.*) and *.sh are skipped.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO_ROOT/plugins/choo-choo-ralph"
DEST="${CHOO_CHOO_PI_PLUGIN:-$PI_CODING_AGENT_DIR/plugins/choo-choo-ralph}"

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