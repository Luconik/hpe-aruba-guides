# Agents Copilot Studio — HPE Aruba Networking

Cette section documente une famille d’agents Microsoft Copilot Studio conçus pour des usages Channel SE et presales HPE Aruba Networking.

Les captures sont caviardées. Le nom de l’auteur est conservé pour attribuer le travail. Les exemples publics n’exposent ni secret, ni donnée client, ni tenant, ni connexion interne, ni endpoint privé.

## Agents documentés

| Agent | Rôle | Architecture | Statut |
|---|---|---|---|
| [Aruba Network Assistant](agents/05-aruba-network-assistant/README.md) | Interroger Aruba Central en langage naturel | MCP Aruba Central, lecture seule | Documenté et démontré |
| [HPE Networking Presales Advisor](agents/02-presales-knowledge-advisor/README.md) | Rechercher la connaissance technique Networking | Knowledge / RAG documentaire | Documenté |
| [Partner & Customer Reference Guide](agents/03-partner-customer-reference-guide/README.md) | Orienter vers les bonnes ressources partenaires et clients | Knowledge documentaire | Documenté |
| [HPE France Opportunity Finder](agents/01-opportunity-finder/README.md) | Construire une vue factuelle des opportunités pour les SE | Outils CRM + référentiel de couverture | Documenté |
| [Juniper Mist Assistant](agents/04-juniper-mist-assistant/README.md) | Évaluer une intégration MCP Juniper | MCP Juniper | Expérimental — non validé dans Copilot Studio |

## Ce que montre cette collection

- Plusieurs patterns d’architecture : MCP, knowledge/RAG et outils métier.
- La différence entre un agent documentaire, un agent opérationnel et un agent connecté à des données live.
- L’importance des sources, des droits, des limites et des garde-fous.
- Une démarche complète : configuration, test, publication, partage et démonstration.

## Captures

Les captures caviardées sont regroupées par agent dans [`captures/`](captures/).

## English

Read the [English version](README-EN.md).
