#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v jq >/dev/null 2>&1; then
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends jq ca-certificates curl
fi

for f in mcp.json plugin.json .cursor-plugin/plugin.json; do
  jq empty "$f"
done

if [[ -f "$ROOT/scripts/verify-mcp-endpoint.sh" ]]; then
  bash "$ROOT/scripts/verify-mcp-endpoint.sh"
fi

echo "install: config validated and remote MCP verified"
