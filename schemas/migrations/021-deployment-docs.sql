-- Deployment page (schemas/migrations/021-deployment-docs.sql).
-- Idempotent: every row is created only when it is missing, so edits made later in the Admin survive a rerun.
SET NAMES utf8mb4;

SET @deployment_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/deployment/' ORDER BY site_id LIMIT 1);
INSERT INTO cms_sites (parent_id, left_id, right_id, strict, visible, link, title, html_title, html_description, html_keywords, acl)
SELECT 1, 0, 0, 1, 1, '/docs/deployment/', 'Deployment', 'Deployment', 'Install the skeleton without Docker: PHP-FPM with Nginx, Apache, permissions, migrations, cron, HTTPS, backups, and built container images.', 'deployment,nginx,apache,php-fpm', 0
WHERE @deployment_site_id IS NULL;
SET @deployment_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/deployment/' ORDER BY site_id LIMIT 1);

INSERT INTO cms_site_translations (site_id, locale, title, html_title, html_description, html_keywords)
SELECT @deployment_site_id, 'cs', 'Nasazení', 'Nasazení', 'Instalace kostry bez Dockeru: PHP-FPM s Nginxem, Apache, oprávnění, migrace, cron, HTTPS, zálohy a sestavené image kontejnerů.', 'nasazení,nginx,apache,php-fpm'
WHERE NOT EXISTS (SELECT 1 FROM cms_site_translations WHERE site_id = @deployment_site_id AND locale = 'cs');

INSERT INTO cms_articles (site_id, grouped, futured, c_enabled, views, title, introtext, bodytext, content_format, published, author, source)
SELECT @deployment_site_id, 0, 0, 0, 0, 'Deployment', 'Install and run the skeleton on a server you manage yourself: requirements, PHP-FPM with Nginx or Apache, writable paths, database and migrations, cron, HTTPS and proxies, backups, health checks, hybrid layouts and published container images.', 'This page mirrors `docs/deploy-bare-metal.md` in the repository. It installs the site on a server where you manage PHP, the web server and the database yourself: a VPS, a dedicated machine or a managed host. The Docker route has its own guide: [Deploy to a clean Ubuntu VPS with Docker](https://github.com/rrsoftcz/wbengine-skeleton-app/blob/main/docs/deploy-vps-docker.md). Every key of `Settings.json` is explained in the [settings reference](/docs/settings/).

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

`bin/wbe install` creates `src/Config/Settings.json` from `settings.json.default` with fresh random JWT keys when the file is missing (an existing file is only validated, never overwritten), creates `src/View/Compiled`, and runs `composer install --no-dev` from the lock file. For a production build you can run `composer install --no-dev --optimize-autoloader` instead.

The document root of the web server is the `public/` directory. Never point it at the project root: `src/`, `vendor/`, `schemas/` and `bin/` must not be reachable from the web.

## 2. Database and migration order

Create an empty database with the `utf8mb4` character set and a user that has rights only on it:

```sql
CREATE DATABASE wbengine_skeleton_app CHARACTER SET utf8mb4;
CREATE USER ''wbengine''@''127.0.0.1'' IDENTIFIED BY ''a long random password'';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX, DROP ON wbengine_skeleton_app.* TO ''wbengine''@''127.0.0.1'';
```

The schema and the content dump are imported in this order, then the framework migrations that belong to the installed release, taken from `vendor` so they always match the framework version:

```sh
mysql wbengine_skeleton_app < schemas/wbengine_skeletone_app_mysql_template.sql
mysql wbengine_skeleton_app < schemas/wbengine_skeletone_app_mysql_template_content.sql
for m in 002-api-v2-integrations.sql 005-api-content.sql 006-analytics.sql 007-api-integration-last-used.sql; do
    mysql wbengine_skeleton_app < vendor/wbengine/wbengine/migrations/4.0.0/$m
done
```

These are the same four framework migrations the Docker installer applies. `001` (an optional index) and `003`/`004` (Markdown columns and a conversion ledger) are not needed on a fresh install because the skeleton schema already has `content_format`. The content dump is a fresh-install seed: it is not idempotent, so never import it into a database that already has content.

