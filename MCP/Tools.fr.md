# Configuration MCP — HPE Aruba Central & Juniper Mist sur Claude Desktop

🇫🇷 Version française — [🇬🇧 English version](./Tools.en.md)

> ℹ️ **Note d'attribution** : ce document ne présente pas une création originale, mais une reprise et documentation personnelle de deux outils existants — la plateforme HPE Networking MCP Server de Jibran Aziz (HPE) et le serveur MCP officiel Juniper Mist. Il compile mes notes de mise en œuvre et de troubleshooting côté client ; tout le crédit du travail sous-jacent revient à leurs auteurs respectifs (voir section Crédits et Sources ci-dessous).

Documentation de la mise en place de deux serveurs MCP (Model Context Protocol) sur Claude Desktop macOS, permettant d'interroger en langage naturel un tenant Aruba Central (démo, multi-plateformes) et une organisation Juniper Mist (homelab) directement depuis Claude.

## Crédits

La partie **HPE Networking MCP Server** (`mcp.arubademo.online`) repose entièrement sur la plateforme développée par **Jibran Aziz** (HPE) — une intégration IA hébergée publiquement, sans installation backend, connectant Aruba Central Classic/New, ClearPass, EdgeConnect Orchestrator et HPE GreenLake à Claude. Toute la logique serveur, l'authentification OAuth2/API Key et les 143 outils exposés sont son travail ; ce document ne fait que documenter ma propre mise en œuvre côté client (Claude Desktop) à partir de son guide utilisateur.

- Portail : https://mcp.arubademo.online/dashboard
- Contact pour accès démo ClearPass : jibran.aziz@hpe.com

La partie **Juniper Mist** repose sur le serveur MCP officiel Juniper (beta), documenté séparément — voir section 2 et sources en bas de page.

## Architecture

```
Claude Desktop (client MCP, stdio)
        │
        ├── HPE Networking MCP Server ──► mcp.arubademo.online (SSE) ──► Aruba Central / ClearPass / EdgeConnect / GreenLake
        │                                   (plateforme Jibran Aziz, HPE)
        │
        └── Juniper Mist ──────────────► mcp.ai.juniper.net/mcp/mist (Streamable HTTP) ──► Mist Cloud API (api.eu.mist.com)
```

---

## 1. HPE Networking MCP Server (plateforme de Jibran Aziz)

### Ce que couvre la plateforme

6 plateformes connectées, 143 outils au total, tous en lecture seule sauf quelques exceptions explicitement marquées ✏️ (ex. `upgrade_firmware`, `cppm_disconnect_session`, `move_device_to_group`) :

| Plateforme | Outils | Authentification |
|---|---|---|
| Aruba Classic Central | 57 | OAuth2 refresh_token |
| Aruba New Central | 30 | OAuth2 client_credentials |
| ClearPass (CPPM) | 19 | OAuth2 client_credentials |
| EdgeConnect Orchestrator | 29 | API Key (X-Auth-Token) |
| HPE GreenLake | 4 | SSO via New Central |
| Network Summary / IA | 4 | Via New Central |

Couverture fonctionnelle : sites & santé, devices/APs, clients, switches, gateways, alertes & événements, firmware, sécurité/WIDS, insights IA, configuration, audit, sessions ClearPass/RADIUS, endpoints & profiling NAC, comptes invités, tunnels/overlays SD-WAN, routage BGP/OSPF, licences. Liste complète des 143 outils dans le guide utilisateur officiel (PDF fourni par Jibran Aziz) ou directement dans l'onglet **Capabilities** du dashboard.

### Étapes de mise en route (~10 min, d'après le guide officiel)

1. **Créer un compte** sur https://mcp.arubademo.online/sign-up (email + mot de passe + code de vérification à 6 chiffres)
2. **Connecter Aruba Central** : onglet *Aruba Central* → choisir *Classic Central* → sélectionner l'URL de base de sa région → renseigner Client ID / Client Secret (Account Home → API Gateway → My Apps & Tokens) et Credential ID / Refresh Token (bouton *Download Token* sur la ligne du token, puis ouvrir le JSON)
   > ⚠️ Générer un token frais juste avant de se connecter — il expire en 2h. Une fois connecté, le serveur le rafraîchit automatiquement toutes les 30 min.
3. **Connecter ClearPass** *(optionnel)* : hostname seul (sans `https://`) + Client ID/Secret (ClearPass → Administration → API Services → API Clients). Le CPPM doit être joignable publiquement sur le port 443 depuis `mcp.arubademo.online`, sinon whitelister son IP publique.
4. **Connecter EdgeConnect** *(optionnel)* : hostname/IP de l'Orchestrator (port 443 joignable) + API Key en lecture seule minimum (Orchestrator → Admin → API → API Keys)
5. **Générer sa clé API** : onglet *API Keys*, label, *Generate API Key* — copiée immédiatement, non récupérable ensuite
6. **Configurer Claude Desktop** — voir ci-dessous

