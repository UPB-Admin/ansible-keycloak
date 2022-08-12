#!/bin/bash

##
## This script is managed by ansible. Manual overrides may be overwritten
##

# Inspired by scripts such as https://icicimov.github.io/blog/server/HAProxy-OCSP-stapling/

set -eu

cert="$1"

if [ $(grep -e '-----BEGIN CERTIFICATE-----' "${cert}" | wc -l) -gt 1 ]; then
    # Extract the issuer's certificate
    isscert=$(awk '/-----BEGIN CERTIFICATE-----/ { cn++ }; cn == 2 { print }; /-----END CERTIFICATE-----/ && cn == 2 { exit }' "${cert}")
else
    isscert=$(cat "${cert}.issuer")
fi

ocsp_url=$(openssl x509 -ocsp_uri -in "${cert}" -noout)

if [ -z "${isscert}" ]; then
    echo "Could not get issuer certificate. Exiting" >&2
    exit 1
fi

if [ -z "${ocsp_url}" ]; then
    echo "Undefined ocsp URL. Exiting" >&2
    exit 2
fi

openssl ocsp -issuer <(echo "${isscert}") -cert "${cert}" -url "${ocsp_url}" -noverify -respout "${cert}.ocsp" >/dev/null

if [ $? -eq 0 ] && killall -0 /usr/sbin/haproxy 2>/dev/null; then
    b64ocsp=$(base64 -w10000 "${cert}.ocsp")
    echo "set ssl ocsp-response ${b64ocsp}" | socat stdio /var/run/haproxy/admin.sock
fi
