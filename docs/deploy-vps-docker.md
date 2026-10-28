# Deploy the Skeleton App to a clean Ubuntu VPS

This procedure installs the public website and a new database from the current
repository. It does not copy an existing database. The separate WBengine Admin
application remains local and connects to this website over its API when it is
configured.

## Requirements

- Ubuntu 24.04 VPS with DNS `www.wbengine.org` pointed to its public IPv4 address
- Root SSH access
- Docker Engine and the Docker Compose plugin
- Ports 80 and 443 allowed by the VPS firewall

The PHP site and MySQL run in Docker. Nginx terminates HTTPS on the host and
proxies only to `127.0.0.1:8080`. MySQL has no published host port.

## First installation

Clone this repository to `/opt/wbengine-skeleton-app`, then run:

```sh
cd /opt/wbengine-skeleton-app
./bin/setup-production.sh
```

The script generates `.env` and `src/Config/Settings.json` with server-only
random secrets, builds the production PHP image, creates an empty MySQL volume,
imports the tracked schema and current content seed, applies the framework API
and analytics table migrations, and disables the public demo account by
replacing its password with an unknown random value. It does not enable native
analytics collection. Keep `.env` and `Settings.json` private; both are ignored
by Git.

## Nginx and HTTPS

Install Nginx and Certbot, create `/var/www/letsencrypt`, and install the
HTTP-only server block. Enable the site and obtain the certificate:

```sh
ln -s /opt/wbengine-skeleton-app/deploy/nginx/www.wbengine.org-http.conf /etc/nginx/sites-enabled/www.wbengine.org.conf
nginx -t && systemctl reload nginx
certbot certonly --webroot -w /var/www/letsencrypt -d www.wbengine.org
```

Replace the symlink with the complete TLS configuration, test it and reload
Nginx:

```sh
ln -sfn /opt/wbengine-skeleton-app/deploy/nginx/www.wbengine.org.conf /etc/nginx/sites-enabled/www.wbengine.org.conf
nginx -t && systemctl reload nginx
certbot renew --dry-run --no-random-sleep-on-renew
```

The apex domain can continue redirecting to `www` at its existing DNS host. The
VPS needs only the `www` DNS record and certificate.

## Updates and checks

Fetch the reviewed commit, then rebuild and restart:

```sh
git pull --ff-only
docker compose -f docker-compose.production.yml up -d --build --wait
docker compose -f docker-compose.production.yml ps
docker compose -f docker-compose.production.yml logs --tail=100 web db
```

Check `/`, `/cs/`, `/docs/`, `/cs/docs/` and the API capabilities endpoint over
HTTPS. Do not restore the demo password or expose port 3306. The database volume
is persistent, but this clean-install guide does not configure backups.
