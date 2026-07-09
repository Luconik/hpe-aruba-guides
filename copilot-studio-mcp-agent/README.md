# Aruba Central Monitoring — Agent Copilot Studio via MCP

Guide de création d'un agent Microsoft Copilot Studio connecté à Aruba Central via un serveur **MCP (Model Context Protocol)**, publié en interne sur Microsoft Teams / Microsoft 365 Copilot.

L'agent obtenu (« Aruba Network Assistant ») répond en langage naturel sur l'état du réseau Aruba Central : équipements, alertes, sites, clients, topologie — en lecture seule.

---

## Contexte

Microsoft Copilot Studio supporte nativement les serveurs MCP comme type d'outil (« Tool »). Cela permet de brancher un agent conversationnel Copilot directement sur un serveur MCP existant (ici, un serveur MCP maison exposant l'API Aruba Central en lecture seule — cf. skill `central`), sans développer de connecteur Power Platform custom.

Résultat : un agent utilisable dans Teams par toute l'équipe, capable d'interroger Aruba Central en direct (devices, clients, alertes, onboarding, topologie...).

---

## Prérequis

- Accès à [Copilot Studio](https://copilotstudio.microsoft.com) sur le tenant HPE
- Un serveur MCP Aruba Central déjà déployé et accessible en HTTPS (URL publique ou exposée via tunnel), en **lecture seule** — voir skill `central` pour le détail des endpoints
- Droits de publication d'agent + de partage Teams sur l'environnement Power Platform concerné

---

## Étapes

### 1. Créer l'agent

Dans Copilot Studio → **Home** → **Agent** → décrire l'agent ou partir d'un agent vide.

![Accueil Copilot Studio](img/1-Accueil-CopilotStudio.png)

Nommer l'agent (ex. `Aruba mcp agent`) puis **Create**.

![Nommer l'agent](img/2-Name-Agent.png)

### 2. Choisir le modèle

Dans **Overview**, sélectionner le modèle sous **Select your agent's model**. Claude Sonnet 4.6 est disponible dans la section *Anthropic models*.

![Choix du modèle](img/3-Choix-Models.png)

> Modèles disponibles au moment du test : GPT-5 (Chat/Auto/Reasoning/5.3/5.5), GPT-4.1, Claude (Sonnet 4.6, Opus 4.6/4.7/4.8). Grok et Mistral étaient désactivés par la politique tenant HPE.

### 3. Ajouter le serveur MCP comme outil

Onglet **Tools** → **Add a tool**.

![Créer le premier outil](img/4-Add-Tool.png)

Dans la fenêtre **Add tool**, choisir **Model Context Protocol** (à côté de *Agent flow*, *Prompt*, *Computer use*).

![Sélection Model Context Protocol](img/5-Add-Tool-mcp.png)

Renseigner :
- **Server name** : nom explicite (ex. `Aruba Central Monitoring MCP`)
- **Server description** : description fonctionnelle claire — elle sert de contexte au LLM pour savoir quand invoquer l'outil (ex. *« Aruba Central read-only MCP server for live monitoring: devices, APs, switches, gateways, clients, sites, alerts and topology »*)
- **Server URL** : URL HTTPS du serveur MCP
- **Authentication** : `None` / `API key` / `OAuth 2.0` selon la configuration du serveur

![Configuration du serveur MCP](img/6-Create-mcp-configuration.png)

### 4. Créer la connexion

Après **Create**, Copilot Studio demande une connexion associée au serveur MCP (**Not connected** par défaut).

![Pas de connexion](img/7-mcp-Not-Connected.png)

Cliquer sur **Create new connection** → une fenêtre de connexion s'affiche avec le nom et la description du serveur.

![Nouvelle connexion](img/8-mcp-New-Connection.png)

**Create** pour valider.

![Création de la connexion](img/9-mcp-Create.png)

La connexion passe au statut connecté (icône verte).

![Connexion établie](img/10-mcp-Connection-ok.png)

**Add and configure** pour finaliser l'ajout de l'outil à l'agent.

### 5. Activer les tools MCP exposés

L'outil MCP ajouté liste automatiquement toutes les fonctions exposées par le serveur (ex. `get_devices`, `get_device_inventory`, `get_config_managed_devices`, `get_clients`, `get_client_onboarding_score`...), chacune avec sa description.

Utiliser **Allow all** pour activer tous les tools d'un coup, ou activer sélectivement via les toggles individuels. Le panneau **Test your agent** à droite permet de valider immédiatement le comportement.

![Détail des tools MCP et test de l'agent](img/11-Agent-publish.png)

### 6. Publier l'agent

Une fois les tools validés, cliquer sur **Publish** (en haut à droite). Copilot Studio affiche les éventuels warnings avant publication (ex. restrictions DLP sur certains channels selon les politiques du tenant).

![Fenêtre de publication](img/12-Publish-this-Agent.png)

Cocher/laisser **Force newest version** si l'agent doit pousser la dernière version aux conversations Teams en cours, puis **Publish**.

### 7. Configurer les channels

Onglet **Channels**. Avec l'authentification Microsoft, seuls les channels Microsoft (**Teams**, **Microsoft 365**, **SharePoint**) sont disponibles ; les autres (WhatsApp, Slack, Telegram, etc.) nécessitent une authentification alternative.

![Vue des channels disponibles](img/13-Channel-configuration.png)

Cliquer sur **Microsoft 365 and Microsoft Teams**.

![Ajout du channel Teams/M365](img/14-Channel-Add.png)

Cocher **Make agent available in Microsoft 365 Copilot**, vérifier l'aperçu de l'agent (nom, icône), puis **Add channel**.

### 8. Personnaliser l'agent pour Teams/M365

Renseigner :
- **Name** (nom affiché, ex. `Aruba Network Assistant`)
- **Icon** (PNG, fond transparent, < 100 Ko)
- **Short description** / **Long description**
- **Teams settings** : *Users can add this agent to a team*, *Use this agent for group and meeting chats*, etc.

![Personnalisation du channel Teams](img/15-Channel-personnalization.png)

**Save**.

### 9. Partager l'agent avec les utilisateurs

Depuis le menu de partage, **Share "..." in Teams** : ajouter les utilisateurs (ou groupes) via **New Users**, ou sélectionner parmi les **Existing users**.

![Ajout d'utilisateurs](img/17-Share-Agent-add-user.png)

Pour chaque utilisateur sélectionné, définir le niveau de permission :

| Rôle | Droits |
|---|---|
| **End user access** | Chat avec l'agent, gestion de ses propres connexions |
| **Analytics viewer** | Consultation des analytics uniquement |
| **Editor access** | Vue, édition, configuration, partage et publication (pas de suppression) |

![Permissions par utilisateur](img/18-Share-Agent-permission-user.png)

**Share** pour valider.

### 10. Récupérer le lien ou le package Teams

Deux options pour la diffusion :
- **Copy link** : lien direct pour ouvrir l'agent dans Teams (utilisateurs déjà partagés)
- **Download .zip** : package pour soumission au store Teams / Microsoft 365 (visibilité *Built with Power Platform* ou *Built by your org* après validation admin)

![Lien de partage et package Teams](img/19-Share-Copy-Link.png)

### 11. Test dans Teams

L'agent est utilisable directement dans Teams comme un contact / app de chat classique. Les réponses sont marquées **AI generated**.

![Test de l'agent dans Teams](img/20-Test-Agent-Teams.png)

---

## Points d'attention

- **Description du serveur MCP** : c'est le seul signal dont dispose le LLM pour décider quand appeler l'outil MCP plutôt qu'une autre source — la rédiger avec autant de soin que les prompts système d'un agent classique.
- **Allow all vs activation sélective** : sur un serveur MCP exposant beaucoup de tools, activer sélectivement seulement les tools pertinents réduit le bruit dans le contexte du modèle et limite les hallucinations d'appel.
- **DLP / channels** : selon les politiques du tenant, certains channels (au-delà de Teams/M365/SharePoint) peuvent être bloqués par les policies de prévention de perte de données — visible sous forme de warning au moment du **Publish**.
- **Authentification Microsoft** : conditionne les channels disponibles. Passer à une auth alternative si des channels non-Microsoft (Slack, WhatsApp...) sont nécessaires.
- **Lecture seule côté MCP** : le serveur documenté ici est volontairement read-only — aucune action de remédiation/config n'est exposée à l'agent, seulement du monitoring.

---

## Voir aussi

- Skill interne `central` — endpoints Aruba Central REST/MCP exposés (Classic + New Central API)
- [Model Context Protocol documentation](https://modelcontextprotocol.io)
