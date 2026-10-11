#!/usr/bin/env bash
# Run pi from this source checkout. Safe to symlink (e.g. ~/bin/pi -> this file).
set -euo pipefail

# Resolve symlinks so the repo is found even when invoked through a link.
SOURCE="${BASH_SOURCE[0]}"
while [[ -L "$SOURCE" ]]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE"
done
REPO_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

# Load API keys from the repo's .env (gitignored); already-set variables win.
if [[ -f "$REPO_DIR/.env" ]]; then
  while IFS='=' read -r key value; do
    [[ -z "$key" || "$key" == \#* ]] && continue
    [[ -z "${!key+x}" ]] && export "$key=$value"
  done < "$REPO_DIR/.env"
fi

# Privacy defaults; override by setting them before calling.
# PI_TELEMETRY=0: no install ping to pi.dev, no provider attribution headers.
# PI_SKIP_VERSION_CHECK=1: no latest-version request to pi.dev.
export PI_TELEMETRY="${PI_TELEMETRY:-0}"
export PI_SKIP_VERSION_CHECK="${PI_SKIP_VERSION_CHECK:-1}"

RESOLVER_URL="$(node -p 'require("node:url").pathToFileURL(process.argv[1]).href' "$REPO_DIR/packages/coding-agent/src/experimental/source-resolver.ts")"
exec node --disable-warning=ExperimentalWarning --import "$RESOLVER_URL" "$REPO_DIR/packages/coding-agent/src/experimental/cli.ts" "$@"
