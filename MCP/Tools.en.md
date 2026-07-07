# MCP Configuration — HPE Aruba Central & Juniper Mist on Claude Desktop

🇬🇧 English version — [🇫🇷 Version française](./Tools.fr.md)

> ℹ️ **Attribution note**: this document is not original work, but a personal write-up and re-documentation of two existing tools — the HPE Networking MCP Server platform by Jibran Aziz (HPE) and Juniper's official Mist MCP server. It compiles my own client-side setup and troubleshooting notes; all credit for the underlying work belongs to their respective authors (see Credits and Sources sections below).

Documentation of setting up two MCP (Model Context Protocol) servers on Claude Desktop macOS, enabling natural-language queries against a multi-platform Aruba Central demo tenant and a Juniper Mist organization (homelab), directly from Claude.

## Credits

The **HPE Networking MCP Server** part (`mcp.arubademo.online`) is entirely built on the platform developed by **Jibran Aziz** (HPE) — a publicly hosted AI integration platform requiring no backend installation, connecting Aruba Central Classic/New, ClearPass, EdgeConnect Orchestrator, and HPE GreenLake to Claude. All server-side logic, OAuth2/API Key authentication, and the 143 exposed tools are his work; this document only covers my own client-side setup (Claude Desktop) based on his user guide.

- Portal: https://mcp.arubademo.online/dashboard
- Contact for ClearPass demo access: jibran.aziz@hpe.com

The **Juniper Mist** part relies on Juniper's official MCP server (beta), documented separately — see section 2 and sources below.

## Architecture

```
Claude Desktop (MCP client, stdio)
        │
        ├── HPE Networking MCP Server ──► mcp.arubademo.online (SSE) ──► Aruba Central / ClearPass / EdgeConnect / GreenLake
        │                                   (platform by Jibran Aziz, HPE)
        │
        └── Juniper Mist ──────────────► mcp.ai.juniper.net/mcp/mist (Streamable HTTP) ──► Mist Cloud API (api.eu.mist.com)
```

---

## 1. HPE Networking MCP Server (platform by Jibran Aziz)

### What the platform covers

6 connected platforms, 143 tools total, all read-only except a few explicitly marked ✏️ (e.g. `upgrade_firmware`, `cppm_disconnect_session`, `move_device_to_group`):

| Platform | Tools | Authentication |
|---|---|---|
| Aruba Classic Central | 57 | OAuth2 refresh_token |
| Aruba New Central | 30 | OAuth2 client_credentials |
| ClearPass (CPPM) | 19 | OAuth2 client_credentials |
| EdgeConnect Orchestrator | 29 | API Key (X-Auth-Token) |
| HPE GreenLake | 4 | SSO via New Central |
| Network Summary / AI | 4 | Via New Central |

Functional coverage: sites & health, devices/APs, clients, switches, gateways, alerts & events, firmware, security/WIDS, AI insights, configuration, audit, ClearPass/RADIUS sessions, NAC endpoint profiling, guest accounts, SD-WAN tunnels/overlays, BGP/OSPF routing, licensing. Full list of the 143 tools available in the official user guide (PDF provided by Jibran Aziz) or directly in the dashboard's **Capabilities** tab.

### Getting started (~10 min, per the official guide)

1. **Create an account** at https://mcp.arubademo.online/sign-up (email + password + 6-digit verification code)
2. **Connect Aruba Central**: *Aruba Central* tab → select *Classic Central* → choose your region's base URL → enter Client ID / Client Secret (Account Home → API Gateway → My Apps & Tokens) and Credential ID / Refresh Token (*Download Token* button on the token row, then open the JSON)
   > ⚠️ Generate a fresh token right before connecting — it expires in 2 hours. Once connected, the server auto-refreshes it every 30 minutes.
3. **Connect ClearPass** *(optional)*: hostname only (no `https://`) + Client ID/Secret (ClearPass → Administration → API Services → API Clients). CPPM must be publicly reachable on port 443 from `mcp.arubademo.online`, otherwise whitelist its public IP.
4. **Connect EdgeConnect** *(optional)*: Orchestrator hostname/IP (port 443 reachable) + read-only-minimum API Key (Orchestrator → Admin → API → API Keys)
5. **Generate your API key**: *API Keys* tab, label it, *Generate API Key* — copy immediately, cannot be retrieved afterwards
6. **Configure Claude Desktop** — see below

### `claude_desktop_config.json` (macOS/Linux, `mcp-proxy` package)

