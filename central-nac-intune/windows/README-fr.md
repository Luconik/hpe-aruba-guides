# Aruba Central NAC — EAP-TLS avec Microsoft Intune (Windows)

> 🇫🇷 Français | 🇬🇧 [English](README.md)

![Plateforme](https://img.shields.io/badge/plateforme-Windows%2010%2F11-lightgrey?logo=windows)
![Central NAC](https://img.shields.io/badge/HPE%20Aruba%20Central%20NAC-requis-FF6600?logo=hpe)
![Auth](https://img.shields.io/badge/auth-EAP--TLS%20%2F%20802.1X-green)
![Mise à jour](https://img.shields.io/badge/mis%20à%20jour-Mai%202026-orange)

---

## Table des matières

- [Présentation](#présentation)
- [Prérequis](#prérequis)
- [Partie 1 — Microsoft Entra ID](#partie-1--microsoft-entra-id)
- [Partie 2 — Aruba Central — Extension Intune](#partie-2--aruba-central--extension-intune)
- [Partie 3 — Configuration Aruba Central NAC](#partie-3--configuration-aruba-central-nac)
- [Partie 4 — Validation dans Central NAC](#partie-4--validation-dans-central-nac)
- [Références](#références)

---

## Présentation

Ce guide couvre la partie **Aruba Central NAC** de la configuration EAP-TLS — App Registration Entra ID, identity store NAC, rôles, politiques d'autorisation, SSID, configuration SCEP et validation des résultats.

```
Poste Windows (géré par Intune)
    │
    │  Certificat SCEP délivré par le CA Central NAC
    ▼
Aruba AP (802.1X EAP-TLS)
    │
    │  Authentification RADIUS
    ▼
Aruba Central NAC
    │
    │  Vérification de conformité via OAuth2
    ▼
Microsoft Intune / Entra ID
    │
    ▼
Accès réseau accordé (rôle assigné par la politique NAC)
```

> [!NOTE]
> Ce guide couvre uniquement la configuration Central NAC. Pour la partie Microsoft Intune (profils Trusted Certificate, SCEP, Wi-Fi), voir [microsoft-intune / eap-tls / windows](https://github.com/Luconik/microsoft-intune/tree/main/eap-tls/windows).

---

## Prérequis

- Workspace **HPE GreenLake** actif avec **Aruba Central** déployé
- Tenant **Microsoft Entra ID** avec droits Global Admin
- Licence **Microsoft Intune** active
- Domaine DNS personnalisé vérifié dans Entra ID
- Points d'accès Aruba gérés dans Aruba Central

| Composant | Rôle |
|---|---|
| **Aruba Central NAC** | Serveur RADIUS + moteur de politique NAC |
| **Microsoft Intune** | UEM — gestion des certificats et profils Wi-Fi |
| **Microsoft Entra ID** | Annuaire identités + App Registration OAuth2 |
| **SCEP** | Protocole de distribution des certificats clients |
| **EAP-TLS** | Méthode d'authentification 802.1X par certificat |

---

## Partie 1 — Microsoft Entra ID

### 1.1 Ajouter et vérifier un domaine personnalisé

Naviguer vers :
```
Entra ID → Domaines personnalisés → + Ajouter un domaine personnalisé
```

<p align="center"><img src="screenshots/01-entra-id-custom-domain-add.png" alt="Entra - Ajouter un domaine" width="900"/></p>

Ajouter l'enregistrement TXT de vérification dans le DNS du registrar.

<p align="center"><img src="screenshots/02-entra-id-custom-domain-txt-record.png" alt="Entra - Enregistrement TXT de vérification" width="900"/></p>

<p align="center"><img src="screenshots/03-entra-id-custom-domain-portal.png" alt="Entra - Domaine dans le portail" width="900"/></p>

<p align="center"><img src="screenshots/04-dns-registrar-records.png" alt="DNS - Enregistrements registrar" width="900"/></p>

<p align="center"><img src="screenshots/05-dns-registrar-txt-record-add.png" alt="DNS - Ajout enregistrement TXT" width="900"/></p>

Retourner dans Entra ID et cliquer **Vérifier**.

<p align="center"><img src="screenshots/06-entra-id-custom-domain-verify.png" alt="Entra - Vérification du domaine" width="900"/></p>

---

### 1.2 Vérifier les enregistrements DNS CNAME pour Intune

Requis pour l'enrôlement automatique des appareils dans Intune.

<p align="center"><img src="screenshots/07-intune-dns-cname-records.png" alt="Intune - Enregistrements DNS CNAME" width="900"/></p>

---

### 1.3 Créer une App Registration

Naviguer vers :
```
Entra ID → Inscriptions d'applications → + Nouvelle inscription
```

<p align="center"><img src="screenshots/08-entra-id-app-registration-new.png" alt="Entra - Nouvelle inscription d'application" width="900"/></p>

Configurer l'URI de redirection.

<p align="center"><img src="screenshots/09-entra-id-app-registration-redirect-uri.png" alt="Entra - URI de redirection" width="900"/></p>

---

### 1.4 Créer un Client Secret

Naviguer vers :
```
Application → Certificats et secrets → + Nouveau secret client
```

<p align="center"><img src="screenshots/10-entra-id-client-secret-new.png" alt="Entra - Nouveau secret client" width="900"/></p>

> [!WARNING]
> Copier la **valeur** du secret immédiatement — elle ne sera plus visible après fermeture de cette page.

<p align="center"><img src="screenshots/11-entra-id-client-secret-value.png" alt="Entra - Valeur du secret client" width="900"/></p>

<p align="center"><img src="screenshots/12-entra-id-client-secret-overview.png" alt="Entra - Vue d'ensemble secret client" width="900"/></p>

---

### 1.5 Ajouter les permissions API

Naviguer vers :
```
Application → Autorisations API → + Ajouter une autorisation → Microsoft Graph → Intune
```

<p align="center"><img src="screenshots/13-entra-id-api-permissions-add.png" alt="Entra - Ajout permissions API" width="900"/></p>

<p align="center"><img src="screenshots/14-entra-id-api-permissions-graph-intune.png" alt="Entra - Permissions Graph + Intune" width="900"/></p>

---

## Partie 2 — Aruba Central — Extension Intune

### 2.1 Installer l'extension Microsoft Intune

Naviguer vers :
```
Aruba Central → Extensions → Available Extensions → Microsoft Intune → Install
```

<p align="center"><img src="screenshots/15-aruba-central-intune-extension-menu.png" alt="Central - Menu extensions" width="900"/></p>

<p align="center"><img src="screenshots/16-aruba-central-intune-extension-install.png" alt="Central - Installation extension Intune" width="900"/></p>

---

### 2.2 Configurer l'extension Intune

Renseigner les informations de l'App Registration :

| Champ | Valeur |
|---|---|
| Tenant ID | Depuis la vue d'ensemble Entra ID |
| Client ID | ID d'application (client) |
| Client Secret | Valeur copiée à l'étape 1.4 |

<p align="center"><img src="screenshots/17-aruba-central-intune-extension-config.png" alt="Central - Configuration extension Intune" width="900"/></p>

---

## Partie 3 — Configuration Aruba Central NAC

### 3.1 Configurer l'Identity Store OAuth

Naviguer vers :
```
Central NAC → Configuration → Identity Management → Identity Stores → Create
```

<p align="center"><img src="screenshots/19-aruba-central-nac-identity-management-menu.png" alt="Central NAC - Menu Identity Management" width="900"/></p>

<p align="center"><img src="screenshots/20-aruba-central-nac-identity-store-create.png" alt="Central NAC - Créer Identity Store" width="900"/></p>

<p align="center"><img src="screenshots/21-aruba-central-nac-identity-store-define-name.png" alt="Central NAC - Définir le nom" width="900"/></p>

Configurer l'URI de redirection OAuth dans l'application Entra ID.

<p align="center"><img src="screenshots/22-entra-id-enterprise-app-redirect-uri.png" alt="Entra - URI redirection app entreprise" width="900"/></p>

<p align="center"><img src="screenshots/23-entra-id-redirect-uri-add.png" alt="Entra - Ajout URI redirection" width="900"/></p>

<p align="center"><img src="screenshots/24-entra-id-redirect-uri-configured.png" alt="Entra - URI redirection configurée" width="900"/></p>

<p align="center"><img src="screenshots/25-entra-id-redirect-uri-confirmed.png" alt="Entra - URI redirection confirmée" width="900"/></p>

Valider le token OAuth dans Central NAC.

<p align="center"><img src="screenshots/18-aruba-central-nac-identity-store-oauth-token.png" alt="Central NAC - OAuth token validé" width="900"/></p>

---

### 3.2 Créer les rôles NAC

Naviguer vers :
```
Central NAC → Configuration → Roles → Create Role
```

<p align="center"><img src="screenshots/26-aruba-central-nac-roles-create.png" alt="Central NAC - Créer un rôle" width="900"/></p>

<p align="center"><img src="screenshots/27-aruba-central-nac-roles-list.png" alt="Central NAC - Liste des rôles" width="900"/></p>

<p align="center"><img src="screenshots/28-aruba-central-nac-roles-scope.png" alt="Central NAC - Scope du rôle" width="900"/></p>

---

### 3.3 Configurer la politique globale NAC

Naviguer vers :
```
Central NAC → Configuration → Policies → Global Policy
```

<p align="center"><img src="screenshots/29-aruba-central-nac-global-policy.png" alt="Central NAC - Politique globale" width="900"/></p>

<p align="center"><img src="screenshots/30-aruba-central-nac-policy-rules.png" alt="Central NAC - Règles de politique" width="900"/></p>

<p align="center"><img src="screenshots/31-aruba-central-nac-policy-roles-rules.png" alt="Central NAC - Rôles et règles" width="900"/></p>

---

### 3.4 Créer le profil SSID 802.1X

Naviguer vers :
```
Aruba Central → Configuration → WLANs → Create SSID
```

Configurer le SSID en mode **WPA3-Enterprise / 802.1X**.

<p align="center"><img src="screenshots/32-aruba-central-ssid-profile-create.png" alt="Central - Créer profil SSID" width="900"/></p>

<p align="center"><img src="screenshots/33-aruba-central-ssid-profile-config.png" alt="Central - Configuration SSID" width="900"/></p>

<p align="center"><img src="screenshots/34-aruba-central-ssid-profile-device-scope.png" alt="Central - Device scope SSID" width="900"/></p>

---

### 3.5 Créer la politique d'autorisation

Naviguer vers :
```
Central NAC → Configuration → Authorization Policies → Create
```

<p align="center"><img src="screenshots/35-aruba-central-nac-authorization-policy-create.png" alt="Central NAC - Créer politique autorisation" width="900"/></p>

<p align="center"><img src="screenshots/36-aruba-central-nac-authorization-policy-config1.png" alt="Central NAC - Config politique (1)" width="900"/></p>

<p align="center"><img src="screenshots/37-aruba-central-nac-authorization-policy-config2.png" alt="Central NAC - Config politique (2)" width="900"/></p>

---

### 3.6 Créer le profil d'authentification EAP-TLS

Naviguer vers :
```
Central NAC → Configuration → Authentication Profiles → Create Profile
```

Configurer avec **EAP-TLS** et l'Identity Store Intune.

<p align="center"><img src="screenshots/38-aruba-central-nac-auth-profile-create.png" alt="Central NAC - Créer profil auth" width="900"/></p>

<p align="center"><img src="screenshots/39-aruba-central-nac-auth-profile-config1.png" alt="Central NAC - Config profil auth (1)" width="900"/></p>

<p align="center"><img src="screenshots/40-aruba-central-nac-auth-profile-config2.png" alt="Central NAC - Config profil auth (2)" width="900"/></p>

<p align="center"><img src="screenshots/41-aruba-central-nac-auth-profile-config3.png" alt="Central NAC - Config profil auth (3)" width="900"/></p>

---

### 3.7 Vérifier la connexion UEM Intune

La connexion Intune doit afficher le statut **vert** dans Central NAC.

<p align="center"><img src="screenshots/42-aruba-central-nac-uem-intune-green.png" alt="Central NAC - UEM Intune connecté (vert)" width="900"/></p>

---

### 3.8 Récupérer l'URL SCEP et le certificat CA racine

Naviguer vers :
```
Central NAC → Configuration → SCEP
```

<p align="center"><img src="screenshots/43-aruba-central-nac-scep-url.png" alt="Central NAC - URL SCEP" width="900"/></p>

Télécharger le certificat CA racine — nécessaire pour le profil Trusted Certificate dans Intune.

<p align="center"><img src="screenshots/44-aruba-central-nac-scep-certificate-download.png" alt="Central NAC - Téléchargement certificat CA" width="900"/></p>

> [!NOTE]
> Conserver l'**URL SCEP** et le **certificat CA racine** — ils sont requis dans [microsoft-intune / eap-tls / windows](https://github.com/Luconik/microsoft-intune/tree/main/eap-tls/windows) aux étapes 1.1 et 1.2.

---

## Partie 4 — Validation dans Central NAC

Naviguer vers :
```
Central NAC → Monitoring → Clients
```

Les clients authentifiés doivent apparaître avec leur rôle NAC attribué.

<p align="center"><img src="screenshots/68-test-aruba-central-nac-monitoring-clients.png" alt="Central NAC - Monitoring clients" width="900"/></p>

<p align="center"><img src="screenshots/69-test-aruba-central-nac-monitoring-clients-list.png" alt="Central NAC - Liste clients" width="900"/></p>

Cliquer sur un client pour voir le détail — vérifier le rôle attribué et le type d'authentification.

<p align="center"><img src="screenshots/70-test-aruba-central-nac-client-detail.png" alt="Central NAC - Détail client" width="900"/></p>

| Champ | Valeur attendue |
|---|---|
| Statut | Accepted |
| Type d'authentification | EAP-TLS (Certificate) |
| Statut du certificat | Valide |
| Identity Store | Luconik_EntraID |
| Rôle assigné | selon la politique d'autorisation |

---

## Références

- 📘 [Aruba Central NAC — UEM Onboarding with Intune](https://arubanetworking.hpe.com/techdocs/NAC/central-nac/central-nac-uem-onboarding-intune/)
- [Aruba Central Documentation](https://www.arubanetworks.com/techdocs/central/latest/content/)
- [Microsoft Intune — Profils de certificat SCEP](https://learn.microsoft.com/fr-fr/mem/intune/protect/certificates-scep-configure)
- [Microsoft Entra ID — App Registration](https://learn.microsoft.com/fr-fr/entra/identity-platform/quickstart-register-app)

---

## Structure des fichiers

```
central-nac-intune/windows/
├── README.md               ← Version anglaise
├── README-fr.md            ← Ce fichier (FR)
└── screenshots/
    ├── 00-aruba-central-nac-banner.png
    ├── 01-entra-id-custom-domain-add.png
    ├── ...
    ├── 44-aruba-central-nac-scep-certificate-download.png
    ├── 68-test-aruba-central-nac-monitoring-clients.png
    ├── 69-test-aruba-central-nac-monitoring-clients-list.png
    └── 70-test-aruba-central-nac-client-detail.png
```

---

*Dernière mise à jour : Mai 2026 — [@Luconik](https://github.com/Luconik)*
