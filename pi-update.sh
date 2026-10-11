#!/usr/bin/env bash
# Merge upstream pi into this fork after showing what changed.
# Usage: ./pi-update.sh [--yes]
set -euo pipefail

REPO_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Uncommitted changes to tracked files. Commit them first." >&2
  exit 1
fi

git fetch upstream --tags --quiet
if [[ -z "$(git rev-list HEAD..upstream/main)" ]]; then
  echo "Already up to date with upstream."
  exit 0
fi

echo "== Incoming commits"
git log --oneline HEAD..upstream/main
echo
echo "== Dependency changes (package.json)"
git diff HEAD...upstream/main -- 'package.json' 'packages/*/package.json' | grep -E '^[+-][[:space:]]+"[^"]+": "[^"]+"' || echo "(none)"
echo
echo "== Added lines touching network or telemetry"
git diff HEAD...upstream/main -- '*.ts' '*.js' '*.mjs' ':!**/test/**' ':!packages/ai/src/models.generated.ts' \
  | grep -nE '^\+.*(fetch\(|https?://|telemetry|PI_TELEMETRY|report-install|sendBeacon|WebSocket\()' || echo "(none)"
echo

if [[ "${1:-}" != "--yes" ]]; then
  read -r -p "Merge upstream/main? [y/N] " answer
  [[ "$answer" == [yY]* ]] || { echo "Aborted."; exit 1; }
fi

if ! git merge --no-edit upstream/main; then
  echo "Merge conflicts. Resolve them, commit, then rerun this script." >&2
  exit 1
fi

npm ci --ignore-scripts
npm run hydrate:model-data
git push origin HEAD || echo "Push to origin failed; run 'git push' manually."
echo "Done. pi is now $(./pi-local.sh --version)."
