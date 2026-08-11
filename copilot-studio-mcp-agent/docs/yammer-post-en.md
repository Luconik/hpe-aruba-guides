# Yammer post draft — HPEN (English)

> Draft for review before posting in the HPEN community.

🚀 **Documenting a family of Copilot Studio agents for HPE Aruba Networking**

Over the past few weeks, I have been documenting several Microsoft Copilot Studio agents designed for Channel SE and presales use cases across HPE Aruba Networking.

The collection covers different patterns:

✅ **Aruba Network Assistant** — a read-only MCP integration for conversational access to Aruba Central operational information
✅ **HPE Networking Presales Advisor** — a knowledge-grounded assistant for technical presales content
✅ **Partner & Customer Reference Guide** — an assistant to help find the right official resource
✅ **HPE France Opportunity Finder** — a fact-based view of opportunities for Sales Engineers
✅ **Juniper Mist Assistant** — an MCP integration currently documented as experimental, since the Juniper MCP was not accessible from Copilot Studio during the last test

The goal was not only to build agents, but also to document the full lifecycle:

- architecture and data sources;
- knowledge and tool configuration;
- MCP connection and read-only boundaries;
- publication and channel setup;
- sharing and Teams demonstrations;
- limitations, guardrails and open questions.

I have consolidated the documentation in the HPE Aruba guides repository, with a dedicated page for each agent and redacted screenshots grouped by use case:

📘 **[Copilot Studio agents — HPE Aruba Networking](https://github.com/Luconik/hpe-aruba-guides/tree/main/copilot-studio-mcp-agent)**

This work also highlights an important principle: the quality of an enterprise AI agent depends as much on source governance, permissions and explicit boundaries as on the model itself.

The next step is to continue validating the remaining integrations and to refine the public examples with synthetic data where appropriate.

#MicrosoftCopilot #CopilotStudio #MCP #ModelContextProtocol #HPEArubaNetworking #ArubaCentral #Presales #ChannelSE #EnterpriseAI

## Suggested attachment

Use the caviardée Teams demonstration of **Aruba Network Assistant**:

`copilot-studio-mcp-agent/captures/aruba-network-assistant/13-teams-demo.png`

Optional carousel order:

1. Aruba Network Assistant — Teams demonstration
2. MCP configuration screenshot
3. Presales Knowledge Advisor — Teams response
4. Opportunity Finder — Teams response

## Review before posting

- Confirm the wording “over the past few weeks” matches the intended timeline.
- Confirm the HPEN community name and the GitHub link.
- Confirm that all attached screenshots are the approved caviardées versions.
- Keep the Juniper wording as experimental until the MCP has been retested in Copilot Studio.
