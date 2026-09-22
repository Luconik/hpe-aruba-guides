# Onboarding Jamf Pro Devices with Aruba Central NAC

> Jamf Pro adaptation of the HPE Aruba Networking [Onboarding with Intune](https://arubanetworking.hpe.com/techdocs/NAC/central-nac/central-nac-uem-onboarding-intune/) technote. It describes using **Central NAC UEM Onboarding** and its built-in PKI to issue EAP-TLS certificates to Apple devices managed by Jamf Pro.
>
> This integration is not documented anywhere else to date, neither by HPE nor by Jamf. The companion repo [`central-nac-jamf`](https://github.com/Luconik/hpe-aruba-guides/tree/main/central-nac-jamf) covers the Aruba Central side in detail; this document focuses on the Jamf Pro configuration and device onboarding.

## Table of contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Configuring the Jamf Pro UEM integration](#configuring-the-jamf-pro-uem-integration)
  - [Configure Entra ID and the Jamf extension in Central](#configure-entra-id-and-the-jamf-extension-in-central)
  - [Create the Jamf API role and client](#create-the-jamf-api-role-and-client)
  - [Configure the WLAN and the Central NAC authentication profile](#configure-the-wlan-and-the-central-nac-authentication-profile)
- [Jamf Pro Configuration](#jamf-pro-configuration)
  - [Enrollment prerequisites — User-initiated enrollment](#enrollment-prerequisites--user-initiated-enrollment)
  - [Create the configuration profile (Certificate + SCEP + Network)](#create-the-configuration-profile-certificate--scep--network)
  - [Deploy the profile](#deploy-the-profile)
- [Validation](#validation)
- [References](#references)
- [File structure](#file-structure)

## Overview

Aruba Central NAC can use a UEM platform to distribute the profiles devices need while keeping certificate issuance within the Central NAC PKI. On the Jamf side, everything lives in **a single configuration profile** combining three payloads: **Certificate** (the Central NAC root certificate, so the device trusts the certificate that will be issued), **SCEP** (pointing directly at the SCEP URL exposed by Central's Jamf extension), and **Network** (the 802.1X Wi-Fi, which consumes the identity issued by the SCEP payload).

1. Jamf Pro distributes this profile (Certificate + SCEP + Network) to managed devices.
2. When the profile is installed, the Jamf agent makes the SCEP request to Central NAC's URL — the challenge exchange with Central's Jamf extension happens server-side, with no field to fill in manually in Jamf.
3. Central NAC issues the client certificate via its SCEP URL.
4. The device connects to the 802.1X SSID using that certificate over EAP-TLS.
5. Central NAC assigns the network role based on the Entra ID identity and the authorization policy.

> ℹ️ **Correction relative to the Intune technote.** There is no separate "PKI proxy server" object to create in Jamf Pro for this integration — despite what the name might suggest by analogy with Intune. The configuration profile's SCEP payload points directly at the SCEP URL provided by Central's Jamf extension, using **Manual configuration**.

> The detailed 10-step flow diagram is in the companion repo [`central-nac-jamf`](https://github.com/Luconik/hpe-aruba-guides/tree/main/central-nac-jamf#overview).

This integration was validated with:

| Component | Reference value |
|---|---|
| Central NAC | Central Foundation |
| UEM | Jamf Pro Cloud 11.32 |
| Identity provider | Microsoft Entra ID |
| SSID | `luconik-jamf` |
| Wi-Fi security | WPA3-Enterprise (CCMP-128), EAP-TLS |
| Validation devices | MacBook Pro M1 and iPad Pro 11 |

## Prerequisites

- An active **Jamf Pro** extension in Aruba Central with an associated Entra ID identity store.
- An 802.1X SSID associated with the **Central NAC** server group.
- The three values from the Central Jamf extension: **SCEP URL**, **SCEP Challenge Webhook URL**, and **Authorization Header**.
- A Jamf Pro account authorized to create API roles/clients and configuration profiles (Certificate, SCEP, Network payloads).
- Existing Entra ID groups for Central NAC role mapping.

> Tenant-specific Jamf values are never included in this document. Use `<jamf-tenant>.jamfcloud.com` in examples and public screenshots.

## Configuring the Jamf Pro UEM integration

Configuration is split between Aruba Central, which provides the PKI and NAC policies, and Jamf Pro, which distributes the Apple profiles and verifies the SCEP challenge.

### Configure Entra ID and the Jamf extension in Central

1. In Central, open **Menu > Extensions**.
2. Create or open the **Jamf Pro** instance.
3. Enter the Jamf instance URL in the form `<jamf-tenant>.jamfcloud.com`.
4. Select the OAuth 2.0 Entra ID identity store, then enter the Tenant ID, Client ID, and Client Secret.
5. Save and verify that the extension is **Active**.

![Active Jamf extension in Aruba Central](screenshots/01-central-extensions-catalog.png)

![Jamf extension configuration](screenshots/03-central-extension-jamf-config.png)

The extension then exposes the three values (SCEP URL, SCEP Challenge Webhook URL, Authorization Header) to carry over into the Jamf configuration profile's SCEP payload. The Authorization Header is not shown again in clear text: store it in a secrets manager before leaving the screen.

![SCEP and webhook information from the Jamf extension](screenshots/04-central-scep-webhook-header.png)

### Create the Jamf API role and client

The Jamf extension queries the Jamf inventory to link the device to the UEM Onboarding flow. Use a dedicated, read-only role rather than a generic admin account.

1. In Jamf Pro, open **Settings > System > API roles and clients > API Roles**.
2. Create the role `<central-nac-read-only>` with only the following privileges:

| Privilege | Usage |
|---|---|
| Read Computers | Read enrolled Macs |
| Read Mobile Devices | Read enrolled iPad/iPhone devices |
| Read Smart Computer Groups | Read dynamic macOS groups |
| Read Smart Mobile Device Groups | Read dynamic iOS/iPadOS groups |

![Jamf API role privileges](screenshots/02-jamf-api-role.png)

3. Under **API Clients**, create a client tied to this role, enable it, and keep its secret.
4. Set **Access token lifetime** to **900 seconds**.

![Jamf API client token lifetime](screenshots/04-jamf-api-token-lifetime.png)

> The default value of 60 seconds is too short for a reliable SCEP flow. Creating or rotating a secret should be treated as a sensitive operation: the secret is only ever shown once.

### Configure the WLAN and the Central NAC authentication profile

Create or verify the 802.1X network before creating the authentication profile.

1. Create the `luconik-jamf` SSID in the Central configuration library.
2. Use **WPA3-Enterprise (CCMP-128)** and select **Central NAC** as the authentication server.
3. Under **Menu > Central NAC > Configuration > Authentication Profiles**, create a profile of type **EAP-TLS**.
4. Associate the SSID, the Entra ID identity store, and the Jamf extension under **UEM Onboarding**.
5. Create an authorization policy that maps the Entra ID groups to the expected NAC roles.

![EAP-TLS profile associated with the Jamf network](screenshots/10-central-nac-eap-tls-profile.png)

![Central NAC authorization policy](screenshots/09-central-nac-authorization-policy.png)

## Jamf Pro Configuration

Everything happens in **a single macOS configuration profile** (repeat the same approach for iOS/iPadOS if both platforms are managed), combining three payloads: **Certificate**, **SCEP**, and **Network**.

### Enrollment prerequisites — User-initiated enrollment

Before the configuration profile can be pushed, devices must already be enrolled as managed devices in Jamf Pro. This document does not cover the choice of enrollment method (PreStage vs. self-enrollment) but documents the configuration observed in the lab, under **Settings > Global > User-initiated enrollment**:

1. **General**: `Skip certificate installation during enrollment` checked (an internal/trusted third-party SSL certificate is already in place on the instance, so the certificate installation step during enrollment is skipped); `Restrict re-enrollment to authorized users only` and `Use a third-party signing certificate` unchecked.

   ![User-initiated enrollment — General](screenshots/16-jamf-enrollment-general.png)

2. **Messaging**: default English enrollment message (`Enroll Your Device`) — adapt/translate as needed.

   ![User-initiated enrollment — Messaging](screenshots/17-jamf-enrollment-messaging.png)

3. **Computers**: `Enable user-initiated enrollment for computers` checked (enrollment URL `https://<jamf-tenant>.jamfcloud.com/enroll`). Managed admin account, forced SSH, and Self Service launch left disabled in the lab.

   ![User-initiated enrollment — Computers](screenshots/18-jamf-enrollment-computers.png)

4. **Devices**: `Enable for institutionally owned devices` checked under **Profile-Driven Enrollment via URL** (organization-owned mobile devices). The **Account-Driven** options (enrollment via Managed Apple ID) are not used in this lab.

   ![User-initiated enrollment — Devices](screenshots/19-jamf-enrollment-devices.png)

5. **Access**: the **Directory Service Groups** table restricts who can self-enroll, by group and by mode (Profile-Driven / Account-Driven). The groups used in the lab have Profile-Driven access (Institutional + Personal).

   ![User-initiated enrollment — Access, Directory Service groups](screenshots/20-jamf-enrollment-access.png)

> This configuration only concerns initial MDM enrollment (getting a Mac/iPad managed in Jamf) — it is independent of the EAP-TLS flow described in this document, which relies on the configuration profile pushed once the device is already enrolled.

### Create the configuration profile (Certificate + SCEP + Network)

1. Open **Computers > Configuration Profiles** and create a profile. Give it an explicit name, e.g. `Luconik-CentralNAC-EAPTLS`.

   ![Configuration profile — General](screenshots/01-jamf-configuration-profile-general.png)

2. Add the **Certificate** payload and upload the Central NAC PKI root certificate to it (`Cloud Authentication Private Root CA (powered by HPE Aruba)`, downloadable from Central NAC). Give it an identifiable name, e.g. `CentralNAC_Certificate` — it will be referenced by the Network payload in step 4.

   ![Certificate payload — Central NAC root certificate](screenshots/03-jamf-certificate-payload.png)

3. Add the **SCEP** payload, with **Certificate authority type: Manual configuration**, and fill in:

   | Field | Value |
   |---|---|
   | URL | SCEP URL provided by Central's Jamf extension (Part 1) |
   | Name | instance identifier, e.g. `CentralNAC` |
   | Subject | `CN=$USERNAME` |
   | SAN type | Uniform Resource Identifier |
   | SAN value | `cnac+jamf:///?DeviceId=$JSSID` |
   | Challenge Type | Dynamic |
   | Key Size | 2048 |

   ![SCEP payload: URL, subject, and SAN](screenshots/05-jamf-scep-profile-san.png)

   The `cnac+jamf://` scheme is specific to the Jamf integration. It replaces the `cnac+intune://` scheme from the Intune technote. `$JSSID` is resolved by Jamf using the device's Jamf identifier; since the Computer and Mobile Device sequences are distinct, a Mac and an iPad can both end up with `DeviceId=1`.

   After issuance, verify on the device's terminal that the certificate contains the following SAN:

   ```
   URI:cnac+jamf:///?DeviceId=<jamf-id>
   ```

   ![SAN URI of the issued certificate](screenshots/06-jamf-cert-san-uri.png)

4. Add the **Network** payload:
   - **Network Interface**: Wi-Fi;
   - **Service Set Identifier (SSID)**: `luconik-jamf`;
   - **Security Type**: WPA3 Enterprise.

   ![Network payload — SSID and Security Type](screenshots/07-jamf-wifi-profile.png)

   Under the **Protocols** tab, check **TLS** in Accepted EAP Types. Under the **Trust** tab:
   - **Identity Certificate**: select the SCEP payload created in step 3 (it appears in the list as `SCEP (<Name>)`);
   - **Trusted Certificates**: check the root certificate uploaded in step 2 (`CentralNAC_Certificate`).

   ![Network payload — Trust tab, Identity Certificate and Trusted Certificates](screenshots/07b-jamf-wifi-trust-identity.png)

5. Save the profile.

### Deploy the profile

1. In the profile's **Scope** tab, assign the target devices. A Smart Computer Group / Smart Mobile Device Group is recommended in production for scaled deployment; in the lab, direct targeting of specific devices (**Specific Computers** / **Specific Mobile Devices**) is enough.
2. Save and wait for the devices' next check-in.

![macOS profile scope — Target Computers](screenshots/08-jamf-profile-scope.png)

> An Apple device can only be enrolled in one MDM at a time. Unenroll the device from any previous MDM before enrolling it in Jamf Pro.

### iOS/iPadOS: a dedicated profile

The same approach (Certificate + SCEP + Network/Wi-Fi) applies to iOS/iPadOS, but in a **separate mobile configuration profile** — Jamf Pro keeps Computers and Mobile Devices profiles apart. Duplicate the naming convention with a suffix, e.g. `Luconik-CentralNAC-EAPTLS-iOS`.

![iOS configuration profile — General](screenshots/09-jamf-ios-profile-general.png)

The Certificate and SCEP payloads are identical to the macOS version. Only the **Network** payload changes name: on mobile, it's the **Wi-Fi** payload (instead of **Network**), with a **Security Type** labeled `WPA3 Enterprise (iOS 13 or later)`. The **Protocols** / **Trust** tabs work the same way (Identity Certificate = the SCEP payload, Trusted Certificates = the root certificate).

![iOS Wi-Fi payload — Trust tab](screenshots/09b-jamf-ios-wifi-trust.png)

## Validation

1. In Jamf Pro, verify that the Mac and iPad are managed and that the SCEP and Wi-Fi profiles are installed. On the Mac side, this can also be verified directly in **System Settings > General > Device Management**: the `Luconik-CentralNAC-EAPTLS` profile should appear with its 3 payloads (Certificate + SCEP + Network).

   ![macOS Device Management — Luconik-CentralNAC-EAPTLS profile installed](screenshots/15-jamf-device-management-profile.png)

2. On the device's terminal, verify the certificate's SAN, then the automatic connection to the `luconik-jamf` SSID.

   > ⚠️ **macOS certificate picker.** If several client identities are present on the device (e.g. an enrollment identity tied to a Managed Apple ID), macOS may prompt to manually choose the certificate to use for the SSID instead of automatically picking the one from the SCEP payload. Select the certificate issued by the Central NAC PKI (SAN `cnac+jamf://...`), not an Apple ID enrollment identity.

   ![macOS certificate picker for the luconik-jamf SSID](screenshots/21-jamf-wifi-cert-picker.png)

3. In Central, open **Menu > Central NAC > Clients** and select the time period containing the test.
4. Verify that the session is **Accepted**, that the WLAN is `luconik-jamf`, and that the role matches the Entra ID group.

![NAC session — Mac](screenshots/12-nac-client-session-mac.png)

![NAC session — iPad](screenshots/13-nac-client-session-ipad.png)

> With the Jamf profile, the **User Groups** field in the Client view may stay empty even though the authorization policy correctly assigns the role. In the lab, this is a non-blocking display issue; validate the result against the role actually assigned.

## References

- [HPE technote — Onboarding with Intune](https://arubanetworking.hpe.com/techdocs/NAC/central-nac/central-nac-uem-onboarding-intune/) — structure and operation of Central NAC UEM Onboarding.
- [Central NAC — Authentication and Authorization](https://arubanetworking.hpe.com/techdocs/NAC/central-nac/central-nac-authorization/).
- [Central NAC — Configuring EAP-TLS Profile](https://arubanetworking.hpe.com/techdocs/new-central/content/nac/config-eap.htm).
- Companion repo — detailed Aruba Central configuration (Jamf extension, NAC): [`Luconik/hpe-aruba-guides/central-nac-jamf`](https://github.com/Luconik/hpe-aruba-guides/tree/main/central-nac-jamf)

## File structure

> Screenshots `01-central-extensions-catalog.png`, `03-central-extension-jamf-config.png`, `04-central-scep-webhook-header.png`, `09-central-nac-authorization-policy.png`, `10-central-nac-eap-tls-profile.png`, `12-nac-client-session-mac.png`, and `13-nac-client-session-ipad.png` are shared with the companion repo [`central-nac-jamf`](https://github.com/Luconik/hpe-aruba-guides/tree/main/central-nac-jamf) — they are duplicated into this repo's `screenshots/` folder.

```
jamf-pro/
└── eap-tls/
    ├── README.md              (French version)
    ├── README-EN.md            (this document, EN)
    └── screenshots/
        ├── 01-central-extensions-catalog.png     (shared)
        ├── 03-central-extension-jamf-config.png  (shared)
        ├── 04-central-scep-webhook-header.png    (shared)
        ├── 02-jamf-api-role.png
        ├── 04-jamf-api-token-lifetime.png
        ├── 09-central-nac-authorization-policy.png (shared)
        ├── 10-central-nac-eap-tls-profile.png    (shared)
        ├── 01-jamf-configuration-profile-general.png
        ├── 03-jamf-certificate-payload.png
        ├── 05-jamf-scep-profile-san.png
        ├── 06-jamf-cert-san-uri.png
        ├── 07-jamf-wifi-profile.png
        ├── 07b-jamf-wifi-trust-identity.png
        ├── 08-jamf-profile-scope.png
        ├── 09-jamf-ios-profile-general.png
        ├── 09b-jamf-ios-wifi-trust.png
        ├── 12-nac-client-session-mac.png         (shared)
        ├── 13-nac-client-session-ipad.png        (shared)
        ├── 15-jamf-device-management-profile.png
        ├── 16-jamf-enrollment-general.png
        ├── 17-jamf-enrollment-messaging.png
        ├── 18-jamf-enrollment-computers.png
        ├── 19-jamf-enrollment-devices.png
        ├── 20-jamf-enrollment-access.png
        └── 21-jamf-wifi-cert-picker.png
```
