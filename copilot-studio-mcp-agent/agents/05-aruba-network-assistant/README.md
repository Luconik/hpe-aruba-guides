# Aruba Network Assistant — Copilot Studio via MCP

Guide de création et de documentation d’un agent Microsoft Copilot Studio connecté à Aruba Central via un serveur **MCP (Model Context Protocol)**.

L’agent répond en langage naturel sur l’état du réseau Aruba Central — équipements, alertes, sites, clients et topologie — en **lecture seule**.

## Vue d’ensemble

```text
Utilisateur Teams / Microsoft 365
              │
              ▼
     Aruba Network Assistant
        Microsoft Copilot Studio
              │
              ▼
       Outil Model Context Protocol
              │
              ▼
     Serveur MCP Aruba Central
          accès lecture seule
```

## Architecture

Copilot Studio supporte les serveurs MCP comme type d’outil. L’agent peut ainsi interroger un serveur MCP existant sans développer de connecteur Power Platform personnalisé.

Le serveur MCP expose des opérations de consultation contrôlées. La démonstration publique ne doit pas exposer de tenant, endpoint, site, équipement ou donnée d’infrastructure réelle.

## Parcours de configuration

1. Créer l’agent dans Copilot Studio.
2. Sélectionner le modèle souhaité.
3. Ajouter un outil **Model Context Protocol**.
4. Créer et vérifier la connexion MCP.
5. Activer uniquement les tools nécessaires.
6. Tester l’agent.
7. Publier l’agent.
8. Configurer les canaux Teams/Microsoft 365.
9. Partager l’agent avec les utilisateurs autorisés.
10. Tester le parcours final dans Teams.

## Principes de conception

- Exposer le minimum d’opérations nécessaire.
- Privilégier une intégration read-only pour les démonstrations.
- Activer les tools MCP de manière sélective.
- Décrire précisément chaque tool afin d’aider le modèle à choisir le bon appel.
- Rendre explicites la source et la fraîcheur des données.
- Ne jamais publier de données d’infrastructure réelles.

## Captures de configuration

- [Contexte Copilot Studio](../../captures/aruba-network-assistant/01-copilot-studio-context.png)
- [Vue générale de l’agent](../../captures/aruba-network-assistant/02-agent-overview.png)
- [Ajout d’un outil](../../captures/aruba-network-assistant/07-add-tool.png)
- [Configuration MCP](../../captures/aruba-network-assistant/08-mcp-configuration.png)
- [Publication et canaux](../../captures/aruba-network-assistant/09-publication-channels.png)
- [Partage](../../captures/aruba-network-assistant/11-sharing.png)

## Démonstrations

- [Vue Copilot App](../../captures/aruba-network-assistant/12-copilot-app-overview.png)
- [Test dans Teams](../../captures/aruba-network-assistant/13-teams-demo.png)

## Points d’attention

### Description du serveur MCP

La description fonctionnelle du serveur est un signal important pour aider le modèle à déterminer quand appeler l’outil. Elle doit préciser le périmètre, les données accessibles et le caractère read-only.

### Activation sélective

Un serveur MCP exposant de nombreux tools ne doit pas nécessairement tous les activer. Une sélection ciblée réduit le bruit de contexte et limite les appels inutiles.

### Authentification et canaux

L’authentification Microsoft peut conditionner les canaux disponibles. Les politiques DLP du tenant peuvent également produire des warnings au moment de la publication.

### Sécurité

Le serveur documenté ici est conçu en lecture seule : aucune action de remédiation ou de configuration n’est exposée à l’agent.

## Documentation complémentaire

- [Fiche publique](PUBLIC.md)
- [Fiche de travail](INTERNAL.md)
- [Captures de l’agent](../../captures/aruba-network-assistant/)
- [Guide de configuration MCP détaillé](configuration-guide.md)
- [Captures de configuration MCP](img/)
