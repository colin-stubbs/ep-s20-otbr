#!/usr/bin/env bash
#
# Generate a certificate signing request for the OTA self-signed CA.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

SERVER_CERTS_DIR="${SERVER_CERTS_DIR:-${REPO_ROOT}/s20-otbr/server_certs}"
OPENSSL_CNF="${OPENSSL_CNF:-${SERVER_CERTS_DIR}/openssl.cnf}"
KEY_FILE="${KEY_FILE:-${SERVER_CERTS_DIR}/ca_key.pem}"
CSR_FILE="${CSR_FILE:-${SERVER_CERTS_DIR}/ca_csr.pem}"

# Optional distinguished-name overrides (applied via a generated config snippet).
CERT_C="${CERT_C:-}"
CERT_ST="${CERT_ST:-}"
CERT_O="${CERT_O:-}"
CERT_CN="${CERT_CN:-}"

die() {
    echo "ERROR: $*" >&2
    exit 1
}

command -v openssl >/dev/null 2>&1 || die "openssl is required but was not found in PATH"
[[ -f "${OPENSSL_CNF}" ]] || die "OpenSSL config not found: ${OPENSSL_CNF}"
[[ -f "${KEY_FILE}" ]] || die "Private key not found: ${KEY_FILE} (run: make ca-key)"

mkdir -p "${SERVER_CERTS_DIR}"

if [[ -f "${CSR_FILE}" ]]; then
    die "Refusing to overwrite existing CSR: ${CSR_FILE} (remove it first or set CSR_FILE)"
fi

config_file="${OPENSSL_CNF}"
tmp_cnf=""

if [[ -n "${CERT_C}${CERT_ST}${CERT_O}${CERT_CN}" ]]; then
    tmp_cnf="$(mktemp)"
    cp "${OPENSSL_CNF}" "${tmp_cnf}"
    {
        echo ""
        echo "[ req_distinguished_name ]"
        [[ -n "${CERT_C}" ]] && echo "C  = ${CERT_C}"
        [[ -n "${CERT_ST}" ]] && echo "ST = ${CERT_ST}"
        [[ -n "${CERT_O}" ]] && echo "O  = ${CERT_O}"
        [[ -n "${CERT_CN}" ]] && echo "CN = ${CERT_CN}"
    } >> "${tmp_cnf}"
    config_file="${tmp_cnf}"
fi

openssl req -new \
    -key "${KEY_FILE}" \
    -out "${CSR_FILE}" \
    -config "${config_file}" \
    -extensions req_ext

[[ -n "${tmp_cnf}" ]] && rm -f "${tmp_cnf}"

echo "Generated CSR: ${CSR_FILE}"
