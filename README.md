# wbengine-skeleton-app

A minimal application built on the [WBengine](https://packagist.org/packages/wbengine/wbengine) PHP framework. Use it as a starting point for a website or a backend: it shows a static page, a database driven blog article, a login, a user profile and the REST API.

## Documentation index

### Skeleton App

- [Production Docker VPS deployment](docs/deploy-vps-docker.md)
- [Plan: refresh the example content and documentation](docs/plan-skeleton-v4-content-refresh.md)
- [WBengine 4 migration plan for the example site](docs/plan-wbengine-4.0-migration.md)
- [Local HTTPS certificates](etc/cert/README.md)
- [Changelog](docs/CHANGELOG.md)
- [Contribution guide](docs/CONTRIBUTING.md)
- [License](docs/LICENSE.md)
- [Live site documentation](https://www.wbengine.org/docs/)

### WBengine framework

- [Framework README](https://github.com/rrsoftcz/wbengine)
- [Markdown reference](https://github.com/rrsoftcz/wbengine/blob/master/ref-markdown.md)
- [Template migration reference](https://github.com/rrsoftcz/wbengine/blob/master/ref-template-migration.md)
- [API v2 reference](https://github.com/rrsoftcz/wbengine/blob/master/ref-api-v2.md)

## Requirements

* PHP 8.3 or newer (8.4 recommended) with the `mysqli` extension
* MySQL 8 or MariaDB 10.6+
* Apache with `mod_rewrite` and `AllowOverride All` for `public/` (or an equivalent Nginx rewrite to `public/index.php`)
* Composer
* Docker (optional, the quickest way to try it)

The Composer application requirement is `wbengine/wbengine:^4.0`. The framework's
runtime Composer dependency is `firebase/php-jwt`. Its native template engine and
Markdown parser are included in WBengine. Composer
also checks PHP platform requirements for the installed release.

## Quick start with Docker

For a clean production VPS deployment, see [docs/deploy-vps-docker.md](docs/deploy-vps-docker.md).

```bash
git clone <this repository> wbengine-skeleton-app
cd wbengine-skeleton-app

docker compose up --build             # http://localhost:8080, MySQL seeded from schemas/
```

The web container runs `bin/wbe install` before Apache starts. It creates `src/Config/Settings.json` with fresh JWT secrets when missing, validates the JSON, prepares the writable compiled-template directory, and runs `composer install` from the committed lock file in the PHP 8.4 container. Existing settings are preserved and validated. Every container start reconciles installed packages with the lock file, so a framework version update is applied on restart. You do not need host PHP or Composer. The installer never uses `chmod 777`.

To run the installer again manually, use `docker compose exec web php bin/wbe install`. `bin/setup.sh` remains as a backwards-compatible alias. You can also run `bin/wbe install` directly when PHP 8.3+ and Composer 2 are installed locally.

If setup stops, read the `Install error:` message in the container output. For a running stack, inspect `docker compose logs web`. The installer reports missing default settings, invalid JSON, unreadable settings, unwritable `src/View/Compiled`, and Composer failures separately. For local debugging only, set `"debug": true` in `src/Config/Settings.json` and restart the web container. Debug output includes file paths and stack traces, so keep it off on public sites. An invalid or missing config is diagnosed by the framework's safe error page; for detailed startup diagnostics, set `WBENGINE_DEBUG=1` only in your private development environment, then remove it before going live.

Open http://localhost:8080 and sign in with the demo account:

| E-mail | Password |
|--------|----------|
| `admin@example.com` | `changeme` |

Change this password before the application is reachable by anyone else.

## Nginx and production Docker deployment

For a clean Ubuntu VPS deployment, follow the [production Docker guide](docs/deploy-vps-docker.md). It runs PHP and MySQL in containers, binds the application to `127.0.0.1:8080`, and uses host Nginx and Certbot for HTTPS. MySQL has no public host port. The procedure does not require PHP or Composer on the host.

The files under `etc/nginx/` are for a separate PHP-FPM installation without the production Docker Compose stack. Do not use those PHP-FPM virtual hosts with `docker-compose.production.yml`.

When Nginx terminates TLS and proxies to a Docker web container, the framework sees the container-side proxy address rather than the browser. Set `http.trustedProxies` to the exact proxy peer address as seen by PHP, and enable only the forwarded headers the proxy overwrites:

```json
"http": {
  "trustedProxies": ["172.18.0.1/32"],
  "forwardedHeaders": ["x-forwarded-for", "x-forwarded-proto"]
}
```

Treat `172.18.0.1/32` as an example only. Inspect the actual Docker network route or request peer before configuring it; the address can change when a Compose network is recreated. Keep the web container port bound to loopback or otherwise reachable only from that proxy. The Nginx configuration must overwrite `X-Forwarded-Proto` with the external scheme and derive `X-Forwarded-For` from the actual client. Never trust all proxies or a broad network without a specific need. Without this configuration, authenticated API requests behind TLS termination can be rejected as insecure, and rate limits can group visitors under the proxy IP.

## HTTPS development with mkcert (optional)

The quick start above uses plain HTTP on port 8080. To develop against `https://wbengine.local` with a locally trusted certificate:

1. Install mkcert: `brew install mkcert` (macOS) or `sudo apt install mkcert` (Ubuntu or Debian).
2. Install its local certificate authority, once per machine: `mkcert -install`.
3. Add the hostname: `echo "127.0.0.1 wbengine.local" | sudo tee -a /etc/hosts`.
4. Generate the certificates in `etc/cert`:

   ```bash
   cd etc/cert
   mkcert -cert-file fullchain.cer -key-file wbengine.local.key wbengine.local localhost 127.0.0.1 ::1
   ```

5. Start Docker with the HTTPS override and open https://wbengine.local:

   ```bash
   docker compose -f docker-compose.yml -f docker-compose.https.yml up -d
   ```

The override (`docker-compose.https.yml`) publishes port 443, mounts `etc/cert` read only and enables the vhost `etc/apache2/sites-available/wbengine-https.conf`. If you prefer your own setup, a git-ignored `docker-compose.override.yml` and `etc/apache2/sites-available/wbengine.local.conf` are loaded the usual way and stay out of the repository.

| | Development | Production |
|---|---|---|
| Hostname | `wbengine.local` | `wbengine.rrsoft.cz` |
| Certificates | mkcert (local, valid about 27 months) | Let's Encrypt (certbot, renewed automatically) |
| Apache config | `wbengine-https.conf` | `wbengine-production.conf` |

**Certificates are never committed.** Production certificates are managed by certbot and renewed automatically, development ones are generated locally by mkcert, and a private key does not belong in version control. See `etc/cert/README.md` for details.

**Troubleshooting**

* SSL certificate error: run `mkcert -install` again, regenerate the certificates (step 4) and restart with `docker compose ... down` and `up -d`.
* `wbengine.local` does not resolve: check `cat /etc/hosts | grep wbengine`.
* Port 443 is already in use: find the process with `lsof -i :443`.

## Manual installation

1. Run `php bin/wbe install` to create and validate settings, prepare the compiled-template directory, and install locked Composer dependencies.
2. Create a database and import `schemas/wbengine_skeletone_app_mysql_template.sql` and `schemas/wbengine_skeletone_app_mysql_template_content.sql`.
3. Edit `dbAdapterDefinition` in `src/Config/Settings.json` and set production secrets through environment variables or a private config.
4. Point the web server document root at `public/` and grant the PHP-FPM user write access to `src/View/Compiled` using ownership or a restricted group permission. Do not use `chmod 777`.

Upgrading an existing database: back it up, then run the applicable scripts in
`schemas/migrations/` once and in order. `005-content-translations.sql` creates the
translation tables; `006-markdown-content-format.sql` adds `content_format`
for WBengine 4.0; `007-markdown-documentation.sql` refreshes the Markdown guide
and removes obsolete template-engine notes; `008-docker-installation-guide.sql`
updates the English and Czech Get started articles with the current installer and
exception diagnostics; `009-repair-czech-installation-guide-encoding.sql` repairs
Czech text if migration 008 was run with a `latin1` connection;
`010-refresh-getting-started-content.sql` synchronizes the English and Czech
installation guides, including matching troubleshooting headings. Apply 005 before
006, then 007 and 008. Run 009 only if Czech characters are corrupted, then apply
010 to synchronize both guides. Migration 011 updates the architecture and API
documentation and adds the bilingual central administration page. Migration 012
adds the clean VPS Docker deployment procedure to the English and Czech Getting
started pages. Review local edits to those built-in documentation articles
before applying content migrations. The guide
migrations set their SQL connection to `utf8mb4`. If the framework migration
`migrations/4.0.0/003-markdown-content.sql` was already applied, skip skeleton 006;
never apply both. Existing article text is preserved and defaults to `legacy_html`;
the 006 schema migration does not convert or overwrite content. Migration 007 is a
narrow update to the built-in getting-started and Markdown documentation pages; it
does not touch other articles. Passwords are stored with `password_hash()`; old
MD5 hashes keep working and are upgraded on each user's next login once the column
is widened.

For an existing Docker database, make a backup before applying pending scripts.
For example, to update the live Getting started page after the earlier migrations
are already applied:

```sh
docker compose exec -T db sh -c 'mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"' > before-install-guide.sql
docker compose exec -T db sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"' < schemas/migrations/008-docker-installation-guide.sql
```

To synchronize the current English and Czech installation guides on an existing
site, back up the database and apply migration 010. It updates only the built-in
article with ID 2 and its Czech translation. Review local edits to that article
before applying it:

```sh
docker compose exec -T db sh -c 'mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"' > before-getting-started-010.sql
docker compose exec -T db sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"' < schemas/migrations/010-refresh-getting-started-content.sql
```

To publish the expanded system documentation on an existing site, first deploy
the code containing migration 011, then back up the database and apply it once:

```sh
docker compose exec -T db sh -c 'mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"' > before-system-docs-011.sql
docker compose exec -T db sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"' < schemas/migrations/011-system-and-central-administration-documentation.sql
```

To add the production Docker deployment instructions to the English and Czech
Getting started pages on an existing site, back up the database and apply the
idempotent content migration once:

```sh
docker compose exec -T db sh -c 'mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"' > before-deployment-guide-012.sql
docker compose exec -T db sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"' < schemas/migrations/012-vps-docker-deployment-guide.sql
```

The page cache can delay the visible change by up to its configured lifetime.

Open `/docs/architecture/`, `/docs/rest-api/`, and `/docs/administration/`,
then check `/cs/docs/architecture/`, `/cs/docs/rest-api/`, and
`/cs/docs/administration/`. Rebuilding containers alone does not
apply this content migration to an existing database.

The database image runs files under `schemas/` only when its data volume is first
created. Rebuilding the web image does not rerun schema initialization scripts. If
the Czech guide contains text such as `Å˜eÅ¡enÃ­`, back it up and run:

```sh
docker compose exec -T db sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"' < schemas/migrations/009-repair-czech-installation-guide-encoding.sql
```

## The demo site

The skeleton is a working site that explains WBengine with itself. Every documentation page has an article that describes a feature and a live box under it that shows the feature on that very request.

| Page | Feature | Live demonstration |
|------|---------|--------------------|
| `/` | `Header\Jumbotron` (a header section box) and `StaticBoxes::Features` | two boxes in two sections of one site |
| `/docs/` | getting started: install, first page | |
| `/docs/architecture/` | sites, sections, boxes, request lifecycle | the `cms_boxes` rows that built the page (`Demo::Structure`) |
| `/docs/boxes/` | static and dynamic boxes, models, the `cms_boxes` columns | |
| `/docs/templates/` | native template syntax, escaping, Markdown files and database content | template and Markdown source live on the page (`Demo::Templates`) |
| `/docs/languages/` | language detection, catalogs, plurals, translated content | the detected locale, plural forms, number and date formats (`Demo::Languages`) |
| `/docs/caching/` | data cache, page cache, invalidation | build time, query count and the `X-WBengine-Cache` header (`Demo::Caching`) |
| `/docs/security/` | the defences, the `acl` of a site | `/profile/` redirects to the login |
| `/docs/rest-api/` | endpoints, roles, conventions | a console that calls the API (`Demo::Api`) |
| `/blog/` | the framework's `Article` box | |
| `/about/` | a static box | |

The documentation text is content, not code: each page is a `cms_sites` row, a `cms_articles` row and a `cms_boxes` row for the reusable `Docs::Page` box (which adds the sidebar). The Czech text is in `cms_article_translations`, the menu names in `cms_menu_translations`. Article rows set `content_format` explicitly to `markdown`; the demo content lives in `schemas/wbengine_skeletone_app_mysql_template_content.sql`, imported after the schema. This seed is for a fresh database and is not idempotent: it updates some base rows and inserts the demo pages, menu item, and articles. Reimporting it into an existing database can overwrite base content and then fail on duplicate IDs. Do not reimport it into an installed site.

To add a documentation page: insert the three rows (copy one of the seeded pages), add the URL and a catalog key to `Docs::PAGES` for the sidebar, and translate it with `PUT /api/translations/article/{id}/cs`. The `.doc` typography styles apply to rendered Markdown; rebuild the stylesheet only when you add new Tailwind utility classes to templates or seeded content.

The default `settings.json.default` switches the data cache and the page cache on (file driver, 60 seconds for pages), so the caching page is meaningful. While you edit templates, set `cache.enabled` to `false` or call `POST /api/cache/flush`, otherwise you see the stored copy for up to a minute.

## How it works

The page you see is assembled from database rows:

```
Site (cms_sites, matched by URL)
  Sections (cms_sections: header, central, api)
    Boxes (cms_boxes: module + method)
      static box  : renders a template only
      dynamic box : loads data through a Model, then renders a template
```

A `cms_boxes` row selects a PHP class and method: module `blog`, method `story`, section `central` runs `App\Box\Central\Blog::Story()`. The method returns HTML, which is placed into the layout (`src/View/site.tpl`) as `{$central}`, `{$header}` and so on. The `sites` column holds the site ids where the box is shown, `shared = 1` shows it on every site.

```
public/index.php          entry point (about ten lines)
public/.htaccess          routes everything to index.php
src/Config/               Settings.json (not committed), settings.json.default
src/Box/<Section>/        box classes, e.g. Central/Blog.php, Central/Profile.php
src/Box/Api/Restapi.php   REST API box
src/View/                 native templates and Markdown sources: site.tpl, <Section>/<Method>.tpl
src/View/Compiled/        template cache, must be writable
schemas/                  database schema and demo data, migrations/
bin/wbe install           first-time setup and dependency validation
bin/setup.sh              backwards-compatible installer alias
```

Examples to read first: `StaticBoxes::About` (static box), `Blog::LocalStoryBox` with `Article/Model.php` (dynamic box with a model), `Profile` (box that uses the logged in user).

## Languages

The skeleton is available in English and Czech. English is the default: unprefixed URLs such as `/` and `/docs/` always use English, regardless of the visitor's browser language or an old locale cookie. Czech URLs use the `/cs/` prefix, and the language switcher keeps the visitor on the same page. `/en/...` redirects to the unprefixed URL. This behavior is set with `i18n.default: "en"` and `i18n.detect: ["url"]`; add `cookie` or `header` to `detect` only if the site should let a saved choice or browser preference override English on unprefixed URLs. The texts live in `src/Locale/en.php` and `src/Locale/cs.php`, the templates use `{t 'key'}`, menu links use `|lurl`, and the layout has a language switcher and `hreflang` links. For production set `i18n.baseUrl` (for example `"https://example.com"`) so the absolute `hreflang` links, which the layout prints from `$hreflangs`, do not depend on the `Host` header. Add a language by listing it in the `i18n.locales` setting and adding `src/Locale/<code>.php`. The content from the database is translated too: site titles and meta tags, menu names and the article live in `cms_site_translations`, `cms_menu_translations` and `cms_article_translations` (demo Czech rows are in the schema), the original tables hold the default language, and a field without a translation falls back to it. `Article/Model.php` shows the one line a box with its own query needs (`ContentTranslations::overlayRow('article', $row)`); the site and the menu are translated by the framework. Editors manage the translations with `GET`, `PUT` and `DELETE /api/translations/{site|menu|article}/{id}[/{locale}]`. An existing database needs `schemas/migrations/005-content-translations.sql`. See the framework README (Internationalisation).

## Templates

The skeleton uses WBengine's native template engine with automatic escaping: `{$value}` is HTML-escaped, so a menu name or an e-mail address containing markup is shown as text, not run. Print HTML generated by a box or the safe Markdown renderer with `|raw`:

```tpl
<title>{$meta.title}</title>          {* escaped *}
{$central|raw}                        {* HTML built by the boxes *}
{$LocalStoryBox->bodytext|raw}        {* article HTML rendered by the framework *}
```

This is WBengine's own syntax and compiler. It includes control flow such as `{if}` and `{foreach}`, includes, modifiers, fragment caching, and the native `{set}` and `{t}` tags.

Markdown can be used in two ways:

1. A `.md` file can be rendered directly by the native renderer with `$this->getRenderer()->render('Central/notice.md')`, or included in an HTML template with `{include 'Central/notice.md'}`. It remains Markdown content: PHP, template variables and directives inside it are not executed.
2. An article or translation row can set `content_format` to `markdown`. The Article box parses that source and returns safe HTML. Existing rows default to `legacy_html` and are not converted automatically.

The parser is included in WBengine, escapes raw HTML, restricts link schemes, and applies input/output limits. It supports CommonMark 0.31.2 and GFM tables, strikethrough, and task lists. For a Markdown string outside the Article box, call `$app->getMarkdown()->render($source)`. The pipeline parses Markdown into a document tree, then a safe HTML renderer escapes text and attributes and emits a limited set of HTML elements. There is no unsafe HTML mode. See the framework's `README.md` section "Markdown content" for the renderer contract and limits.

## Adding a page

1. Insert a row into `cms_sites` (the URL) and optionally `cms_menu` (the navigation entry).
2. Create `src/Box/Central/Hello.php`:

   ```php
   namespace App\Box\Central;

   use Wbengine\Box\WbengineBoxAbstract;

   class Hello extends WbengineBoxAbstract
   {
       public function Hello()
       {
           return $this->getRenderer()->render($this->getBoxTemplatePath());
       }
   }
   ```
3. Create `src/View/Central/Hello.tpl`.
4. Insert a `cms_boxes` row: module `hello`, method `hello`, section 1 (central), `sites` `["<your site_id>"]`.

Always pass values to SQL as bound parameters: `Db::fetchAssoc('SELECT * FROM cms_articles WHERE id = ?', [$id])`.

## REST API

Served under `/api/`. Obtain a token, then send it as a bearer token:

```bash
curl -X POST -H 'Content-Type: application/json' \
     -d '{"username":"admin@example.com","password":"changeme"}' \
     http://localhost:8080/api/auth/login

curl -H "Authorization: Bearer <token>" http://localhost:8080/api/sections
```

Every route except `/api/auth/login` needs a valid token. Currently available: `auth` (login, logout, identify, revalidate), `users` (list, get, create, patch, delete), `sections` (CRUD), `translations` (content translations, editor role), `cache/flush`.

## Security notes

* The JWT keys and reCAPTCHA secret live in `Settings.json` (or the environment variables `WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`). Never commit them. `Settings.json` is ignored by git.
* Keep `"debug": false` in production: debug mode prints SQL and error details.
* Set `i18n.baseUrl` in the production `Settings.json` to `"https://www.wbengine.org"`. Keep the site behind HTTPS, create unique production JWT signing keys, and replace or remove the demo administrator before opening the site to the public.
* On an existing installation, `Settings.json` is preserved during rebuilds. To make the unprefixed live site English, set `i18n.default` to `"en"` and `i18n.detect` to `["url"]` in that file; the tracked `settings.json.default` affects fresh installations only.
* Build and deploy the reviewed application and database schema, run the documented migrations, then verify `/`, `/cs/`, `/docs/` and `/cs/docs/` over HTTPS. Do not deploy with the demo login `admin@example.com` / `changeme` enabled.
* API operations require the documented role: user and section administration and cache flushing require an administrator; translation management requires an editor or administrator.
* Do not commit TLS certificates or private keys; terminate TLS in front of the application.

## Google Analytics and cookie consent

The site uses Google Analytics 4 property `G-PRGMM4N3S6`. The localized cookie banner uses Google's basic consent approach: analytics storage starts denied, and the `gtag.js` library is not requested until the visitor allows analytics. Rejecting optional cookies keeps the tag disabled. A persistent Cookie settings button in the footer lets visitors reopen the choice; withdrawing a previous grant disables analytics and removes visible Google Analytics cookies before reloading. The choice is kept in browser local storage and is not sent to this application.

The banner explains the analytics purpose and links to Google's privacy policy. It is a technical consent control, not a complete privacy notice. Before treating the site as legally ready, publish the site's own privacy and cookie information with the controller identity, purposes, legal basis, retention, recipients and any international transfers. See [Google's Consent Mode documentation](https://developers.google.com/tag-platform/security/concepts/consent-mode) and the [Czech Data Protection Authority's cookie guidance](https://uoou.gov.cz/verejnost/qa-otazky-a-odpovedi/cookies).

## TailwindCSS

The stylesheet is built from `src/input.css` with Tailwind (`tailwind.config.js`):

```bash
npm install
npx tailwindcss -i ./src/input.css -o ./public/Css/output.min.css --watch --minify
```

Without a local Node, use Docker: `docker run --rm -v "$PWD":/app -w /app node:22-alpine sh -c "npm install && npx tailwindcss -i ./src/input.css -o ./public/Css/output.min.css --minify"`. `tailwind.config.js` scans the templates, the framework's own box templates and `schemas/**/*.sql`; generated Markdown articles use the typography classes in `src/input.css`.

Console examples use fenced Markdown blocks labeled `bash`. The dependency-free
`public/code-highlight.js` colors shell commands, options, strings and comments
with the homepage palette. It builds spans with DOM text nodes, preserving readable
and copyable source. Without JavaScript, code remains plain text.

## WBengine CLI

Composer installs `vendor/bin/wbengine.php`. These commands inspect configuration,
deployment readiness and migration state; they do not run database migrations:

```bash
vendor/bin/wbengine.php config:check --config=src/Config/Settings.json --root=src
vendor/bin/wbengine.php doctor --config=src/Config/Settings.json --root=src
vendor/bin/wbengine.php migration:status --config=src/Config/Settings.json --root=src
```

`doctor` is read-only. Review its findings in both the CLI PHP environment and the
web worker, since extensions, OPcache and filesystem permissions may differ. For
all supported commands and options, run `vendor/bin/wbengine.php help`.

## Contributing

Please read [CONTRIBUTING](docs/CONTRIBUTING.md) for the code of conduct and the process for submitting pull requests.

## Improving this sample

The WBengine library and this sample application are open source and a volunteer effort. RRsoft does not have people fully dedicated to maintaining them. If you want something improved or a new feature, please submit a pull request. The library lives at https://github.com/rrsoftcz/wbengine.

## License

MIT, see [LICENSE](docs/LICENSE.md).


## WBengine 4.0 migration and HTTP verification

This branch targets WBengine ^4.0. Production Composer installation requires the
4.0 release; the isolated development profile uses a path checkout with an explicit
4.0.x-dev version. It never replaces the normal deployment configuration.

The application root now owns a lazy App\Site service. Layout user data is prepared
after framework routes and the page-cache gate, so anonymous public pages can reach
HIT without starting a session. Logged-in navigation uses a POST logout form and
its own purpose CSRF token. Production diagnostics are displayed only when supplied.

For repeatable local smoke testing, build the framework test image, set
WBENGINE_FRAMEWORK_PATH to its 4.0 checkout, and run:

```sh
docker compose -p wbengine-skeleton-smoke -f compose.smoke.yml run --rm tools php tests/setup-smoke.php
docker compose -p wbengine-skeleton-smoke -f compose.smoke.yml run --rm tools composer install --no-dev --no-interaction --prefer-dist
docker compose -p wbengine-skeleton-smoke -f compose.smoke.yml run --rm tools php tests/seed-smoke.php
docker compose -p wbengine-skeleton-smoke -f compose.smoke.yml up -d --wait web
docker compose -p wbengine-skeleton-smoke -f compose.smoke.yml exec -T web php tests/http-smoke.php
docker compose -p wbengine-skeleton-smoke -f compose.smoke.yml down --remove-orphans
```

This creates only the isolated Compose database and ignored Settings/vendor files.
The fixture password and JWT values are test-only. No ports are published by this
profile. The 20 checks cover native page output, anonymous HIT, locale, 404, article,
real login/CSRF/profile, rejected GET/invalid POST logout, successful POST logout,
public API v2 discovery and unchanged API v1 authorization. CI executes the same
workflow against the framework development branch.

[Migration checkpoint and remaining work](docs/plan-wbengine-4.0-migration.md).


## Izolovaný CMS benchmark WBengine 4.0

Po přípravě stejného smoke prostředí lze spustit:

```sh
docker compose -p wbengine-skeleton-modernization -f compose.smoke.yml run --rm tools php tests/benchmark-cms.php
```

Runner vyžaduje WBENGINE_SMOKE marker a vlastní existující seed DB. Spustí pouze svůj čtyřprocesový HTTP server na interním loopback8081, použije skutečné CSRF přihlášení a DB sessions. Mění pouze konfiguraci jednotlivých testovacích requestů a čistí jen vlastní náhodný cache adresář před každou kohortou; hlavní konfiguraci ani server nemění. Testovací router přidává měřicí hlavičky pouze zde, ne v produkci.

Výsledek tests/benchmark-cms-result.json obsahuje 15 kombinací cache/identity,20vzorků každé,p50/p95,throughput,HTTPerrors,SQL/spojení/paměť a skutečné HIT počty. Cookies ani hesla ve výsledku nejsou. Měření na malé lokální fixture není záruka produkčního výkonu. Throughput zahrnuje fork a sběr klientských procesů, paměť je vrchol alokovaných bajtů serveru, OPcacheCLI byl při uloženém běhu vypnutý.


`tests/content-migration-smoke.php` ověřuje skutečné demo HTML články a překlady na dočasných kopiích:18suchýchplánů,8vratných bezpečných převodů a10 případů k ručnímu rozhodnutí. Původní obsah a schéma zůstávají bezezměn. Spusťte ve stejném smoke prostředí přes tools stejně jako benchmark; kompletní stav a důvody jsou v docs/plan-wbengine-4.0-migration.md.
