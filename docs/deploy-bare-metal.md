# Deploy the Skeleton App without Docker

This guide installs the site on a server where you manage PHP, the web server and the database yourself: a VPS, a dedicated machine or a managed host. It is the source of truth for the live page `/docs/deployment/`. The Docker route has its own guide: [Deploy to a clean Ubuntu VPS with Docker](deploy-vps-docker.md). Every key of `Settings.json` is explained in the settings reference (`/docs/settings/`).

## Requirements

- PHP 8.3 or newer (8.4 is the development target) with the extensions `mysqli`, `json`, `mbstring`, `fileinfo`, `curl`, `zip` and `opcache`. `zip` and `curl` are used by Composer, `opcache` keeps the compiled templates in memory.
- Composer 2 on the machine that installs the dependencies (it can be your workstation).
- MySQL 8 or MariaDB 10.6 or newer (box selection uses `JSON_SEARCH`).
- A web server that sends every request that is not a file to `public/index.php`: Nginx with PHP-FPM, or Apache with `mod_rewrite` and either `mod_php` or PHP-FPM.
- HTTPS in front of the site. Plain HTTP is fine only for a local test.

## 1. Get the code and the dependencies

```sh
git clone https://github.com/rrsoftcz/wbengine-skeleton-app.git /var/www/wbengine-skeleton-app
cd /var/www/wbengine-skeleton-app
git checkout <release tag>
php bin/wbe install --no-dev
```

`bin/wbe install` creates `src/Config/Settings.json` from `settings.json.default` when the file is missing (an existing file is only validated, never overwritten), creates `src/View/Compiled`, and runs `composer install --no-dev` from the lock file. For a production build you can run `composer install --no-dev --optimize-autoloader` instead.

The document root of the web server is the `public/` directory. Never point it at the project root: `src/`, `vendor/`, `schemas/` and `bin/` must not be reachable from the web.

## 2. Database and migration order

Create an empty database with the `utf8mb4` character set and a user that has rights only on it:

```sql
CREATE DATABASE wbengine_skeleton_app CHARACTER SET utf8mb4;
CREATE USER 'wbengine'@'127.0.0.1' IDENTIFIED BY 'a long random password';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX, DROP ON wbengine_skeleton_app.* TO 'wbengine'@'127.0.0.1';
```

The schema and the content dump are imported in this order, then the framework tables (API, analytics and change log) are created from the files shipped with the installed framework, so they always match its version:

```sh
mysql wbengine_skeleton_app < schemas/wbengine_skeletone_app_mysql_template.sql
mysql wbengine_skeleton_app < schemas/wbengine_skeletone_app_mysql_template_content.sql
sh bin/update-database.sh wbengine_skeleton_app
```

The script applies the same framework updates as the Docker installer and is safe to run again. The change log columns are required for sites that use API v2: `doctor` fails without them.

An existing installation that is upgraded to a new release applies only the new files from `schemas/migrations/` once and in numeric order (each content migration is idempotent), after a backup. A new framework release may add files under `vendor/wbengine/wbengine/migrations/`; check with `vendor/bin/wbengine.php migration:status`.

Then edit `dbAdapterDefinition` in `Settings.json` (host, database, user, password, `charset`). Create your own administrator and remove the demo account (`admin@example.com` / `changeme`, never leave it enabled):

```sh
php bin/wbe user:create --email=you@example.com --role=admin
php bin/wbe user:delete --example
```

## 3. Settings.json and secrets

Keep `Settings.json` out of version control and readable only by the deploy user and the PHP user (`chmod 640`, group of the PHP user). Put the secrets in the environment of the PHP process instead of the file: `WBENGINE_RECAPTCHA_SECRET`, and optionally `WBENGINE_DEBUG` and `WBENGINE_IMAGE_DIR`. With PHP-FPM, set them in the pool file:

```ini
; /etc/php/8.4/fpm/pool.d/wbengine.conf
env[WBENGINE_RECAPTCHA_SECRET] = "..."
```

A complete production-ready file is shown on the settings page (`/docs/settings/`). The minimum for production: `debug` off, `cache` on, `renderer.compileCheck` false, `i18n.baseUrl` set to the public address, `http.trustedProxies` set when a proxy sits in front, and explicit absolute directories for runtime files (next section). After the first deploy run `php vendor/bin/wbengine.php config:check --config=src/Config/Settings.json --root=src`.

## 4. Writable paths and permissions

PHP runs as one user (for example `www-data`). Give that user write access only where the application writes, using ownership or a restricted group, never `chmod 777`:

| Path | Purpose | Setting |
|------|---------|---------|
| `src/View/Compiled/` | compiled templates | `renderer.compiledDir` |
| `/var/lib/wbengine/counters` | batched article view counters | `counters.views.dir` |
| `/var/lib/wbengine/ratelimit` | login rate limit counters | `rateLimit.login.dir` |
| `/var/cache/wbengine` | file cache and page cache | `cache.dir` |
| `/var/lib/wbengine/images` | images uploaded through API v2 | `apiV2.imageDirectory` or `WBENGINE_IMAGE_DIR` |

