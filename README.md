# Clawkit

A wrapper image around [OpenClaw](https://hub.docker.com/r/alpine/openclaw) that adds **Linuxbrew** and other development tools, published to GHCR for easy consumption via Docker Compose.

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/ashokbaruaakas/clawkit.git
cd clawkit

# 2. Copy the environment file
cp .env.example .env
# Edit .env with your API keys (see comments in the file)

# 3. Start the container
docker compose -f example-docker-compose.yml up -d
```

The container will pull the latest `ghcr.io/ashokbaruaakas/clawkit` image and start OpenClaw with Linuxbrew available.

## Image Tags

| Tag | Example | Description |
|---|---|---|
| `latest` | `ghcr.io/ashokbaruaakas/clawkit:latest` | Latest release |
| `v0.0.N` | `ghcr.io/ashokbaruaakas/clawkit:v0.0.6` | Specific clawkit version (semver) |
| `openclaw-<ver>` | `ghcr.io/ashokbaruaakas/clawkit:openclaw-2026.5.19` | Specific OpenClaw upstream version |

## How It Works

This project provides a **GitHub Actions workflow** (`release-check.yml`) that:

1. **Checks daily** at midnight UTC for the latest stable OpenClaw release
2. **Compares the image digest** against the last known digest (stored in GHA cache)
3. **If upstream changed**: builds a new clawkit image, pushes to GHCR, creates a GitHub Release
4. **Can be triggered manually** with `force_release` and `release_type` inputs

The Docker image is based on the resolved stable `ghcr.io/openclaw/openclaw:<version>` image and adds:
- **Linuxbrew** (Homebrew for Linux) installed for the `node` user
- Development tools: `build-essential`, `git`, `curl`, `openssh-client`, `sudo`, `vim`
- Global npm installs configured for non-root user
- Node compile cache directory pre-configured

## Environment Variables

See [`.env.example`](.env.example) for all available configuration.

Key variables:
- `OPENCLAW_GATEWAY_TOKEN` — Gateway authentication token
- `DEEPSEEK_API_KEY` — DeepSeek LLM provider key
- `GEMINI_API_KEY` — Google Gemini API key
- `OPENROUTER_API_KEY` — OpenRouter API key
- `DISCORD_BOT_TOKEN` — Discord bot token (optional)
- `NOTION_API_KEY` — Notion integration token (optional)

## Releasing

This project uses automated releases via GitHub Actions:

- **Automated**: Runs daily at midnight UTC, checks for upstream OpenClaw changes
- **Manual**: Use the `release-check.yml` workflow with `force_release=true` or set `release_type` to `code_update` or `emergency`
- **Emergency**: Use the manual `Create Release` workflow for tag-only releases

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## License

MIT
