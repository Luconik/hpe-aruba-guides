# HPE France Opportunity Finder

The HPE France Opportunity Finder is a Copilot Studio agent designed to produce a fact-based opportunity view for Sales Engineers.

## Purpose

It combines a coverage reference and an opportunity system to present a readable dashboard: pipeline, open opportunities, relevant accounts and data-quality notes.

## Functional architecture

- SE coverage reference.
- Opportunity query tool.
- Validated ownership mapping before querying.
- Structured response with explicit errors and limitations.

## Guardrails

- No strategic recommendation by default.
- No invented amount, date or mapping.
- Missing or failed sources are reported.
- Public demonstrations use synthetic or approved data only.

## Demonstration

- [Teams response](../../captures/opportunity-finder/09-teams-demo.png)
- [Tools view](../../captures/opportunity-finder/03-tools-overview.png)
- [Publication configuration](../../captures/opportunity-finder/05-publication.png)

## More documentation

- [French page](README.md)
- [Agent captures](../../captures/opportunity-finder/)
