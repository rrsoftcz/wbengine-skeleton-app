# Changelog

## [Unreleased]

### Changed

- WBengine 6.2.0 (`composer.json` `^6.2`, `composer.lock`): published articles can be hidden through the API. A hidden article is not shown, its page answers 404 and its menu item disappears. `bin/update-database.sh` and `bin/setup-production.sh` also apply the update for it, `src/Box/Central/Article/Model.php` skips a hidden article, and `schemas/migrations/034-api-hide-docs.sql` mentions it on the API page of the public documentation, in English and Czech; mirrored in the content dump.
- WBengine 6.1.0 (`composer.json` `^6.1`, `composer.lock`): an integration key can be bound to IP addresses. `bin/update-database.sh` and `bin/setup-production.sh` also apply the update for it. `schemas/migrations/033-key-address-docs.sql` describes it in the Connecting a site section of the public documentation, in English and Czech; mirrored in the content dump.
- WBengine 6.0.0 (`composer.json` `^6.0`, `composer.lock`): the unused settings `codePage`, `cdnPath`, `cssFiles`, `ipAdmins`, `minimizeHtml`, `minimizeCss` and `minimizeJs` are removed from `settings.json.default`; an existing `Settings.json` keeps working, the keys are ignored. `schemas/migrations/032-unused-settings-docs.sql` removes them from the Settings reference page, in English and Czech; mirrored in the content dump. The home page badge no longer names a version.
- WBengine 5.2.0 (`composer.json` `^5.2`, `composer.lock`): the permission groups of the key form on `/integrations/` are one row each with None, Read and Write buttons, colored red, blue and green by the choice.
- WBengine 5.1.1 (`composer.lock`): the permission groups of the key form on `/integrations/` are cards with soft pastel colors.
- WBengine 5.1.0 (`composer.json` `^5.1`, `composer.lock`): an integration key is issued with permission groups, and the Integrations box needs no class in the application. The skeleton class `src/Box/Central/Integrations.php` is removed: the box row alone connects the page. `schemas/migrations/031-key-groups-docs.sql` updates the Connecting a site section of the public documentation, in English and Czech; mirrored in the content dump. The smoke test now also renders the page for an administrator.

### Changed (breaking)

- WBengine 5.0.0 (`composer.json` `^5.0`, `composer.lock`): API v2 is the only API. The former routes under `/api/auth`, `/api/users`, `/api/sections`, `/api/translations` and `/api/cache/flush` and the JWT login are gone, and so is the `jwt` section of `Settings.json` (an existing file keeps working, the section is ignored). `bin/wbe install` and `bin/setup-production.sh` no longer generate signing keys. The database update `bin/update-database.sh` drops the unused table `cms_refresh_tokens`. The live request console and the box `src/Box/Api/Restapi.php` are removed. `schemas/migrations/029-api-v2-only-docs.sql` updates the public documentation accordingly, in English and Czech; mirrored in the content dump. The skeleton migrations 003 and 004 for the refresh token table are removed.

### Fixed

- README, deployment guides, interface texts and public documentation match WBengine 5: the PHP extensions, the removed refresh tokens, the API v2 cache flush and translation routes, the current CLI commands, the local stack database updates (`bin/update-database.sh`), the home page counter of runtime packages (0) and the home and API page titles. The Czech Architecture page is the full translation of the English one. `schemas/migrations/030-framework-5-docs.sql` updates the public pages in English and Czech; mirrored in the content dump.
- Apache rewrite keeps the query string, so API v2 filters and dates (for example the analytics period) reach the framework.

### Added

