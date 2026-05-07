# Aruba Central NAC — Intégration Microsoft Intune (802.1X / SCEP)
# Aruba Central NAC — Microsoft Intune Integration (802.1X / SCEP)

> 🇫🇷 [Français](#fr) | 🇬🇧 [English](#en)

---

<a name="fr"></a>
## 🇫🇷 Français

### Objectif

Ce guide documente la configuration complète du **Network Access Control (NAC)** d'Aruba Central avec **Microsoft Intune** comme UEM (Unified Endpoint Management), permettant une authentification **802.1X EAP-TLS** par certificat SCEP pour les postes Windows gérés par Intune.

```
Endpoint Windows (Intune)
    │
    │ Certificat SCEP délivré par Central NAC
    ▼
Aruba AP (802.1X EAP-TLS)
    │
    │ Authentification RADIUS
    ▼
Aruba Central NAC
    │
    │ Vérification conformité via OAuth2
    ▼
Microsoft Intune (Entra ID)
    │
    ▼
Accès réseau accordé (rôle selon politique NAC)
```

### Prérequis

- Workspace **HPE GreenLake** actif avec **Aruba Central** déployé
- Tenant **Microsoft Entra ID** avec droits Global Admin
- Licence **Microsoft Intune** active
- Domaine DNS personnalisé vérifié dans Entra ID
- Points d'accès Aruba gérés dans Aruba Central

> 📎 Prérequis GreenLake : voir [`../greenlake-workspace/`](../greenlake-workspace/)  
> 📎 SSO GreenLake (optionnel) : voir [`../greenlake-sso/`](../greenlake-sso/)

---

### Architecture

| Composant | Rôle |
|-----------|------|
| **Aruba Central NAC** | Serveur RADIUS + moteur de politique NAC |
| **Microsoft Intune** | UEM — gestion des certificats et profils WiFi |
| **Microsoft Entra ID** | Annuaire identités + App Registration OAuth2 |
| **SCEP** | Protocole de distribution des certificats clients |
| **EAP-TLS** | Méthode d'authentification 802.1X par certificat |

---

## Partie 1 — Configuration Microsoft Entra ID

### 1.1 Ajouter et vérifier un domaine personnalisé

```
Entra ID → Domaines personnalisés → Ajouter un domaine personnalisé
```

![Entra - Ajouter un domaine](screenshots/01-entra-id-custom-domain-add.png)

GreenLake génère un enregistrement **TXT** de vérification à ajouter dans le DNS.

![Entra - Enregistrement TXT de vérification](screenshots/02-entra-id-custom-domain-txt-record.png)

Ajouter l'enregistrement TXT chez le registrar DNS.

![DNS - Enregistrements du registrar](screenshots/04-dns-registrar-records.png)

![DNS - Ajout enregistrement TXT](screenshots/05-dns-registrar-txt-record-add.png)

Retourner dans Entra ID et cliquer **Vérifier**.

![Entra - Domaine personnalisé dans le portail](screenshots/03-entra-id-custom-domain-portal.png)

![Entra - Vérification domaine](screenshots/06-entra-id-custom-domain-verify.png)

---

### 1.2 Vérifier les enregistrements DNS CNAME pour Intune

Les enregistrements CNAME sont requis pour l'enrôlement automatique des appareils dans Intune.

![Intune - Enregistrements DNS CNAME](screenshots/07-intune-dns-cname-records.png)

---

### 1.3 Créer une App Registration

```
Entra ID → Inscriptions d'applications → + Nouvelle inscription
```

![Entra - Nouvelle inscription d'application](screenshots/08-entra-id-app-registration-new.png)

Configurer l'URI de redirection.

![Entra - URI de redirection (inscription)](screenshots/09-entra-id-app-registration-redirect-uri.png)

---

### 1.4 Créer un Client Secret

```
Application → Certificats et secrets → + Nouveau secret client
```

![Entra - Nouveau secret client](screenshots/10-entra-id-client-secret-new.png)

> ⚠️ Copier la **valeur** du secret immédiatement — elle ne sera plus visible après fermeture.

![Entra - Valeur du secret client](screenshots/11-entra-id-client-secret-value.png)

![Entra - Vue d'ensemble secret client](screenshots/12-entra-id-client-secret-overview.png)

---

### 1.5 Ajouter les permissions API

```
Application → Autorisations API → + Ajouter une autorisation → Microsoft Graph → Intune
```

![Entra - Ajout permissions API](screenshots/13-entra-id-api-permissions-add.png)

Sélectionner les permissions **Microsoft Graph** requises pour Intune.

![Entra - Permissions Graph + Intune](screenshots/14-entra-id-api-permissions-graph-intune.png)

---

## Partie 2 — Configuration Aruba Central — Extension Intune

### 2.1 Installer l'extension Microsoft Intune

```
Aruba Central → Extensions → Available Extensions → Microsoft Intune → Install
```

![Central - Menu extensions](screenshots/15-aruba-central-intune-extension-menu.png)

![Central - Installation extension Intune](screenshots/16-aruba-central-intune-extension-install.png)

---

### 2.2 Configurer l'extension Intune

Renseigner les informations de l'App Registration créée à l'étape 1.3 :

- **Tenant ID** (depuis Entra ID)
- **Client ID** (ID d'application)
- **Client Secret** (valeur copiée à l'étape 1.4)

![Central - Configuration extension Intune](screenshots/17-aruba-central-intune-extension-config.png)

---

## Partie 3 — Configuration Aruba Central NAC

### 3.1 Configurer l'Identity Store OAuth (Intune)

```
Central NAC → Configuration → Identity Management → Identity Stores → Create
```

![Central NAC - Menu Identity Management](screenshots/19-aruba-central-nac-identity-management-menu.png)

![Central NAC - Créer Identity Store](screenshots/20-aruba-central-nac-identity-store-create.png)

![Central NAC - Définir le nom de l'Identity Store](screenshots/21-aruba-central-nac-identity-store-define-name.png)

Configurer l'URI de redirection OAuth dans l'application Entra ID.

![Entra - App entreprise URI redirection](screenshots/22-entra-id-enterprise-app-redirect-uri.png)

![Entra - Ajout URI redirection](screenshots/23-entra-id-redirect-uri-add.png)

![Entra - URI redirection configurée](screenshots/24-entra-id-redirect-uri-configured.png)

![Entra - URI redirection confirmée](screenshots/25-entra-id-redirect-uri-confirmed.png)

Finaliser la configuration OAuth dans Central NAC et valider le token.

![Central NAC - OAuth Token validé](screenshots/18-aruba-central-nac-identity-store-oauth-token.png)

---

### 3.2 Créer les rôles NAC

```
Central NAC → Configuration → Roles → Create Role
```

![Central NAC - Créer un rôle](screenshots/26-aruba-central-nac-roles-create.png)

![Central NAC - Liste des rôles](screenshots/27-aruba-central-nac-roles-list.png)

Définir le scope du rôle (accès réseau accordé).

![Central NAC - Scope du rôle](screenshots/28-aruba-central-nac-roles-scope.png)

---

### 3.3 Configurer la politique globale NAC

```
Central NAC → Configuration → Policies → Global Policy
```

![Central NAC - Politique globale](screenshots/29-aruba-central-nac-global-policy.png)

Configurer les règles de la politique.

![Central NAC - Règles de politique](screenshots/30-aruba-central-nac-policy-rules.png)

![Central NAC - Rôles et règles de politique](screenshots/31-aruba-central-nac-policy-roles-rules.png)

---

### 3.4 Créer le profil SSID 802.1X

```
Aruba Central → Configuration → WLANs → Create SSID
```

![Central - Créer profil SSID](screenshots/32-aruba-central-ssid-profile-create.png)

Configurer le SSID en mode **WPA3-Enterprise / 802.1X**.

![Central - Configuration profil SSID](screenshots/33-aruba-central-ssid-profile-config.png)

Définir le scope des appareils (Device Scope).

![Central - Device Scope SSID](screenshots/34-aruba-central-ssid-profile-device-scope.png)

---

### 3.5 Créer la politique d'autorisation NAC

```
Central NAC → Configuration → Authorization Policies → Create
```

![Central NAC - Créer politique autorisation](screenshots/35-aruba-central-nac-authorization-policy-create.png)

![Central NAC - Config politique autorisation (1)](screenshots/36-aruba-central-nac-authorization-policy-config1.png)

![Central NAC - Config politique autorisation (2)](screenshots/37-aruba-central-nac-authorization-policy-config2.png)

---

### 3.6 Créer le profil d'authentification EAP-TLS

```
Central NAC → Configuration → Authentication Profiles → Create Profile
```

![Central NAC - Créer profil auth](screenshots/38-aruba-central-nac-auth-profile-create.png)

Configurer le profil avec **EAP-TLS** et l'Identity Store Intune.

![Central NAC - Config profil auth (1)](screenshots/39-aruba-central-nac-auth-profile-config1.png)

![Central NAC - Config profil auth (2)](screenshots/40-aruba-central-nac-auth-profile-config2.png)

![Central NAC - Config profil auth (3)](screenshots/41-aruba-central-nac-auth-profile-config3.png)

---

### 3.7 Vérifier la connexion UEM Intune

La connexion Intune doit afficher le statut **vert** dans Central NAC.

![Central NAC - UEM Intune connecté (vert)](screenshots/42-aruba-central-nac-uem-intune-green.png)

---

### 3.8 Récupérer l'URL SCEP et le certificat CA

```
Central NAC → Configuration → SCEP
```

![Central NAC - URL SCEP](screenshots/43-aruba-central-nac-scep-url.png)

Télécharger le certificat CA racine (nécessaire pour le profil Trusted Certificate dans Intune).

![Central NAC - Téléchargement certificat SCEP](screenshots/44-aruba-central-nac-scep-certificate-download.png)

---

## Partie 4 — Configuration Microsoft Intune

### 4.1 Créer le profil Trusted Certificate

```
Intune → Appareils → Configuration → + Créer un profil → Trusted Certificate
```

![Intune - Créer profil Trusted Certificate](screenshots/45-intune-trusted-certificate-create.png)

![Intune - Nom du profil](screenshots/46-intune-trusted-certificate-name.png)

Importer le certificat CA téléchargé à l'étape 3.8.

![Intune - Import certificat CA](screenshots/47-intune-trusted-certificate-import.png)

Assigner le profil aux utilisateurs et appareils cibles.

![Intune - Assigner aux utilisateurs/appareils](screenshots/48-intune-trusted-certificate-assign-users-devices.png)

![Intune - Vérification et création](screenshots/49-intune-trusted-certificate-review-create.png)

---

### 4.2 Créer le profil SCEP Certificate

```
Intune → Appareils → Configuration → + Créer un profil → SCEP Certificate
```

![Intune - Créer profil SCEP](screenshots/50-intune-scep-certificate-profile-create.png)

![Intune - Config SCEP (1)](screenshots/51-intune-scep-certificate-config1.png)

![Intune - Config SCEP (2)](screenshots/52-intune-scep-certificate-config2.png)

![Intune - Config SCEP (3)](screenshots/53-intune-scep-certificate-config3.png)

Renseigner l'**URL SCEP** récupérée à l'étape 3.8.

![Intune - URL SCEP](screenshots/54-intune-scep-certificate-scep-url.png)

![Intune - Détail URL SCEP](screenshots/55-intune-scep-certificate-scep-url-detail.png)

---

### 4.3 Créer le profil WiFi Windows

```
Intune → Appareils → Configuration → + Créer un profil → Wi-Fi (Windows 10 et versions ultérieures)
```

![Intune - Créer profil WiFi Windows](screenshots/56-intune-wifi-profile-windows-create.png)

Configurer le SSID, le type de sécurité (**WPA2-Enterprise**) et la méthode EAP (**EAP-TLS**).

![Intune - Config WiFi (1)](screenshots/57-intune-wifi-profile-windows-config1.png)

![Intune - Config WiFi (2)](screenshots/58-intune-wifi-profile-windows-config2.png)

![Intune - Config WiFi (3)](screenshots/59-intune-wifi-profile-windows-config3.png)

![Intune - Config WiFi (4)](screenshots/60-intune-wifi-profile-windows-config4.png)

![Intune - Config WiFi (5)](screenshots/61-intune-wifi-profile-windows-config5.png)

![Intune - Config WiFi (6)](screenshots/62-intune-wifi-profile-windows-config6.png)

---

## Partie 5 — Tests et validation

### 5.1 Vérifier les certificats sur le poste Windows

Ouvrir **certmgr.msc** sur un poste Windows géré par Intune :

![Test - Certificat racine utilisateur (certmgr)](screenshots/63-test-certmgr-root-user-certificate.png)

Vérifier la présence du certificat client SCEP.

![Test - Détail certificat (1)](screenshots/64-test-certmgr-certificates-detail1.png)

![Test - Détail certificat (2)](screenshots/65-test-certmgr-certificates-detail2.png)

---

### 5.2 Connexion WiFi sur le poste Windows

Le SSID 802.1X doit apparaître dans les réseaux WiFi connus.

![Test - SSID dans les réseaux connus](screenshots/66-test-windows-wifi-ssid-known-networks.png)

La connexion s'établit automatiquement via le certificat EAP-TLS.

![Test - Connexion WiFi avec certificat](screenshots/67-test-windows-wifi-connect-certificate.png)

---

### 5.3 Vérification dans Aruba Central NAC

Depuis **Central NAC → Monitoring → Clients**, vérifier les clients authentifiés.

![Central NAC - Monitoring clients](screenshots/68-test-aruba-central-nac-monitoring-clients.png)

![Central NAC - Liste clients authentifiés](screenshots/69-test-aruba-central-nac-monitoring-clients-list.png)

Consulter le détail d'un client pour confirmer le rôle NAC attribué.

![Central NAC - Détail client](screenshots/70-test-aruba-central-nac-client-detail.png)

---

## Références

- 📘 **TechNote officielle HPE TechDocs** : [Aruba Central NAC — UEM Onboarding with Intune](https://arubanetworking.hpe.com/techdocs/NAC/central-nac/central-nac-uem-onboarding-intune/)
- [Aruba Central Documentation](https://www.arubanetworks.com/techdocs/central/latest/content/)
- [Microsoft Intune — SCEP Certificate Profiles](https://learn.microsoft.com/en-us/mem/intune/protect/certificates-scep-configure)
- [Microsoft Entra ID — App Registration](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app)
- [`../greenlake-workspace/`](../greenlake-workspace/) — Prérequis GreenLake
- [`../greenlake-sso/`](../greenlake-sso/) — SSO GreenLake + Entra ID

---
---

<a name="en"></a>
## 🇬🇧 English

### Purpose

This guide documents the full configuration of **Aruba Central NAC** integrated with **Microsoft Intune** as UEM, enabling **802.1X EAP-TLS** certificate-based authentication for Windows endpoints managed by Intune.

---

### Prerequisites

- Active **HPE GreenLake** workspace with **Aruba Central** deployed
- **Microsoft Entra ID** tenant with Global Admin rights
- Active **Microsoft Intune** license
- Custom DNS domain verified in Entra ID
- Aruba APs managed in Aruba Central

> 📎 GreenLake prerequisites: see [`../greenlake-workspace/`](../greenlake-workspace/)

---

### Architecture

| Component | Role |
|-----------|------|
| **Aruba Central NAC** | RADIUS server + NAC policy engine |
| **Microsoft Intune** | UEM — certificate and WiFi profile management |
| **Microsoft Entra ID** | Identity directory + OAuth2 App Registration |
| **SCEP** | Client certificate distribution protocol |
| **EAP-TLS** | 802.1X certificate-based authentication method |

---

## Part 1 — Microsoft Entra ID

### 1.1 Add and verify a custom domain

Add a TXT verification record to DNS, then verify in Entra ID.

Screenshots: `01` → `06` (see FR section above).

### 1.2 Verify Intune CNAME DNS records

Required for automatic device enrollment in Intune.

Screenshot: `07`.

### 1.3 Create an App Registration

`Entra ID → App registrations → + New registration`

Configure the redirect URI. Screenshots: `08` → `09`.

### 1.4 Create a Client Secret

`Application → Certificates & secrets → + New client secret`

> ⚠️ Copy the **value** immediately — it won't be shown again.

Screenshots: `10` → `12`.

### 1.5 Add API permissions

`Application → API permissions → + Add permission → Microsoft Graph → Intune`

Screenshots: `13` → `14`.

---

## Part 2 — Aruba Central — Intune Extension

### 2.1 Install the Microsoft Intune extension

`Aruba Central → Extensions → Available Extensions → Microsoft Intune → Install`

Screenshots: `15` → `16`.

### 2.2 Configure the Intune extension

Enter the App Registration credentials (Tenant ID, Client ID, Client Secret).

Screenshot: `17`.

---

## Part 3 — Aruba Central NAC

### 3.1 Configure OAuth Identity Store (Intune)

`Central NAC → Configuration → Identity Management → Identity Stores → Create`

Configure the OAuth redirect URI in the Entra ID enterprise app, validate the OAuth token.

Screenshots: `18` → `25`.

### 3.2 Create NAC roles

`Central NAC → Configuration → Roles → Create Role`

Screenshots: `26` → `28`.

### 3.3 Configure global NAC policy

`Central NAC → Configuration → Policies → Global Policy`

Screenshots: `29` → `31`.

### 3.4 Create 802.1X SSID profile

`Aruba Central → Configuration → WLANs → Create SSID`

Configure SSID with **WPA3-Enterprise / 802.1X**.

Screenshots: `32` → `34`.

### 3.5 Create authorization policy

`Central NAC → Configuration → Authorization Policies → Create`

Screenshots: `35` → `37`.

### 3.6 Create EAP-TLS authentication profile

`Central NAC → Configuration → Authentication Profiles → Create Profile`

Configure with **EAP-TLS** and the Intune Identity Store.

Screenshots: `38` → `41`.

### 3.7 Verify Intune UEM connection

The Intune connection must show **green** status in Central NAC.

Screenshot: `42`.

### 3.8 Retrieve SCEP URL and CA certificate

`Central NAC → Configuration → SCEP`

Download the root CA certificate (required for the Trusted Certificate profile in Intune).

Screenshots: `43` → `44`.

---

## Part 4 — Microsoft Intune

### 4.1 Create Trusted Certificate profile

`Intune → Devices → Configuration → + Create profile → Trusted Certificate`

Import the CA certificate downloaded in step 3.8. Assign to target users/devices.

Screenshots: `45` → `49`.

### 4.2 Create SCEP Certificate profile

`Intune → Devices → Configuration → + Create profile → SCEP Certificate`

Enter the SCEP URL from step 3.8.

Screenshots: `50` → `55`.

### 4.3 Create Windows WiFi profile

`Intune → Devices → Configuration → + Create profile → Wi-Fi (Windows 10 and later)`

Configure SSID, security type (**WPA2-Enterprise**), EAP method (**EAP-TLS**).

Screenshots: `56` → `62`.

---

## Part 5 — Testing and validation

### 5.1 Verify certificates on Windows endpoint

Open **certmgr.msc** — verify SCEP client certificate presence.

Screenshots: `63` → `65`.

### 5.2 WiFi connection on Windows

The 802.1X SSID should appear in known networks and connect automatically via EAP-TLS certificate.

Screenshots: `66` → `67`.

### 5.3 Verify in Aruba Central NAC

`Central NAC → Monitoring → Clients` — verify authenticated clients and assigned NAC role.

Screenshots: `68` → `70`.

---

## References

- 📘 **Official HPE TechDocs**: [Aruba Central NAC — UEM Onboarding with Intune](https://arubanetworking.hpe.com/techdocs/NAC/central-nac/central-nac-uem-onboarding-intune/)
- [Aruba Central Documentation](https://www.arubanetworks.com/techdocs/central/latest/content/)
- [Microsoft Intune — SCEP Certificate Profiles](https://learn.microsoft.com/en-us/mem/intune/protect/certificates-scep-configure)
- [`../greenlake-workspace/`](../greenlake-workspace/) — GreenLake prerequisites
- [`../greenlake-sso/`](../greenlake-sso/) — GreenLake SSO + Entra ID

---

## File structure / Structure des fichiers

```
central-nac-intune/
├── README.md                           ← Index général / General index
├── windows/
│   ├── README.md                       ← Ce fichier / This file
│   └── screenshots/
│       ├── 00-aruba-central-nac-banner.png
│       ├── 01-entra-id-custom-domain-add.png
│       ├── ...
│       └── 70-test-aruba-central-nac-client-detail.png
├── macos/
│   ├── README.md                       ← Guide macOS (EN)
│   ├── README-fr.md                    ← Guide macOS (FR)
│   └── screenshots/                    ← Captures 71 → 130
│       └── fr/                         ← Captures FR
└── ios/
    ├── README.md                       ← Guide iOS (EN) — à venir
    ├── README-fr.md                    ← Guide iOS (FR) — à venir
    └── screenshots/                    ← À venir
```

---

*Last updated: March 2026 — [@Luconik](https://github.com/Luconik)*
