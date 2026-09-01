#!/usr/bin/env bash
#
# Sign the OTA CA CSR as a self-signed CA certificate.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

SERVER_CERTS_DIR="${SERVER_CERTS_DIR:-${REPO_ROOT}/s20-otbr/server_certs}"
OPENSSL_CNF="${OPENSSL_CNF:-${SERVER_CERTS_DIR}/openssl.cnf}"
KEY_FILE="${KEY_FILE:-${SERVER_CERTS_DIR}/ca_key.pem}"
CSR_FILE="${CSR_FILE:-${SERVER_CERTS_DIR}/ca_csr.pem}"
CERT_FILE="${CERT_FILE:-${SERVER_CERTS_DIR}/ca_cert.pem}"
CERT_DAYS="${CERT_DAYS:-3650}"

die() {
    echo "ERROR: $*" >&2
    exit 1
}

command -v openssl >/dev/null 2>&1 || die "openssl is required but was not found in PATH"
[[ -f "${OPENSSL_CNF}" ]] || die "OpenSSL config not found: ${OPENSSL_CNF}"
[[ -f "${KEY_FILE}" ]] || die "Private key not found: ${KEY_FILE} (run: make ca-key)"
[[ -f "${CSR_FILE}" ]] || die "CSR not found: ${CSR_FILE} (run: make ca-csr)"

mkdir -p "${SERVER_CERTS_DIR}"

if [[ -f "${CERT_FILE}" ]]; then
    die "Refusing to overwrite existing certificate: ${CERT_FILE} (run: make ca-clean first or set CERT_FILE)"
fi

openssl x509 -req \
    -in "${CSR_FILE}" \
    -signkey "${KEY_FILE}" \
    -out "${CERT_FILE}" \
    -days "${CERT_DAYS}" \
    -sha256 \
    -extfile "${OPENSSL_CNF}" \
    -extensions v3_ca

echo "Issued self-signed CA certificate: ${CERT_FILE}"
echo "Valid for ${CERT_DAYS} days."
openssl x509 -in "${CERT_FILE}" -noout -subject -dates -fingerprint -sha256
