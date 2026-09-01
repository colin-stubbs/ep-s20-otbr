# OTA self-signed CA certificate tooling for ep-s20-otbr.
#
# Typical workflow:
#   make ca-clean ca-all
#
# Override paths or subject fields, for example:
#   make ca-csr CERT_CN=ota.example.com CERT_O="My Org"
#   make ca-cert CERT_DAYS=825

SHELL := /bin/bash

REPO_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
UTILS_DIR := $(REPO_ROOT)/utils
SERVER_CERTS_DIR ?= $(REPO_ROOT)/s20-otbr/server_certs

OPENSSL_CNF ?= $(SERVER_CERTS_DIR)/openssl.cnf
KEY_FILE ?= $(SERVER_CERTS_DIR)/ca_key.pem
CSR_FILE ?= $(SERVER_CERTS_DIR)/ca_csr.pem
CERT_FILE ?= $(SERVER_CERTS_DIR)/ca_cert.pem

KEY_BITS ?= 2048
CERT_DAYS ?= 3650

# Optional distinguished-name overrides passed through to generate_ca_csr.sh
export CERT_C CERT_ST CERT_O CERT_CN

.PHONY: help ca-key ca-csr ca-cert ca-all ca-clean ca-show

help:
	@echo "OTA CA certificate targets:"
	@echo "  make ca-key      Generate a new RSA private key ($(KEY_BITS) bits)"
	@echo "  make ca-csr      Generate a CSR from the private key"
	@echo "  make ca-cert     Sign the CSR as a self-signed CA certificate"
	@echo "  make ca-all      Run ca-key, ca-csr, and ca-cert in sequence"
	@echo "  make ca-show     Display certificate details"
	@echo "  make ca-clean    Remove generated key, CSR, and certificate"
	@echo ""
	@echo "Artifacts are written under: $(SERVER_CERTS_DIR)"
	@echo "Environment overrides: SERVER_CERTS_DIR, KEY_FILE, CSR_FILE, CERT_FILE,"
	@echo "KEY_BITS, CERT_DAYS, CERT_C, CERT_ST, CERT_O, CERT_CN"

ca-key:
	@KEY_BITS='$(KEY_BITS)' KEY_FILE='$(KEY_FILE)' SERVER_CERTS_DIR='$(SERVER_CERTS_DIR)' \
		'$(UTILS_DIR)/generate_ca_key.sh'

ca-csr:
	@KEY_FILE='$(KEY_FILE)' CSR_FILE='$(CSR_FILE)' SERVER_CERTS_DIR='$(SERVER_CERTS_DIR)' \
		OPENSSL_CNF='$(OPENSSL_CNF)' \
		'$(UTILS_DIR)/generate_ca_csr.sh'

ca-cert:
	@KEY_FILE='$(KEY_FILE)' CSR_FILE='$(CSR_FILE)' CERT_FILE='$(CERT_FILE)' \
		SERVER_CERTS_DIR='$(SERVER_CERTS_DIR)' OPENSSL_CNF='$(OPENSSL_CNF)' CERT_DAYS='$(CERT_DAYS)' \
		'$(UTILS_DIR)/sign_ca_cert.sh'

ca-all: ca-key ca-csr ca-cert

ca-show:
	@test -f '$(CERT_FILE)' || (echo "Certificate not found: $(CERT_FILE)" >&2; exit 1)
	@openssl x509 -in '$(CERT_FILE)' -noout -text

ca-clean:
	@rm -f '$(KEY_FILE)' '$(CSR_FILE)' '$(CERT_FILE)' '$(SERVER_CERTS_DIR)'/*.srl
	@echo "Removed generated CA artifacts from $(SERVER_CERTS_DIR)"
