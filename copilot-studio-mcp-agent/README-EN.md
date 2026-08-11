# Copilot Studio Agents — HPE Aruba Networking

This section documents a family of Microsoft Copilot Studio agents designed for HPE Aruba Networking Channel SE and presales use cases.

The screenshots have been redacted. The author’s name is intentionally retained for attribution. Public examples expose no secrets, customer data, tenant details, internal connections or private endpoints.

## Documented agents

| Agent | Role | Architecture | Status |
|---|---|---|---|
| [Aruba Network Assistant](agents/05-aruba-network-assistant/README-EN.md) | Query Aruba Central in natural language | Read-only Aruba Central MCP | Documented and demonstrated |
| [HPE Networking Presales Advisor](agents/02-presales-knowledge-advisor/README-EN.md) | Retrieve Networking technical knowledge | Documentary knowledge / RAG | Documented |
| [Partner & Customer Reference Guide](agents/03-partner-customer-reference-guide/README-EN.md) | Route users to the right partner and customer resources | Documentary knowledge | Documented |
| [HPE France Opportunity Finder](agents/01-opportunity-finder/README-EN.md) | Build a fact-based opportunity view for SEs | CRM tools + coverage reference | Documented |
| [Juniper Mist Assistant](agents/04-juniper-mist-assistant/README-EN.md) | Evaluate a Juniper MCP integration | Juniper MCP | Experimental — not validated in Copilot Studio |

## What this collection demonstrates

- Several Copilot Studio architecture patterns: MCP, knowledge/RAG and business tools.
- The difference between a documentary agent, an operational agent and a live-data agent.
- Why sources, permissions, limitations and guardrails must be documented.
- A complete workflow: configuration, testing, publishing, sharing and demonstration.

## Screenshots

Redacted screenshots are grouped by agent in [`captures/`](captures/).

## Français

Read the [French version](README.md).
