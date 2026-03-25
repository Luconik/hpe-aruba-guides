# HPE Aruba Guides
# HPE Aruba Guides

> 🇫🇷 [Français](#fr) | 🇬🇧 [English](#en)

---

<a name="fr"></a>
## 🇫🇷 Français

### Présentation

Ce repo regroupe des guides pratiques sur les solutions **HPE Aruba Networking** : création de compte, configuration de la plateforme GreenLake, déploiement d'Aruba Central et intégration avec Microsoft Intune pour le NAC (Network Access Control).

Ces guides sont issus d'expériences terrain et de labs personnels. Ils s'adressent aussi bien aux administrateurs réseau qu'aux architectes sécurité souhaitant déployer ou tester les solutions HPE Aruba.

---

### Contenu

| Dossier | Description | Statut |
|---------|-------------|--------|
| [`greenlake-workspace/`](greenlake-workspace/) | Création d'un compte HPE NSP, workspace GreenLake et déploiement du service Aruba Central | ✅ Disponible |
| [`greenlake-sso/`](greenlake-sso/) | Configuration du SSO (Single Sign-On) sur HPE GreenLake | 🔜 À venir |
| [`central-nac-intune/`](central-nac-intune/) | Intégration Aruba Central NAC + Microsoft Intune (802.1X / SCEP) | 🔜 À venir |

---

### Prérequis généraux

- Une adresse e-mail professionnelle ou sur domaine personnalisé (ex. `@votre-domaine.com`)
- Un compte HPE Networking Support Portal (NSP) — voir [`greenlake-workspace/`](greenlake-workspace/)
- Un workspace HPE GreenLake actif

---

### Références

- [HPE Networking Support Portal](https://networkingsupport.hpe.com)
- [HPE GreenLake Platform](https://common.cloud.hpe.com)
- [Aruba Central TechDocs](https://www.arubanetworks.com/techdocs/central/latest/content/)
- [HPE Aruba NAC + Intune — TechDocs officiel](https://arubanetworking.hpe.com/techdocs/NAC/central-nac/central-nac-uem-onboarding-intune/)

---
---

<a name="en"></a>
## 🇬🇧 English

### Overview

This repository contains practical guides for **HPE Aruba Networking** solutions: account creation, GreenLake platform setup, Aruba Central deployment, and Microsoft Intune integration for NAC (Network Access Control).

These guides are based on real-world experience and personal lab work. They target network administrators and security architects looking to deploy or test HPE Aruba solutions.

---

### Contents

| Folder | Description | Status |
|--------|-------------|--------|
| [`greenlake-workspace/`](greenlake-workspace/) | HPE NSP account creation, GreenLake workspace setup, and Aruba Central service deployment | ✅ Available |
| [`greenlake-sso/`](greenlake-sso/) | SSO (Single Sign-On) configuration on HPE GreenLake | 🔜 Coming soon |
| [`central-nac-intune/`](central-nac-intune/) | Aruba Central NAC + Microsoft Intune integration (802.1X / SCEP) | 🔜 Coming soon |

---

### General prerequisites

- A professional or custom-domain email address (e.g. `@your-domain.com`)
- An HPE Networking Support Portal (NSP) account — see [`greenlake-workspace/`](greenlake-workspace/)
- An active HPE GreenLake workspace

---

### References

- [HPE Networking Support Portal](https://networkingsupport.hpe.com)
- [HPE GreenLake Platform](https://common.cloud.hpe.com)
- [Aruba Central TechDocs](https://www.arubanetworks.com/techdocs/central/latest/content/)
- [HPE Aruba NAC + Intune — Official TechDocs](https://arubanetworking.hpe.com/techdocs/NAC/central-nac/central-nac-uem-onboarding-intune/)

---

## Structure

```
hpe-aruba-guides/
├── README.md                    ← This file / Ce fichier
├── greenlake-workspace/
│   ├── README.md
│   └── screenshots/
├── greenlake-sso/
└── central-nac-intune/
```

---

*Last updated: March 2026 — [@Luconik](https://github.com/Luconik)*
