# Aruba Central NAC — Microsoft Intune Integration (802.1X / EAP-TLS)

> 🇫🇷 [Français](#fr) | 🇬🇧 [English](#en)

---

<a name="fr"></a>
## 🇫🇷 Français

### Présentation

Ce dépôt documente l'intégration complète d'**Aruba Central NAC** avec **Microsoft Intune** pour l'authentification **802.1X EAP-TLS** par certificat SCEP, déclinée sur trois plateformes.

### Guides disponibles

| Plateforme | Guide | Statut |
|------------|-------|--------|
| 🖥️ **Windows** | [`windows/`](windows/) | ✅ Disponible |
| 🍎 **macOS** | [`macos/`](macos/) | ✅ Disponible |
| 📱 **iOS / iPadOS** | [`ios/`](ios/) | 🔜 À venir |

### Architecture globale

```
Endpoint (Windows / macOS / iOS)
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

### Prérequis communs

- Workspace **HPE GreenLake** actif avec **Aruba Central** déployé
- Tenant **Microsoft Entra ID** avec droits Global Admin
- Licence **Microsoft Intune** active
- Domaine DNS personnalisé vérifié dans Entra ID
- Points d'accès Aruba gérés dans Aruba Central
- SSID 802.1X configuré dans Aruba Central

> 📎 Prérequis GreenLake : voir [`../greenlake-workspace/`](../greenlake-workspace/)  
> 📎 SSO GreenLake (optionnel) : voir [`../greenlake-sso/`](../greenlake-sso/)

### Structure du dépôt

```
central-nac-intune/
├── README.md               ← Ce fichier / This file
├── windows/
│   ├── README.md           ← Guide Windows (FR + EN)
│   └── screenshots/        ← Captures 00 → 70
├── macos/
│   ├── README.md           ← Guide macOS (EN)
│   ├── README-fr.md        ← Guide macOS (FR)
│   └── screenshots/        ← Captures 71 → 130
│       └── fr/             ← Captures FR
└── ios/
    ├── README.md           ← Guide iOS (EN) — à venir
    ├── README-fr.md        ← Guide iOS (FR) — à venir
    └── screenshots/        ← À venir
```

---

<a name="en"></a>
## 🇬🇧 English

### Overview

This repository documents the complete integration of **Aruba Central NAC** with **Microsoft Intune** for **802.1X EAP-TLS** certificate-based authentication via SCEP, across three platforms.

### Available guides

| Platform | Guide | Status |
|----------|-------|--------|
| 🖥️ **Windows** | [`windows/`](windows/) | ✅ Available |
| 🍎 **macOS** | [`macos/`](macos/) | ✅ Available |
| 📱 **iOS / iPadOS** | [`ios/`](ios/) | 🔜 Coming soon |

### Global architecture

```
Endpoint (Windows / macOS / iOS)
    │
    │  SCEP certificate issued by Central NAC
    ▼
Aruba AP (802.1X EAP-TLS)
    │
    │  RADIUS authentication
    ▼
Aruba Central NAC
    │
    │  Compliance check via OAuth2
    ▼
Microsoft Intune (Entra ID)
    │
    ▼
Network access granted (role per NAC policy)
```

### Common prerequisites

- Active **HPE GreenLake** workspace with **Aruba Central** deployed
- **Microsoft Entra ID** tenant with Global Admin rights
- Active **Microsoft Intune** licence
- Custom DNS domain verified in Entra ID
- Aruba access points managed in Aruba Central
- 802.1X SSID configured in Aruba Central

> 📎 GreenLake prerequisites: see [`../greenlake-workspace/`](../greenlake-workspace/)  
> 📎 GreenLake SSO (optional): see [`../greenlake-sso/`](../greenlake-sso/)

### Repository structure

```
central-nac-intune/
├── README.md               ← This file / Ce fichier
├── windows/
│   ├── README.md           ← Windows guide (FR + EN)
│   └── screenshots/        ← Screenshots 00 → 70
├── macos/
│   ├── README.md           ← macOS guide (EN)
│   ├── README-fr.md        ← macOS guide (FR)
│   └── screenshots/        ← Screenshots 71 → 130
│       └── fr/             ← FR screenshots
└── ios/
    ├── README.md           ← iOS guide (EN) — coming soon
    ├── README-fr.md        ← iOS guide (FR) — coming soon
    └── screenshots/        ← Coming soon
```

---

## References

- 📘 [Aruba Central NAC — UEM Onboarding with Intune](https://arubanetworking.hpe.com/techdocs/NAC/central-nac/central-nac-uem-onboarding-intune/)
- [Microsoft Intune — SCEP Certificate Profiles](https://learn.microsoft.com/en-us/mem/intune/protect/certificates-scep-configure)
- [Microsoft Intune — Apple MDM Push Certificate](https://learn.microsoft.com/en-us/mem/intune/enrollment/apple-mdm-push-certificate-get)
- [Aruba Central Documentation](https://www.arubanetworks.com/techdocs/central/latest/content/)

---

*Last updated: May 2026 — [@Luconik](https://github.com/Luconik)*
