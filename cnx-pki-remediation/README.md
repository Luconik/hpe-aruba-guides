# CNX PKI TA-Profile Remediation / Remédiation PKI TA-Profile CNX

---

## Francais

### Contexte

HPE Aruba New Central (CNX) peut écraser la configuration PKI des switches AOS-CX lors de ses synchronisations. Ce package automatise la creation et la remediation du ta-profile ClearPass via l API REST AOS-CX directe.

### Architecture

    CNX Webhook -> Listener HTTP -> remediate.sh -> API REST AOS-CX

### Prerequis

- Switch AOS-CX firmware 10.09+ (valide sur CX-6100 PL.10.16)
- Acces reseau direct au switch depuis le serveur listener
- curl, bash, python3, nc (netcat) installes sur le serveur
- Certificat CA au format PEM

### Installation

    git clone https://github.com/Luconik/hpe-aruba-guides.git
    cd hpe-aruba-guides/cnx-pki-remediation
    cp config/settings.env.template config/settings.env
    nano config/settings.env
    cp /chemin/vers/ca.pem certs/ca.pem
    chmod +x scripts/remediate.sh scripts/listener.sh

### Test manuel

    bash scripts/remediate.sh

Resultat attendu sur le switch :

    TA Profile Name     TA Certificate    Revocation Check
    clearpass-ca        Installed, valid  disabled

### Demarrer le listener webhook

    bash scripts/listener.sh
    # Configurer NPM/Nginx : webhook.exemple.fr -> localhost:8080

### Comportement du script

| Situation | Action |
|-----------|--------|
| TA-profile absent | Creation + injection cert |
| TA-profile present, valid | Skip (idempotent) |
| TA-profile present, malformed | Suppression + recreation |

### API CNX - Sequence documentee

#### 1. Token OAuth2

    TOKEN=$(curl -s -X POST "https://sso.common.cloud.hpe.com/as/token.oauth2" \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "grant_type=client_credentials" \
      -d "client_id=<CLIENT_ID>" \
      -d "client_secret=<CLIENT_SECRET>" \
      | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)

#### 2. Recuperer le scope-id numerique CNX du switch

    curl -s "https://de1.api.central.arubanetworks.com/network-config/v1alpha1/devices" \
      -H "Authorization: Bearer $TOKEN" \
      | python3 -c "
    import json,sys
    data=json.load(sys.stdin)
    for d in data.get('items',[]):
        if d.get('scopeName')=='<SERIAL>':
            print('scopeId:', d['scopeId'])
    "

#### 3. Creer le certificat dans le store CNX

Via l UI CNX : Global -> Certificate Management -> Add

- Name : clearpass-ca (max 20 caracteres)
- Type : CA
- Format : PEM
- Upload : ca.pem

#### 4. Creer le ta-profile en LIBRARY

    curl -s -X POST \
      "https://de1.api.central.arubanetworks.com/network-config/v1alpha1/certificate-rcp/clearpass-ca" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"name":"clearpass-ca","trusted-certificate":"clearpass-ca"}'

#### 5. Assigner au device

    curl -s -X PATCH \
      "https://de1.api.central.arubanetworks.com/network-config/v1alpha1/certificate-rcp/clearpass-ca?scope-id=<SCOPE_ID>" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"name":"clearpass-ca","trusted-certificate":"clearpass-ca"}'

Note (avril 2026) : L API certificate-rcp retourne SUCC_001 pour l assignation
au scope device mais ne push pas encore effectivement la config sur le switch.
Le script remediate.sh via l API REST AOS-CX directe est la methode operationnelle validee.

### Environnement teste

- Switch : HPE Aruba CX 6100 12G (JL679A) - firmware PL.10.16.1006
- CNX : New Central cluster de1 (eu-central) - avril 2026
- OS serveur : Ubuntu 22.04

---

## English

### Context

HPE Aruba New Central (CNX) may overwrite the PKI configuration of AOS-CX switches
during configuration synchronizations. This package automates the creation and
remediation of the ClearPass ta-profile via the direct AOS-CX REST API.

### Architecture

    CNX Webhook -> HTTP Listener -> remediate.sh -> AOS-CX REST API

### Prerequisites

- AOS-CX switch firmware 10.09+ (validated on CX-6100 PL.10.16)
- Direct network access to the switch from the listener server
- curl, bash, python3, nc (netcat) installed on the server
- CA certificate in PEM format

### Installation

    git clone https://github.com/Luconik/hpe-aruba-guides.git
    cd hpe-aruba-guides/cnx-pki-remediation
    cp config/settings.env.template config/settings.env
    nano config/settings.env
    cp /path/to/ca.pem certs/ca.pem
    chmod +x scripts/remediate.sh scripts/listener.sh

### Manual test

    bash scripts/remediate.sh

Expected result on the switch:

    TA Profile Name     TA Certificate    Revocation Check
    clearpass-ca        Installed, valid  disabled

### Start the webhook listener

    bash scripts/listener.sh
    # Configure NPM/Nginx: webhook.example.com -> localhost:8080

