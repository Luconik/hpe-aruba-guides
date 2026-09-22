# Posts — Aruba Central NAC + Jamf Pro (EAP-TLS)

> Lien GitHub à compléter dans les 4 posts une fois les repos `central-nac-jamf/` et `jamf-pro/eap-tls/` poussés (placeholder `[lien]` ci-dessous).

---

## 1. Yammer interne (EN)

🔧 New integration tested and documented in the lab: Aruba Central NAC + Jamf Pro (EAP-TLS)

After the official Central NAC + Microsoft Intune technote, I wanted to check whether the same approach would hold with another UEM that's widely used at our Apple-centric customers: Jamf Pro. Turns out it works — but it wasn't documented anywhere, neither on HPE's side nor on Jamf's.

What I validated:
- Jamf extension in Central (SCEP URL + Webhook + Authorization Header mechanism — no "Extension" field like the Intune one)
- Jamf configuration profile combining Certificate + SCEP + Network (a single payload, no separate "PKI proxy server")
- EAP-TLS authentication validated on MacBook Pro M1 and iPad Pro, WPA3-Enterprise

Along the way I also flagged a display anomaly worth digging into on the Central side (empty User Groups field in the NAC Client view with a Jamf profile, even though the role is correctly assigned — not blocking).

Everything is documented (GitHub repo, screenshots included), and this work will feed into an official article on the Aruba site, with Matthew.

Happy to dig into this further with anyone dealing with Apple-centric customers.

---

## 2. LinkedIn FR

Nouvelle brique dans le lab : intégration Aruba Central NAC + Jamf Pro pour l'onboarding EAP-TLS des terminaux Apple (macOS/iPadOS).

Ce schéma n'était documenté nulle part — ni côté HPE, ni côté Jamf. Je suis parti de la logique de la technote officielle Central NAC + Microsoft Intune et je l'ai adaptée et validée avec Jamf Pro Cloud : extension Jamf, mécanisme SCEP/webhook, profil Certificate + SCEP + Network, testé sur MacBook Pro et iPad Pro.

Tout est documenté (FR + EN) et disponible sur mon GitHub, captures à l'appui :
[lien]

Je vous laisse juger.

---

## 3. LinkedIn EN

New piece in the lab: Aruba Central NAC + Jamf Pro integration for EAP-TLS onboarding of Apple devices (macOS/iPadOS).

This flow wasn't documented anywhere — neither on HPE's side, nor on Jamf's. I took the logic from the official Central NAC + Microsoft Intune technote and adapted and validated it with Jamf Pro Cloud: Jamf extension, SCEP/webhook mechanism, Certificate + SCEP + Network profile, tested on MacBook Pro and iPad Pro.

Everything is documented (FR + EN) and available on my GitHub, with screenshots:
[link]

I let you judge.

---

## 4. Reddit — r/jamf (EN)

**Title:** Got Aruba Central NAC EAP-TLS working end-to-end with Jamf Pro (no official docs existed for this combo)

**Body:**

I run a homelab with Aruba Central NAC and wanted to onboard Apple devices via 802.1X/EAP-TLS using Jamf Pro instead of Intune. HPE has an official technote for Central NAC + Microsoft Intune, but nothing for Jamf — and I couldn't find anything on Jamf's side either, so I built and validated the whole flow myself.

Quick summary of what's involved:

- **Central side:** install/configure the Jamf extension (no "Extension" field like the Intune one — you just get a SCEP URL + SCEP Challenge Webhook URL + Authorization Header, that's the whole integration surface), identity store (EntraID), roles, authorization policy, SSID (WPA3-Enterprise/EAP-TLS), and an EAP-TLS authentication profile pointing at the Jamf UEM instance.
- **Jamf side:** a single Configuration Profile with three payloads — Certificate (Central NAC's root CA), SCEP (manual CA, pointing at the SCEP URL from the extension, SAN = `cnac+jamf:///?DeviceId=$JSSID`), and Network/Wi-Fi (TLS as accepted EAP type, trust chain = the SCEP identity + the root cert).
- Tested and confirmed working on a MacBook Pro (macOS) and an iPad Pro (iPadOS) — separate Computer/Mobile Device profiles, same logic.

One gotcha worth flagging if you try this: the SCEP Challenge Webhook Authorization Header on the Central side is shown once and never displayed again — write it down before you leave the screen.

Full write-up with screenshots (FR + EN) is up on my GitHub: [link]

Happy to answer questions if anyone's trying to do the same thing.
