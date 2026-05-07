# Aruba Central NAC — Microsoft Intune Integration (802.1X / SCEP)

> 🇫🇷 [Français](README-fr.md) | 🇬🇧 English

---


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

## File structure

```
central-nac-intune/
├── README.md                           ← General index
├── windows/
│   ├── README.md                       ← This file (EN)
│   ├── README-fr.md                    ← French version
│   └── screenshots/
│       ├── 00-aruba-central-nac-banner.png
│       ├── 01-entra-id-custom-domain-add.png
│       ├── ...
│       └── 70-test-aruba-central-nac-client-detail.png
├── macos/
│   ├── README.md                       ← macOS guide (EN)
│   ├── README-fr.md                    ← macOS guide (FR)
│   └── screenshots/                    ← Screenshots 71 → 130
│       └── fr/
└── ios/
    ├── README.md                       ← Coming soon
    └── screenshots/
```

---

*Last updated: May 2026 — [@Luconik](https://github.com/Luconik)*