### Configuration `claude_desktop_config.json` (macOS/Linux, package `mcp-proxy`)

D'après le guide officiel, l'installation recommandée passe par `npm install -g mcp-proxy` puis :

```json
{
  "mcpServers": {
    "HPE Networking MCP Server": {
      "command": "mcp-proxy",
      "args": [
        "-H", "X-API-Key", "amcp_VOTRE_CLE",
        "https://mcp.arubademo.online/sse"
      ]
    }
  }
}
```

### Ce que j'ai rencontré en pratique (retour d'expérience)

- Avec le binaire `mcp-proxy` installé via **Homebrew** (plutôt que `npm`), la syntaxe `-H KEY VALUE` en deux tokens séparés a provoqué une erreur `spawn amcp_... ENOENT` — le process tentait de spawn la clé API elle-même comme commande.
- Contournement retenu : basculer sur `npx mcp-remote` avec la syntaxe `--header "Key:Value"` en une seule chaîne, qui a fonctionné de façon fiable :
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
        "env": { "API_KEY": "amcp_VOTRE_CLE" }
      }
    }
  }
  ```
  → Si le package officiel `mcp-proxy` (npm ou pip selon l'OS) fonctionne directement chez vous, préférez la méthode du guide officiel ci-dessus ; `mcp-remote` reste une alternative de secours validée dans mon cas.
- Le fichier de config doit contenir **un seul objet `mcpServers`** — erreur fréquente : refermer l'objet trop tôt et placer un second serveur au niveau racine du JSON, où Claude Desktop ne le voit pas. Toujours valider avec :
  ```bash
  python3 -m json.tool ~/Library/Application\ Support/Claude/claude_desktop_config.json
  ```

### Test

Redémarrer complètement Claude Desktop (Cmd+Q puis relance), puis demander :
> *"How many clients are connected to my network right now?"*

---

## 2. Juniper Mist (serveur MCP officiel Juniper, beta)

Source officielle : [Using the Juniper Mist MCP Server with Claude Desktop (Beta) — Juniper Networks](https://www.juniper.net/documentation/us/en/software/mist/mist-aiops/shared-content/topics/concept/juniper-mist-mcp-claude.html)

Cette partie est indépendante de la plateforme de Jibran Aziz (qui affiche d'ailleurs Mist comme "🔜 Coming Soon" dans son offre) : il s'agit du serveur MCP publié directement par Juniper.

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
      "env": { "MIST_TOKEN": "VOTRE_TOKEN_MIST" }
    }
  }
}
```

### Problèmes rencontrés et résolus

1. **`HTTP 401`** avec `api.mist.com` (shard US par défaut) → Mist Cloud est réparti en shards régionaux (`api.mist.com` US, `api.eu.mist.com` EU...) ; un token n'est valide que sur son shard d'origine. Diagnostic rapide en direct :
   ```bash
   curl -s -H "Authorization: Token VOTRE_TOKEN" https://api.eu.mist.com/api/v1/self
   ```
2. **`authentication required: missing authorization`** avec le schéma `Token` → le serveur MCP Juniper attend spécifiquement `Bearer` dans le header `Authorization`, puis reformate en interne vers l'API Mist. Résolu avec `Authorization:Bearer <token>` + `X-Mist-Base-URL:https://api.eu.mist.com`.

---

## Sécurité

- Tokens jamais en clair dans `args` — passés par variables d'environnement (`env`, référencées en `${VAR}`)
- `chmod 600 ~/Library/Application\ Support/Claude/claude_desktop_config.json`
- `mcp.arubademo.online` est un service tiers hébergé publiquement qui détient les credentials Aruba Central/ClearPass/EdgeConnect côté serveur externe — adapté à un usage démo/lab ; à valider auprès de la politique sécurité interne pour tout usage sur du Central de production
- Le MCP Mist donne accès à des données potentiellement sensibles (PSK, secrets RADIUS, credentials SNMP selon les ressources interrogées)

## Sources

- **HPE Networking MCP Server — User Guide** (PDF), plateforme et documentation par **Jibran Aziz** (HPE) — https://mcp.arubademo.online/dashboard
- [Using the Juniper Mist MCP Server with Claude Desktop (Beta) — Juniper Networks](https://www.juniper.net/documentation/us/en/software/mist/mist-aiops/shared-content/topics/concept/juniper-mist-mcp-claude.html)
- [sparfenyuk/mcp-proxy — GitHub](https://github.com/sparfenyuk/mcp-proxy)
- [tmunzer/mistmcp — GitHub](https://github.com/tmunzer/mistmcp) (alternative self-hosted, non utilisée dans cette configuration finale)
