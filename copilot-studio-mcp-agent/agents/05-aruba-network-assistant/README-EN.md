# Aruba Network Assistant — Copilot Studio via MCP

The Aruba Network Assistant is a Microsoft Copilot Studio agent connected to Aruba Central through a **Model Context Protocol (MCP)** server.

It answers natural-language questions about network operations — devices, alerts, sites, clients and topology — in **read-only mode**.

## Functional architecture

```text
Teams / Microsoft 365 user
          │
          ▼
Aruba Network Assistant
   Microsoft Copilot Studio
          │
          ▼
Model Context Protocol tool
          │
          ▼
Aruba Central MCP server
       read-only access
```

## Configuration workflow

1. Create the agent in Copilot Studio.
2. Select the model.
3. Add a **Model Context Protocol** tool.
4. Create and verify the MCP connection.
5. Enable only the required tools.
6. Test the agent.
7. Publish it.
8. Configure Teams/Microsoft 365 channels.
9. Share it with authorized users.
10. Run the final Teams test.

## Design principles

- Expose the minimum required operations.
- Prefer read-only integrations for demonstrations.
- Enable MCP tools selectively.
- Describe each tool clearly so the model can select the right call.
- Make data source and freshness explicit.
- Keep tenant, endpoint, site, device and operational details private.

## Configuration screenshots

- [Copilot Studio context](../../captures/aruba-network-assistant/01-copilot-studio-context.png)
- [Agent overview](../../captures/aruba-network-assistant/02-agent-overview.png)
- [Add a tool](../../captures/aruba-network-assistant/07-add-tool.png)
- [MCP configuration](../../captures/aruba-network-assistant/08-mcp-configuration.png)
- [Publication and channels](../../captures/aruba-network-assistant/09-publication-channels.png)
- [Sharing](../../captures/aruba-network-assistant/11-sharing.png)

## Demonstrations

- [Copilot App view](../../captures/aruba-network-assistant/12-copilot-app-overview.png)
- [Teams test](../../captures/aruba-network-assistant/13-teams-demo.png)

## Detailed guide

- [MCP configuration guide in English](configuration-guide-en.md)
- [Guide de configuration MCP en français](configuration-guide.md)
- [Agent captures](../../captures/aruba-network-assistant/)
- [Public page](PUBLIC.md)
- [Internal working sheet](INTERNAL.md)

## Key considerations

- The MCP server description helps the model decide when to call the tool.
- Selective activation reduces context noise and unnecessary calls.
- Microsoft authentication and tenant DLP policies affect available channels.
- The documented server is read-only: no remediation or configuration action is exposed.

## Français

Lire la [version française](README.md).
