#!/bin/bash
set -e
source /home/nico/ta-remediation/config/settings.env
LOG="[$(date '+%Y-%m-%d %H:%M:%S')]"

echo "${LOG} === Remediation START ==="

# 1. Login switch
echo "${LOG} Login switch ${SWITCH_IP}..."
curl -sk -c /tmp/aoscx_cookie.txt \
  -X POST "https://${SWITCH_IP}/rest/latest/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=${SWITCH_USER}&password=${SWITCH_PASS}" \
  -o /dev/null -w "%{http_code}" > /tmp/login_code.txt

LOGIN_CODE=$(cat /tmp/login_code.txt)
if [ "$LOGIN_CODE" != "200" ]; then
  echo "${LOG} ERROR: Login failed (HTTP ${LOGIN_CODE})"
  exit 1
fi
echo "${LOG} Login OK"

# 2. Vérifier si ta-profile existe déjà
echo "${LOG} Checking existing ta-profile..."
STATUS=$(curl -sk -b /tmp/aoscx_cookie.txt \
  "https://${SWITCH_IP}/rest/latest/system/pki_ta_profiles/${TA_PROFILE_NAME}" \
  -o /dev/null -w "%{http_code}")

if [ "$STATUS" == "200" ]; then
  # Vérifier si valid ou malformed
  CERT_STATUS=$(curl -sk -b /tmp/aoscx_cookie.txt \
    "https://${SWITCH_IP}/rest/latest/system/pki_ta_profiles/${TA_PROFILE_NAME}" \
    | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('certificate_status','unknown'))")
  
  if [ "$CERT_STATUS" == "valid" ]; then
    echo "${LOG} ta-profile ${TA_PROFILE_NAME} already valid, skipping"
    curl -sk -b /tmp/aoscx_cookie.txt \
      -X POST "https://${SWITCH_IP}/rest/latest/logout" -o /dev/null
    exit 0
  else
    echo "${LOG} ta-profile exists but status=${CERT_STATUS}, deleting..."
    curl -sk -b /tmp/aoscx_cookie.txt \
      -X DELETE "https://${SWITCH_IP}/rest/latest/system/pki_ta_profiles/${TA_PROFILE_NAME}" \
      -o /dev/null
  fi
fi

# 3. Préparer et injecter le cert
echo "${LOG} Injecting certificate..."
CERT_INLINE=$(cat "${CERT_FILE}" | tr -d '\r' | awk '{printf "%s\\n", $0}' | tr -d '\n')

HTTP_CODE=$(curl -sk -b /tmp/aoscx_cookie.txt \
  -X POST "https://${SWITCH_IP}/rest/latest/system/pki_ta_profiles" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"${TA_PROFILE_NAME}\", \"certificate\": \"${CERT_INLINE}\"}" \
  -o /dev/null -w "%{http_code}")

if [ "$HTTP_CODE" == "201" ]; then
  echo "${LOG} SUCCESS: ta-profile ${TA_PROFILE_NAME} created (HTTP 201)"
else
  echo "${LOG} ERROR: Creation failed (HTTP ${HTTP_CODE})"
  curl -sk -b /tmp/aoscx_cookie.txt \
    -X POST "https://${SWITCH_IP}/rest/latest/logout" -o /dev/null
  exit 1
fi

# 4. Logout
curl -sk -b /tmp/aoscx_cookie.txt \
  -X POST "https://${SWITCH_IP}/rest/latest/logout" -o /dev/null
echo "${LOG} === Remediation END ==="
