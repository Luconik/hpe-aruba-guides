# Linux Ubuntu 24.04 — Accès réseau via Entra ID avec Central NAC

Ce document consolidé décrit deux étapes complémentaires pour permettre à un poste Linux Ubuntu 24.04 de s'authentifier sur un réseau Wi-Fi d'entreprise via Microsoft Entra ID :

1. **Enrollment Intune** — enregistrement de l'appareil pour la gestion de conformité
2. **Portail captif Central NAC** — accès réseau via authentification Entra ID (contournement des limites de profils Linux dans Intune)

> **Contexte** : Intune ne propose pas de profils de configuration natifs sur Linux (Wi-Fi EAP-TLS, certificats SCEP/Trusted). L'enrollment Intune gère uniquement la conformité de l'appareil. Pour l'accès réseau, le flux décrit dans la partie 2 (portail captif Central NAC avec Entra ID) constitue le contournement opérationnel.

---

# Partie 1 — Enrollment Microsoft Intune sur Ubuntu 24.04

## Prérequis

- Ubuntu Desktop **24.04 LTS** (Noble Numbat), architecture amd64
- Compte Microsoft Entra ID avec une licence Intune active
- Accès Internet vers packages.microsoft.com
- Droits sudo sur la machine

---

## 1. Installation de l'agent Intune Portal

### Pourquoi ne pas utiliser le script officiel ?

Le script `installer.sh` disponible sur le dépôt GitHub Microsoft présente un bug connu sur Ubuntu 24.04 : la variable `EDGE_GPG_KEY` n'est pas liée (ligne 277), ce qui provoque l'arrêt du script :

```
./installer.sh: ligne 277: EDGE_GPG_KEY : variable sans liaison
```

### Installation manuelle via apt

```bash
# 1. Télécharger et installer la clé GPG Microsoft
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
sudo rm microsoft.gpg

# 2. Ajouter le repository Microsoft pour Ubuntu 24.04 (Noble)
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] \
https://packages.microsoft.com/ubuntu/24.04/prod noble main" \
> /etc/apt/sources.list.d/microsoft-ubuntu-noble-prod.list'

# 3. Mettre à jour et installer
sudo apt update && sudo apt install intune-portal -y
```

Les paquets suivants sont installés automatiquement :

| Paquet | Description |
|---|---|
| `intune-portal` | Application Intune Portal (v1.2604.x) |
| `microsoft-identity-broker` | Broker d'authentification Microsoft (v3.0.x) |

> **Note** : Si un fichier `microsoft-prod.list` existe déjà dans `/etc/apt/sources.list.d/`, le supprimer avant : `sudo rm /etc/apt/sources.list.d/microsoft-prod.list`

### Reload systemd après installation

```bash
systemctl --user daemon-reload
```

---

## 2. Enrollment de l'appareil

### Lancement de l'application

```bash
intune-portal
```

L'écran d'accueil **Agent Intune** s'affiche. Cliquer sur **Se connecter**.

