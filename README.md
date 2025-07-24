<p align="center">
<img src="https://raw.githubusercontent.com/zenthracore/zen.falcon/main/assets/zenthra.png" width="120" alt="ZENTHRA logo" />
</p>

<h1 align="center">zen.nodejs</h1>
<p align="center">
Alpine-based Node.js + OpenSSL 3.3.4 image with Falcon post-quantum crypto and oqs-provider.<br>
<strong>Silence is infrastructure.</strong>
</p>

---

## What is this?

`zen.nodejs` is a minimal Alpine Linux container featuring:

- Node.js **v24.4.1** (built from source)
- OpenSSL **3.3.4** (built July 2025)
- Integrated [`oqs-provider`](https://github.com/open-quantum-safe/oqs-provider) for OpenSSL 3.x
- Post-quantum algorithms: **Falcon512 / Falcon1024** from [NIST PQC standards](https://csrc.nist.gov/projects/post-quantum-cryptography)
- Working `openssl.cnf` with dynamic provider loading
- Full CLI support for:
  - `genpkey`, `req`, `x509` with Falcon keys
  - `openssl list -providers`, `openssl list -public-key-algorithms`
  - **Node.js** CLI and runtime

---

## Use cases

- Building **post-quantum-ready Node.js microservices**
- Generating **Falcon-based TLS certificates** directly inside your Node.js containers
- Running **secure, mTLS-enforced Node.js endpoints** with PQC support
- Using as a **base image** for your Node.js projects requiring hardened cryptography
- Integrating Falcon/OQS into **CI/CD pipelines**, signing, verification (`cosign`, `sigstore`, etc.)
- Testing next-gen PQC infrastructure in containerized Node.js apps

---

## Quick start

### 1. Clone and build the image
```bash
git clone https://github.com/zenthracore/zen.nodejs.git
cd zen.nodejs
```

### 2. Build the image locally
```bash
docker build -t zenthracore/zen.nodejs .
```

### 3. Run the container
```bash
docker run -it --rm zenthracore/zen.nodejs sh
```
or run Node directly:
```bash
docker run -it --rm zenthracore/zen.nodejs node
```

### 4. Generate Falcon key and cert
```bash
# Generate Falcon1024 private key
openssl genpkey -algorithm falcon1024 -out server.key

# Generate CSR
openssl req -new -key server.key -out server.csr \
-subj "/C=UA/ST=Kyiv/L=Kyiv/O=ZENTHRACORE/CN=api.example.com"

# Self-sign certificate
openssl x509 -req -in server.csr -signkey server.key -out server.crt -days 365
```
## Provider check
```bash
openssl version
openssl list -providers
openssl list -public-key-algorithms
```
You should see oqsprovider active and Falcon listed among the algorithms.

## Node.js check
```bash
node -v
```

## License
- Falcon: MIT
- oqs-provider: Apache-2.0 + BSD-compatible
- OpenSSL 3.3.4: Apache 2.0
- Node.js: MIT
- Everything in this repo: MIT

## About ZENTHRACORE
Silence is infrastructure.<br>
ZENTHRACORE is a minimal security-first stack for post-quantum, zero-trust, hardened systems.

## Contact
- 🐘 Mastodon: @zenthracore@mastodon.social
- 🧑‍💻 DEV.to: https://dev.to/zenthracore
- 📧 Email: zenthracore@proton.me
- ⚡ Damus (Nostr): npub1msz8ejzagf5z760c74d6svrpmqcd3nq6ffhrq7akesege9dq748sjlul4s