- `schemas/migrations/028-integrations-install-docs.sql` documents the `integrations:install` command in the Connecting a site section, in English and Czech; mirrored in the content dump.
- WBengine updated to 4.11.0 (`composer.lock`): `vendor/bin/wbengine.php integrations:install` creates the page and box for the Integrations screen on a site that lacks them.
- WBengine updated to 4.10.1 (`composer.lock`): the integrations page lists active keys as cards and folds revoked keys away.
- WBengine updated to 4.10.0 (`composer.lock`). `bin/update-database.sh` and `bin/setup-production.sh` also apply the remote user management update. `schemas/migrations/027-site-users-docs.sql` documents the site users and settings pages of the central administration, in English and Czech, and fixes one wording that named a release; mirrored in the content dump.
- WBengine updated to 4.9.0 (`composer.lock`). `schemas/migrations/026-change-feed-docs.sql` documents the change feed `GET /api/v2/changes` (scope `audit:read`) on the Logging and audit page, in English and Czech, mirrored in the content dump.
- `bin/update-database.sh` applies the framework database updates (API, analytics and change log tables) from `vendor`, or prints the SQL with `--print` to pipe into another mysql client. The public documentation pages refer to it instead of naming migration files.
- Public documentation wording: `schemas/migrations/024-public-docs-cleanup.sql` removes release numbers, migration file names and CI details from the documentation pages (mirrored in the content dump); `025-public-docs-cleanup-2.sql` removes the remaining migration numbers from the deployment page of sites that applied the earlier updates one by one.
- Settings reference page `/docs/settings/` (every `Settings.json` key, a production example, Google Analytics) and deployment page `/docs/deployment/`, in English and Czech, added by `schemas/migrations/020-settings-reference-docs.sql` and `021-deployment-docs.sql` and mirrored in the content dump. `Docs::PAGES` and the `doc.settings` and `doc.deployment` locale keys list them in the sidebar.
- `docs/deploy-bare-metal.md`: installation without Docker (PHP-FPM with Nginx, Apache, permissions, migration order, cron, backups, health checks, external database, shared hosting limits, running a built image) and `etc/nginx/wbengine-fpm.conf`, a unix-socket server block.
- `.github/workflows/image.yml` builds `Dockerfile.production` on `v*` tags and pushes `ghcr.io/rrsoftcz/wbengine-skeleton-app`.
- `googleAnalytics.measurementId` setting. The measurement id is no longer hardcoded in `public/cookie-consent.js`: the layout passes it to the script through the banner, and an empty or missing id renders no cookie banner and loads nothing. `minimizeJs` and `googleAnalytics` are in `src/Config/settings.json.default` (the id is empty); a site that used Google Analytics sets its id in its own `Settings.json`.
- WBengine updated to 4.8.0 (`composer.lock`). Logging and audit page `/docs/logging/` (English and Czech, `schemas/migrations/022-logging-docs.sql`): what is logged where, the API audit and change log, who/what/when queries, retention and `audit:prune`, privacy notes. `schemas/migrations/023-audit-settings-and-cron-docs.sql` adds the `audit.*` keys and the production example to the settings page and `audit:prune` and the framework migration `4.8.0/008-change-log-source.sql` to the deployment page (also `docs/deploy-bare-metal.md`). `bin/setup-production.sh` applies that framework migration; installed sites with API v2 apply it once (`doctor` fails without it) and schedule `audit:prune`.
- Documentation update for the history of changes in the central Admin: `schemas/migrations/019-history-panel-docs.sql`.
- WBengine updated to 4.7.0 (API lists the languages that have a translation). Documentation of how languages are chosen in the central Admin updated by `schemas/migrations/018-language-selection-docs.sql`.
- Documentation of languages and translations (where languages are configured, how translations are stored, how to add a language or change the default) in the Central administration article, in English and Czech. Installed sites apply `schemas/migrations/017-languages-and-translations-docs.sql`.
- The site registers the box type `story` (module `blog`, method `story`, section `central`) at startup in
  `App\Application`, so API v2 reports it in `box_types` and `capabilities.boxes.write` is true. WBengine
  Admin can now add the article box to a page. The HTTP smoke test checks both. The README explains how to
  register your own box types.

### Changed

- `etc/apache2/sites-available/wbengine-production.conf` is now a documented template without a hardcoded host or environment.

### Fixed

- The sample Nginx configuration rewrites absolute `http://` redirects from the container (for example `/blog` to
  `/blog/`) to HTTPS with `proxy_redirect`. WBengine updated to 4.5.0 (article source is optional free text).
- Behind host Nginx a fresh production install treated every request as plain HTTP (empty
  `http.trustedProxies`), so `/integrations/` refused to issue a key. `bin/setup-production.sh` now detects
  the Compose network gateway and configures `http.trustedProxies` and `http.forwardedHeaders`. The installer
  also takes the public site address as its first argument instead of the hard-coded
  `https://www.wbengine.org`.
- The profile page links administrators to `/integrations/`, so the page no longer has to be typed by hand.
  Guide text updated by `schemas/migrations/016-installer-site-url-and-proxy-docs.sql`.
