#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENDPOINT="$(jq -r '.mcpServers["agent-index"].url' "$ROOT/mcp.json")"

if [[ -z "$ENDPOINT" || "$ENDPOINT" == "null" ]]; then
  echo "mcp.json is missing mcpServers.agent-index.url" >&2
  exit 1
fi

init_payload='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"agent-index-mcp-verify","version":"1.0.0"}}}'

init_result="$(curl -fsS -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -d "$init_payload")"

if ! jq -e '.result.serverInfo.name == "agent-index"' >/dev/null <<<"$init_result"; then
  echo "initialize failed or unexpected serverInfo:" >&2
  echo "$init_result" >&2
  exit 1
fi

search_payload='{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"search_agents","arguments":{"query":"soc2","limit":1}}}'

search_result="$(curl -fsS -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -d "$search_payload")"

slug="$(jq -r '.result.content[0].text | fromjson | .results[0].slug' <<<"$search_result")"

if [[ -z "$slug" || "$slug" == "null" ]]; then
  echo "search_agents returned no results:" >&2
  echo "$search_result" >&2
  exit 1
fi

echo "OK: Agent Index MCP at $ENDPOINT (sample agent: $slug)"