```sh
install -d -o www-data -g www-data -m 2770 /var/lib/wbengine/counters /var/lib/wbengine/ratelimit /var/lib/wbengine/images /var/cache/wbengine
chown -R www-data:www-data src/View/Compiled && chmod 2775 src/View/Compiled
```

If you leave the directories unset, the framework uses subdirectories of the system temporary directory. Under systemd with `PrivateTmp=true` (the default for PHP-FPM on many distributions) that directory disappears on restart and is not shared with the command line, so set explicit paths. The image directory must be outside `public/`; images are served by the application as bytes.

When `renderer.compileCheck` is `false`, templates are not checked for changes: after every deploy empty the compiled directory (`rm -f src/View/Compiled/*`) and flush the cache (see section 9).

## 5. PHP-FPM with Nginx

Install `nginx`, `php8.4-fpm` and the extensions, then use the ready server block `etc/nginx/wbengine-fpm.conf`, which is derived from the Docker one but talks to a unix socket:

```sh
cp etc/nginx/wbengine-fpm.conf /etc/nginx/sites-available/wbengine.conf
# edit server_name, root and the fastcgi_pass socket
ln -s /etc/nginx/sites-available/wbengine.conf /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```

Only `/index.php` is executed (marked `internal`), direct `*.php` requests answer 404, and `src`, `vendor`, `schemas`, `bin` and `etc` are denied even if the root is wrong. Use opcache in production (`opcache.enable=1`, `opcache.validate_timestamps=0` together with a PHP-FPM reload on deploy gives the best result; the default of validating timestamps also works). In `php.ini` keep `display_errors = Off` and `log_errors = On`.

## 6. Apache

With `mod_php` or PHP-FPM, `public/.htaccess` does the routing, so the virtual host needs `AllowOverride All` on `public/`. A documented template is `etc/apache2/sites-available/wbengine-production.conf`:

```sh
a2enmod rewrite headers ssl
cp etc/apache2/sites-available/wbengine-production.conf /etc/apache2/sites-available/wbengine.conf
# replace every value marked CHANGE
a2ensite wbengine && apache2ctl configtest && systemctl reload apache2
```

For PHP-FPM add the `SetHandler "proxy:unix:/run/php/php8.4-fpm.sock|fcgi://localhost"` block that the template shows and enable `proxy_fcgi`. With `mod_php`, set secrets with `SetEnv` in the virtual host only if the host cannot use the environment of another service; the PHP-FPM pool `env[]` entries are cleaner.

## 7. HTTPS and trusted proxy headers

Obtain a certificate (`certbot --nginx` or `certbot --apache`) and redirect HTTP to HTTPS. When PHP itself is behind a reverse proxy, a load balancer or a container network, the framework sees the proxy as the client and the request as plain HTTP unless you opt in to forwarded metadata:

```json
"http": {
  "trustedProxies": ["127.0.0.1", "10.0.0.0/24"],
  "forwardedHeaders": ["x-forwarded-for", "x-forwarded-proto"]
}
```

List only the addresses of proxies you operate, and make each proxy overwrite `X-Forwarded-Proto` with the external scheme and build `X-Forwarded-For` from the real connection. Without it secure cookies, `/integrations/`, absolute locale links and rate limit keys are wrong. When the web server terminates TLS itself (the Nginx or Apache above), leave both lists empty. Set `i18n.baseUrl` so the `hreflang` links do not depend on the `Host` header.

## 8. Cron

Native analytics keeps daily aggregates for `analytics.retentionDays`. Prune the expired rows daily:

```cron
17 3 * * * www-data /usr/bin/php /var/www/wbengine-skeleton-app/vendor/bin/wbengine.php analytics:prune --config=/var/www/wbengine-skeleton-app/src/Config/Settings.json --root=/var/www/wbengine-skeleton-app/src >> /var/log/wbengine-cron.log 2>&1
```

The job reads the same environment secrets, so run it as the web user with the same variables (for example by sourcing a root-owned file in the crontab line). Framework 4.8.0 adds the change log and audit tables, which also need daily pruning (`audit.retentionDays`, see the page Logging and audit at `/docs/logging/`):

```cron
27 3 * * * www-data /usr/bin/php /var/www/wbengine-skeleton-app/vendor/bin/wbengine.php audit:prune --config=/var/www/wbengine-skeleton-app/src/Config/Settings.json --root=/var/www/wbengine-skeleton-app/src >> /var/log/wbengine-cron.log 2>&1
```

## 9. Updates, backup and rollback

Back up before every deploy: the database, `Settings.json`, the image directory and the pool or environment file with secrets.

```sh
mysqldump --single-transaction --routines wbengine_skeleton_app | gzip > /var/backups/wbengine-$(date +%F).sql.gz
tar czf /var/backups/wbengine-files-$(date +%F).tgz src/Config/Settings.json /var/lib/wbengine/images
```

Update:

```sh
git fetch --tags && git checkout <new tag>
composer install --no-dev --optimize-autoloader
# apply new files from schemas/migrations/ (in order) and framework migrations, if any
rm -f src/View/Compiled/*
php vendor/bin/wbengine.php doctor --config=src/Config/Settings.json --root=src
systemctl reload php8.4-fpm
```

Flush the cache with `POST /api/v2/cache/flush` (integration key with the `cache:write` scope, for example from the central administration), or remove the files in `cache.dir`. For APCu cache restart PHP-FPM.

Rollback: check out the previous tag, run `composer install --no-dev`, empty the compiled directory, reload PHP-FPM. Migrations are not reversed automatically: if one changed the schema, restore the database dump taken before the deploy. Content migrations only change text and are safe to leave in place.

## 10. Logs

| Log | Typical location |
|-----|------------------|
| Nginx | `/var/log/nginx/access.log`, `error.log` |
| Apache | `${APACHE_LOG_DIR}` (`/var/log/apache2/`), the files named in the virtual host |
| PHP-FPM | `/var/log/php8.4-fpm.log`, pool slow log if enabled |
| PHP errors | the `error_log` ini value, otherwise the web server error log |
| Application | the framework writes through `error_log` (for example "cache disabled: ..." when the cache directory is not writable) |

## 11. Health checks

```sh
php vendor/bin/wbengine.php doctor --config=src/Config/Settings.json --root=src
php vendor/bin/wbengine.php config:check --config=src/Config/Settings.json --root=src
php vendor/bin/wbengine.php migration:status --config=src/Config/Settings.json --root=src
curl -sI https://example.com/ | head -1
curl -sI https://example.com/cs/docs/ | head -1
curl -s https://example.com/api/v2/capabilities
```

`doctor` checks secrets, debug, cache and directory state without changing the schema, `config:check` validates the settings file, `migration:status` shows which framework migrations are applied. They exit with 0 when healthy and 1 when a check fails, so they fit a deploy script. The command line uses its own PHP configuration: verify web-SAPI opcache, the web user permissions and HTTPS separately with real requests.

## Hybrid layouts

### Host Nginx in front of containers

Run PHP and MySQL in Docker and keep TLS on the host. This is exactly the setup of [Deploy to a clean Ubuntu VPS with Docker](deploy-vps-docker.md): the container is published only on `127.0.0.1:8080`, host Nginx proxies to it and the installer writes the matching `http.trustedProxies`.

### External managed database

Point `dbAdapterDefinition.hostname` at the managed MySQL or MariaDB service and import the schema, content and migrations of section 2 with the `mysql` client from a machine that can reach it (the `docker-entrypoint-initdb.d` import only exists for the bundled database). Use a dedicated user and database, allow connections only from the application host, and enable TLS on the server side when it crosses a network. In a Compose file, remove the `db` service and the `depends_on` entry. Check that the database version meets the requirements (`JSON_SEARCH`).

### Shared hosting

It works when the host offers PHP 8.3 or newer with the extensions above, MySQL or MariaDB, `mod_rewrite` and `.htaccess`, and lets you set the document root to `public/` (otherwise the project cannot be installed safely). Limits to expect: no shell or cron, so run `composer install --no-dev` locally and upload the whole tree including `vendor/`; import the SQL files through the host's database tool; no environment variables, so secrets must live in `Settings.json` (out of version control, with the most restrictive permissions the host allows); no `analytics:prune` unless the panel offers cron; write access to `src/View/Compiled` and the runtime directories must be arranged through the panel. If the host cannot do these, use a VPS.

## Built images

Build the image from a checkout with `docker build -f Dockerfile.production -t wbengine-skeleton-app .`. Pushing a version tag (`v*`) also runs the workflow `.github/workflows/image.yml`, which builds `Dockerfile.production` and pushes `ghcr.io/rrsoftcz/wbengine-skeleton-app` tagged with the version (`1.2.3`, `1.2`) and `latest`. The image contains the code and the production Composer dependencies and no secrets. Pull and run it with `Settings.json` mounted read-only and a volume for the compiled templates:

```sh
docker pull ghcr.io/rrsoftcz/wbengine-skeleton-app:1.2.3
docker run -d --name wbengine --restart unless-stopped \
  -p 127.0.0.1:8080:80 \
  -v /etc/wbengine/Settings.json:/var/www/html/src/Config/Settings.json:ro \
  -v wbengine_compiled:/var/www/html/src/View/Compiled \
  -e WBENGINE_RECAPTCHA_SECRET="..." \
  ghcr.io/rrsoftcz/wbengine-skeleton-app:1.2.3
```

Pin a version tag in production rather than `latest`. The container serves plain HTTP on port 80: put host Nginx in front (see the VPS guide) and set `http.trustedProxies` to the address the container sees the proxy from. The database is not part of the image; use the bundled Compose file or an external database as described above. To update, pull the new tag, apply the new migrations, then `docker rm -f wbengine` and run again; the compiled volume is reused (empty it when `compileCheck` is `false`).