![Agent Intune — écran d'accueil](intune-portal-accueil.png)

### Authentification Entra ID

La fenêtre Microsoft Sign in s'ouvre. Saisir l'adresse email du compte organisationnel et cliquer sur **Next**.

![Microsoft Sign in — saisie de l'email](intune-portal-signin-email.png)

Saisir le mot de passe du compte et cliquer sur **Sign in**.

![Microsoft Authentication — saisie du mot de passe](intune-portal-signin-password.png)

### Enregistrement du device (MFA)

Si une politique d'accès conditionnel est en place, une étape **"Help us keep your device secure"** s'affiche. Cliquer sur **Register**.

![Microsoft Authentication — enregistrement du device](intune-portal-register-device.png)

Si le MFA est activé sur le compte, saisir le code affiché dans l'application **Microsoft Authenticator** et cliquer sur **Verify**.

![Microsoft Authentication — code MFA](intune-portal-mfa.png)

### Portail Company — Configuration de l'accès

Après authentification, le portail affiche l'écran **Configurer l'accès**. Cliquer sur **Commencer**.

![Portail Company — Configurer l'accès](intune-portal-configurer-acces.png)

L'écran suivant présente les informations que l'organisation peut consulter sur l'appareil. Cliquer sur **Commencer** pour confirmer le consentement.

![Portail Company — consentement organisation](intune-portal-consentement.png)

### Enrollment en cours

L'enrollment démarre automatiquement. L'écran **Enregistrement de votre appareil** s'affiche pendant quelques secondes.

![Portail Company — enregistrement en cours](intune-portal-enrollment-progress.png)

### Résultat post-enrollment

Une fois l'enrollment terminé, l'application affiche la fiche de l'appareil avec son nom, son fabricant et son système d'exploitation.

![Portail Company — appareil enregistré](intune-portal-enrolled.png)

> **Note** : L'état **"Impossible de vérifier l'état"** est normal à ce stade — aucune politique de conformité n'est encore assignée. Cette erreur correspond à l'erreur IWS 500 visible dans les logs, sans impact sur l'enrollment.

---

## 3. Vérification côté administration

### Liste des appareils Linux

Dans le **Microsoft Intune admin center**, naviguer vers **Devices > Linux devices**.

![Intune admin center — Linux devices list](intune-linux-devices-list.png)

| Champ | Valeur |
|---|---|
| Managed by | `Intune` |
| Ownership | `Corporate` |
| OS | `Linux` |
| OS version | `24.04` |
| Compliance | `Not evaluated` |

### Détail de l'appareil

Cliquer sur le nom de l'appareil pour afficher le détail :

![Intune admin center — détail de l'appareil](intune-linux-device-detail.png)

---

## 4. Limitations — Profils de configuration Linux

**Intune ne propose aucun profil de configuration natif pour Linux.** En naviguant vers **Devices > Configuration > Create > Linux**, le menu *Profile type* indique **No available items**.

![Intune — No available items pour Linux](intune-linux-no-profile.png)

| Fonctionnalité | Windows | macOS | iOS | Linux |
|---|---|---|---|---|
| Profil Wi-Fi EAP-TLS | Oui | Oui | Oui | **Non** |
| Profil certificat SCEP | Oui | Oui | Oui | **Non** |
| Trusted certificate profile | Oui | Oui | Oui | **Non** |
| Compliance policy | Oui | Oui | Oui | Oui |
| Scripts | Oui | Oui | Non | Oui |
| Enrollment MDM | Oui | Oui | Oui | Oui |

> **Contournement** : pour l'accès réseau Wi-Fi sur Linux, utiliser le flux **portail captif Entra ID** décrit en Partie 2.

---

## Troubleshooting Intune

### Erreur `EDGE_GPG_KEY : variable sans liaison`

Utiliser la méthode d'installation manuelle décrite en section 1.

### Warning de doublon de repository

```
W: La cible Packages est spécifiée plusieurs fois dans microsoft-prod.list
   et microsoft-ubuntu-noble-prod.list
```

```bash
sudo rm /etc/apt/sources.list.d/microsoft-prod.list
sudo apt update
```

### État "Impossible de vérifier l'état" dans l'app

L'erreur IWS 500 post-enrollment est liée au service Company Portal côté Microsoft. **Elle n'affecte pas l'enrollment ni la réception des politiques.** L'appareil est bien enregistré et visible dans l'admin center.

### Consulter les logs

```bash
cat ~/intune-installer.log
journalctl --user -u intune-agent.timer -f
```

---

# Partie 2 — Contournement : Portail captif Central NAC avec Entra ID (Linux)

## Contexte

Cette procédure permet aux utilisateurs Linux de se connecter au réseau via un portail captif authentifié avec Entra ID, **sans certificat EAP-TLS ni profil Intune Wi-Fi** — contournement des limitations décrites en Partie 1, Section 4.

Les étapes de configuration côté infrastructure sont :

1. Création du **SSID** ouvert dans New Central
2. Configuration du **Portal Profile** dans Central NAC
3. Configuration de l'**Authentication Profile** Captive Portal dans Central NAC

---

## 1. Création du SSID

Depuis le dashboard New Central, naviguer vers **Global > Network Overview**, puis cliquer sur l'icône de configuration (roue crantée) en haut à droite.

![Network Overview — accès à la configuration](dashboard-central-roue.png)

Dans le menu de gauche, sélectionner **Library**, puis naviguer vers **Profiles Management > Wireless > WLAN** et cliquer sur **Manage**.

![Library — Profiles Management WLAN](library-WLAN-Manage.png)

Cliquer sur **Create Profile** et renseigner les paramètres suivants :

| Paramètre | Valeur |
|---|---|
| Profile Name | `Luconik-invite` |
| ESSID Name | `Luconik-invite` |
| Default VLAN | `1` |
| Security Level | `Open` |
| Key Management | `Enhanced Open` |
| Captive Portal Type | `Central NAC` |

![Création du profil WLAN](WLAN-Creation.png)

> **Note :** Le Security Level `Open` avec Key Management `Enhanced Open` (OWE) assure un chiffrement opportuniste sans pré-partage de clé, adapté à un portail captif.

---

## 2. Configuration du Portal Profile

Naviguer vers **Global > Central NAC > Configuration > Portal Customization > Portal Profiles**.

Créer ou éditer un profil avec les paramètres suivants :

| Paramètre | Valeur |
|---|---|
| Name | `Luconik_Portal_Profiles_Entra` |
| Require user to accept terms | Activé |
| Show terms | `Show terms on the sign-in page` |
| Theme | `Use system default theme` |
| Overrides | `None` |

![Portal Profile — configuration Sign-in](dashboard-centralnac-portal-profile.png)

![Portal Profile — configuration complète](dashboard-centralnac-portal-profile-2.png)

> **Note :** L'activation de "Require user to accept terms" impose à l'utilisateur de cocher les conditions générales avant de pouvoir s'authentifier.

---

## 3. Configuration de l'Authentication Profile

Naviguer vers **Global > Central NAC > Configuration > Authentication Profiles**.

Sélectionner le profil `Luconik_Captive_Portal` ou en créer un nouveau avec les paramètres suivants :

| Paramètre | Valeur |
|---|---|
| Name | `Luconik_Captive_Portal` |
| Authentication Type | `Captive Portal` |
| Network | `Luconik-invite` |
| Authentication | `Users sign in with an account` |
| Identity Stores | `Luconik_Visitor`, `Luconik_EntraID` |
| Allow users to register an account | Activé |

![Authentication Profile — configuration Captive Portal](Centralnac-authenticationprofiles-captiveportal.png)

Les Identity Stores sélectionnés permettent l'authentification via Entra ID (`Luconik_EntraID`) ou via un compte visiteur local (`Luconik_Visitor`).

![Authentication Profile — sélection des Identity Stores](Centralnac-authenticationprofiles-captiveportal-identitystore.png)

En bas du panneau, configurer les paramètres complémentaires :

| Paramètre | Valeur |
|---|---|
| Registered user identity store | `Luconik_Visitor` |
| Register | `Register email address only` |
| Expire registered accounts after | `1 day` |
| Portal Customization | `Luconik_Portal_Profiles_Entra` |

![Authentication Profile — Portal Customization et Portal URL](dashboard-centralnac-AP-Manage.png)

Cliquer sur **Save**.

---

## Expérience utilisateur Linux

### Connexion au réseau

Dans la barre de notifications système, cliquer sur le bouton **Wi-Fi** et sélectionner le réseau `Luconik-invite`.

![Sélection du réseau Wi-Fi Luconik-invite](wifi-selection.png)

Une notification système apparaît confirmant la connexion au réseau.

![Notification de connexion au réseau](wifi-notification.png)

### Authentification sur le portail captif

Le navigateur s'ouvre automatiquement sur le portail captif. Trois méthodes d'authentification sont disponibles :

- **Se connecter** : avec un compte visiteur local (nom d'utilisateur + mot de passe)
- **S'inscrire** : pour créer un compte visiteur
- **Se connecter avec Luconik_EntraID** : authentification via le compte Microsoft Entra ID de l'organisation

![Portail captif — page de connexion](captive-portal-login.png)

Cliquer sur **Se connecter avec Luconik_EntraID**.

### Acceptation des conditions générales

Si le Portal Profile est configuré avec l'acceptation des conditions générales, une page intermédiaire s'affiche. Cocher **J'accepte les conditions générales** puis cliquer sur **Accepter**.

![Conditions générales — acceptation](captive-portal-terms.png)

### Authentification Entra ID

La page Microsoft apparaît. Sélectionner le compte de l'organisation ou en saisir un manuellement.

![Microsoft — sélection du compte](entra-account-select.png)

Saisir le mot de passe du compte Microsoft et cliquer sur **Se connecter**.

![Microsoft — saisie du mot de passe](entra-password.png)

Si une invite "Rester connecté ?" apparaît, cliquer sur **Oui** pour réduire les demandes de reconnexion lors des prochaines sessions.

![Microsoft — rester connecté](entra-stay-connected.png)

### Accès au réseau

Une fois l'authentification réussie, le navigateur redirige vers la page web par défaut configurée dans le Portal Profile. L'accès Internet est accordé.

![Accès Internet confirmé](access-confirmed.png)

---

## Vérification côté administration

### Liste des clients connectés

Naviguer vers **Global > Central NAC > Monitor > Clients** pour consulter la liste des clients authentifiés.

![NAC Clients — liste des connexions actives](centralnac-clients-list.png)

La session de l'utilisateur doit apparaître avec le statut **Accepted**, le type de connexion **Wireless** et le WLAN **Luconik-invite**.

### Détail d'une session client

Cliquer sur un client pour afficher le détail de sa session et vérifier :

- **Status** : `Accepted`
- **Authentication Type** : `Captive Portal`
- **Captive Portal Name** : `Luconik_Captive_Portal`
- **Identity Store** : `Luconik_EntraID`
- **Assigned Role** : rôle assigné par la politique d'autorisation

![NAC Client — détail de la session](centralnac-client-detail.png)

Le diagramme de connectivité confirme le chemin : utilisateur → SSID → AP → Central NAC.
