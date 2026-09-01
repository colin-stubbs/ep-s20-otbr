* 2026-06-10 - Add OTA CA certificate generation tooling

- Add root `Makefile` with `ca-key`, `ca-csr`, `ca-cert`, `ca-all`, `ca-clean`, and `ca-show` targets
- Add `utils/generate_ca_key.sh`, `utils/generate_ca_csr.sh`, and `utils/sign_ca_cert.sh`
- Add `s20-otbr/server_certs/openssl.cnf` and `.gitignore` for generated key material
- Fix OpenSSL CSR extensions so `authorityKeyIdentifier` is only applied at certificate signing time
- Document OTA CA regeneration workflow in `README.md`
