# Aruba Central NAC — macOS Onboarding with Microsoft Intune (802.1X / EAP-TLS)

> 🇫🇷 [Français](README-fr.md) | 🇬🇧 English

---

## Overview

This guide documents the complete configuration of **Aruba Central NAC** with **Microsoft Intune** for macOS devices, enabling **802.1X EAP-TLS** certificate-based authentication via SCEP.

> 📎 Prerequisites (Entra ID, Central NAC, SSID, roles, policies): see [`../windows/`](../windows/)  
> These steps are identical for macOS — only the Intune profiles differ.

```
macOS endpoint (Intune-enrolled)
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

---

## Prerequisites

- Aruba Central NAC fully configured (see [`../windows/`](../windows/))
- Microsoft Intune tenant active
- **Apple MDM Push Certificate** configured in Intune (see Part 0 below)
- macOS device with macOS 14 Sonoma or later
- Microsoft **Company Portal** app installed on the device

---

## Part 0 — Apple MDM Push Certificate

Before enrolling any Apple device in Intune, an Apple MDM Push Certificate must be configured. This is a one-time prerequisite for the entire Apple ecosystem (macOS + iOS).

### 0.1 Open Apple enrollment in Intune

```
Intune Admin Center → Devices → Enrollment → Apple tab
```

![Intune - Apple enrollment tab](screenshots/71-intune-apns-enrollment-apple-tab.png)

Click **Apple MDM Push Certificate**.

---

### 0.2 Configure MDM Push Certificate — agree and download CSR

Check **I agree** to grant Microsoft permission to send data to Apple, then click **Download your CSR**.

![Intune - Configure MDM Push Certificate](screenshots/72-intune-apns-configure-mdm-push-agree.png)

---

### 0.3 Sign in to Apple Push Certificates Portal

Go to [https://identity.apple.com](https://identity.apple.com) and sign in with a corporate Apple ID.

![Apple ID - Sign in](screenshots/73-intune-apns-apple-id-login.png)

---

### 0.4 Create a new Push Certificate

In the Apple Push Certificates Portal, click **Create a Certificate**.

![Apple Push Portal - Existing certificates](screenshots/74-intune-apns-push-portal-existing-certs.png)

Accept the Terms of Use.

![Apple Push Portal - Terms of Use](screenshots/75-intune-apns-push-portal-terms.png)

![Apple Push Portal - Terms accepted](screenshots/76-intune-apns-push-portal-terms-accepted.png)

---

### 0.5 Upload the CSR and download the certificate

Upload the `IntuneCSR.csr` file downloaded in step 0.2, then click **Upload**.

![Apple Push Portal - Upload CSR](screenshots/77-intune-apns-push-portal-upload-csr.png)

Download the generated `.pem` certificate.

![Apple Push Portal - Confirmation](screenshots/78-intune-apns-push-portal-confirmation.png)

---

### 0.6 Upload the certificate back to Intune

Back in Intune, enter the Apple ID used, upload the `.pem` file, then click **Upload**.

![Intune - Upload MDM Push Certificate](screenshots/79-intune-apns-configure-mdm-push-upload-pem.png)

The certificate is now configured and active.

![Intune - MDM Push Certificate configured](screenshots/80-intune-apns-configure-mdm-push-configured.png)

---

## Part 1 — Intune Configuration Profiles for macOS

Three profiles must be created in Intune, in order:

| # | Profile type | Name | Purpose |
|---|-------------|------|---------|
| 1 | Trusted Certificate | `Luconik Trusted - macOS` | Deploy the Central NAC root CA |
| 2 | SCEP Certificate | `Luconik SCEP - macOS` | Request client certificate from Central NAC |
| 3 | Wi-Fi | `Luconik Wi-Fi - macOS` | Configure 802.1X EAP-TLS on the SSID |

---

### 1.1 Create Trusted Certificate profile

```
Intune Admin Center → Devices → macOS → Configuration → + Create → Templates → Trusted certificate
```

![Intune - Select Trusted certificate template](screenshots/81-intune-macos-trusted-profile-select.png)

**Basics** — Name: `Luconik Trusted - macOS`

![Intune - Trusted certificate basics](screenshots/82-intune-macos-trusted-basics.png)

**Configuration settings** — Upload the root CA certificate (`.cer`) downloaded from Central NAC.  
Set **Deployment Channel** to `Device Channel`.

![Intune - Trusted certificate — upload CA cert](screenshots/83-intune-macos-trusted-config-cert-uploaded.png)

**Assignments** — leave empty for now.

![Intune - Trusted certificate assignments](screenshots/84-intune-macos-trusted-assignments.png)

**Review + create** — verify the summary then click **Create**.

![Intune - Trusted certificate review](screenshots/85-intune-macos-trusted-review-create.png)

**Post-creation** — assign to **All devices** and **All users**.

![Intune - Trusted certificate assigned](screenshots/86-intune-macos-trusted-assigned-all.png)

---

### 1.2 Create SCEP Certificate profile

```
Intune Admin Center → Devices → macOS → Configuration → + Create → Templates → SCEP certificate
```

![Intune - Select SCEP certificate template](screenshots/87-intune-macos-scep-profile-select.png)

**Basics** — Name: `Luconik SCEP - macOS`

![Intune - SCEP basics](screenshots/88-intune-macos-scep-basics.png)

**Configuration settings (top)**

| Setting | Value |
|---------|-------|
| Deployment Channel | `Device Channel` |
| Certificate type | `User` |
| Subject name format | `CN={{UserPrincipalName}}` |
| Subject alternative name | `User principal name (UPN)` → `{{UserPrincipalName}}` |
| Certificate validity period | `1 Years` |
| Key usage | `Digital signature` |
| Key size (bits) | `2048` |
| Root Certificate | `Luconik Trusted - macOS` |

![Intune - SCEP config settings top](screenshots/89-intune-macos-scep-config-top.png)

**Configuration settings (bottom)**

| Setting | Value |
|---------|-------|
| Extended key usage | `Client Authentication` — `1.3.6.1.5.5.7.3.2` |
| Renewal threshold (%) | `20` |
| SCEP Server URLs | Central NAC SCEP URL |

![Intune - SCEP config settings bottom](screenshots/90-intune-macos-scep-config-bottom.png)

**Review + create** — verify the full summary.

![Intune - SCEP review top](screenshots/91-intune-macos-scep-review-create-top.png)

![Intune - SCEP review bottom](screenshots/92-intune-macos-scep-review-create-bottom.png)

**Post-creation** — assign to **All devices** and **All users**.

![Intune - SCEP assigned](screenshots/93-intune-macos-scep-assigned-all.png)

---

### 1.3 Create Wi-Fi profile

```
Intune Admin Center → Devices → macOS → Configuration → + Create → Templates → Wi-Fi
```

![Intune - Select Wi-Fi template](screenshots/94-intune-macos-wifi-profile-select.png)

**Basics** — Name: `Luconik Wi-Fi - macOS`

![Intune - Wi-Fi basics](screenshots/95-intune-macos-wifi-basics.png)

**Configuration settings**

| Setting | Value |
|---------|-------|
| SSID | `luconik-corp` |
| Connect automatically | `Enable` |
| Hidden network | `Disable` |
| EAP type | `EAP - TLS` |
| Certificate server names | `luconik` |
| Root certificates for server validation | `Luconik Trusted - macOS` |
| Certificates (client auth) | `Luconik SCEP - macOS` |

![Intune - Wi-Fi config settings](screenshots/96-intune-macos-wifi-config.png)

**Review + create** — verify the full summary.

![Intune - Wi-Fi review](screenshots/97-intune-macos-wifi-review-create.png)

**Post-creation** — assign to **All devices** and **All users**.

![Intune - Wi-Fi assigned](screenshots/98-intune-macos-wifi-assigned-all.png)

---

## Part 2 — macOS Enrollment via Company Portal

### 2.1 Download and install Company Portal

Download the Company Portal `.pkg` from Microsoft:

```
https://go.microsoft.com/fwlink/?linkid=853070
```

![Company Portal - Download installer](screenshots/99-macos-cp-installer-download.png)

Run the installer and follow the wizard.

![Company Portal - Introduction](screenshots/100-macos-cp-install-intro.png)

![Company Portal - License agreement](screenshots/101-macos-cp-install-license.png)

![Company Portal - Accept license](screenshots/102-macos-cp-install-license-agree.png)

![Company Portal - Installation type](screenshots/103-macos-cp-install-type.png)

Authenticate with Touch ID or password to authorize the installation.

![Company Portal - Authentication](screenshots/104-macos-cp-install-auth.png)

![Company Portal - Installation successful](screenshots/105-macos-cp-install-success.png)

Move the installer to Trash when prompted.

![Company Portal - Move installer to Trash](screenshots/106-macos-cp-install-trash-installer.png)

---

### 2.2 Sign in and enroll the device

Open **Company Portal** and click **Sign in**.

![Company Portal - Sign in](screenshots/107-macos-cp-signin.png)

Sign in with the Entra ID / Microsoft 365 corporate account.

Click **Begin** to start device enrollment.

![Company Portal - Set up MSFT access](screenshots/108-macos-cp-setup-begin.png)

Review the privacy information — what the organization can and cannot see.

![Company Portal - Privacy review](screenshots/109-macos-cp-privacy-review.png)

---

### 2.3 Install the management profile

Click **Download profile** in Company Portal.

![Company Portal - Install management profile](screenshots/110-macos-cp-install-mgmt-profile.png)

macOS opens **System Settings → General → Device Management** and shows a notification.

![System Settings - Profile downloaded notification](screenshots/111-macos-syssettings-profile-downloaded.png)

The profile appears as **Not installed** — double-click to review it.

![System Settings - Profile pending](screenshots/112-macos-syssettings-profile-pending.png)

Review the profile details (signed by `IOSProfileSigning.manage.microsoft.com`), then click **Install**.

![System Settings - Profile review](screenshots/113-macos-syssettings-profile-review.png)

Enter the macOS user password to authorize MDM enrollment.

![System Settings - MDM enrollment password](screenshots/114-macos-syssettings-mdm-enroll-password.png)

The profile is now installed. The Mac is **supervised and managed by MSFT**.

![System Settings - Profile enrolled](screenshots/115-macos-syssettings-profile-enrolled.png)

---

### 2.4 Complete enrollment in Company Portal

Return to Company Portal — the profile download completes automatically.

![Company Portal - Profile downloading](screenshots/116-macos-cp-mgmt-profile-downloading.png)

Enrollment is complete.

![Company Portal - You're all set](screenshots/117-macos-cp-enrollment-complete.png)

Select the **device category** when prompted: `RootCA-Installed`.

![Company Portal - Device category](screenshots/118-macos-cp-device-category.png)

![Company Portal - Device category selected](screenshots/119-macos-cp-device-category-selected.png)

---

## Part 3 — Validation

### 3.1 Verify certificates in Keychain Access

Open **Keychain Access** and check the **System** keychain — the Intune MDM Device certificate should be present.

![Keychain Access - System — Intune MDM cert](screenshots/120-macos-keychain-system-intune-cert.png)

In the **login** keychain, verify the presence of:
- `Cloud Authentication Private Root CA (powered by HPE Aruba)` — trusted
- `Cloud Authentication SCEP RA (powered by HPE Aruba)` — RA certificates
- `nicoculetto@luconik.fr` — client certificate (×2, SCEP-issued)

![Keychain Access - Login — Aruba CA and SCEP certs](screenshots/121-macos-keychain-login-aruba-ca-scep.png)

---

### 3.2 Verify profiles in System Settings

```
System Settings → General → Device Management
```

Three profiles should appear under **User (Managed)**:
- `Credential Profile` (Trusted Certificate)
- `SCEP Profile`
- `WiFi Profile`

![System Settings - All profiles deployed](screenshots/122-macos-syssettings-profiles-deployed.png)

---

### 3.3 Verify Wi-Fi connection

The `luconik-corp` SSID should appear as connected with **WPA2 Enterprise** security.

![Wi-Fi - luconik-corp connected WPA2 Enterprise](screenshots/123-macos-wifi-connected-wpa2-enterprise.png)

---

### 3.4 Verify in Aruba Central NAC

```
Central NAC → Monitoring → Clients
```

The enrolled user should appear as **Accepted** with connection type **Wireless**.

![Central NAC - Clients list — Accepted](screenshots/124-central-nac-clients-accepted.png)

Click the client to view the detail:
- **Status**: Accepted
- **Authentication Type**: EAP-TLS (Certificate)
- **Certificate Status**: Valid
- **Assigned Role**: per NAC policy
- **Identity Store**: Luconik_EntraID
- **Vendor / Model/OS**: Apple / Mac OS

![Central NAC - Client detail EAP-TLS](screenshots/125-central-nac-client-detail-eap-tls.png)

---

### 3.5 Verify in Intune Admin Center

```
Intune Admin Center → Devices → macOS devices
```

The device should appear as **Compliant**.

![Intune Admin - macOS devices list](screenshots/126-intune-admin-macos-device-compliant.png)

Click the device to view the overview (serial number, OS version, compliance status).

![Intune Admin - Device overview](screenshots/127-intune-admin-device-overview.png)

Navigate to **Device configuration** — all three profiles should show **Succeeded**.

![Intune Admin - Device configuration profiles succeeded](screenshots/128-intune-admin-device-config-succeeded.png)

---

## References

- 📘 [Aruba Central NAC — UEM Onboarding with Intune](https://arubanetworking.hpe.com/techdocs/NAC/central-nac/central-nac-uem-onboarding-intune/)
- [Microsoft Intune — Apple MDM Push Certificate](https://learn.microsoft.com/en-us/mem/intune/enrollment/apple-mdm-push-certificate-get)
- [Microsoft Intune — SCEP Certificate Profiles](https://learn.microsoft.com/en-us/mem/intune/protect/certificates-scep-configure)
- [Microsoft Intune — macOS enrollment](https://learn.microsoft.com/en-us/mem/intune/enrollment/macos-enroll)
- [Apple Push Certificates Portal](https://identity.apple.com/pushcert/)

---

## File structure

```
macos/
├── README.md               ← This file (EN)
├── README-fr.md            ← French version
└── screenshots/
    ├── 71-intune-apns-enrollment-apple-tab.png
    ├── 72-intune-apns-configure-mdm-push-agree.png
    ├── 73-intune-apns-apple-id-login.png
    ├── 74-intune-apns-push-portal-existing-certs.png
    ├── 75-intune-apns-push-portal-terms.png
    ├── 76-intune-apns-push-portal-terms-accepted.png
    ├── 77-intune-apns-push-portal-upload-csr.png
    ├── 78-intune-apns-push-portal-confirmation.png
    ├── 79-intune-apns-configure-mdm-push-upload-pem.png
    ├── 80-intune-apns-configure-mdm-push-configured.png
    ├── 81-intune-macos-trusted-profile-select.png
    ├── 82-intune-macos-trusted-basics.png
    ├── 83-intune-macos-trusted-config-cert-uploaded.png
    ├── 84-intune-macos-trusted-assignments.png
    ├── 85-intune-macos-trusted-review-create.png
    ├── 86-intune-macos-trusted-assigned-all.png
    ├── 87-intune-macos-scep-profile-select.png
    ├── 88-intune-macos-scep-basics.png
    ├── 89-intune-macos-scep-config-top.png
    ├── 90-intune-macos-scep-config-bottom.png
    ├── 91-intune-macos-scep-review-create-top.png
    ├── 92-intune-macos-scep-review-create-bottom.png
    ├── 93-intune-macos-scep-assigned-all.png
    ├── 94-intune-macos-wifi-profile-select.png
    ├── 95-intune-macos-wifi-basics.png
    ├── 96-intune-macos-wifi-config.png
    ├── 97-intune-macos-wifi-review-create.png
    ├── 98-intune-macos-wifi-assigned-all.png
    ├── 99-macos-cp-installer-download.png
    ├── 100-macos-cp-install-intro.png
    ├── 101-macos-cp-install-license.png
    ├── 102-macos-cp-install-license-agree.png
    ├── 103-macos-cp-install-type.png
    ├── 104-macos-cp-install-auth.png
    ├── 105-macos-cp-install-success.png
    ├── 106-macos-cp-install-trash-installer.png
    ├── 107-macos-cp-signin.png
    ├── 108-macos-cp-setup-begin.png
    ├── 109-macos-cp-privacy-review.png
    ├── 110-macos-cp-install-mgmt-profile.png
    ├── 111-macos-syssettings-profile-downloaded.png
    ├── 112-macos-syssettings-profile-pending.png
    ├── 113-macos-syssettings-profile-review.png
    ├── 114-macos-syssettings-mdm-enroll-password.png
    ├── 115-macos-syssettings-profile-enrolled.png
    ├── 116-macos-cp-mgmt-profile-downloading.png
    ├── 117-macos-cp-enrollment-complete.png
    ├── 118-macos-cp-device-category.png
    ├── 119-macos-cp-device-category-selected.png
    ├── 120-macos-keychain-system-intune-cert.png
    ├── 121-macos-keychain-login-aruba-ca-scep.png
    ├── 122-macos-syssettings-profiles-deployed.png
    ├── 123-macos-wifi-connected-wpa2-enterprise.png
    ├── 124-central-nac-clients-accepted.png
    ├── 125-central-nac-client-detail-eap-tls.png
    ├── 126-intune-admin-macos-device-compliant.png
    ├── 127-intune-admin-device-overview.png
    ├── 128-intune-admin-device-config-succeeded.png
    ├── 129-central-nac-confirm-connection.png
    ├── 130-intune-macos-profiles-list.png
    └── fr/
        ├── 100-macos-cp-install-intro-fr.png
        └── ...
```

---

*Last updated: May 2026 — [@Luconik](https://github.com/Luconik)*
