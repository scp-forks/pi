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
- Still enabled: model catalog refresh from pi.dev. Use `PI_OFFLINE=1` (or `--offline`) to disable all automatic network activity.

## Keys

Put provider keys in `.env` at the repo root (gitignored), e.g. `OPENROUTER_API_KEY=sk-or-...`. `pi-local.sh` loads it; variables already set in the shell win.

## Refreshing from upstream

`upstream` is https://github.com/earendil-works/pi; `origin` is this fork. Local changes are ordinary commits on `main`.

```bash
./pi-update.sh          # shows incoming commits, dependency changes, and new network/telemetry lines, then asks
./pi-update.sh --yes    # skip the prompt
```

It merges `upstream/main`, runs `npm ci --ignore-scripts` and `npm run hydrate:model-data`, and pushes to `origin`. On merge conflicts it stops; resolve, commit, and rerun.
