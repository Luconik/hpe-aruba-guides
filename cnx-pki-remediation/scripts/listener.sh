#!/bin/bash
PORT=8080
REMEDIATE_SCRIPT="/home/nico/ta-remediation/scripts/remediate.sh"
LOG_FILE="/home/nico/ta-remediation/listener.log"

echo "[$(date)] Listener starting on port ${PORT}" | tee -a "${LOG_FILE}"

while true; do
  # Attendre une connexion, lire la requête, répondre 200 OK
  REQUEST=$(echo -e "HTTP/1.1 200 OK\r\nContent-Length: 2\r\nConnection: close\r\n\r\nOK" \
    | nc -l -p "${PORT}" -q 1 2>/dev/null)
  
  echo "[$(date)] Webhook received" | tee -a "${LOG_FILE}"
  echo "${REQUEST}" >> "${LOG_FILE}"
  
  # Lancer la remédiation en background
  bash "${REMEDIATE_SCRIPT}" >> "${LOG_FILE}" 2>&1 &
done
