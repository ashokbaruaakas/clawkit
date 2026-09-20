# Clawkit

A wrapper image around OpenClaw that adds Linuxbrew and development tooling, published to GHCR for easy use with Docker Compose.

## Prerequisites

- Docker Engine with Docker Compose support
- Git
- Network access to pull images from GHCR

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/ashokbaruaakas/clawkit.git
cd clawkit

# 2. Copy the environment file
cp .env.example .env
# Edit .env with at least one LLM provider API key

# 3. Start the container
docker compose -f docker-compose.yml up -d
```

Default behavior:

- Pulls `ghcr.io/ashokbaruaakas/clawkit:latest`
- Publishes the gateway on host port `127.0.0.1:${PORT}` (default `18789`); the gateway itself always listens on `18789` inside the container
- Persists `/home/node` and `/home/linuxbrew/.linuxbrew` via named volumes

## Configuration

All variables are documented in [.env.example](.env.example).

Common variables:

- `CONTAINER_NAME`: container name in Docker
- `IMAGE_NAME`: image repository to pull from
- `IMAGE_TAG`: image tag to use (defaults to `latest`)
- `PORT`: host port to publish the gateway on (default `18789`); the container port stays `18789`

OpenClaw runtime:

- `OPENCLAW_GATEWAY_TOKEN`: (required) gateway authentication token; the Gateway will not authenticate without it
- `OPENCLAW_NO_RESPAWN`: when set to `1`, disables automatic respawn behavior
- `NODE_COMPILE_CACHE`: compile cache directory path

LLM providers (set at least one):

- `DEEPSEEK_API_KEY`
- `GEMINI_API_KEY`
- `OPENROUTER_API_KEY`

Optional integrations:

- `DISCORD_BOT_TOKEN`
- `NOTION_API_KEY`

## Tailscale (optional)

Clawkit can join your tailnet through an optional sidecar so you can reach the
OpenClaw gateway over Tailscale and let OpenClaw SSH to other tailnet devices.
It is opt-in and uses a separate Compose override file.

### Enable

1. Set `TS_AUTHKEY` in `.env` (generate one at
   [https://login.tailscale.com/admin/settings/keys](https://login.tailscale.com/admin/settings/keys)).
2. Start with both Compose files:

```bash
docker compose -f docker-compose.yml -f docker-compose.tailscale.yml up -d
```

Stop using Tailscale by starting with only the base file:

```bash
docker compose -f docker-compose.yml up -d
```

### What it gives you

- **Gateway over Tailscale:** access the gateway at
  `https://<tailnet-hostname>:18789` from any device on your tailnet.
- **SSH from OpenClaw to tailnet devices:** from inside the container, connect
  with `ssh <tailnet-ip>` (or a MagicDNS name if `TS_ACCEPT_DNS=true`), using
  the `openssh-client` already present in the image.

### Details

- The Tailscale node runs in **kernel networking mode** (`TS_USERSPACE=false`),
  so it needs `/dev/net/tun` and `net_admin`/`net_raw` (available on Linux hosts
  and Docker Desktop).
- Node identity persists in the `openclaw-tailscale-state` volume. When you
  upgrade OpenClaw, recreate both services together so the shared network
  namespace stays in sync.
- `TS_EXTRA_ARGS` accepts extra `tailscale up` flags (for example
  `--ssh --advertise-exit-node`).

## Image Tags

| Tag              | Example                                             | Description                        |
| ---------------- | --------------------------------------------------- | ---------------------------------- |
| `latest`         | `ghcr.io/ashokbaruaakas/clawkit:latest`             | Latest release                     |
| `v0.0.N`         | `ghcr.io/ashokbaruaakas/clawkit:v0.0.6`             | Specific clawkit version (semver)  |
| `openclaw-<ver>` | `ghcr.io/ashokbaruaakas/clawkit:openclaw-2026.5.19` | Specific OpenClaw upstream version |

For production, pin `IMAGE_TAG` to a specific `openclaw-<ver>` tag rather than
`latest` so upgrades are reproducible and reversible. `latest` always tracks the
newest release and can change underneath you between pulls.

## Image Contents

The published image is built from a digest-pinned stable OpenClaw base selected by the release workflow.

Note:

