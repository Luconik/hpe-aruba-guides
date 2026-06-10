# Configure Aruba CX switches for Central NAC — EAP-TLS with Microsoft Intune

[![HPE Aruba Central NAC](https://img.shields.io/badge/HPE%20Aruba%20Central%20NAC-required-FF6600)](.)
[![HPE Aruba CX](https://img.shields.io/badge/HPE%20Aruba%20CX-required-FF6600)](.)
[![Microsoft Intune](https://img.shields.io/badge/Microsoft%20Intune-required-0078D4)](.)
[![AOS-CX](https://img.shields.io/badge/AOS--CX-10.17-blue)](.)
[![Read Time](https://img.shields.io/badge/ReadTime-15%20min-01A982)](.)

## Table of contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Architecture](#architecture)
- [Part 1 — Central NAC configuration (wired delta)](#part-1--central-nac-configuration-wired-delta)
  - [1.1 Authentication Profile for wired EAP-TLS](#11-authentication-profile-for-wired-eap-tls)
  - [1.2 Authorization Policy for wired](#12-authorization-policy-for-wired)
  - [1.3 Wired roles — Local User Roles (CX 6000/6100 constraint)](#13-wired-roles--local-user-roles-cx-60006100-constraint)
- [Part 2 — CX switch configuration in Central](#part-2--cx-switch-configuration-in-central)
  - [2.1 Authentication Server sys_central_nac](#21-authentication-server-sys_central_nac)
  - [2.2 AAA Profile](#22-aaa-profile)
  - [2.3 Port Profile](#23-port-profile)
  - [2.4 Apply Port Profile to switch interfaces](#24-apply-port-profile-to-switch-interfaces)
- [Part 2b — Configure 802.1X supplicant on Windows](#part-2b--configure-8021x-supplicant-on-windows)
- [Part 3 — Validation](#part-3--validation)
  - [3.1 Central NAC — Clients view](#31-central-nac--clients-view)
  - [3.2 CX switch CLI validation](#32-cx-switch-cli-validation)
- [Common issues](#common-issues)
- [References](#references)

---

## Overview

This guide extends the Wi-Fi EAP-TLS + Intune configuration to **wired 802.1X on Aruba CX switches** managed in Aruba Central.

> **Part 0 — Base Wi-Fi configuration (prerequisite)**
> Complete the Wi-Fi guide first:
> [central-nac-intune](../central-nac-intune/README.md) — Central NAC EAP-TLS with Microsoft Intune (Wi-Fi)
>
> The Intune Extension, OAuth Identity Store, SCEP URL, and root CA certificate are **reused as-is**. This guide only covers the wired-specific deltas in Central NAC and the CX switch profiles.

> **Base switch configuration (prerequisite)**
> This guide extends [willembargeman/hpe-networking-guides — central-nac-cx-switch](https://github.com/willembargeman/hpe-networking-guides/blob/main/central-nac-cx-switch/README.md) for MAC authentication.

In this lab, an **Aruba CX 6000 running AOS-CX 10.17** is used.
The same steps apply to any CX platform supporting 802.1X (CX 6100, 6300, 6400, 8xxx).

---

## Prerequisites

- Aruba CX switch managed in **Aruba Central** (AOS-CX 10.16 or later recommended)
- Wi-Fi EAP-TLS guide completed: Intune Extension active, OAuth Identity Store validated, SCEP active
- **TCP port 2083** open between the switch and Central NAC (RadSec)
- Intune SCEP profile and Trusted Certificate profile deployed to endpoints (see [microsoft-intune / eap-tls](https://github.com/Luconik/microsoft-intune/tree/main/eap-tls))
- Endpoints must receive the client certificate **before** connecting to the wired port

---

## Architecture

```
Endpoint (Intune-managed — Windows / macOS)
    │
    │  SCEP certificate issued by Central NAC CA
    │  (deployed via Intune — same certificate as Wi-Fi)
    ▼
Aruba CX 6000 (802.1X EAP-TLS, port-access)
    │
    │  RadSec TLS / TCP-2083
    ▼
Aruba Central NAC
    │
    │  Compliance check via OAuth2
    ▼
Microsoft Intune / Entra ID
    │
    ▼
Network access granted
Role assigned → VLAN applied on CX interface
(CoA: Central NAC sends RADIUS CoA to update role/VLAN without full re-authentication)
```

---

## Part 1 — Central NAC configuration (wired delta)

> The Intune Extension and OAuth Identity Store from the Wi-Fi guide are **unchanged**.
> Only the following three objects need to be updated for wired.

### 1.1 Authentication Profile for wired EAP-TLS

Navigate to:

```
Central NAC → Configuration → Authentication Profiles → [your EAP-TLS profile] → Edit
```

Enable wired support on the existing EAP-TLS profile.

| Parameter | Value |
|---|---|
| **Authentication Type** | EAP-TLS |
| **Identity Store** | *your Intune OAuth store* |
| **Use for wired connection** | ✓ |
| **Use for wireless connection** | ✓ (keep enabled if shared with Wi-Fi) |

![Central NAC Authentication Profile — EAP-TLS wired](screenshots/03-centralnac-auth-profile-eaptls-wired.png)

---

### 1.2 Authorization Policy for wired

Navigate to:

```
Central NAC → Configuration → Authorization Policies → [your policy] → Edit
```

The `Luconik_Authorization_Policies` policy (type **User**, Identity Store `Luconik_EntraID`) is used for both wired and Wi-Fi.

| Rule | Condition | Role returned (Aruba-User-Role VSA) |
|---|---|---|
| Corp compliant | Intune compliant = true | `employee-role` |
| Marketing | EntraID group = Marketing | `marketing-role` |
| Retail | EntraID group = Retail | `retail-role` |
| Design | EntraID group = Design | `design-role` |
| Sales | EntraID group = Sales | `sales-role` |
| IT Admin | EntraID group = IT Admins | `admin-role` |
| Deny All | — | Deny |

![Central NAC Authorization Policy](screenshots/04-centralnac-authorization-policies.png)

> **CoA behaviour** — When an endpoint's Intune compliance status changes, Central NAC sends a RADIUS Change of Authorization to the switch. The switch updates the role/VLAN for the session without full re-authentication.

---

### 1.3 Wired roles — Local User Roles (CX 6000/6100 constraint)

> **CX 6000/6100 constraint**
> DUR (Downloadable User Role) is **not supported** on the CX 6000 and 6100 Switch Series (ASIC limitation, all AOS-CX versions).
> The **Always Download Role** option in Central NAC has no effect on these platforms.
>
> **Workaround: Local User Roles (LUR)**
> Roles must be pre-configured locally on the switch. Central NAC returns the role name via the RADIUS VSA `Aruba-User-Role`. The switch applies the matching LUR which contains the VLAN assignment.
>
> DUR / Always Download Role works on CX 6200, 6300, 6400, 8xxx.

LUR roles are configured locally on the switch (pushed by Central via Library roles):

```
port-access role employee-role
    auth-mode client-mode
    vlan access 11
    stp-admin-edge-port
!
port-access role marketing-role
    auth-mode client-mode
    vlan access 12
    stp-admin-edge-port
!
port-access role retail-role
    auth-mode client-mode
    vlan access 13
    stp-admin-edge-port
!
port-access role design-role
    auth-mode client-mode
    vlan access 14
    stp-admin-edge-port
!
port-access role sales-role
    auth-mode client-mode
    vlan access 15
    stp-admin-edge-port
!
port-access role admin-role
    auth-mode client-mode
    vlan access 90
    stp-admin-edge-port
!
```

| Role name (LUR on switch) | VLAN | VLAN name |
|---|---|---|
| `employee-role` | 11 | Corporate |
| `marketing-role` | 12 | Marketing |
| `retail-role` | 13 | Retail |
| `design-role` | 14 | Design |
| `sales-role` | 15 | Sales |
| `admin-role` | 90 | admin |

> Role names are **case-sensitive** and must match exactly between the LUR on the switch and the `Aruba-User-Role` VSA value returned by Central NAC.

---

## Part 2 — CX switch configuration in Central

### 2.1 Authentication Server sys_central_nac

The `sys_central_nac` server is automatically generated by Central NAC when the switch is registered.

Navigate to:

```
Aruba Central → Configuration → Library → Security → Authentication Server → sys_central_nac
```

| Parameter | Value |
|---|---|
| **Server Type** | RADIUS |
| **Secure RADIUS** | ✓ |
| **Auth Server Mode** | RADIUS with CoA (Change of Authorization) |
| **IP Address/FQDN** | `euw1.cloudguest.central.arubanetworks.com` |
| **Secure Authentication Port** | 2083 |
| **Certificate Type** | Internal |

![Authentication Server sys_central_nac](screenshots/07-authentication-server-sys-central-nac.png)

Configuration pushed to the switch:

```
radius-server host euw1.cloudguest.central.arubanetworks.com tls timeout 20 port-access keep-alive
!
aaa group server radius sys_central_nac
    server euw1.cloudguest.central.arubanetworks.com tls
!
aaa radius-attribute group sys_central_nac
    nas-id value <SWITCH-UUID>
    nas-id request-type both
!
aaa accounting port-access start-stop interim 5 group sys_central_nac
!
radius dyn-authorization enable
radius dyn-authorization client euw1.cloudguest.central.arubanetworks.com tls
!
aaa authentication port-access dot1x authenticator
    radius server-group sys_central_nac
    enable
!
```

> **FQDN** — `euw1` for Europe West 1. Check Central NAC → Configuration → RADIUS Server for your region.

---

### 2.2 AAA Profile

Navigate to:

```
Aruba Central → [switch] → Profiles → Security → AAA Authentication → CentralNAC_LAN
```

| Parameter | Value |
|---|---|
| **Authentication Protocol** | 802.1X |
| **802.1X Authentication Server Group** | Central NAC (`sys_central_nac`) |
| **RADIUS Override** | ✓ |

---

### 2.3 Port Profile

Navigate to:

```
Aruba Central → [switch] → Profiles → Interfaces → Port Profiles → CentralNAC_LAN
```

| Parameter | Value |
|---|---|
| **Device** | Switch |
| **VLAN Mode** | Access |
| **Access VLAN** | 1 (pre-auth VLAN) |
| **Admin Edge** | ✓ |
| **BPDU Guard** | ✓ |
| **Enable Port Authentication** | ✓ |
| **AAA Profile** | `CentralNAC_LAN` |

![Port Profile CentralNAC_LAN](screenshots/02-port-profile-centralnac-lan.png)

Configuration pushed to the switch:

```
interface 1/1/2
    no shutdown
    vlan access 1
    spanning-tree bpdu-guard
    spanning-tree port-type admin-edge
    no aaa authentication port-access allow-lldp-auth
    no aaa authentication port-access allow-cdp-auth
    aaa authentication port-access radius-override enable
    aaa authentication port-access dot1x authenticator
        radius server-group sys_central_nac
        enable
    exit
```

---

### 2.4 Apply Port Profile to switch interfaces

Navigate to:

```
Aruba Central → [switch] → Interfaces → Switch Interface Configuration → [interface] → Edit
```

| Parameter | Value |
|---|---|
| **Use Port Profile** | ✓ |
| **Port Profile** | `CentralNAC_LAN` |

![Interface 1/1/2 — Use Port Profile](screenshots/01-switch-interface-config-use-port-profile.png)

---

## Part 2b — Configure 802.1X supplicant on Windows

> This section applies to Windows endpoints **not managed by a GPO or Intune wired 802.1X profile**.

### Enable the Wired AutoConfig service

Open `services.msc`, locate **Wired AutoConfig** (dot3svc).

![Services — Wired AutoConfig (Manual, stopped)](screenshots/11-windows-services-wired-autoconfig.png)

Double-click → set Startup type to **Automatic** → **Start**.

![Wired AutoConfig — Automatic, started](screenshots/12-windows-wired-autoconfig-automatic.png)

### Configure 802.1X authentication on the Ethernet adapter

```
Control Panel → Network and Sharing Center
→ Change adapter settings
→ Right-click Ethernet → Properties → Authentication tab
→ ✓ Enable IEEE 802.1X authentication
→ Method: Microsoft: Smart Card or other certificate
→ Settings → ✓ Use a certificate on this computer
```

### First connection — certificate selection

When plugging in the cable, Windows displays a **"Connecting, action needed"** notification.

![Windows — Continue connecting?](screenshots/13-windows-ethernet-continue-connecting.png)

Click **Connect** then select the `nicoculetto@luconik.fr` certificate (issued by the Central NAC CA via Intune SCEP).

![Windows — Choose a certificate](screenshots/14-windows-ethernet-choose-certificate.png)

Once authenticated, the network shows as **Unidentified network** (expected behaviour for wired 802.1X connections).

![Windows — Ethernet connected](screenshots/15-windows-ethernet-connected.png)

> **Note** — On subsequent connections, Windows automatically selects the certificate without manual intervention.

---

## Part 3 — Validation

### 3.1 Central NAC — Clients view

Navigate to:

```
Central NAC → Monitoring → Clients
```

A successfully authenticated wired endpoint should show:

| Field | Expected value |
|---|---|
| **Status** | Accepted |
| **Connection Type** | Wired |
| **Authentication Type** | EAP-TLS (Certificate) |
| **Certificate Status** | Valid |
| **Identity Store** | Luconik_EntraID |
| **Assigned Role** | per authorization policy |
| **Tags** | Intune: Compliant |

![Central NAC — Wired and Wireless clients accepted](screenshots/05-centralnac-clients-wired-wireless.png)

![Central NAC — Wired client detail](screenshots/06-centralnac-client-detail-accepted.png)

---

### 3.2 CX switch CLI validation

| Validation | Command | Expected result |
|---|---|---|
| Central NAC cert installed | `show crypto pki ta-profile sys_central_nac` | `TA Certificate: Installed and valid` |
| RadSec connection up | `show radius-server detail` | `TLS Connection Status: tls_connection_established` |
| Authenticated clients | `show port-access clients` | Client list with assigned role and VLAN |
| CoA listener active | `show radius dynamic-authorization` | CoA client entry for Central NAC FQDN |

![CLI — show crypto pki ta-profile sys_central_nac](screenshots/08-cli-show-crypto-pki-sys-central-nac.png)

![CLI — show radius-server detail](screenshots/09-cli-show-radius-server-detail.png)

![CLI — show port-access clients](screenshots/10-cli-show-port-access-clients.png)

---

## Common issues

| Issue | Most likely cause |
|---|---|
| **RadSec connection down** | TCP-2083 blocked between switch and Central NAC |
| **Central NAC cert not installed** | Switch System Profile not correctly scoped or not pushed |
| **MAC auth failure — unexpected data error** | MAC Radius Auth Method not set to PAP |
| **EAP-TLS failure — certificate validation error** | SCEP certificate not yet deployed by Intune on the endpoint |
| **EAP-TLS failure — identity store error** | OAuth token expired in Central NAC — revalidate the Identity Store |
| **Role not applied / wrong VLAN (CX 6000/6100)** | LUR missing on the switch or name mismatch vs `Aruba-User-Role` VSA — DUR not supported on 6000/6100 |
| **Role not applied / wrong VLAN (CX 6200+)** | Always Download Role not enabled on the Role |
| **CoA not received by switch** | `radius dyn-authorization` not pushed — check Switch System Profile and Audit Trail |
| **Incorrect system time on endpoint** | SCEP / certificate validation failure — sync NTP before Intune enrollment |

---

## References

- 📘 [Base wired guide — willembargeman/hpe-networking-guides](https://github.com/willembargeman/hpe-networking-guides/blob/main/central-nac-cx-switch/README.md)
- 📘 [Central NAC — UEM Onboarding with Intune](https://arubanetworking.hpe.com/techdocs/NAC/central-nac/central-nac-uem-onboarding-intune/)
- 📘 [AOS-CX — Cached Critical Role](https://arubanetworking.hpe.com/techdocs/AOS-CX/10.17/HTML/security_5420-6200-6300-6400/Content/Chp_Port_acc/spe-cac-cri-rol.htm)
- 📘 [AOS-CX — Port Access documentation](https://arubanetworking.hpe.com/techdocs/AOS-CX/10.17/HTML/security_5420-6200-6300-6400/Content/Chp_Port_acc/)
- [central-nac-intune](../central-nac-intune/README.md) — Wi-Fi EAP-TLS base guide (prerequisite)
- [microsoft-intune / eap-tls](https://github.com/Luconik/microsoft-intune/tree/main/eap-tls) — Intune profiles per platform