Per the official guide, the recommended install path is `npm install -g mcp-proxy`, then:

```json
{
  "mcpServers": {
    "HPE Networking MCP Server": {
      "command": "mcp-proxy",
      "args": [
        "-H", "X-API-Key", "amcp_YOUR_KEY",
        "https://mcp.arubademo.online/sse"
      ]
    }
  }
}
```

### What I actually ran into (field notes)

- With `mcp-proxy` installed via **Homebrew** (rather than `npm`), the two-token `-H KEY VALUE` syntax triggered a `spawn amcp_... ENOENT` error — the process tried to spawn the API key itself as the command.
- Workaround: switch to `npx mcp-remote` with the single-string `--header "Key:Value"` syntax, which worked reliably:
  ```json
  {
    "mcpServers": {
      "HPE Networking MCP Server": {
        "command": "npx",
        "args": [
          "mcp-remote",
          "https://mcp.arubademo.online/sse",
          "--header",
          "X-API-Key:${API_KEY}"
        ],
        "env": { "API_KEY": "amcp_YOUR_KEY" }
      }
    }
  }
  ```
  → If the official `mcp-proxy` package (npm or pip, depending on OS) works directly for you, prefer the official method above; `mcp-remote` remains a validated fallback in my case.
- The config file must contain **a single `mcpServers` object** — a common mistake is closing it too early and placing a second server at the JSON root, where Claude Desktop won't see it. Always validate with:
  ```bash
  python3 -m json.tool ~/Library/Application\ Support/Claude/claude_desktop_config.json
  ```

### Test

Fully restart Claude Desktop (Cmd+Q, then relaunch), then ask:
> *"How many clients are connected to my network right now?"*

---

## 2. Juniper Mist (official Juniper MCP server, beta)

Official source: [Using the Juniper Mist MCP Server with Claude Desktop (Beta) — Juniper Networks](https://www.juniper.net/documentation/us/en/software/mist/mist-aiops/shared-content/topics/concept/juniper-mist-mcp-claude.html)

This part is independent from Jibran Aziz's platform (which actually lists Mist as "🔜 Coming Soon" in its offering): this is Juniper's own officially published MCP server.

### Configuration

```json
{
  "mcpServers": {
    "Juniper Mist": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "https://mcp.ai.juniper.net/mcp/mist",
        "--header",
        "Authorization:Bearer ${MIST_TOKEN}",
        "--header",
        "X-Mist-Base-URL:https://api.eu.mist.com"
      ],
      "env": { "MIST_TOKEN": "YOUR_MIST_TOKEN" }
    }
  }
}
```

### Issues encountered and resolved

1. **`HTTP 401`** with `api.mist.com` (default US shard) → Mist Cloud is split across regional shards (`api.mist.com` US, `api.eu.mist.com` EU, etc.); a token is only valid on its origin shard. Quick direct check:
   ```bash
   curl -s -H "Authorization: Token YOUR_TOKEN" https://api.eu.mist.com/api/v1/self
   ```
2. **`authentication required: missing authorization`** with the `Token` scheme → Juniper's MCP server specifically expects `Bearer` in the `Authorization` header, then reformats it internally toward the Mist API. Resolved with `Authorization:Bearer <token>` + `X-Mist-Base-URL:https://api.eu.mist.com`.

---

## Security

- Tokens are never hardcoded in `args` — passed via environment variables (`env`, referenced as `${VAR}`)
- `chmod 600 ~/Library/Application\ Support/Claude/claude_desktop_config.json`
- `mcp.arubademo.online` is a publicly hosted third-party service holding Aruba Central/ClearPass/EdgeConnect credentials server-side — suitable for demo/lab use; check internal security policy before any production Central use
- The Mist MCP grants access to potentially sensitive data (PSKs, RADIUS secrets, SNMP credentials, depending on the queried config resources)

## Sources

- **HPE Networking MCP Server — User Guide** (PDF), platform and documentation by **Jibran Aziz** (HPE) — https://mcp.arubademo.online/dashboard
- [Using the Juniper Mist MCP Server with Claude Desktop (Beta) — Juniper Networks](https://www.juniper.net/documentation/us/en/software/mist/mist-aiops/shared-content/topics/concept/juniper-mist-mcp-claude.html)
- [sparfenyuk/mcp-proxy — GitHub](https://github.com/sparfenyuk/mcp-proxy)
- [tmunzer/mistmcp — GitHub](https://github.com/tmunzer/mistmcp) (self-hosted alternative, not used in this final configuration)
