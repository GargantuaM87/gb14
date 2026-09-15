#!/usr/bin/env bash

# Disable Git Bash path rewriting so /CN=localhost is preserved
export MSYS2_ARG_CONV_EXCL="*"

CERT_FILE="cert.pem"
KEY_FILE="key.pem"
DAYS_LEFT_THRESHOLD=30

needs_new_cert=true

# Check if cert.pem exists
if [[ -f "$CERT_FILE" ]]; then
  # Extract expiration date (notAfter) in seconds since epoch
  exp_date=$(openssl x509 -enddate -noout -in "$CERT_FILE" | sed 's/notAfter=//')
  exp_epoch=$(date -d "$exp_date" +%s 2>/dev/null)

  # Current time in epoch seconds
  now_epoch=$(date +%s)

  # Days until expiration
  days_left=$(( (exp_epoch - now_epoch) / 86400 ))

  if (( days_left > DAYS_LEFT_THRESHOLD )); then
    echo "Existing certificate is valid for another $days_left days. Reusing it."
    needs_new_cert=false
  else
    echo "Certificate expires in $days_left days. Regenerating."
  fi
else
  echo "No certificate found. Generating a new one."
fi

# Generate new cert if needed
if [[ "$needs_new_cert" = true ]]; then
  openssl req -x509 -newkey rsa:2048 -nodes \
    -keyout "$KEY_FILE" -out "$CERT_FILE" -days 365 \
    -subj "/CN=localhost"
fi

# Start HTTPS server
npx http-server -c-1 --ssl --cert "$CERT_FILE" --key "$KEY_FILE" -a localhost