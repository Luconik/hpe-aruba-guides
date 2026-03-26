<div align="center">

# hpe-aruba-guides

**Guides pratiques HPE Aruba Networking — GreenLake · Central NAC · Intune · SSO**

[![GitHub](https://img.shields.io/badge/GitHub-Luconik-181717?style=flat-square&logo=github)](https://github.com/Luconik)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-nicolasculetto-0077B5?style=flat-square&logo=linkedin)](https://www.linkedin.com/in/nicolasculetto/)
[![HPE TechDocs](https://img.shields.io/badge/HPE-TechDocs-01A982?style=flat-square)](https://arubanetworking.hpe.com/techdocs/NAC/central-nac/central-nac-uem-onboarding-intune/)

> 🇫🇷 [Français](#fr) | 🇬🇧 [English](#en)

</div>

---

<a name="fr"></a>
## 🇫🇷 Français

### Présentation

Ce repo regroupe des guides pratiques sur les solutions **HPE Aruba Networking** : création de compte, configuration de la plateforme GreenLake, déploiement d'Aruba Central, SSO avec Microsoft Entra ID, et intégration NAC avec Microsoft Intune.

Ces guides sont issus d'expériences terrain et de labs personnels. Ils s'adressent aussi bien aux administrateurs réseau qu'aux architectes sécurité souhaitant déployer ou tester les solutions HPE Aruba.

---

### Guides disponibles

| Dossier | Description | Statut |
|---------|-------------|--------|
| [`nsp-account/`](nsp-account/) | Création d'un compte HPE Networking Support Portal (NSP) | ✅ |
| [`greenlake-workspace/`](greenlake-workspace/) | Création d'un workspace HPE GreenLake + déploiement Aruba Central | ✅ |
| [`greenlake-sso/`](greenlake-sso/) | Configuration SSO GreenLake avec Microsoft Entra ID (SAML 2.0) | ✅ |
| [`central-nac-intune/`](central-nac-intune/) | Aruba Central NAC + Microsoft Intune — 802.1X EAP-TLS / SCEP | ✅ |

---

### Parcours recommandé

```
1. nsp-account/          ← Créer le compte HPE NSP (prérequis tout)
        │
        ▼
2. greenlake-workspace/  ← Créer le workspace GreenLake + déployer Central
        │
        ├──▶ 3. greenlake-sso/       ← SSO Entra ID (optionnel mais recommandé)
        │
        └──▶ 4. central-nac-intune/  ← NAC 802.1X EAP-TLS avec Intune
```

---

### Prérequis généraux

- Une adresse e-mail professionnelle ou sur domaine personnalisé
- Un compte HPE Networking Support Portal (NSP) — voir [`nsp-account/`](nsp-account/)
- Un workspace HPE GreenLake actif — voir [`greenlake-workspace/`](greenlake-workspace/)

---

### Références officielles

| Ressource | URL |
|-----------|-----|
| HPE Networking Support Portal | [networkingsupport.hpe.com](https://networkingsupport.hpe.com) |
| HPE GreenLake Platform | [common.cloud.hpe.com](https://common.cloud.hpe.com) |
| Aruba Central TechDocs | [arubanetworks.com/techdocs](https://www.arubanetworks.com/techdocs/central/latest/content/) |
| 📘 TechNote NAC + Intune (officielle HPE) | [arubanetworking.hpe.com/techdocs/NAC/...](https://arubanetworking.hpe.com/techdocs/NAC/central-nac/central-nac-uem-onboarding-intune/) |

---

### Repos liés

| Repo | Description |
|------|-------------|
| [`homelab-setup`](https://github.com/Luconik/homelab-setup) | Infrastructure homelab (Proxmox, EVE-NG, Docker) |
| [`netdevops`](https://github.com/Luconik/netdevops) | Ansible + Terraform AOS-CX + GitLab CI/CD |

---
---

<a name="en"></a>
## 🇬🇧 English

### Overview

This repository contains practical guides for **HPE Aruba Networking** solutions: account creation, GreenLake platform setup, Aruba Central deployment, SSO with Microsoft Entra ID, and NAC integration with Microsoft Intune.

---

### Available guides

| Folder | Description | Status |
|--------|-------------|--------|
| [`nsp-account/`](nsp-account/) | HPE Networking Support Portal (NSP) account creation | ✅ |
| [`greenlake-workspace/`](greenlake-workspace/) | HPE GreenLake workspace + Aruba Central deployment | ✅ |
| [`greenlake-sso/`](greenlake-sso/) | GreenLake SSO with Microsoft Entra ID (SAML 2.0) | ✅ |
| [`central-nac-intune/`](central-nac-intune/) | Aruba Central NAC + Microsoft Intune — 802.1X EAP-TLS / SCEP | ✅ |

---

### Recommended path

```
1. nsp-account/          ← Create HPE NSP account (prerequisite for everything)
        │
        ▼
2. greenlake-workspace/  ← Create GreenLake workspace + deploy Central
        │
        ├──▶ 3. greenlake-sso/       ← Entra ID SSO (optional but recommended)
        │
        └──▶ 4. central-nac-intune/  ← NAC 802.1X EAP-TLS with Intune
```

---

### Official references

| Resource | URL |
|----------|-----|
| HPE Networking Support Portal | [networkingsupport.hpe.com](https://networkingsupport.hpe.com) |
| HPE GreenLake Platform | [common.cloud.hpe.com](https://common.cloud.hpe.com) |
| Aruba Central TechDocs | [arubanetworks.com/techdocs](https://www.arubanetworks.com/techdocs/central/latest/content/) |
| 📘 Official HPE TechNote NAC + Intune | [arubanetworking.hpe.com/techdocs/NAC/...](https://arubanetworking.hpe.com/techdocs/NAC/central-nac/central-nac-uem-onboarding-intune/) |

---

### Related repos

| Repo | Description |
|------|-------------|
| [`homelab-setup`](https://github.com/Luconik/homelab-setup) | Homelab infrastructure (Proxmox, EVE-NG, Docker) |
| [`netdevops`](https://github.com/Luconik/netdevops) | Ansible + Terraform AOS-CX + GitLab CI/CD |

---

*Last updated: March 2026 — [@Luconik](https://github.com/Luconik)*
