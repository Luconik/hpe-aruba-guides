# Aruba Central NAC — EAP-TLS with Microsoft Intune

> 🇫🇷 [Français](README-fr.md) | 🇬🇧 English

![Central NAC](https://img.shields.io/badge/HPE%20Aruba%20Central%20NAC-required-FF6600?logo=hpe)
![Intune](https://img.shields.io/badge/Microsoft%20Intune-required-blue?logo=microsoft)
![Auth](https://img.shields.io/badge/auth-EAP--TLS%20%2F%20802.1X-green)
![Last updated](https://img.shields.io/badge/updated-May%202026-orange)

---

## Table of contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Part 1 — Aruba Central — Intune Extension](#part-1--aruba-central--intune-extension)
- [Part 2 — Aruba Central NAC Configuration](#part-2--aruba-central-nac-configuration)
- [Part 3 — Validation](#part-3--validation)
- [References](#references)

---

## Overview

This guide covers the **Aruba Central NAC** configuration for EAP-TLS certificate-based Wi-Fi authentication with Microsoft Intune as the UEM — NAC identity store, roles, authorization policies, SSID, and SCEP setup.

```
Endpoint (Intune-managed — Windows / macOS / iOS)
    │
    │  SCEP certificate issued by Central NAC CA
    ▼
Aruba AP (802.1X EAP-TLS)
    │
    │  RADIUS authentication
    ▼
Aruba Central NAC
    │
    │  Compliance check via OAuth2
    ▼
Microsoft Intune / Entra ID
    │
    ▼
Network access granted (role assigned by NAC policy)
```

> [!NOTE]
> This guide covers Central NAC configuration only. For Microsoft Intune profiles and device enrollment, see [microsoft-intune / eap-tls](https://github.com/Luconik/microsoft-intune/tree/main/eap-tls).

---

## Prerequisites

> [!IMPORTANT]
> **Complete the prerequisites before starting this guide.**
> The Entra ID App Registration (Tenant ID, Client ID, Client Secret) is required to configure the Aruba Central Intune extension and the NAC OAuth identity store.
> → [microsoft-intune / prerequisites](https://github.com/Luconik/microsoft-intune/tree/main/prerequisites)

- Active **HPE GreenLake** workspace with **Aruba Central** deployed
- **Microsoft Entra ID** App Registration configured — see [microsoft-intune / prerequisites](https://github.com/Luconik/microsoft-intune/tree/main/prerequisites)
- Active **Microsoft Intune** license
- Custom DNS domain verified in Entra ID
- Aruba APs managed in Aruba Central

| Component | Role |
|---|---|
| **Aruba Central NAC** | RADIUS server + NAC policy engine |
| **Microsoft Intune** | UEM — certificate and Wi-Fi profile management |
| **Microsoft Entra ID** | Identity directory + OAuth2 App Registration |
| **SCEP** | Client certificate distribution protocol |
| **EAP-TLS** | 802.1X certificate-based authentication method |

---

## Part 1 — Aruba Central — Intune Extension

### 1.1 Install the Microsoft Intune extension

Navigate to:
```
Aruba Central → Extensions → Available Extensions → Microsoft Intune → Install
```

<p align="center"><img src="screenshots/15-aruba-central-intune-extension-menu.png" alt="Central - Extensions menu" width="900"/></p>

<p align="center"><img src="screenshots/16-aruba-central-intune-extension-install.png" alt="Central - Install Intune extension" width="900"/></p>

---

### 1.2 Configure the Intune extension

Enter the App Registration credentials from the prerequisites:

| Field | Value |
|---|---|
| Tenant ID | From Entra ID overview |
| Client ID | Application (client) ID |
| Client Secret | Value from prerequisites step 0.4 |

<p align="center"><img src="screenshots/17-aruba-central-intune-extension-config.png" alt="Central - Configure Intune extension" width="900"/></p>

---

## Part 2 — Aruba Central NAC Configuration

### 2.1 Configure OAuth Identity Store

Navigate to:
```
Central NAC → Configuration → Identity Management → Identity Stores → Create
```

<p align="center"><img src="screenshots/19-aruba-central-nac-identity-management-menu.png" alt="Central NAC - Identity Management menu" width="900"/></p>

<p align="center"><img src="screenshots/20-aruba-central-nac-identity-store-create.png" alt="Central NAC - Create Identity Store" width="900"/></p>

<p align="center"><img src="screenshots/21-aruba-central-nac-identity-store-define-name.png" alt="Central NAC - Define Identity Store name" width="900"/></p>

Configure the OAuth redirect URI in the Entra ID enterprise app.

<p align="center"><img src="screenshots/22-entra-id-enterprise-app-redirect-uri.png" alt="Entra - Enterprise app redirect URI" width="900"/></p>

<p align="center"><img src="screenshots/23-entra-id-redirect-uri-add.png" alt="Entra - Add redirect URI" width="900"/></p>

<p align="center"><img src="screenshots/24-entra-id-redirect-uri-configured.png" alt="Entra - Redirect URI configured" width="900"/></p>

<p align="center"><img src="screenshots/25-entra-id-redirect-uri-confirmed.png" alt="Entra - Redirect URI confirmed" width="900"/></p>

Validate the OAuth token in Central NAC.

<p align="center"><img src="screenshots/18-aruba-central-nac-identity-store-oauth-token.png" alt="Central NAC - OAuth token validated" width="900"/></p>

---

### 2.2 Create NAC roles

Navigate to:
```
Central NAC → Configuration → Roles → Create Role
```

<p align="center"><img src="screenshots/26-aruba-central-nac-roles-create.png" alt="Central NAC - Create role" width="900"/></p>

<p align="center"><img src="screenshots/27-aruba-central-nac-roles-list.png" alt="Central NAC - Roles list" width="900"/></p>

<p align="center"><img src="screenshots/28-aruba-central-nac-roles-scope.png" alt="Central NAC - Role scope" width="900"/></p>

---

### 2.3 Configure global NAC policy

Navigate to:
```
Central NAC → Configuration → Policies → Global Policy
```

<p align="center"><img src="screenshots/29-aruba-central-nac-global-policy.png" alt="Central NAC - Global policy" width="900"/></p>

<p align="center"><img src="screenshots/30-aruba-central-nac-policy-rules.png" alt="Central NAC - Policy rules" width="900"/></p>

<p align="center"><img src="screenshots/31-aruba-central-nac-policy-roles-rules.png" alt="Central NAC - Policy roles and rules" width="900"/></p>

---

### 2.4 Create 802.1X SSID profile

Navigate to:
```
Aruba Central → Configuration → WLANs → Create SSID
```

Configure the SSID with **WPA3-Enterprise / 802.1X**.

<p align="center"><img src="screenshots/32-aruba-central-ssid-profile-create.png" alt="Central - Create SSID profile" width="900"/></p>

<p align="center"><img src="screenshots/33-aruba-central-ssid-profile-config.png" alt="Central - SSID profile config" width="900"/></p>

<p align="center"><img src="screenshots/34-aruba-central-ssid-profile-device-scope.png" alt="Central - SSID device scope" width="900"/></p>

---

### 2.5 Create authorization policy

Navigate to:
```
Central NAC → Configuration → Authorization Policies → Create
```

<p align="center"><img src="screenshots/35-aruba-central-nac-authorization-policy-create.png" alt="Central NAC - Create authorization policy" width="900"/></p>

<p align="center"><img src="screenshots/36-aruba-central-nac-authorization-policy-config1.png" alt="Central NAC - Auth policy config 1" width="900"/></p>

<p align="center"><img src="screenshots/37-aruba-central-nac-authorization-policy-config2.png" alt="Central NAC - Auth policy config 2" width="900"/></p>

---

### 2.6 Create EAP-TLS authentication profile

Navigate to:
```
Central NAC → Configuration → Authentication Profiles → Create Profile
```

Configure with **EAP-TLS** and the Intune Identity Store.

<p align="center"><img src="screenshots/38-aruba-central-nac-auth-profile-create.png" alt="Central NAC - Create auth profile" width="900"/></p>

<p align="center"><img src="screenshots/39-aruba-central-nac-auth-profile-config1.png" alt="Central NAC - Auth profile config 1" width="900"/></p>

<p align="center"><img src="screenshots/40-aruba-central-nac-auth-profile-config2.png" alt="Central NAC - Auth profile config 2" width="900"/></p>

<p align="center"><img src="screenshots/41-aruba-central-nac-auth-profile-config3.png" alt="Central NAC - Auth profile config 3" width="900"/></p>

---

### 2.7 Verify Intune UEM connection

The Intune connection must show **green** status in Central NAC.

<p align="center"><img src="screenshots/42-aruba-central-nac-uem-intune-green.png" alt="Central NAC - Intune UEM green status" width="900"/></p>

---

### 2.8 Retrieve SCEP URL and root CA certificate

Navigate to:
```
Central NAC → Configuration → SCEP
```

<p align="center"><img src="screenshots/43-aruba-central-nac-scep-url.png" alt="Central NAC - SCEP URL" width="900"/></p>

Download the root CA certificate — required for the Trusted Certificate profile in Intune.

<p align="center"><img src="screenshots/44-aruba-central-nac-scep-certificate-download.png" alt="Central NAC - Download SCEP CA certificate" width="900"/></p>

> [!NOTE]
> Keep both the **SCEP URL** and the **root CA certificate** — they are required in [microsoft-intune / eap-tls](https://github.com/Luconik/microsoft-intune/tree/main/eap-tls) for each platform guide.

---

## Part 3 — Validation

Navigate to:
```
Central NAC → Monitoring → Clients
```

Authenticated clients should appear with their assigned NAC role.

**Windows**

<p align="center"><img src="screenshots/68-test-aruba-central-nac-monitoring-clients.png" alt="Central NAC - Monitoring clients" width="900"/></p>

<p align="center"><img src="screenshots/69-test-aruba-central-nac-monitoring-clients-list.png" alt="Central NAC - Clients list" width="900"/></p>

<p align="center"><img src="screenshots/70-test-aruba-central-nac-client-detail.png" alt="Central NAC - Client detail" width="900"/></p>

**macOS**

<p align="center"><img src="screenshots/124-central-nac-clients-accepted.png" alt="Central NAC - macOS client accepted" width="900"/></p>

<p align="center"><img src="screenshots/125-central-nac-client-detail-eap-tls.png" alt="Central NAC - macOS client detail EAP-TLS" width="900"/></p>

**iOS/iPadOS**

<p align="center"><img src="screenshots/221-central-nac-monitoring-global.png" alt="Central NAC - Monitoring global" width="900"/></p>

<p align="center"><img src="screenshots/222-central-nac-clients-accepted.png" alt="Central NAC - iOS client accepted" width="900"/></p>

<p align="center"><img src="screenshots/223-central-nac-client-detail-accepted.png" alt="Central NAC - iOS client detail" width="900"/></p>

For each platform, the client detail should show:

| Field | Expected value |
|---|---|
| Status | Accepted |
| Authentication Type | EAP-TLS (Certificate) |
| Certificate Status | Valid |
| Identity Store | Luconik_EntraID |
| Assigned Role | per authorization policy |

---

## References

- 📘 [Aruba Central NAC — UEM Onboarding with Intune](https://arubanetworking.hpe.com/techdocs/NAC/central-nac/central-nac-uem-onboarding-intune/)
- [Aruba Central Documentation](https://www.arubanetworks.com/techdocs/central/latest/content/)
- [Microsoft Intune — SCEP Certificate Profiles](https://learn.microsoft.com/en-us/mem/intune/protect/certificates-scep-configure)
- [Microsoft Entra ID — App Registration](https://learn.microsoft.com/en-us/entra/identity-platform/quickstart-register-app)
- [microsoft-intune / prerequisites](https://github.com/Luconik/microsoft-intune/tree/main/prerequisites) — Entra ID App Registration + APNs
- [microsoft-intune / eap-tls](https://github.com/Luconik/microsoft-intune/tree/main/eap-tls) — Intune profiles + enrollment per platform

---

## File structure

```
central-nac-intune/
├── README.md               ← This file (EN)
├── README-fr.md            ← French version
└── screenshots/
    ├── 00-aruba-central-nac-banner.png
    ├── 15-aruba-central-intune-extension-menu.png
    ├── ...
    ├── 44-aruba-central-nac-scep-certificate-download.png
    ├── 68-test-aruba-central-nac-monitoring-clients.png
    ├── 69-test-aruba-central-nac-monitoring-clients-list.png
    ├── 70-test-aruba-central-nac-client-detail.png
    ├── 124-central-nac-clients-accepted.png
    ├── 125-central-nac-client-detail-eap-tls.png
    ├── 221-central-nac-monitoring-global.png
    ├── 222-central-nac-clients-accepted.png
    └── 223-central-nac-client-detail-accepted.png
```

---

*Last updated: May 2026 — [@Luconik](https://github.com/Luconik)*
