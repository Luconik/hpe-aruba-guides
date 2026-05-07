# Aruba Central NAC — Onboarding macOS avec Microsoft Intune (802.1X / EAP-TLS)

> 🇫🇷 Français | 🇬🇧 [English](README.md)

---

## Présentation

Ce guide documente la configuration complète d'**Aruba Central NAC** avec **Microsoft Intune** pour les appareils macOS, permettant une authentification **802.1X EAP-TLS** par certificat SCEP.

> 📎 Prérequis (Entra ID, Central NAC, SSID, rôles, politiques) : voir [`../windows/`](../windows/)  
> Ces étapes sont identiques pour macOS — seuls les profils Intune diffèrent.

```
Endpoint macOS (géré par Intune)
    │
    │  Certificat SCEP délivré par Central NAC
    ▼
Aruba AP (802.1X EAP-TLS)
    │
    │  Authentification RADIUS
    ▼
Aruba Central NAC
    │
    │  Vérification conformité via OAuth2
    ▼
Microsoft Intune (Entra ID)
    │
    ▼
Accès réseau accordé (rôle selon politique NAC)
```

---

## Prérequis

- Aruba Central NAC entièrement configuré (voir [`../windows/`](../windows/))
- Tenant Microsoft Intune actif
- **Certificat Apple MDM Push** configuré dans Intune (voir Partie 0 ci-dessous)
- Appareil macOS sous macOS 14 Sonoma ou version ultérieure
- Application Microsoft **Company Portal** installée sur l'appareil

---

## Partie 0 — Certificat Apple MDM Push

Avant d'enrôler un appareil Apple dans Intune, un certificat Apple MDM Push doit être configuré. C'est un prérequis unique pour l'ensemble de l'écosystème Apple (macOS + iOS).

### 0.1 Ouvrir l'enrollment Apple dans Intune

```
Intune Admin Center → Appareils → Enrollment → Onglet Apple
```

![Intune - Onglet enrollment Apple](screenshots/71-intune-apns-enrollment-apple-tab.png)

Cliquer sur **Apple MDM Push Certificate**.

---

### 0.2 Configurer le certificat MDM Push — accepter et télécharger le CSR

Cocher **I agree** pour autoriser Microsoft à envoyer des données à Apple, puis cliquer sur **Download your CSR**.

![Intune - Configurer MDM Push Certificate](screenshots/72-intune-apns-configure-mdm-push-agree.png)

---

### 0.3 Se connecter au portail Apple Push Certificates