- Workflow releases pin `OPENCLAW_IMAGE` to a resolved upstream digest.
- Local Dockerfile builds use the default floating base `ghcr.io/openclaw/openclaw:latest` unless you override `OPENCLAW_IMAGE`.

This image adds:

- Linuxbrew installed under `/home/linuxbrew/.linuxbrew` for the `node` user
- Development packages: `build-essential`, `ca-certificates`, `curl`, `file`, `git`, `openssh-client`, `procps`, `sudo`, `vim`
- Global npm install path configured for non-root use (`/home/node/.npm-global`)
- Node compile cache directory pre-created (`/home/node/.cache/node-compile-cache`)

Note: the `linuxbrew-prefix` volume is seeded from the image on first run and is
not refreshed by image upgrades. Linuxbrew itself (and any brew-installed
packages) persist in the volume, so run `brew update && brew upgrade` inside the
container when you need newer formulae.

## Release and Update Strategy

This project uses the GitHub Actions workflow `.github/workflows/release-check.yml`.

Automated behavior:

- Runs daily at `00:00 UTC`
- Resolves latest stable OpenClaw version and digest
- Compares with cached upstream state
- Builds and releases only when upstream stable version changed (or on first run)

Manual behavior (`workflow_dispatch`):

- `change_type=patch|minor|major`: controls semantic version bump for manual releases
- `force_release=true`: build and release even when upstream stable version is unchanged/already released
- On first run (no cached state), an initial release is created

The automatic release trigger compares the upstream stable **version string**, not
the image digest. If OpenClaw republishes the same version under a new digest, the
workflow skips it; use a manual `force_release` run to pick up such a republish.

Published tags per release:

- `latest`
- `v0.0.N`
- `openclaw-<upstream-version>`

## Upgrading OpenClaw

Clawkit upgrades OpenClaw by replacing the image, not by running an in-container
package updater. When a new image starts against the existing state volume, the
Gateway runs its startup-safe migrations and plugin convergence before readiness.
See OpenClaw's [Upgrading container images](https://docs.openclaw.ai/install/docker#upgrading-container-images)
for the upstream behavior this relies on.

### Routine upgrade

The compose file sets `pull_policy: always`, so pulling and recreating is enough:

```bash
docker compose -f docker-compose.yml pull
docker compose -f docker-compose.yml up -d
```

No separate migration step is required for routine updates.

### Before a significant update

OpenClaw recommends a verified backup before major version changes. Run a
one-off backup against the state volume, writing to a host directory:

```bash
mkdir -p backups
docker compose -f docker-compose.yml stop
docker run --rm \
  -v openclaw-node-home:/home/node \
  -v "$PWD/backups:/backup" \
  ghcr.io/ashokbaruaakas/clawkit:latest \
  node openclaw.mjs backup create --output /backup --verify
docker compose -f docker-compose.yml start
```

See OpenClaw's [backup guidance](https://docs.openclaw.ai/install/updating/rollback-and-recovery#before-updating-create-a-verified-backup).

### If the container won't become healthy

If startup cannot repair the mounted state safely, the Gateway exits instead of
reporting healthy and Docker restarts it in a loop. Run the repair command once
against the same state volume, then restart the container:

```bash
docker run --rm \
  -v openclaw-node-home:/home/node \
  ghcr.io/ashokbaruaakas/clawkit:latest \
  node openclaw.mjs doctor --fix
docker compose -f docker-compose.yml up -d
```

### Rollback

To return to a previous OpenClaw version, pin `IMAGE_TAG` to the matching
`openclaw-<version>` tag in `.env`, then recreate:

```bash
# .env
IMAGE_TAG=openclaw-2026.9.5
```

```bash
docker compose -f docker-compose.yml pull
docker compose -f docker-compose.yml up -d
```

### Not applicable inside the container

- `openclaw update` targets npm/pnpm/bun/git installs; the container image is
  immutable, so replacing the image is the update path.
- `openclaw migrate` is for cross-system moves (e.g. Claude import or
  machine-to-machine). For clawkit, "migration" means moving the `node-home`
  volume and config to a new host.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## AI Context

For AI-session handoff and repository operating rules, see [AGENTS.md](AGENTS.md).

## License

This project is licensed under the [MIT License](LICENSE).
