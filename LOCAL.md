# Local fork usage

Runs pi from this source checkout (no build step), so only reviewed code runs.

## Requirements

Node 22.19+ (`nvm alias default 22.23.3`).

## Setup

```bash
npm install --ignore-scripts
npm run hydrate:model-data
ln -sf "$PWD/pi-local.sh" ~/bin/pi
echo 'OPENROUTER_API_KEY=sk-or-...' > .env   # or /login inside pi
pi --model openrouter/<id>
```

## Privacy defaults (set in pi-local.sh)

- `PI_TELEMETRY=0`: no install ping to `pi.dev/api/report-install`, no OpenRouter attribution headers.
- `PI_SKIP_VERSION_CHECK=1`: no latest-version request to pi.dev.
- `PI_OFFLINE=1`: no automatic network activity (pi.dev model catalog refresh, package update checks, fd/rg downloads). New models arrive via `./pi-update.sh`, which re-hydrates model data. Run `PI_OFFLINE=0 pi` to allow a one-off catalog refresh.

Verified by a network trace (2026-10-11): with these settings pi contacts only `openrouter.ai`, and only when sending a prompt. Each request carries a random per-session `x-session-id` (cache affinity) and a User-Agent with OS/arch.

## Keys

Put provider keys in `.env` at the repo root (gitignored), e.g. `OPENROUTER_API_KEY=sk-or-...`. `pi-local.sh` loads it; variables already set in the shell win.

## Refreshing from upstream

`upstream` is https://github.com/earendil-works/pi; `origin` is this fork. Local changes are ordinary commits on `main`.

```bash
./pi-update.sh          # shows incoming commits, dependency changes, and new network/telemetry lines, then asks
./pi-update.sh --yes    # skip the prompt
```

It merges `upstream/main`, runs `npm ci --ignore-scripts` and `npm run hydrate:model-data`, and pushes to `origin`. On merge conflicts it stops; resolve, commit, and rerun.