Aller sur [https://identity.apple.com](https://identity.apple.com) et se connecter avec un Apple ID d'entreprise.

![Apple ID - Connexion](screenshots/73-intune-apns-apple-id-login.png)

---

### 0.4 Créer un nouveau certificat Push

Dans le portail Apple Push Certificates, cliquer sur **Create a Certificate**.

![Apple Push Portal - Certificats existants](screenshots/74-intune-apns-push-portal-existing-certs.png)

Accepter les Conditions d'utilisation.

![Apple Push Portal - Conditions d'utilisation](screenshots/75-intune-apns-push-portal-terms.png)

![Apple Push Portal - Conditions acceptées](screenshots/76-intune-apns-push-portal-terms-accepted.png)

---

### 0.5 Uploader le CSR et télécharger le certificat

Uploader le fichier `IntuneCSR.csr` téléchargé à l'étape 0.2, puis cliquer sur **Upload**.

![Apple Push Portal - Upload du CSR](screenshots/77-intune-apns-push-portal-upload-csr.png)

Télécharger le certificat `.pem` généré.

![Apple Push Portal - Confirmation](screenshots/78-intune-apns-push-portal-confirmation.png)

---

### 0.6 Uploader le certificat dans Intune

De retour dans Intune, saisir l'Apple ID utilisé, uploader le fichier `.pem`, puis cliquer sur **Upload**.

![Intune - Upload du certificat MDM Push](screenshots/79-intune-apns-configure-mdm-push-upload-pem.png)

Le certificat est maintenant configuré et actif.

![Intune - Certificat MDM Push configuré](screenshots/80-intune-apns-configure-mdm-push-configured.png)

---

## Partie 1 — Profils de configuration Intune pour macOS

Trois profils doivent être créés dans Intune, dans l'ordre suivant :

| # | Type de profil | Nom | Rôle |
|---|---------------|-----|------|
| 1 | Trusted Certificate | `Luconik Trusted - macOS` | Déployer le CA racine de Central NAC |
| 2 | SCEP Certificate | `Luconik SCEP - macOS` | Demander un certificat client auprès de Central NAC |
| 3 | Wi-Fi | `Luconik Wi-Fi - macOS` | Configurer le 802.1X EAP-TLS sur le SSID |

---

### 1.1 Créer le profil Trusted Certificate

```
Intune Admin Center → Appareils → macOS → Configuration → + Créer → Modèles → Trusted certificate
```

![Intune - Sélectionner le modèle Trusted certificate](screenshots/81-intune-macos-trusted-profile-select.png)

**Basics** — Nom : `Luconik Trusted - macOS`

![Intune - Trusted certificate basics](screenshots/82-intune-macos-trusted-basics.png)

**Paramètres de configuration** — Uploader le certificat CA racine (`.cer`) téléchargé depuis Central NAC.  
Définir **Deployment Channel** sur `Device Channel`.

![Intune - Trusted certificate — upload du CA](screenshots/83-intune-macos-trusted-config-cert-uploaded.png)

**Affectations** — laisser vide pour l'instant.

![Intune - Trusted certificate affectations](screenshots/84-intune-macos-trusted-assignments.png)

**Vérifier + créer** — vérifier le résumé puis cliquer sur **Créer**.

![Intune - Trusted certificate révision](screenshots/85-intune-macos-trusted-review-create.png)

**Après création** — affecter à **Tous les appareils** et **Tous les utilisateurs**.

![Intune - Trusted certificate affecté](screenshots/86-intune-macos-trusted-assigned-all.png)

---

### 1.2 Créer le profil SCEP Certificate

```
Intune Admin Center → Appareils → macOS → Configuration → + Créer → Modèles → SCEP certificate
```

![Intune - Sélectionner le modèle SCEP certificate](screenshots/87-intune-macos-scep-profile-select.png)

**Basics** — Nom : `Luconik SCEP - macOS`

![Intune - SCEP basics](screenshots/88-intune-macos-scep-basics.png)

**Paramètres de configuration (haut)**

| Paramètre | Valeur |
|-----------|--------|
| Deployment Channel | `Device Channel` |
| Type de certificat | `User` |
| Format du nom de l'objet | `CN={{UserPrincipalName}}` |
| Autre nom de l'objet | `User principal name (UPN)` → `{{UserPrincipalName}}` |
| Période de validité du certificat | `1 Ans` |
| Utilisation de la clé | `Digital signature` |
| Taille de la clé (bits) | `2048` |
| Certificat racine | `Luconik Trusted - macOS` |

![Intune - SCEP paramètres de configuration haut](screenshots/89-intune-macos-scep-config-top.png)

**Paramètres de configuration (bas)**

| Paramètre | Valeur |
|-----------|--------|
| Utilisation étendue de la clé | `Client Authentication` — `1.3.6.1.5.5.7.3.2` |
| Seuil de renouvellement (%) | `20` |
| URL du serveur SCEP | URL SCEP de Central NAC |

![Intune - SCEP paramètres de configuration bas](screenshots/90-intune-macos-scep-config-bottom.png)

**Vérifier + créer** — vérifier le résumé complet.

![Intune - SCEP révision haut](screenshots/91-intune-macos-scep-review-create-top.png)

![Intune - SCEP révision bas](screenshots/92-intune-macos-scep-review-create-bottom.png)

**Après création** — affecter à **Tous les appareils** et **Tous les utilisateurs**.

![Intune - SCEP affecté](screenshots/93-intune-macos-scep-assigned-all.png)

---

### 1.3 Créer le profil Wi-Fi

```
Intune Admin Center → Appareils → macOS → Configuration → + Créer → Modèles → Wi-Fi
```

![Intune - Sélectionner le modèle Wi-Fi](screenshots/94-intune-macos-wifi-profile-select.png)

**Basics** — Nom : `Luconik Wi-Fi - macOS`

![Intune - Wi-Fi basics](screenshots/95-intune-macos-wifi-basics.png)

**Paramètres de configuration**

| Paramètre | Valeur |
|-----------|--------|
| SSID | `luconik-corp` |
| Se connecter automatiquement | `Activer` |
| Réseau masqué | `Désactiver` |
| Type EAP | `EAP - TLS` |
| Noms des serveurs de certificats | `luconik` |
| Certificats racines pour la validation du serveur | `Luconik Trusted - macOS` |
| Certificats (authentification client) | `Luconik SCEP - macOS` |

![Intune - Wi-Fi paramètres de configuration](screenshots/96-intune-macos-wifi-config.png)

**Vérifier + créer** — vérifier le résumé complet.

![Intune - Wi-Fi révision](screenshots/97-intune-macos-wifi-review-create.png)

**Après création** — affecter à **Tous les appareils** et **Tous les utilisateurs**.

![Intune - Wi-Fi affecté](screenshots/98-intune-macos-wifi-assigned-all.png)

---

## Partie 2 — Enrôlement macOS via Company Portal

### 2.1 Télécharger et installer Company Portal

Télécharger le `.pkg` Company Portal depuis Microsoft :

```
https://go.microsoft.com/fwlink/?linkid=853070
```

![Company Portal - Téléchargement de l'installeur](screenshots/fr/99-macos-cp-installer-download.png)

Lancer l'installeur et suivre l'assistant.

![Company Portal - Introduction](screenshots/fr/100-macos-cp-install-intro-fr.png)

![Company Portal - Contrat de licence](screenshots/fr/101-macos-cp-install-license-fr.png)

![Company Portal - Accepter la licence](screenshots/fr/102-macos-cp-install-license-agree-fr.png)

![Company Portal - Type d'installation](screenshots/fr/103-macos-cp-install-type-fr.png)

S'authentifier avec Touch ID ou mot de passe pour autoriser l'installation.

![Company Portal - Authentification](screenshots/fr/104-macos-cp-install-auth-fr.png)

![Company Portal - Installation réussie](screenshots/fr/105-macos-cp-install-success-fr.png)

Placer l'installeur dans la corbeille lorsque demandé.

![Company Portal - Placer dans la corbeille](screenshots/fr/106-macos-cp-install-trash-installer-fr.png)

---

### 2.2 Se connecter et enrôler l'appareil

Ouvrir **Company Portal** et cliquer sur **Se connecter**.

![Company Portal - Connexion](screenshots/fr/107-macos-cp-signin-fr.png)

Se connecter avec le compte d'entreprise Entra ID / Microsoft 365.

Cliquer sur **Commencer** pour démarrer l'enrôlement.

![Company Portal - Configurer l'accès MSFT](screenshots/fr/108-macos-cp-setup-begin-fr.png)

Consulter les informations de confidentialité — ce que l'organisation peut et ne peut pas voir.

![Company Portal - Révision de la confidentialité](screenshots/fr/109-macos-cp-privacy-review-fr.png)

---

### 2.3 Installer le profil de gestion

Cliquer sur **Télécharger le profil** dans Company Portal.

![Company Portal - Installer le profil de gestion](screenshots/fr/110-macos-cp-install-mgmt-profile-fr.png)

macOS ouvre **Réglages Système → Général → Gestion des appareils** et affiche une notification.

![Réglages Système - Profil téléchargé](screenshots/fr/111-macos-syssettings-profile-downloaded-fr.png)

Le profil apparaît comme **Non installé** — double-cliquer pour le consulter.

![Réglages Système - Profil en attente](screenshots/fr/112-macos-syssettings-profile-pending-fr.png)

Consulter les détails du profil (signé par `IOSProfileSigning.manage.microsoft.com`), puis cliquer sur **Installer**.

![Réglages Système - Révision du profil](screenshots/fr/113-macos-syssettings-profile-review-fr.png)

Saisir le mot de passe de l'utilisateur macOS pour autoriser l'enrôlement MDM.

![Réglages Système - Mot de passe enrôlement MDM](screenshots/fr/114-macos-syssettings-mdm-enroll-password-fr.png)

Le profil est maintenant installé. Le Mac est **supervisé et géré par MSFT**.

![Réglages Système - Profil installé](screenshots/fr/115-macos-syssettings-profile-enrolled-fr.png)

---

### 2.4 Finaliser l'enrôlement dans Company Portal

Retourner dans Company Portal — le téléchargement du profil se finalise automatiquement.

![Company Portal - Téléchargement du profil](screenshots/fr/116-macos-cp-mgmt-profile-downloading-fr.png)

L'enrôlement est terminé.

![Company Portal - C'est prêt !](screenshots/fr/117-macos-cp-enrollment-complete-fr.png)

Sélectionner la **catégorie d'appareil** lorsque demandé : `RootCA-Installed`.

![Company Portal - Catégorie d'appareil](screenshots/fr/118-macos-cp-device-category-fr.png)

![Company Portal - Catégorie sélectionnée](screenshots/fr/119-macos-cp-device-category-selected-fr.png)

---

## Partie 3 — Validation

### 3.1 Vérifier les certificats dans Trousseau d'accès

Ouvrir **Trousseau d'accès** et vérifier le trousseau **Système** — le certificat Intune MDM Device doit être présent.

![Trousseau d'accès - Système — cert Intune MDM](screenshots/120-macos-keychain-system-intune-cert.png)

Dans le trousseau **login**, vérifier la présence de :
- `Cloud Authentication Private Root CA (powered by HPE Aruba)` — de confiance
- `Cloud Authentication SCEP RA (powered by HPE Aruba)` — certificats RA
- `nicoculetto@luconik.fr` — certificat client (×2, émis par SCEP)

![Trousseau d'accès - Login — CA Aruba et certs SCEP](screenshots/121-macos-keychain-login-aruba-ca-scep.png)

---

### 3.2 Vérifier les profils dans Réglages Système

```
Réglages Système → Général → Gestion des appareils
```

Trois profils doivent apparaître sous **Utilisateur (géré)** :
- `Credential Profile` (Trusted Certificate)
- `SCEP Profile`
- `WiFi Profile`

![Réglages Système - Tous les profils déployés](screenshots/122-macos-syssettings-profiles-deployed.png)

---

### 3.3 Vérifier la connexion Wi-Fi

Le SSID `luconik-corp` doit apparaître comme connecté avec la sécurité **WPA2 Enterprise**.

![Wi-Fi - luconik-corp connecté WPA2 Enterprise](screenshots/123-macos-wifi-connected-wpa2-enterprise.png)

---

### 3.4 Vérifier dans Aruba Central NAC

```
Central NAC → Monitoring → Clients
```

L'utilisateur enrôlé doit apparaître comme **Accepted** avec le type de connexion **Wireless**.

![Central NAC - Liste clients — Accepted](screenshots/124-central-nac-clients-accepted.png)

Cliquer sur le client pour voir le détail :
- **Statut** : Accepted
- **Type d'authentification** : EAP-TLS (Certificate)
- **Statut du certificat** : Valide
- **Rôle assigné** : selon la politique NAC
- **Identity Store** : Luconik_EntraID
- **Vendor / Model/OS** : Apple / Mac OS

![Central NAC - Détail client EAP-TLS](screenshots/125-central-nac-client-detail-eap-tls.png)

---

### 3.5 Vérifier dans Intune Admin Center

```
Intune Admin Center → Appareils → Appareils macOS
```

L'appareil doit apparaître comme **Conforme**.

![Intune Admin - Liste appareils macOS](screenshots/126-intune-admin-macos-device-compliant.png)

Cliquer sur l'appareil pour voir la vue d'ensemble (numéro de série, version OS, statut de conformité).

![Intune Admin - Vue d'ensemble de l'appareil](screenshots/127-intune-admin-device-overview.png)

Naviguer vers **Configuration de l'appareil** — les trois profils doivent afficher le statut **Réussi**.

![Intune Admin - Profils de configuration réussis](screenshots/128-intune-admin-device-config-succeeded.png)

---

## Références

- 📘 [Aruba Central NAC — UEM Onboarding with Intune](https://arubanetworking.hpe.com/techdocs/NAC/central-nac/central-nac-uem-onboarding-intune/)
- [Microsoft Intune — Certificat Apple MDM Push](https://learn.microsoft.com/fr-fr/mem/intune/enrollment/apple-mdm-push-certificate-get)
- [Microsoft Intune — Profils de certificat SCEP](https://learn.microsoft.com/fr-fr/mem/intune/protect/certificates-scep-configure)
- [Microsoft Intune — Enrôlement macOS](https://learn.microsoft.com/fr-fr/mem/intune/enrollment/macos-enroll)
- [Portail Apple Push Certificates](https://identity.apple.com/pushcert/)

---

## Structure des fichiers

```
macos/
├── README.md               ← Version anglaise
├── README-fr.md            ← Ce fichier (FR)
└── screenshots/
    ├── 71-intune-apns-enrollment-apple-tab.png
    ├── ...
    ├── 130-intune-macos-profiles-list.png
    └── fr/
        ├── 100-macos-cp-install-intro-fr.png
        └── ...
```

---

*Dernière mise à jour : Mai 2026 — [@Luconik](https://github.com/Luconik)*
