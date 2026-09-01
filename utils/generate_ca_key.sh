#!/usr/bin/env bash
#
# Generate a new RSA private key for the OTA self-signed CA.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

SERVER_CERTS_DIR="${SERVER_CERTS_DIR:-${REPO_ROOT}/s20-otbr/server_certs}"
KEY_BITS="${KEY_BITS:-2048}"
KEY_FILE="${KEY_FILE:-${SERVER_CERTS_DIR}/ca_key.pem}"

die() {
    echo "ERROR: $*" >&2
    exit 1
}

command -v openssl >/dev/null 2>&1 || die "openssl is required but was not found in PATH"

mkdir -p "${SERVER_CERTS_DIR}"

if [[ -f "${KEY_FILE}" ]]; then
    die "Refusing to overwrite existing key: ${KEY_FILE} (remove it first or set KEY_FILE)"
fi

umask 077
openssl genrsa -out "${KEY_FILE}" "${KEY_BITS}"
chmod 600 "${KEY_FILE}"

echo "Generated private key: ${KEY_FILE}"
