# Aruba Central NAC — EAP-TLS with Microsoft Intune (Windows)

> 🇫🇷 [Français](README-fr.md) | 🇬🇧 English

![Platform](https://img.shields.io/badge/platform-Windows%2010%2F11-lightgrey?logo=windows)
![Central NAC](https://img.shields.io/badge/HPE%20Aruba%20Central%20NAC-required-FF6600?logo=hpe)
![Auth](https://img.shields.io/badge/auth-EAP--TLS%20%2F%20802.1X-green)
![Last updated](https://img.shields.io/badge/updated-May%202026-orange)

---

## Table of contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Part 1 — Microsoft Entra ID](#part-1--microsoft-entra-id)
- [Part 2 — Aruba Central — Intune Extension](#part-2--aruba-central--intune-extension)
- [Part 3 — Aruba Central NAC Configuration](#part-3--aruba-central-nac-configuration)
- [Part 4 — Validation in Central NAC](#part-4--validation-in-central-nac)
- [References](#references)

---

## Overview

This guide covers the **Aruba Central NAC** side of the EAP-TLS configuration — Entra ID App Registration, NAC identity store, roles, authorization policies, SSID, SCEP configuration, and result validation.

```
Windows endpoint (Intune-managed)
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
> This guide covers Central NAC configuration only. For the Microsoft Intune side (Trusted Certificate, SCEP, and Wi-Fi profiles), see [microsoft-intune / eap-tls / windows](https://github.com/Luconik/microsoft-intune/tree/main/eap-tls/windows).

---

## Prerequisites

- Active **HPE GreenLake** workspace with **Aruba Central** deployed
- **Microsoft Entra ID** tenant with Global Admin rights
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

## Part 1 — Microsoft Entra ID

### 1.1 Add and verify a custom domain

Navigate to:
```
Entra ID → Custom domains → + Add custom domain
```

<p align="center"><img src="screenshots/01-entra-id-custom-domain-add.png" alt="Entra - Add custom domain" width="900"/></p>

Add the TXT verification record to your DNS registrar.

<p align="center"><img src="screenshots/02-entra-id-custom-domain-txt-record.png" alt="Entra - TXT verification record" width="900"/></p>

<p align="center"><img src="screenshots/03-entra-id-custom-domain-portal.png" alt="Entra - Custom domain in portal" width="900"/></p>

<p align="center"><img src="screenshots/04-dns-registrar-records.png" alt="DNS - Registrar records" width="900"/></p>

<p align="center"><img src="screenshots/05-dns-registrar-txt-record-add.png" alt="DNS - Add TXT record" width="900"/></p>

Return to Entra ID and click **Verify**.

<p align="center"><img src="screenshots/06-entra-id-custom-domain-verify.png" alt="Entra - Verify domain" width="900"/></p>

---

### 1.2 Verify Intune CNAME DNS records

Required for automatic device enrollment in Intune.

<p align="center"><img src="screenshots/07-intune-dns-cname-records.png" alt="Intune - DNS CNAME records" width="900"/></p>

---

### 1.3 Create an App Registration

Navigate to:
```
Entra ID → App registrations → + New registration
```

<p align="center"><img src="screenshots/08-entra-id-app-registration-new.png" alt="Entra - New App Registration" width="900"/></p>

Configure the redirect URI.

<p align="center"><img src="screenshots/09-entra-id-app-registration-redirect-uri.png" alt="Entra - Redirect URI" width="900"/></p>

---

### 1.4 Create a Client Secret

Navigate to:
```
Application → Certificates & secrets → + New client secret
```

<p align="center"><img src="screenshots/10-entra-id-client-secret-new.png" alt="Entra - New client secret" width="900"/></p>

> [!WARNING]
> Copy the **value** immediately — it won't be shown again after you leave this page.

<p align="center"><img src="screenshots/11-entra-id-client-secret-value.png" alt="Entra - Client secret value" width="900"/></p>

<p align="center"><img src="screenshots/12-entra-id-client-secret-overview.png" alt="Entra - Client secret overview" width="900"/></p>

---

### 1.5 Add API permissions

Navigate to:
```
Application → API permissions → + Add permission → Microsoft Graph → Intune
```

<p align="center"><img src="screenshots/13-entra-id-api-permissions-add.png" alt="Entra - Add API permissions" width="900"/></p>

<p align="center"><img src="screenshots/14-entra-id-api-permissions-graph-intune.png" alt="Entra - Graph + Intune permissions" width="900"/></p>

---

## Part 2 — Aruba Central — Intune Extension

### 2.1 Install the Microsoft Intune extension

Navigate to:
```
Aruba Central → Extensions → Available Extensions → Microsoft Intune → Install
```

<p align="center"><img src="screenshots/15-aruba-central-intune-extension-menu.png" alt="Central - Extensions menu" width="900"/></p>

<p align="center"><img src="screenshots/16-aruba-central-intune-extension-install.png" alt="Central - Install Intune extension" width="900"/></p>

---

### 2.2 Configure the Intune extension

Enter the App Registration credentials:

| Field | Value |
|---|---|
| Tenant ID | From Entra ID overview |
| Client ID | Application (client) ID |
| Client Secret | Value copied in step 1.4 |

<p align="center"><img src="screenshots/17-aruba-central-intune-extension-config.png" alt="Central - Configure Intune extension" width="900"/></p>

---

## Part 3 — Aruba Central NAC Configuration

### 3.1 Configure OAuth Identity Store

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

### 3.2 Create NAC roles

Navigate to:
```
Central NAC → Configuration → Roles → Create Role
```

<p align="center"><img src="screenshots/26-aruba-central-nac-roles-create.png" alt="Central NAC - Create role" width="900"/></p>

<p align="center"><img src="screenshots/27-aruba-central-nac-roles-list.png" alt="Central NAC - Roles list" width="900"/></p>

<p align="center"><img src="screenshots/28-aruba-central-nac-roles-scope.png" alt="Central NAC - Role scope" width="900"/></p>

---

### 3.3 Configure global NAC policy

Navigate to:
```
Central NAC → Configuration → Policies → Global Policy
```

<p align="center"><img src="screenshots/29-aruba-central-nac-global-policy.png" alt="Central NAC - Global policy" width="900"/></p>

<p align="center"><img src="screenshots/30-aruba-central-nac-policy-rules.png" alt="Central NAC - Policy rules" width="900"/></p>

<p align="center"><img src="screenshots/31-aruba-central-nac-policy-roles-rules.png" alt="Central NAC - Policy roles and rules" width="900"/></p>

---

### 3.4 Create 802.1X SSID profile

Navigate to:
```
Aruba Central → Configuration → WLANs → Create SSID
```

Configure the SSID with **WPA3-Enterprise / 802.1X**.

<p align="center"><img src="screenshots/32-aruba-central-ssid-profile-create.png" alt="Central - Create SSID profile" width="900"/></p>

<p align="center"><img src="screenshots/33-aruba-central-ssid-profile-config.png" alt="Central - SSID profile config" width="900"/></p>

<p align="center"><img src="screenshots/34-aruba-central-ssid-profile-device-scope.png" alt="Central - SSID device scope" width="900"/></p>

---

### 3.5 Create authorization policy

Navigate to:
```
Central NAC → Configuration → Authorization Policies → Create
```

<p align="center"><img src="screenshots/35-aruba-central-nac-authorization-policy-create.png" alt="Central NAC - Create authorization policy" width="900"/></p>

<p align="center"><img src="screenshots/36-aruba-central-nac-authorization-policy-config1.png" alt="Central NAC - Auth policy config 1" width="900"/></p>

<p align="center"><img src="screenshots/37-aruba-central-nac-authorization-policy-config2.png" alt="Central NAC - Auth policy config 2" width="900"/></p>

---

### 3.6 Create EAP-TLS authentication profile

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

### 3.7 Verify Intune UEM connection

The Intune connection must show **green** status in Central NAC.

<p align="center"><img src="screenshots/42-aruba-central-nac-uem-intune-green.png" alt="Central NAC - Intune UEM green status" width="900"/></p>

---

### 3.8 Retrieve SCEP URL and root CA certificate

Navigate to:
```
Central NAC → Configuration → SCEP
```

<p align="center"><img src="screenshots/43-aruba-central-nac-scep-url.png" alt="Central NAC - SCEP URL" width="900"/></p>

Download the root CA certificate — required for the Trusted Certificate profile in Intune.

<p align="center"><img src="screenshots/44-aruba-central-nac-scep-certificate-download.png" alt="Central NAC - Download SCEP CA certificate" width="900"/></p>

> [!NOTE]
> Keep both the **SCEP URL** and the **root CA certificate** — they are required in [microsoft-intune / eap-tls / windows](https://github.com/Luconik/microsoft-intune/tree/main/eap-tls/windows) steps 1.1 and 1.2.

---

## Part 4 — Validation in Central NAC

Navigate to:
```
Central NAC → Monitoring → Clients
```

Authenticated clients should appear with their assigned NAC role.

<p align="center"><img src="screenshots/68-test-aruba-central-nac-monitoring-clients.png" alt="Central NAC - Monitoring clients" width="900"/></p>

<p align="center"><img src="screenshots/69-test-aruba-central-nac-monitoring-clients-list.png" alt="Central NAC - Clients list" width="900"/></p>

Click a client to view the detail — verify the assigned role and authentication type.

<p align="center"><img src="screenshots/70-test-aruba-central-nac-client-detail.png" alt="Central NAC - Client detail" width="900"/></p>

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

---

## File structure

```
central-nac-intune/windows/
├── README.md               ← This file (EN)
├── README-fr.md            ← French version
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

*Last updated: May 2026 — [@Luconik](https://github.com/Luconik)*
