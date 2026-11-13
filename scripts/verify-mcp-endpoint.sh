#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENDPOINT="$(jq -r '.mcpServers["agent-index"].url' "$ROOT/mcp.json")"

if [[ -z "$ENDPOINT" || "$ENDPOINT" == "null" ]]; then
  echo "mcp.json is missing mcpServers.agent-index.url" >&2
  exit 1
fi

USER_AGENT="AgentIndex-Internal-Validator/1.0"

init_payload='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"agent-index-mcp-verify","version":"1.0.0"}}}'
list_payload='{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}'

header_file="${TMPDIR:-/tmp}/agent-index-mcp-verify.$$"
rm -f "$header_file"
trap 'rm -f "$header_file"' EXIT

init_result="$(curl -fsS -D "$header_file" -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "User-Agent: ${USER_AGENT}" \
  -d "$init_payload")"

if ! jq -e '.result.serverInfo.name == "agent-index"' >/dev/null <<<"$init_result"; then
  echo "initialize failed or unexpected serverInfo:" >&2
  echo "$init_result" >&2
  exit 1
fi

session_id=""
while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%$'\r'}"
  key="${line%%:*}"
  key="${key%"${key##*[![:space:]]}"}"
  key_lc="$(printf '%s' "$key" | tr '[:upper:]' '[:lower:]')"
  if [[ "$key_lc" == "mcp-session-id" ]]; then
    session_id="${line#*:}"
    session_id="${session_id#"${session_id%%[![:space:]]*}"}"
    session_id="${session_id%"${session_id##*[![:space:]]}"}"
    break
  fi
done < "$header_file"

if [[ -n "$session_id" && "$session_id" =~ [[:cntrl:]] ]]; then
  echo "initialize returned an invalid Mcp-Session-Id" >&2
  exit 1
fi

list_headers=(
  -H "Content-Type: application/json"
  -H "User-Agent: ${USER_AGENT}"
)
if [[ -n "$session_id" ]]; then
  list_headers+=(-H "Mcp-Session-Id: ${session_id}")
fi

list_result="$(curl -fsS -X POST "$ENDPOINT" \
  "${list_headers[@]}" \
  -d "$list_payload")"

if ! jq -e '.result.tools | type == "array"' >/dev/null <<<"$list_result"; then
  echo "tools/list failed or did not return a tools array:" >&2
  echo "$list_result" >&2
  exit 1
fi

tool_count="$(jq -r '.result.tools | length' <<<"$list_result")"
if ! jq -e '[.result.tools[].name] | index("search_agents") != null' >/dev/null <<<"$list_result"; then
  echo "tools/list did not include search_agents (tools: ${tool_count})" >&2
  exit 1
fi

echo "tools: ${tool_count}"
echo "OK: Agent Index MCP at ${ENDPOINT}"
