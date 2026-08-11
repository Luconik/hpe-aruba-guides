# Copilot Studio — agents HPE Aruba Networking

Cette section documente une famille d’agents Microsoft Copilot Studio conçus pour des usages Channel SE et presales HPE Aruba Networking.

Les exemples et captures sont documentés à partir d’un environnement de travail réel, avec les informations sensibles caviardées. Le nom de l’auteur est conservé pour attribuer le travail. Les données commerciales, clients, tenants, connexions et endpoints internes ne sont pas documentés ici.

## Agents

| Agent | Rôle | Architecture | Statut | Page |
|---|---|---|---|---|
| **Aruba Network Assistant** | Interroger Aruba Central en langage naturel | MCP Aruba Central, lecture seule | Documenté et démontré | [Voir la page](agents/05-aruba-network-assistant/README.md) |
| **HPE Networking Presales Advisor** | Rechercher et synthétiser la connaissance technique Networking | Knowledge / RAG documentaire | Documenté | [Voir la page](agents/02-presales-knowledge-advisor/README.md) |
| **Partner & Customer Reference Guide** | Orienter vers les bonnes ressources partenaires et clients | Knowledge documentaire | Documenté | [Voir la page](agents/03-partner-customer-reference-guide/README.md) |
| **HPE France Opportunity Finder** | Construire une vue factuelle des opportunités pour les SE | Outils CRM + référentiel de couverture | Documenté | [Voir la page](agents/01-opportunity-finder/README.md) |
| **Juniper Mist Assistant** | Évaluer une intégration MCP Juniper | MCP Juniper | Expérimental — non validé dans Copilot Studio | [Voir la page](agents/04-juniper-mist-assistant/README.md) |

## Ce que montre cette collection

- Plusieurs patterns d’architecture dans Copilot Studio : MCP, knowledge/RAG et outils métier.
- La différence entre un agent documentaire, un agent opérationnel et un agent connecté à des données live.
- La nécessité de documenter les sources, les droits, les limites et les garde-fous.
- Une approche de publication progressive : configuration, test, partage, démonstration puis revue.

## Captures

Les captures sont regroupées par agent dans [`captures/`](captures/). Les vues de configuration illustrent le parcours Copilot Studio ; les vues Teams montrent les réponses finales des agents.

## Documentation transversale

- [Inventaire des captures](docs/capture-inventory.md)
- [Politique d’anonymisation](docs/anonymization.md)
- [Checklist avant publication](docs/publishing-checklist.md)
- [Structure de travail](WORKING_STRUCTURE.md)

## Confidentialité et portée

Ce repository est une documentation technique et une démonstration. Il ne contient pas de secrets, de données client, de données commerciales réelles ni d’endpoint interne. Les exemples publics ne doivent pas être interprétés comme une description complète de la configuration d’un tenant.
