# Aruba Central Monitoring — Copilot Studio Agent via MCP

Guide for building a Microsoft Copilot Studio agent connected to Aruba Central through an **MCP (Model Context Protocol)** server, published internally to Microsoft Teams / Microsoft 365 Copilot.

The resulting agent (« Aruba Network Assistant ») answers natural-language questions about the state of the Aruba Central network — devices, alerts, sites, clients, topology — in read-only mode.

---

## Context

Microsoft Copilot Studio natively supports MCP servers as a tool type. This lets you wire a Copilot conversational agent directly to an existing MCP server (here, an in-house MCP server exposing the Aruba Central API in read-only mode — see the `central` skill) without building a custom Power Platform connector.

Result: an agent usable in Teams by the whole team, able to query Aruba Central live (devices, clients, alerts, onboarding, topology...).

---

## Prerequisites

- Access to [Copilot Studio](https://copilotstudio.microsoft.com) on the HPE tenant
- An Aruba Central MCP server already deployed and reachable over HTTPS (public URL or exposed via tunnel), **read-only** — see the `central` skill for endpoint details
- Agent publishing rights + Teams sharing rights on the target Power Platform environment

---

## Steps

### 1. Create the agent

In Copilot Studio → **Home** → **Agent** → describe the agent or start from a blank one.

![Copilot Studio home](img/1-Accueil-CopilotStudio.png)

Name the agent (e.g. `Aruba mcp agent`), then **Create**.

![Name the agent](img/2-Name-Agent.png)

### 2. Choose the model

In **Overview**, select the model under **Select your agent's model**. Claude Sonnet 4.6 is available under *Anthropic models*.

![Model selection](img/3-Choix-Models.png)

> Models available at test time: GPT-5 (Chat/Auto/Reasoning/5.3/5.5), GPT-4.1, Claude (Sonnet 4.6, Opus 4.6/4.7/4.8). Grok and Mistral were disabled by the HPE tenant policy.

### 3. Add the MCP server as a tool

**Tools** tab → **Add a tool**.

![Create your first tool](img/4-Add-Tool.png)

In the **Add tool** window, choose **Model Context Protocol** (next to *Agent flow*, *Prompt*, *Computer use*).

![Model Context Protocol selection](img/5-Add-Tool-mcp.png)

Fill in:
- **Server name**: explicit name (e.g. `Aruba Central Monitoring MCP`)
- **Server description**: clear functional description — this is the context the LLM uses to decide when to call the tool (e.g. *"Aruba Central read-only MCP server for live monitoring: devices, APs, switches, gateways, clients, sites, alerts and topology"*)
- **Server URL**: HTTPS URL of the MCP server
- **Authentication**: `None` / `API key` / `OAuth 2.0` depending on the server's configuration

![MCP server configuration](img/6-Create-mcp-configuration.png)

### 4. Create the connection

After **Create**, Copilot Studio asks for a connection associated with the MCP server (**Not connected** by default).

![No connection](img/7-mcp-Not-Connected.png)

Click **Create new connection** → a connection window opens showing the server's name and description.

![New connection](img/8-mcp-New-Connection.png)

**Create** to confirm.

![Connection creation](img/9-mcp-Create.png)

The connection switches to connected status (green icon).

![Connection established](img/10-mcp-Connection-ok.png)

**Add and configure** to finalize adding the tool to the agent.

### 5. Enable the exposed MCP tools

The added MCP tool automatically lists every function exposed by the server (e.g. `get_devices`, `get_device_inventory`, `get_config_managed_devices`, `get_clients`, `get_client_onboarding_score`...), each with its description.

Use **Allow all** to enable every tool at once, or enable them selectively via the individual toggles. The **Test your agent** panel on the right lets you validate behavior immediately.

![MCP tools detail and agent testing](img/11-Agent-publish.png)

### 6. Publish the agent

Once the tools are validated, click **Publish** (top right). Copilot Studio displays any warnings before publishing (e.g. DLP restrictions on certain channels depending on tenant policies).

![Publish window](img/12-Publish-this-Agent.png)

Keep/check **Force newest version** if the agent should push its latest version to ongoing Teams conversations, then **Publish**.

### 7. Configure channels

**Channels** tab. With Microsoft authentication, only Microsoft channels (**Teams**, **Microsoft 365**, **SharePoint**) are available; other channels (WhatsApp, Slack, Telegram, etc.) require alternative authentication.

![Available channels view](img/13-Channel-configuration.png)

Click **Microsoft 365 and Microsoft Teams**.

![Adding the Teams/M365 channel](img/14-Channel-Add.png)

Check **Make agent available in Microsoft 365 Copilot**, review the agent preview (name, icon), then **Add channel**.

### 8. Customize the agent for Teams/M365

Fill in:
- **Name** (display name, e.g. `Aruba Network Assistant`)
- **Icon** (PNG, transparent background, < 100 KB)
- **Short description** / **Long description**
- **Teams settings**: *Users can add this agent to a team*, *Use this agent for group and meeting chats*, etc.

![Teams channel customization](img/15-Channel-personnalization.png)

**Save**.

### 9. Share the agent with users

From the sharing menu, **Share "..." in Teams**: add users (or groups) via **New Users**, or pick from **Existing users**.

![Adding users](img/17-Share-Agent-add-user.png)

For each selected user, set the permission level:

| Role | Rights |
|---|---|
| **End user access** | Chat with the agent, manage their own connections |
| **Analytics viewer** | View analytics only |
| **Editor access** | View, edit, configure, share and publish (no delete) |

![Per-user permissions](img/18-Share-Agent-permission-user.png)

**Share** to confirm.

### 10. Get the link or the Teams package

Two distribution options:
- **Copy link**: direct link to open the agent in Teams (for already-shared users)
- **Download .zip**: package for submission to the Teams / Microsoft 365 store (visibility as *Built with Power Platform* or *Built by your org* after admin approval)

![Share link and Teams package](img/19-Share-Copy-Link.png)

### 11. Test in Teams

The agent can be used directly in Teams like a regular chat contact/app. Responses are flagged **AI generated**.

![Testing the agent in Teams](img/20-Test-Agent-Teams.png)

---

## Things to watch

- **MCP server description**: this is the only signal the LLM has to decide when to call the MCP tool rather than another source — write it with as much care as a classic system prompt.
- **Allow all vs. selective activation**: on an MCP server exposing many tools, selectively enabling only the relevant ones reduces context noise and limits tool-call hallucinations.
- **DLP / channels**: depending on tenant policy, some channels beyond Teams/M365/SharePoint may be blocked by data-loss-prevention policies — shown as a warning at **Publish** time.
- **Microsoft authentication**: determines which channels are available. Switch to an alternative auth method if non-Microsoft channels (Slack, WhatsApp...) are needed.
- **Read-only on the MCP side**: the server documented here is intentionally read-only — no remediation/config action is exposed to the agent, monitoring only.

---

## See also

- Internal `central` skill — exposed Aruba Central REST/MCP endpoints (Classic + New Central API)
- [Model Context Protocol documentation](https://modelcontextprotocol.io)