### Script behavior

| Situation | Action |
|-----------|--------|
| TA-profile missing | Create + inject cert |
| TA-profile present, valid | Skip (idempotent) |
| TA-profile present, malformed | Delete + recreate |

### CNX API - Documented sequence

#### 1. OAuth2 Token

    TOKEN=$(curl -s -X POST "https://sso.common.cloud.hpe.com/as/token.oauth2" \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "grant_type=client_credentials" \
      -d "client_id=<CLIENT_ID>" \
      -d "client_secret=<CLIENT_SECRET>" \
      | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)

#### 2. Get the CNX numeric scope-id of the switch

    curl -s "https://de1.api.central.arubanetworks.com/network-config/v1alpha1/devices" \
      -H "Authorization: Bearer $TOKEN" \
      | python3 -c "
    import json,sys
    data=json.load(sys.stdin)
    for d in data.get('items',[]):
        if d.get('scopeName')=='<SERIAL>':
            print('scopeId:', d['scopeId'])
    "

#### 3. Create the certificate in the CNX store

Via CNX UI: Global -> Certificate Management -> Add

- Name: clearpass-ca (max 20 characters)
- Type: CA
- Format: PEM
- Upload: ca.pem

#### 4. Create the ta-profile in LIBRARY

    curl -s -X POST \
      "https://de1.api.central.arubanetworks.com/network-config/v1alpha1/certificate-rcp/clearpass-ca" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"name":"clearpass-ca","trusted-certificate":"clearpass-ca"}'

#### 5. Assign to device

    curl -s -X PATCH \
      "https://de1.api.central.arubanetworks.com/network-config/v1alpha1/certificate-rcp/clearpass-ca?scope-id=<SCOPE_ID>" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"name":"clearpass-ca","trusted-certificate":"clearpass-ca"}'

Note (April 2026): The certificate-rcp API returns SUCC_001 for device scope
assignment but does not yet effectively push the config to the switch.
The remediate.sh script via direct AOS-CX REST API is the validated operational method.

### Tested environment

- Switch: HPE Aruba CX 6100 12G (JL679A) - firmware PL.10.16.1006
- CNX: New Central cluster de1 (eu-central) - April 2026
- Server OS: Ubuntu 22.04

---

## License / Licence

MIT - HPE Aruba Networking Presales, 2026

---

## Deploiement containerise / Container deployment

### Francais

#### Prerequis

- Docker + Docker Compose installes sur le serveur listener
- Acces reseau au switch depuis le serveur Docker

#### Structure

    cnx-pki-remediation/
    ├── Dockerfile
    ├── docker-compose.yml
    ├── scripts/
    │   ├── remediate.sh
    │   └── listener.sh
    ├── certs/
    │   └── ca.pem
    └── config/
        └── settings.env

#### Dockerfile

    FROM alpine:3.19
    RUN apk add --no-cache bash curl netcat-openbsd python3
    COPY scripts/ /scripts/
    RUN chmod +x /scripts/*.sh
    EXPOSE 8080
    CMD ["/scripts/listener.sh"]

#### docker-compose.yml

    services:
      ta-remediation:
        build: .
        container_name: ta-remediation
        restart: unless-stopped
        ports:
          - "8080:8080"
        volumes:
          - ./certs:/certs:ro
          - ./config/settings.env:/config/settings.env:ro
        env_file:
          - config/settings.env

#### Configuration NPM (Nginx Proxy Manager)

Creer un Proxy Host dans NPM :
- Domain : webhook.exemple.fr
- Scheme : http
- Forward Hostname : localhost
- Forward Port : 8080
- Path : /webhook/cnx

#### Demarrage

    docker compose up -d
    docker compose logs -f

---

### English

#### Prerequisites

- Docker + Docker Compose installed on the listener server
- Network access to the switch from the Docker server

#### Structure

    cnx-pki-remediation/
    ├── Dockerfile
    ├── docker-compose.yml
    ├── scripts/
    │   ├── remediate.sh
    │   └── listener.sh
    ├── certs/
    │   └── ca.pem
    └── config/
        └── settings.env

#### Dockerfile

    FROM alpine:3.19
    RUN apk add --no-cache bash curl netcat-openbsd python3
    COPY scripts/ /scripts/
    RUN chmod +x /scripts/*.sh
    EXPOSE 8080
    CMD ["/scripts/listener.sh"]

#### docker-compose.yml

    services:
      ta-remediation:
        build: .
        container_name: ta-remediation
        restart: unless-stopped
        ports:
          - "8080:8080"
        volumes:
          - ./certs:/certs:ro
          - ./config/settings.env:/config/settings.env:ro
        env_file:
          - config/settings.env

#### NPM (Nginx Proxy Manager) configuration

Create a Proxy Host in NPM:
- Domain: webhook.example.com
- Scheme: http
- Forward Hostname: localhost
- Forward Port: 8080
- Path: /webhook/cnx

#### Start

    docker compose up -d
    docker compose logs -f