An existing installation that is upgraded to a new release applies only the new files from `schemas/migrations/` once and in numeric order (each content migration is idempotent), after a backup. A new framework release may add files under `vendor/wbengine/wbengine/migrations/`; check with `vendor/bin/wbengine.php migration:status`.

Then edit `dbAdapterDefinition` in `Settings.json` (host, database, user, password, `charset`). Create your own administrator and remove the demo account (`admin@example.com` / `changeme`, never leave it enabled):

```sh
php bin/wbe user:create --email=you@example.com --role=admin
php bin/wbe user:delete --example
```

## 3. Settings.json and secrets

Keep `Settings.json` out of version control and readable only by the deploy user and the PHP user (`chmod 640`, group of the PHP user). Put the secrets in the environment of the PHP process instead of the file: `WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY` (at least 32 characters each, `openssl rand -hex 32`), `WBENGINE_RECAPTCHA_SECRET`, and optionally `WBENGINE_DEBUG` and `WBENGINE_IMAGE_DIR`. With PHP-FPM, set them in the pool file:

```ini
; /etc/php/8.4/fpm/pool.d/wbengine.conf
env[WBENGINE_JWT_KEY] = "..."
env[WBENGINE_JWT_REFRESH_KEY] = "..."
```

A complete production-ready file is shown in the [settings reference](/docs/settings/). The minimum for production: `debug` off, `cache` on, `renderer.compileCheck` false, `i18n.baseUrl` set to the public address, `http.trustedProxies` set when a proxy sits in front, and explicit absolute directories for runtime files (next section). After the first deploy run `php vendor/bin/wbengine.php config:check --config=src/Config/Settings.json --root=src`.

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

The job reads the same environment secrets, so run it as the web user with the same variables (for example by sourcing a root-owned file in the crontab line). A matching `audit:prune` command arrives with framework 4.8.0 and will be added to this schedule then.

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

Flush the cache with `POST /api/cache/flush` (administrator), or remove the files in `cache.dir`. For APCu cache restart PHP-FPM.

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

