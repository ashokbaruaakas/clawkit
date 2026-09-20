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
#   # or, to name everything (container, volumes, network) after your bot:
#   curl -fsSL https://raw.githubusercontent.com/ashokbaruaakas/clawkit/main/install.sh | bash -s mybot

set -euo pipefail

REPO="ashokbaruaakas/clawkit"
REF="${CLAWKIT_REF:-main}"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${REF}"

FILES=(
  "docker-compose.yml"
  "docker-compose.tailscale.yml"
  ".env.example"
)

TARGET_DIR="${1:-./clawkit}"
NAME="$(basename "${TARGET_DIR}")"

mkdir -p "${TARGET_DIR}"

echo "==> Downloading deploy files into ${TARGET_DIR}"
for file in "${FILES[@]}"; do
  echo "    ${file}"
  curl -fsSL --retry 3 "${RAW_BASE}/${file}" -o "${TARGET_DIR}/${file}"
done

if [ ! -f "${TARGET_DIR}/.env" ]; then
  awk -v name="${NAME}" 'BEGIN{OFS=FS="="} $1=="CONTAINER_NAME" {$0="CONTAINER_NAME=" name} {print}' \
    "${TARGET_DIR}/.env.example" > "${TARGET_DIR}/.env"
  echo "==> Created ${TARGET_DIR}/.env from .env.example (CONTAINER_NAME=${NAME})"
else
  echo "==> ${TARGET_DIR}/.env already exists, leaving it untouched"
fi

# Seed a starter gateway config so the Gateway boots in local mode and reads its
# auth token from OPENCLAW_GATEWAY_TOKEN in .env via ${...} env substitution.
# Only written when no config exists yet; never clobbers an existing config.
CONFIG_PATH="/home/node/.openclaw/openclaw.json"

if command -v docker >/dev/null 2>&1; then
  echo "==> Seeding gateway config (mode=local, bind=lan, auth token from env)"
  docker compose \
    -f "${TARGET_DIR}/docker-compose.yml" \
    --project-directory "${TARGET_DIR}" \
    run --rm --no-deps -T --entrypoint sh openclaw -c \
    "test -f '${CONFIG_PATH}' || cat > '${CONFIG_PATH}'" <<'CONFIG_EOF'
{
  "gateway": {
    "mode": "local",
    "bind": "lan",
    "auth": { "mode": "token", "token": "${OPENCLAW_GATEWAY_TOKEN}" }
  }
}
CONFIG_EOF
else
  echo "==> Docker not found; skipping config seed. After installing Docker, run:"
  echo "    docker compose -f docker-compose.yml run --rm --no-deps -T --entrypoint sh openclaw -c \\"
  echo "      \"test -f /home/node/.openclaw/openclaw.json || cat > /home/node/.openclaw/openclaw.json\""
fi

echo ""
echo "Done. Next steps:"
echo "  1. cd ${TARGET_DIR}"
echo "  2. Edit .env and set OPENCLAW_GATEWAY_TOKEN (openssl rand -hex 32) and at least one LLM API key"
echo "  3. Start without Tailscale:"
echo "       docker compose -f docker-compose.yml up -d"
echo "     Or with Tailscale (set TS_AUTHKEY in .env first):"
echo "       docker compose -f docker-compose.yml -f docker-compose.tailscale.yml up -d"
echo ""
echo "Pin IMAGE_TAG to a specific openclaw-<version> tag in .env for reproducible production deployments."
