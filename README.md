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
docker compose -f example-docker-compose.yml up -d
```

Default behavior:

- Pulls `ghcr.io/ashokbaruaakas/clawkit:latest`
- Binds to `127.0.0.1:${PORT}` (default `18789`)
- Persists `/home/node` and `/home/linuxbrew/.linuxbrew` via named volumes

## Configuration

All variables are documented in [.env.example](.env.example).

Common variables:

- `CONTAINER_NAME`: container name in Docker
- `IMAGE_NAME`: image repository to pull from
- `IMAGE_TAG`: image tag to use (defaults to `latest`)
- `PORT`: local bind and service port (default `18789`)

OpenClaw runtime:

- `OPENCLAW_GATEWAY_TOKEN`: gateway authentication token
- `OPENCLAW_NO_RESPAWN`: when set to `1`, disables automatic respawn behavior
- `NODE_COMPILE_CACHE`: compile cache directory path

LLM providers (set at least one):

- `DEEPSEEK_API_KEY`
- `GEMINI_API_KEY`
- `OPENROUTER_API_KEY`

Optional integrations:

- `DISCORD_BOT_TOKEN`
- `NOTION_API_KEY`

## Image Tags

| Tag              | Example                                             | Description                        |
| ---------------- | --------------------------------------------------- | ---------------------------------- |
| `latest`         | `ghcr.io/ashokbaruaakas/clawkit:latest`             | Latest release                     |
| `v0.0.N`         | `ghcr.io/ashokbaruaakas/clawkit:v0.0.6`             | Specific clawkit version (semver)  |
| `openclaw-<ver>` | `ghcr.io/ashokbaruaakas/clawkit:openclaw-2026.5.19` | Specific OpenClaw upstream version |

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

Published tags per release:

- `latest`
- `v0.0.N`
- `openclaw-<upstream-version>`

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## AI Context

For AI-session handoff and repository operating rules, see [AGENTS.md](AGENTS.md).

## License

This project is licensed under the [MIT License](LICENSE).