Run PHP and MySQL in Docker and keep TLS on the host. This is exactly the setup of [Deploy to a clean Ubuntu VPS with Docker](https://github.com/rrsoftcz/wbengine-skeleton-app/blob/main/docs/deploy-vps-docker.md): the container is published only on `127.0.0.1:8080`, host Nginx proxies to it and the installer writes the matching `http.trustedProxies`.

### External managed database

Point `dbAdapterDefinition.hostname` at the managed MySQL or MariaDB service and import the schema, content and migrations of section 2 with the `mysql` client from a machine that can reach it (the `docker-entrypoint-initdb.d` import only exists for the bundled database). Use a dedicated user and database, allow connections only from the application host, and enable TLS on the server side when it crosses a network. In a Compose file, remove the `db` service and the `depends_on` entry. Check that the database version meets the requirements (`JSON_SEARCH`).

### Shared hosting

It works when the host offers PHP 8.3 or newer with the extensions above, MySQL or MariaDB, `mod_rewrite` and `.htaccess`, and lets you set the document root to `public/` (otherwise the project cannot be installed safely). Limits to expect: no shell or cron, so run `composer install --no-dev` locally and upload the whole tree including `vendor/`; import the SQL files through the host''s database tool; no environment variables, so secrets must live in `Settings.json` (out of version control, with the most restrictive permissions the host allows); no `analytics:prune` unless the panel offers cron; write access to `src/View/Compiled` and the runtime directories must be arranged through the panel. If the host cannot do these, use a VPS.

## Built images

Version tags (`v*`) run the workflow `.github/workflows/image.yml`, which builds `Dockerfile.production` and pushes `ghcr.io/rrsoftcz/wbengine-skeleton-app` tagged with the version (`1.2.3`, `1.2`) and `latest`. The image contains the code and the production Composer dependencies and no secrets. Pull and run it with `Settings.json` mounted read-only and a volume for the compiled templates:

```sh
docker pull ghcr.io/rrsoftcz/wbengine-skeleton-app:1.2.3
docker run -d --name wbengine --restart unless-stopped \\
  -p 127.0.0.1:8080:80 \\
  -v /etc/wbengine/Settings.json:/var/www/html/src/Config/Settings.json:ro \\
  -v wbengine_compiled:/var/www/html/src/View/Compiled \\
  -e WBENGINE_JWT_KEY="..." -e WBENGINE_JWT_REFRESH_KEY="..." \\
  ghcr.io/rrsoftcz/wbengine-skeleton-app:1.2.3
```

Pin a version tag in production rather than `latest`. The container serves plain HTTP on port 80: put host Nginx in front (see the VPS guide) and set `http.trustedProxies` to the address the container sees the proxy from. The database is not part of the image; use the bundled Compose file or an external database as described above. To update, pull the new tag, apply the new migrations, then `docker rm -f wbengine` and run again; the compiled volume is reused (empty it when `compileCheck` is `false`).', 'markdown', UNIX_TIMESTAMP(), 'RRSOFT', 'https://www.wbengine.org/'
WHERE NOT EXISTS (SELECT 1 FROM cms_articles WHERE site_id = @deployment_site_id);
SET @deployment_article_id = (SELECT id FROM cms_articles WHERE site_id = @deployment_site_id ORDER BY id LIMIT 1);

INSERT INTO cms_article_translations (article_id, locale, title, introtext, bodytext, content_format)
SELECT @deployment_article_id, 'cs', 'Nasazení', 'Instalace a provoz kostry na vlastním serveru: požadavky, PHP-FPM s Nginxem nebo Apache, zapisovatelné cesty, databáze a migrace, cron, HTTPS a proxy, zálohy, kontroly stavu, hybridní uspořádání a publikované image kontejnerů.', 'Tento návod instaluje web na server, kde si PHP, webový server a databázi spravujete sami: VPS, vyhrazený stroj nebo spravovaný hosting. Postup s Dockerem má vlastní návod: [Nasazení na čisté VPS s Ubuntu pomocí Dockeru](https://github.com/rrsoftcz/wbengine-skeleton-app/blob/main/docs/deploy-vps-docker.md). Každý klíč `Settings.json` vysvětluje [přehled nastavení](/cs/docs/settings/).

## Požadavky

- PHP 8.3 nebo novější (vývojový cíl je 8.4) s rozšířeními `mysqli`, `json`, `mbstring`, `fileinfo`, `curl`, `zip` a `opcache`. `zip` a `curl` používá Composer, `opcache` drží zkompilované šablony v paměti.
- Composer 2 na stroji, který instaluje závislosti (může to být váš počítač).
- MySQL 8 nebo MariaDB 10.6 a novější (výběr boxů používá `JSON_SEARCH`).
- Webový server, který každý požadavek, jenž není soubor, pošle do `public/index.php`: Nginx s PHP-FPM, nebo Apache s `mod_rewrite` a `mod_php` či PHP-FPM.
- HTTPS před webem. Prosté HTTP stačí jen pro místní zkoušku.

## 1. Kód a závislosti

```sh
git clone https://github.com/rrsoftcz/wbengine-skeleton-app.git /var/www/wbengine-skeleton-app
cd /var/www/wbengine-skeleton-app
git checkout <značka vydání>
php bin/wbe install --no-dev
```

`bin/wbe install` vytvoří `src/Config/Settings.json` ze `settings.json.default` s novými náhodnými klíči JWT, pokud soubor chybí (existující soubor jen zkontroluje, nikdy nepřepíše), vytvoří `src/View/Compiled` a spustí `composer install --no-dev` podle zamčeného souboru. Pro produkční build můžete místo toho spustit `composer install --no-dev --optimize-autoloader`.

Kořenem webového serveru je adresář `public/`. Nikdy ho nesměrujte na kořen projektu: `src/`, `vendor/`, `schemas/` a `bin/` nesmí být dostupné z webu.

## 2. Databáze a pořadí migrací

Vytvořte prázdnou databázi se znakovou sadou `utf8mb4` a uživatele s právy jen na ni:

```sql
CREATE DATABASE wbengine_skeleton_app CHARACTER SET utf8mb4;
CREATE USER ''wbengine''@''127.0.0.1'' IDENTIFIED BY ''dlouhé náhodné heslo'';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX, DROP ON wbengine_skeleton_app.* TO ''wbengine''@''127.0.0.1'';
```

Schéma a obsah se importují v tomto pořadí, poté migrace frameworku odpovídající nainstalovanému vydání, převzaté z `vendor`, takže vždy sedí na verzi frameworku:

```sh
mysql wbengine_skeleton_app < schemas/wbengine_skeletone_app_mysql_template.sql
mysql wbengine_skeleton_app < schemas/wbengine_skeletone_app_mysql_template_content.sql
for m in 002-api-v2-integrations.sql 005-api-content.sql 006-analytics.sql 007-api-integration-last-used.sql; do
    mysql wbengine_skeleton_app < vendor/wbengine/wbengine/migrations/4.0.0/$m
done
```

Jsou to stejné čtyři migrace frameworku, které použije instalátor pro Docker. Migrace `001` (volitelný index) a `003`/`004` (sloupce Markdown a záznam převodu) na čisté instalaci netřeba, protože schéma kostry už `content_format` má. Soubor s obsahem je počáteční naplnění nové instalace: není idempotentní, proto ho nikdy neimportujte do databáze, která už obsah má.

Existující instalace při přechodu na nové vydání po záloze spustí jen nové soubory ze `schemas/migrations/` jednou a v číselném pořadí (obsahové migrace jsou idempotentní). Nové vydání frameworku může přidat soubory v `vendor/wbengine/wbengine/migrations/`; zjistíte to příkazem `vendor/bin/wbengine.php migration:status`.

Poté upravte `dbAdapterDefinition` v `Settings.json` (hostitel, databáze, uživatel, heslo, `charset`). Vytvořte vlastního správce a odstraňte demo účet (`admin@example.com` / `changeme`, nikdy ho nenechávejte zapnutý):

```sh
php bin/wbe user:create --email=you@example.com --role=admin
php bin/wbe user:delete --example
```

## 3. Settings.json a tajné hodnoty

`Settings.json` nedávejte do správy verzí a nechte ho čitelný jen pro uživatele nasazení a uživatele PHP (`chmod 640`, skupina uživatele PHP). Tajné hodnoty dejte do prostředí procesu PHP místo souboru: `WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY` (každý nejméně 32 znaků, `openssl rand -hex 32`), `WBENGINE_RECAPTCHA_SECRET` a volitelně `WBENGINE_DEBUG` a `WBENGINE_IMAGE_DIR`. U PHP-FPM je nastavte v souboru poolu:

```ini
; /etc/php/8.4/fpm/pool.d/wbengine.conf
env[WBENGINE_JWT_KEY] = "..."
env[WBENGINE_JWT_REFRESH_KEY] = "..."
```

Kompletní produkční soubor je v [přehledu nastavení](/cs/docs/settings/). Minimum pro produkci: `debug` vypnuté, `cache` zapnutá, `renderer.compileCheck` na `false`, `i18n.baseUrl` na veřejnou adresu, `http.trustedProxies` při proxy před webem a výslovné absolutní adresáře pro běhové soubory (další část). Po prvním nasazení spusťte `php vendor/bin/wbengine.php config:check --config=src/Config/Settings.json --root=src`.

## 4. Zapisovatelné cesty a oprávnění

PHP běží pod jedním uživatelem (například `www-data`). Zápis mu dovolte jen tam, kam aplikace zapisuje, pomocí vlastnictví nebo omezené skupiny, nikdy `chmod 777`:

| Cesta | Účel | Nastavení |
|-------|------|-----------|
| `src/View/Compiled/` | zkompilované šablony | `renderer.compiledDir` |
| `/var/lib/wbengine/counters` | dávkovaná počítadla zobrazení článků | `counters.views.dir` |
| `/var/lib/wbengine/ratelimit` | počítadla limitu přihlášení | `rateLimit.login.dir` |
| `/var/cache/wbengine` | souborová cache a cache stránek | `cache.dir` |
| `/var/lib/wbengine/images` | obrázky nahrané přes API v2 | `apiV2.imageDirectory` nebo `WBENGINE_IMAGE_DIR` |

```sh
install -d -o www-data -g www-data -m 2770 /var/lib/wbengine/counters /var/lib/wbengine/ratelimit /var/lib/wbengine/images /var/cache/wbengine
chown -R www-data:www-data src/View/Compiled && chmod 2775 src/View/Compiled
```

Necháte-li adresáře nenastavené, framework použije podadresáře systémového dočasného adresáře. Při systemd s `PrivateTmp=true` (výchozí u PHP-FPM na mnoha distribucích) takový adresář po restartu zmizí a nesdílí se s příkazovou řádkou, proto nastavte výslovné cesty. Adresář obrázků musí být mimo `public/`; obrázky servíruje aplikace jako bajty.

Při `renderer.compileCheck` na `false` se šablony nekontrolují: po každém nasazení vyprázdněte adresář zkompilovaných šablon (`rm -f src/View/Compiled/*`) a vyprázdněte cache (část 9).

## 5. PHP-FPM s Nginxem

Nainstalujte `nginx`, `php8.4-fpm` a rozšíření a použijte hotový blok `etc/nginx/wbengine-fpm.conf`, odvozený od dockerového, ale komunikující přes unixový socket:

```sh
cp etc/nginx/wbengine-fpm.conf /etc/nginx/sites-available/wbengine.conf
# upravte server_name, root a socket ve fastcgi_pass
ln -s /etc/nginx/sites-available/wbengine.conf /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```

Spouští se jen `/index.php` (označeno `internal`), přímé požadavky na `*.php` dostanou 404 a `src`, `vendor`, `schemas`, `bin` a `etc` jsou zakázané i při chybně zadaném kořeni. V produkci používejte opcache (`opcache.enable=1`, `opcache.validate_timestamps=0` spolu s reloadem PHP-FPM při nasazení dává nejlepší výsledek; funguje i výchozí kontrola časových razítek). V `php.ini` ponechte `display_errors = Off` a `log_errors = On`.

## 6. Apache

S `mod_php` i PHP-FPM směruje požadavky `public/.htaccess`, takže virtuální host potřebuje `AllowOverride All` na `public/`. Zdokumentovaná šablona je `etc/apache2/sites-available/wbengine-production.conf`:

```sh
a2enmod rewrite headers ssl
cp etc/apache2/sites-available/wbengine-production.conf /etc/apache2/sites-available/wbengine.conf
# nahraďte každou hodnotu označenou CHANGE
a2ensite wbengine && apache2ctl configtest && systemctl reload apache2
```

Pro PHP-FPM přidejte blok `SetHandler "proxy:unix:/run/php/php8.4-fpm.sock|fcgi://localhost"`, který šablona ukazuje, a zapněte `proxy_fcgi`. U `mod_php` používejte `SetEnv` ve virtuálním hostu jen tehdy, když nelze použít prostředí jiné služby; záznamy `env[]` v poolu PHP-FPM jsou čistší.

## 7. HTTPS a hlavičky důvěryhodných proxy

Získejte certifikát (`certbot --nginx` nebo `certbot --apache`) a přesměrujte HTTP na HTTPS. Když je PHP samo za reverzní proxy, load balancerem nebo sítí kontejnerů, framework vidí proxy jako klienta a požadavek jako prosté HTTP, dokud výslovně nepovolíte předávaná metadata:

```json
"http": {
  "trustedProxies": ["127.0.0.1", "10.0.0.0/24"],
  "forwardedHeaders": ["x-forwarded-for", "x-forwarded-proto"]
}
```

Uveďte jen adresy proxy, které provozujete, a každá proxy musí přepsat `X-Forwarded-Proto` vnějším schématem a sestavit `X-Forwarded-For` ze skutečného spojení. Bez toho jsou špatně zabezpečená cookies, `/integrations/`, absolutní odkazy jazyků i klíče limitu pokusů. Když TLS ukončuje přímo webový server (Nginx nebo Apache výše), nechte oba seznamy prázdné. Nastavte `i18n.baseUrl`, aby odkazy `hreflang` nezávisely na hlavičce `Host`.

## 8. Cron

Vlastní analytika drží denní souhrny po dobu `analytics.retentionDays`. Prošlé řádky mažte denně:

```cron
17 3 * * * www-data /usr/bin/php /var/www/wbengine-skeleton-app/vendor/bin/wbengine.php analytics:prune --config=/var/www/wbengine-skeleton-app/src/Config/Settings.json --root=/var/www/wbengine-skeleton-app/src >> /var/log/wbengine-cron.log 2>&1
```

Úloha čte stejné tajné hodnoty z prostředí, proto ji spouštějte pod webovým uživatelem se stejnými proměnnými (například načtením souboru vlastněného rootem v řádku crontabu). Odpovídající příkaz `audit:prune` přijde s frameworkem 4.8.0 a do tohoto rozvrhu se přidá až tehdy.

## 9. Aktualizace, záloha a návrat

Před každým nasazením zálohujte databázi, `Settings.json`, adresář obrázků a soubor poolu či prostředí s tajnými hodnotami.

```sh
mysqldump --single-transaction --routines wbengine_skeleton_app | gzip > /var/backups/wbengine-$(date +%F).sql.gz
tar czf /var/backups/wbengine-files-$(date +%F).tgz src/Config/Settings.json /var/lib/wbengine/images
```

Aktualizace:

```sh
git fetch --tags && git checkout <nová značka>
composer install --no-dev --optimize-autoloader
# spusťte nové soubory ze schemas/migrations/ (v pořadí) a případné migrace frameworku
rm -f src/View/Compiled/*
php vendor/bin/wbengine.php doctor --config=src/Config/Settings.json --root=src
systemctl reload php8.4-fpm
```

Cache vyprázdníte voláním `POST /api/cache/flush` (správce) nebo smazáním souborů v `cache.dir`. U cache APCu restartujte PHP-FPM.

Návrat: přepněte na předchozí značku, spusťte `composer install --no-dev`, vyprázdněte adresář zkompilovaných šablon a reloadujte PHP-FPM. Migrace se automaticky nevracejí: pokud některá změnila schéma, obnovte zálohu databáze pořízenou před nasazením. Obsahové migrace mění jen text a lze je ponechat.

## 10. Logy

| Log | Obvyklé umístění |
|-----|------------------|
| Nginx | `/var/log/nginx/access.log`, `error.log` |
| Apache | `${APACHE_LOG_DIR}` (`/var/log/apache2/`), soubory uvedené ve virtuálním hostu |
| PHP-FPM | `/var/log/php8.4-fpm.log`, případně slow log poolu |
| Chyby PHP | hodnota ini `error_log`, jinak chybový log webového serveru |
| Aplikace | framework zapisuje přes `error_log` (například „cache disabled: ...“, když do adresáře cache nelze zapisovat) |

## 11. Kontroly stavu

```sh
php vendor/bin/wbengine.php doctor --config=src/Config/Settings.json --root=src
php vendor/bin/wbengine.php config:check --config=src/Config/Settings.json --root=src
php vendor/bin/wbengine.php migration:status --config=src/Config/Settings.json --root=src
curl -sI https://example.com/ | head -1
curl -sI https://example.com/cs/docs/ | head -1
curl -s https://example.com/api/v2/capabilities
```

`doctor` kontroluje tajné hodnoty, ladění, cache a stav adresářů bez změny schématu, `config:check` ověří soubor nastavení a `migration:status` ukáže, které migrace frameworku jsou použité. Končí kódem 0 při zdravém stavu a 1 při neúspěšné kontrole, takže se hodí do skriptu nasazení. Příkazová řádka má vlastní konfiguraci PHP: opcache webového SAPI, oprávnění webového uživatele a HTTPS ověřte zvlášť skutečnými požadavky.

## Hybridní uspořádání

### Hostitelský Nginx před kontejnery

PHP a MySQL běží v Dockeru a TLS zůstává na hostiteli. Přesně takové je uspořádání návodu [Nasazení na čisté VPS s Ubuntu pomocí Dockeru](https://github.com/rrsoftcz/wbengine-skeleton-app/blob/main/docs/deploy-vps-docker.md): kontejner je publikovaný jen na `127.0.0.1:8080`, hostitelský Nginx na něj proxyuje a instalátor zapíše odpovídající `http.trustedProxies`.

### Externí spravovaná databáze

Nasměrujte `dbAdapterDefinition.hostname` na spravovanou službu MySQL nebo MariaDB a importujte schéma, obsah a migrace z části 2 klientem `mysql` ze stroje, který na ni dosáhne (import přes `docker-entrypoint-initdb.d` existuje jen pro přibalenou databázi). Použijte vyhrazeného uživatele a databázi, povolte připojení jen z hostitele aplikace a při přenosu po síti zapněte TLS na straně serveru. V souboru Compose odeberte službu `db` a položku `depends_on`. Ověřte, že verze databáze splňuje požadavky (`JSON_SEARCH`).

### Sdílený hosting

Funguje, pokud hosting nabízí PHP 8.3 nebo novější s výše uvedenými rozšířeními, MySQL nebo MariaDB, `mod_rewrite` a `.htaccess` a dovolí nastavit kořen webu na `public/` (jinak projekt nelze bezpečně nainstalovat). Čeho se držet: bez shellu a cronu, proto spusťte `composer install --no-dev` lokálně a nahrajte celý strom včetně `vendor/`; SQL soubory importujte nástrojem hostingu; bez proměnných prostředí, proto tajné hodnoty musí být v `Settings.json` (mimo správu verzí, s co nejpřísnějšími oprávněními, jaká hosting dovolí); bez `analytics:prune`, pokud panel nenabízí cron; zápis do `src/View/Compiled` a běhových adresářů je nutné zařídit přes panel. Pokud to hosting nezvládne, použijte VPS.

## Sestavené image

Značky verzí (`v*`) spouštějí workflow `.github/workflows/image.yml`, které sestaví `Dockerfile.production` a publikuje `ghcr.io/rrsoftcz/wbengine-skeleton-app` se značkami verze (`1.2.3`, `1.2`) a `latest`. Image obsahuje kód a produkční závislosti Composeru a žádná tajemství. Stáhněte a spusťte ho s `Settings.json` připojeným jen pro čtení a svazkem pro zkompilované šablony:

```sh
docker pull ghcr.io/rrsoftcz/wbengine-skeleton-app:1.2.3
docker run -d --name wbengine --restart unless-stopped \\
  -p 127.0.0.1:8080:80 \\
  -v /etc/wbengine/Settings.json:/var/www/html/src/Config/Settings.json:ro \\
  -v wbengine_compiled:/var/www/html/src/View/Compiled \\
  -e WBENGINE_JWT_KEY="..." -e WBENGINE_JWT_REFRESH_KEY="..." \\
  ghcr.io/rrsoftcz/wbengine-skeleton-app:1.2.3
```

V produkci připněte značku verze, ne `latest`. Kontejner obsluhuje prosté HTTP na portu 80: postavte před něj hostitelský Nginx (viz návod pro VPS) a nastavte `http.trustedProxies` na adresu, ze které kontejner proxy vidí. Databáze součástí image není; použijte přibalený soubor Compose nebo externí databázi popsanou výše. Při aktualizaci stáhněte novou značku, spusťte nové migrace, pak `docker rm -f wbengine` a spusťte znovu; svazek se zkompilovanými šablonami se použije znovu (při `compileCheck` na `false` ho vyprázdněte).', 'markdown'
WHERE @deployment_article_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cms_article_translations WHERE article_id = @deployment_article_id AND locale = 'cs');

INSERT INTO cms_boxes (name, module, method, section_id, static, shared, device_min, device_strict, acl, `order`, sites)
SELECT 'Docs: Deployment', 'docs', 'page', 1, 1, 0, 1, 0, 0, 0, JSON_ARRAY(CAST(@deployment_site_id AS CHAR))
WHERE NOT EXISTS (SELECT 1 FROM cms_boxes WHERE name = 'Docs: Deployment');
