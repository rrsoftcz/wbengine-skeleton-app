# SSL Certificates

This directory contains SSL certificates for the application.

**Important:** Certificates are NOT tracked in git. Each environment manages its own.

---

## Quick Reference

| Environment | Hostname | Certificate Source | Managed By |
|-------------|----------|-------------------|------------|
| Development | wbengine.local | mkcert | Developer (manual) |
| Production | wbengine.rrsoft.cz | Let's Encrypt | certbot (automatic) |

---

## Development Setup (Step by Step)

### Step 1: Install mkcert

**macOS:**
```bash
brew install mkcert
```

**Ubuntu/Debian:**
```bash
sudo apt install mkcert
```

### Step 2: Install Local CA

This adds a root certificate to your system's trust store (one-time per machine):

```bash
mkcert -install
```

### Step 3: Add Hostname to /etc/hosts

```bash
echo "127.0.0.1 wbengine.local" | sudo tee -a /etc/hosts
```

### Step 4: Generate Certificates

Run this from the `etc/cert` directory:

```bash
mkcert -cert-file fullchain.cer -key-file wbengine.local.key wbengine.local localhost 127.0.0.1 ::1
```

**Output files:**
- `fullchain.cer` - Certificate (valid ~27 months)
- `wbengine.local.key` - Private key

### Step 5: Start Docker

```bash
docker-compose up -d
```

### Step 6: Open in Browser

```
https://wbengine.local
```

---

## Production Setup

Certificates are managed automatically by **certbot** (Let's Encrypt).

**Expected files:**
- `fullchain.cer` - Full certificate chain
- `wbengine.rrsoft.cz.key` - Private key

**Auto-renewal:** Handled by cron every 3 months. No manual action required.

---

## Troubleshooting

### Browser shows SSL warning

1. Re-run: `mkcert -install`
2. Regenerate certs (Step 4)
3. Restart browser

### Certificate expired

Regenerate using Step 4. mkcert certs last ~27 months.
