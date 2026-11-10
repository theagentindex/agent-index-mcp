# Agent Index MCP

Thin public wrapper for the [Agent Index](https://theagentindex.io) remote MCP server, published by Heritage Services. This repository does not contain the site, the dataset, or a bundled server. It points clients at the hosted endpoint.

The server is read-only. It covers an open [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) dataset of governance, risk, compliance, and security AI agents, plus compliance audit firms. DOI: [10.5281/zenodo.23604511](https://doi.org/10.5281/zenodo.23604511).

## Endpoint

- URL: `https://theagentindex.io/api/mcp`
- Transport: Streamable HTTP
- Authentication: none
- Protocol version: `2025-03-26`
- Official MCP Registry: `io.theagentindex/agent-index` 1.1.0

## Tools

- `search_agents`
- `get_agent`
- `search_auditors`
- `get_auditor`
- `compare_agents`
- `get_alternatives`

## Client config

```json
{"$schema":"https://agent-plugins.org/schemas/1.0.0/mcp.schema.json","mcpServers":{"agent-index":{"type":"streamable-http","url":"https://theagentindex.io/api/mcp"}}}
```

The same object is in [`mcp.json`](mcp.json).

## Links

- Docs: https://theagentindex.io/data/#mcp
- Privacy: https://theagentindex.io/privacy/
- Contact: https://theagentindex.io/contact/
- Support: sales@heritageservices.online

## License

The code and config in this repository are released under the MIT License (see [LICENSE](LICENSE)). The Agent Index data served by the endpoint is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

Publisher: Heritage Services.
