#!/usr/bin/env bash
#
# Clawkit deploy bootstrap.
#
# Downloads the deploy files (docker-compose.yml, docker-compose.tailscale.yml,
# and .env.example) from the main branch and seeds a local .env, so you can run
# Clawkit in production without cloning the repository.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/ashokbaruaakas/clawkit/main/install.sh | bash
#   # or, to install into a specific directory:
#   curl -fsSL https://raw.githubusercontent.com/ashokbaruaakas/clawkit/main/install.sh | bash -s /path/to/clawkit

set -euo pipefail

REPO="ashokbaruaakas/clawkit"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"

FILES=(
  "docker-compose.yml"
  "docker-compose.tailscale.yml"
  ".env.example"
)

TARGET_DIR="${1:-./clawkit}"

mkdir -p "${TARGET_DIR}"

echo "==> Downloading deploy files into ${TARGET_DIR}"
for file in "${FILES[@]}"; do
  echo "    ${file}"
  curl -fsSL --retry 3 "${RAW_BASE}/${file}" -o "${TARGET_DIR}/${file}"
done

if [ ! -f "${TARGET_DIR}/.env" ]; then
  cp "${TARGET_DIR}/.env.example" "${TARGET_DIR}/.env"
  echo "==> Created ${TARGET_DIR}/.env from .env.example"
else
  echo "==> ${TARGET_DIR}/.env already exists, leaving it untouched"
fi

echo ""
echo "Done. Next steps:"
echo "  1. cd ${TARGET_DIR}"
echo "  2. Edit .env and set OPENCLAW_GATEWAY_TOKEN (openssl rand -hex 32) and at least one LLM API key"
echo "  3. docker compose -f docker-compose.yml up -d"
echo ""
echo "Pin IMAGE_TAG to a specific openclaw-<version> tag in .env for reproducible production deployments."
