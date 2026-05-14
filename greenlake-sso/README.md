# HPE GreenLake SSO — Microsoft Entra ID (SAML 2.0)
# HPE GreenLake SSO — Microsoft Entra ID (SAML 2.0)

> 🇫🇷 [Français](#fr) | 🇬🇧 [English](#en)

---

<a name="fr"></a>
## 🇫🇷 Français

### Objectif

Ce guide documente la configuration du SSO fédéré entre **Microsoft Entra ID** (ex-Azure AD) et **HPE GreenLake Cloud Platform** via le protocole **SAML 2.0**.

Une fois configuré, les utilisateurs du domaine (ex. `@your-domain.com`) se connectent à GreenLake et Aruba Central via leur compte Entra ID, avec MFA si activé.

```
Utilisateur
    │
    ▼ login @your-domain.com
Microsoft Entra ID ──── SAML Assertion ────► HPE GreenLake SSO
    │                  (attributs + rôles)         │
    │                                        Politique auth
    │                                              │
    ▼                                              ▼
Authentification                          Aruba Central
(MFA inclus si configuré)                (rôle selon hpe_ccs_attribute)
```

### Flux d'authentification SAML

1. L'utilisateur accède à `common.cloud.hpe.com`
2. GreenLake détecte le domaine → redirige vers Entra ID
3. Entra ID authentifie l'utilisateur (MFA si activé)
4. Entra ID retourne une **SAML Assertion** avec les attributs et rôles
5. GreenLake consomme l'assertion → ouvre la session avec les droits définis

---

### Prérequis

- Tenant **Microsoft Entra ID** avec droits Global Admin
- Workspace **HPE GreenLake** actif (type : Standard Enterprise Workspace)
- Domaine DNS géré (ex. via Cloudflare)
- Compte HPE NSP → voir [`../nsp-account/`](../nsp-account/)
- Workspace GreenLake + service Central → voir [`../greenlake-workspace/`](../greenlake-workspace/)

---

## Partie 1 — Configuration Microsoft Entra ID

### 1.1 Créer une nouvelle application d'entreprise

Dans le portail Azure (`portal.azure.com`) :

```
Services Identité → Applications d'entreprise → + Nouvelle application
```

![Entra - Applications d'entreprise](screenshots/01_entra_enterprise_apps.png)

Cliquer sur **"+ Créer votre propre application"**.

![Entra - Galerie d'applications](screenshots/02_entra_new_app_gallery.png)

Renseigner le nom (ex. `SSO-GreenLake`), sélectionner **"Intégrer une autre application que vous ne trouvez pas dans la galerie"**, puis cliquer **Créer**.

![Entra - Créer l'application](screenshots/03_entra_create_app.png)

---

### 1.2 Assigner les utilisateurs et groupes

Depuis la vue d'ensemble de l'application, cliquer sur **"Attribuer des utilisateurs et des groupes"**.

![Entra - Vue d'ensemble application](screenshots/04_entra_app_overview.png)

Cliquer sur **"+ Ajouter un utilisateur/groupe"**.

![Entra - Utilisateurs et groupes (vide)](screenshots/05_entra_users_groups_empty.png)

Sélectionner les utilisateurs ou groupes à autoriser, puis cliquer **Sélectionner** → **Attribuer**.

![Entra - Sélection utilisateurs](screenshots/06_entra_users_select.png)

![Entra - Attribution en cours](screenshots/07_entra_users_assign.png)

![Entra - Utilisateurs attribués](screenshots/08_entra_users_assigned.png)

> ✅ Recommandation : assigner des **groupes** plutôt que des utilisateurs individuels.

---

### 1.3 Configurer l'authentification unique SAML

Dans l'application → **Authentification unique** → sélectionner **SAML**.

![Entra - Sélection méthode SSO](screenshots/09_entra_sso_select_saml.png)

La page de configuration SAML s'affiche.

![Entra - Config SAML (vide)](screenshots/10_entra_saml_config_empty.png)

Cliquer sur **Modifier** dans "Configuration SAML de base" et renseigner :

| Champ | Valeur |
|-------|--------|
| **Identificateur (ID d'entité)** | `https://sso.common.cloud.hpe.com` |
| **URL de réponse (ACS)** | `https://sso.common.cloud.hpe.com/sp/ACS.saml2` |

Cliquer **Enregistrer**.

![Entra - Configuration SAML de base](screenshots/11_entra_saml_basic_config.png)

---

### 1.4 Configurer les attributs et revendications

Cliquer sur **Modifier** dans "Attributs et revendications" → **+ Ajouter une nouvelle revendication**.

![Entra - Attributs par défaut](screenshots/12_entra_attributes_default.png)

Configurer les attributs suivants :

| Nom de l'attribut | Valeur source |
|-------------------|---------------|
| `emailaddress` | `user.givenname` |
| `name` | `user.userprincipalname` |
| `gl_first_name` | `user.givenname` |
| `gl_last_name` | `user.surname` |

![Entra - Attributs configurés](screenshots/13_entra_attributes_configured.png)

---

### 1.5 Configurer l'attribut hpe_ccs_attribute ⚠️

Cet attribut est **critique** — il définit les rôles de l'utilisateur dans GreenLake et Aruba Central.

Avant de le configurer, récupérer le **Service ID** d'Aruba Central dans GreenLake :

`Services → Catalogue → HPE Aruba Networking Central → ID de service`

![GreenLake - Service ID Central](screenshots/14_gl_central_service_id.png)

Créer la revendication `hpe_ccs_attribute` avec des **conditions par groupe** :

![Entra - hpe_ccs_attribute (condition)](screenshots/17_entra_hpe_ccs_attribute.png)

Sélectionner le groupe Entra ID correspondant au rôle :

![Entra - Sélection groupe pour condition](screenshots/18_entra_hpe_ccs_group_select.png)

#### Format de la valeur

```
version_1#{workspace_id}:{service_id}:{role_greenlake}:{scope}:{service_id_central}:{role_central}:{scope}
```

**Exemple — compte support (Observer GreenLake + Operator Central) :**
```
version_1#<workspace_id>:0:Workspace Observer:ALL_SCOPES:<central_service_id>:Aruba Central Operator:ALL_SCOPES
```

**Exemple — compte admin (Administrator GreenLake + Administrator Central) :**
```
version_1#<workspace_id>:0:Workspace Administrator:ALL_SCOPES:<central_service_id>:Aruba Central Administrator:ALL_SCOPES
```

#### Rôles disponibles

| Rôle GreenLake | Droits |
|----------------|--------|
| `Workspace Administrator` | Admin complet du tenant |
| `Workspace Observer` | Lecture seule |

| Rôle Aruba Central | Droits |
|--------------------|--------|
| `Aruba Central Administrator` | Admin complet |
| `Aruba Central Operator` | Lecture + opérations limitées |

Les rôles disponibles sont visibles dans GreenLake :

![GreenLake - Rôles et autorisations](screenshots/16_gl_roles_permissions.png)

Vue finale des attributs avec `hpe_ccs_attribute` configuré :

![Entra - Attributs finaux](screenshots/19_entra_attributes_final.png)

---

### 1.6 Télécharger le XML de métadonnées

Dans la section **"Certificats SAML"**, télécharger le **XML de métadonnées de fédération**.

![Entra - Certificat SAML](screenshots/20_entra_saml_certificate.png)

Ce fichier sera chargé lors de la configuration de la connexion SSO côté GreenLake (étape 2.3).

---

## Partie 2 — Configuration HPE GreenLake

### 2.1 Activer les fonctionnalités entreprise

```
Gérer l'espace de travail → Enable enterprise capabilities
```

![GreenLake - Gérer workspace (IAM)](screenshots/15_gl_manage_workspace_iam.png)

![GreenLake - Activer fonctionnalités entreprise](screenshots/21_gl_manage_workspace_enterprise.png)

Cliquer sur **"Créer l'organisation"** pour activer SSO, SCIM et gestion des domaines.

![GreenLake - Modal activation entreprise](screenshots/22_gl_enable_enterprise_modal.png)

---

### 2.2 Ajouter et vérifier le domaine

```
Gérer l'espace de travail → Domaines → Ajouter un domaine
```

![GreenLake - Gérer workspace (Domaines)](screenshots/23_gl_manage_workspace_domains.png)

![GreenLake - Domaines (vide)](screenshots/24_gl_domains_empty.png)

GreenLake génère un **enregistrement TXT** de vérification.

![GreenLake - Vérification domaine TXT](screenshots/25_gl_domain_verify_txt.png)

#### Ajout de l'enregistrement DNS dans Cloudflare

Dans le dashboard Cloudflare → **DNS → Enregistrements DNS → Ajouter un enregistrement** :

![Cloudflare - Dashboard DNS](screenshots/26_cloudflare_dns_home.png)

![Cloudflare - Enregistrements DNS](screenshots/27_cloudflare_dns_records.png)

| Champ | Valeur |
|-------|--------|
| Type | `TXT` |
| Nom | `@` |
| Contenu | Valeur générée par GreenLake |

![Cloudflare - Ajout enregistrement TXT](screenshots/28_cloudflare_dns_add_txt.png)

Retourner sur GreenLake → domaine en état **"En attente"** → cliquer **"Vérifier le domaine maintenant"**.

![GreenLake - Domaine en attente](screenshots/29_gl_domain_pending.png)

Une fois vérifié, le bouton **"Créer une politique d'authentification"** apparaît.

![GreenLake - Domaine vérifié](screenshots/44_gl_domain_verified.png)

> ⏱️ La propagation DNS peut prendre quelques minutes à 72h selon le TTL.

---

### 2.3 Créer la connexion SSO

```
Gérer l'espace de travail → Configuration SSO → Actions → Créer une connexion SSO
```

![GreenLake - Manage workspace (SSO)](screenshots/30_gl_manage_workspace_sso.png)

![GreenLake - Config SSO (vide)](screenshots/31_gl_sso_config_empty.png)

**Step 1 of 6 — Généralités** : nommer la connexion (ex. `your-domain-SSO`), sélectionner **SAML 2.0**.

![GreenLake - SSO Step 1](screenshots/32_gl_sso_create_step1.png)

**Step 2 of 6 — Attributs SAML** : renseigner les noms des attributs correspondant à Entra ID.

| Champ | Valeur |
|-------|--------|
| Adresse e-mail | `NameId` |
| Autorisation HPE GreenLake | `hpe_ccs_attribute` |
| Prénom | `gl_first_name` |
| Nom | `gl_last_name` |

![GreenLake - SSO Step 2 (attributs)](screenshots/33_gl_sso_create_step2_attributes.png)

**Step 3 of 6 — Informations SP** : GreenLake affiche les URLs à configurer côté Entra ID (déjà faites à l'étape 1.3).

![GreenLake - SSO Step 3 (info SP)](screenshots/34_gl_sso_create_step3_idp_info.png)

**Step 4 of 6 — Charger le XML** : charger le fichier XML de métadonnées téléchargé à l'étape 1.6.

![GreenLake - SSO Step 4 (upload XML)](screenshots/35_gl_sso_create_step4_upload_xml.png)

**Step 6 of 6 — Examiner et créer** : vérifier la configuration complète, puis cliquer **"Créer une connexion SSO"**.

![GreenLake - SSO Step 6 (review)](screenshots/36_gl_sso_create_step6_review.png)

La connexion SSO apparaît dans la liste.

![GreenLake - Connexion SSO créée](screenshots/37_gl_sso_connection_created.png)

---

### 2.4 Créer la politique d'authentification

```
Configuration SSO → Actions → Créer une politique d'authentification
```

**Step 1 of 3 — Généralités** :

| Champ | Valeur |
|-------|--------|
| Type de domaine | Domaine vérifié |
| Domaine | `your-domain.com` |
| Connexion SSO | Connexion créée à l'étape 2.3 |
| Mode d'autorisation | **Affectations de rôles SSO** |

![GreenLake - Politique auth Step 1](screenshots/38_gl_auth_policy_step1.png)

**Step 2 of 3 — Compte de récupération** :

> ⚠️ **Étape critique** : créer un compte de récupération local avant d'activer la politique. Ce compte permet de reprendre la main en cas de problème SSO.

![GreenLake - Compte de récupération](screenshots/39_gl_auth_policy_step2_recovery.png)

Une fois créée, la politique passe à l'état **Active**.

![GreenLake - Politique auth active](screenshots/40_gl_auth_policy_active.png)

---

## Partie 3 — Tests de validation

### Scénarios testés

| Compte | Groupe Entra ID | Rôle GreenLake | Rôle Central |
|--------|-----------------|----------------|--------------|
| `support1@your-domain.com` | Groupe support | Workspace Observer | Aruba Central Operator |
| `admin1@your-domain.com` | Groupe admin | Workspace Administrator | Aruba Central Administrator |

### Procédure

1. Ouvrir une session de navigation privée
2. Accéder à `https://common.cloud.hpe.com`
3. Saisir l'email → GreenLake détecte le domaine → redirige vers Entra ID
4. Authentification Entra ID

**Test support1 :**

![Test - support1 login](screenshots/41_test_sso_support1_login.png)

**Test admin1 :**

![Test - admin1 login](screenshots/42_test_sso_admin1_login.png)

![Test - admin1 mot de passe](screenshots/43_test_sso_admin1_password.png)

### Résultats attendus

- **support1** → accès en lecture seule à Central, pas de droits d'administration GreenLake
- **admin1** → accès administrateur complet Central + droits admin GreenLake

---

## Troubleshooting

| Symptôme | Cause probable | Solution |
|----------|---------------|----------|
| Erreur SAML après login Entra | Mauvais ACS URL ou Entity ID | Vérifier étape 1.3 |
| Utilisateur sans droits dans Central | `hpe_ccs_attribute` mal formé | Vérifier le format et les IDs |
| Domaine non vérifié | Propagation DNS non terminée | Attendre et retenter |
| Boucle de redirection | Politique auth mal configurée | Utiliser le compte de récupération |
| Service ID incorrect | ID copié depuis le mauvais service | Vérifier dans le Catalogue GreenLake |

---

## Notes importantes

> 💡 Une fois le SSO configuré, les **tokens API GreenLake** restent générés via le flow **Client Credentials OAuth2** — le SSO s'applique uniquement à la connexion interface web.

> 💡 Pour les scripts d'automatisation, utiliser les **Personal API Clients** créés sous l'identité d'un compte de service dédié (non SSO).

---

## Références

- [HPE GreenLake SSO — Documentation officielle](https://support.hpe.com/hpesc/public/docDisplay?docId=a00120892en_us&page=GUID-56FE5BF1-AD93-4AFB-90F3-4DE52BDA9EF9.html)
- [Configuration hpe_ccs_attribute](https://support.hpe.com/hpesc/public/docDisplay?docId=a00120892en_us&page=GUID-A4965F9A-2C8F-4D4D-B067-AAF96E95E7DE.html)
- [HPE GreenLake Platform](https://common.cloud.hpe.com)
- [`../central-nac-intune/`](../central-nac-intune/) — Intégration NAC + Intune

---
---

<a name="en"></a>
## 🇬🇧 English

### Purpose

This guide covers the SSO federation configuration between **Microsoft Entra ID** and **HPE GreenLake Cloud Platform** using **SAML 2.0**.

Once configured, users with a domain account (e.g. `@your-domain.com`) authenticate to GreenLake and Aruba Central via Entra ID, with MFA if enabled.

---

### Prerequisites

- **Microsoft Entra ID** tenant with Global Admin rights
- Active **HPE GreenLake** workspace (Standard Enterprise Workspace type)
- DNS domain managed via Cloudflare or equivalent
- HPE NSP account → see [`../nsp-account/`](../nsp-account/)
- GreenLake workspace + Central service → see [`../greenlake-workspace/`](../greenlake-workspace/)

---

## Part 1 — Microsoft Entra ID configuration

### 1.1 Create an enterprise application

In Azure portal (`portal.azure.com`):

```
Identity Services → Enterprise applications → + New application
→ Create your own application → SSO-GreenLake → Create
```

Screenshots: see FR section above (same UI, English labels).

---

### 1.2 Assign users and groups

Navigate to **Users and groups** → **+ Add user/group** → select users or groups → **Assign**.

> ✅ Recommendation: use **groups** instead of individual users for scalability.

---

### 1.3 Configure SAML SSO

**Application → Single sign-on → SAML**

Basic SAML configuration:

| Field | Value |
|-------|-------|
| **Identifier (Entity ID)** | `https://sso.common.cloud.hpe.com` |
| **Reply URL (ACS)** | `https://sso.common.cloud.hpe.com/sp/ACS.saml2` |

---

### 1.4 Configure attributes and claims

Add these claims:

| Attribute name | Source value |
|----------------|--------------|
| `emailaddress` | `user.givenname` |
| `name` | `user.userprincipalname` |
| `gl_first_name` | `user.givenname` |
| `gl_last_name` | `user.surname` |

---

### 1.5 Configure hpe_ccs_attribute ⚠️

This attribute is **critical** — it maps Entra ID groups to GreenLake and Central roles.

**Value format:**
```
version_1#{workspace_id}:0:{greenlake_role}:ALL_SCOPES:{central_service_id}:{central_role}:ALL_SCOPES
```

**Support account example:**
```
version_1#<workspace_id>:0:Workspace Observer:ALL_SCOPES:<central_service_id>:Aruba Central Operator:ALL_SCOPES
```

**Admin account example:**
```
version_1#<workspace_id>:0:Workspace Administrator:ALL_SCOPES:<central_service_id>:Aruba Central Administrator:ALL_SCOPES
```

Get the **Central Service ID** from: `GreenLake → Services → Catalog → HPE Aruba Networking Central → Service ID`

---

### 1.6 Download federation metadata XML

In the **SAML Signing Certificate** section → download **Federation Metadata XML**.

This file will be uploaded during GreenLake SSO connection setup (step 2.3).

---

## Part 2 — HPE GreenLake configuration

### 2.1 Enable enterprise capabilities

```
Manage workspace → Enable enterprise capabilities → Create organization
```

### 2.2 Add and verify domain

```
Manage workspace → Domains → Add domain
```

Add the TXT record generated by GreenLake to Cloudflare DNS, then click **"Verify domain now"**.

> ⏱️ DNS propagation may take a few minutes to 72h.

### 2.3 Create SSO connection

```
Manage workspace → SSO Configuration → Actions → Create SSO connection
```

6-step wizard:

| Step | Action |
|------|--------|
| 1 — General | Name: `your-domain-SSO`, Protocol: SAML 2.0 |
| 2 — SAML attributes | Map: NameId, hpe_ccs_attribute, gl_first_name, gl_last_name |
| 3 — SP info | Confirm Entity ID + ACS URL (already configured in step 1.3) |
| 4 — IdP config | Upload Entra ID federation metadata XML |
| 5 — Expiration | Leave default (30 min) |
| 6 — Review | Verify and click **"Create SSO connection"** |

### 2.4 Create authentication policy

```
SSO Configuration → Actions → Create authentication policy
```

| Field | Value |
|-------|-------|
| Domain type | Verified domain |
| Domain | `your-domain.com` |
| SSO connection | Connection from step 2.3 |
| Authorization mode | **SSO role assignments** |

> ⚠️ **Critical**: create a recovery account before activating the policy to avoid lockout.

---

## Part 3 — Validation tests

| Account | Entra ID group | GreenLake role | Central role |
|---------|----------------|----------------|--------------|
| `support1@your-domain.com` | support | Workspace Observer | Aruba Central Operator |
| `admin1@your-domain.com` | admin | Workspace Administrator | Aruba Central Administrator |

Test in private browsing → `common.cloud.hpe.com` → enter email → redirected to Entra ID → authenticate.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| SAML error after Entra login | Wrong ACS URL or Entity ID | Check step 1.3 |
| User has no rights in Central | Malformed `hpe_ccs_attribute` | Check format and IDs |
| Domain not verified | DNS propagation pending | Wait and retry |
| Redirect loop | Auth policy misconfigured | Use recovery account |
| Wrong Service ID | Copied from wrong service | Check GreenLake Catalog |

---

## File structure / Structure des fichiers

```
greenlake-sso/
├── README.md                                ← This file / Ce fichier
└── screenshots/
    ├── 01_entra_enterprise_apps.png
    ├── 02_entra_new_app_gallery.png
    ├── 03_entra_create_app.png
    ├── 04_entra_app_overview.png
    ├── 05_entra_users_groups_empty.png
    ├── 06_entra_users_select.png          
    ├── 07_entra_users_assign.png
    ├── 08_entra_users_assigned.png
    ├── 09_entra_sso_select_saml.png
    ├── 10_entra_saml_config_empty.png
    ├── 11_entra_saml_basic_config.png
    ├── 12_entra_attributes_default.png
    ├── 13_entra_attributes_configured.png
    ├── 14_gl_central_service_id.png
    ├── 15_gl_manage_workspace_iam.png
    ├── 16_gl_roles_permissions.png
    ├── 17_entra_hpe_ccs_attribute.png
    ├── 18_entra_hpe_ccs_group_select.png
    ├── 19_entra_attributes_final.png
    ├── 20_entra_saml_certificate.png        
    ├── 21_gl_manage_workspace_enterprise.png
    ├── 22_gl_enable_enterprise_modal.png
    ├── 23_gl_manage_workspace_domains.png
    ├── 24_gl_domains_empty.png
    ├── 25_gl_domain_verify_txt.png
    ├── 26_cloudflare_dns_home.png
    ├── 27_cloudflare_dns_records.png
    ├── 28_cloudflare_dns_add_txt.png
    ├── 29_gl_domain_pending.png
    ├── 30_gl_manage_workspace_sso.png
    ├── 31_gl_sso_config_empty.png
    ├── 32_gl_sso_create_step1.png
    ├── 33_gl_sso_create_step2_attributes.png
    ├── 34_gl_sso_create_step3_idp_info.png
    ├── 35_gl_sso_create_step4_upload_xml.png
    ├── 36_gl_sso_create_step6_review.png
    ├── 37_gl_sso_connection_created.png
    ├── 38_gl_auth_policy_step1.png
    ├── 39_gl_auth_policy_step2_recovery.png
    ├── 40_gl_auth_policy_active.png
    ├── 41_test_sso_support1_login.png
    ├── 42_test_sso_admin1_login.png
    ├── 43_test_sso_admin1_password.png
    └── 44_gl_domain_verified.png
```

---

*Last updated: March 2026 — [@Luconik](https://github.com/Luconik)*