- The Integrations page (`/integrations/`) was inserted with `visible = 0`, but the framework resolves only
  visible pages, so it answered 404 for everyone. Migration 013 and the content dump now use `visible = 1`;
  installations that already applied 013 run `schemas/migrations/015-integrations-page-visible.sql`.
  The HTTP smoke test now checks that the page redirects anonymous visitors to the login.

### Added

- `bin/wbe user:create|user:password|user:list|user:delete`: account management wrappers around the
  framework CLI (requires WBengine 4.3), `bin/setup-production.sh` prints the next step, and the README,
  `docs/deploy-vps-docker.md` and the site documentation (`schemas/migrations/014-users-and-site-connection-docs.sql`,
  also appended to the fresh install content dump) explain the first login and connecting a site to WBengine Admin.
- "Integrations" page (`/integrations/`, login required) where a local `ADMIN` issues,
  revokes and rotates API v2 integration keys for the central WBengine Admin:
  `App\Box\Central\Integrations` extends the framework box and
  `schemas/migrations/013-integrations-page.sql` adds the site and box rows (also appended to the
  fresh install content dump). Requires the first WBengine release after 4.1.0 (not released yet), API v2 enabled and
  the framework migrations `4.0.0/002` and `4.0.0/007`. Do not merge before that release.

### Changed

- Docker setup: PHP 8.4 image, MySQL 8.4, lowercase `public/` and `schemas/`
  paths, an HTTP vhost with `AllowOverride All`, port 8080. TLS certificates are
  no longer part of the repository.
- `settings.json.default`: correct `SmartyRenderer` adapter name, `jwt` and
  `recaptcha` sections, `ipAdmins`, no minification by default.
- `cms_users.password` is `varchar(255)`. Existing databases: run
  `schemas/migrations/001-widen-user-password.sql`.
- The demo account is `admin@example.com` / `changeme` (change it).
- `public/.htaccess` no longer redirects `/api` to add a trailing slash.
- The blog box and its model use bound parameters.

### Languages

- English and Czech (`src/Locale/en.php`, `cs.php`) with the `i18n` setting enabled in
  `settings.json.default`: `/cs/` URLs, a language switcher, `hreflang` links, translated
  layout, profile and jumbotron, localized menu and login URLs (`|lurl`).
  Requires WBengine 3.2 (`composer.json` requires `^3.2`).

### Changed (Docker and HTTPS)

- Plain HTTP on port 8080 is the zero-setup default. The mkcert HTTPS development
  setup (https://wbengine.local) is kept as an optional override:
  `docker compose -f docker-compose.yml -f docker-compose.https.yml up -d`, with
  the vhost `etc/apache2/sites-available/wbengine-https.conf`. The production vhost
  is `wbengine-production.conf`. Certificates are still never committed
  (`etc/cert/README.md`). `etc/php/custom.ini` (development PHP settings) is mounted.

### Changed (templates)

- The skeleton now uses the native template engine with automatic escaping
  (`"adapterName": "NativeRenderer"`, `"autoEscape": true`). Trusted HTML is marked
  `|raw` in `site.tpl` and `LocalStoryBox.tpl`; everything else is escaped. The
  pages are identical to the Smarty ones. The templates also work with Smarty.

### Added

- `etc/nginx/wbengine.conf`: an Nginx configuration equivalent to `.htaccess`. The
  skeleton was run end to end on Nginx with PHP-FPM and MariaDB 11.4.
- `cms_refresh_tokens`: server side refresh tokens for the REST API. Existing
  databases: run `schemas/migrations/003-add-refresh-tokens.sql` and then
  `004-refresh-token-family-start.sql` (absolute lifetime of a login).
- `cms_users.role` (`user`, `editor`, `admin`): the REST API now authorizes by role.
  Existing databases: run `schemas/migrations/002-add-user-role.sql` and promote
  your administrators, otherwise the API answers 403 to everybody.
- `bin/setup.sh`: creates `Settings.json` with random JWT keys, prepares the
  template cache and runs `composer install`.
- `Profile` box and template, `schemas/migrations/`.
- Rewritten README.

### Fixed

- The REST API box called methods that do not exist.
- `Blog::LocalStoryBox` resolved the wrong model class.

### Removed

- Private keys, certificates and a customer vhost from version control (rotate
  any key that was committed), the PHP 7.0 Dockerfile and its Apache snippet,
  `Exception.html`.

Requires WBengine 3.1 or newer (`composer.json` requires `^3.1` and PHP 8.3 or newer).
