# Changelog

## [Unreleased]

### Added

- Documentation update for the history of changes in the central Admin: `schemas/migrations/019-history-panel-docs.sql`.
- WBengine updated to 4.7.0 (API lists the languages that have a translation). Documentation of how languages are chosen in the central Admin updated by `schemas/migrations/018-language-selection-docs.sql`.
- Documentation of languages and translations (where languages are configured, how translations are stored, how to add a language or change the default) in the Central administration article, in English and Czech. Installed sites apply `schemas/migrations/017-languages-and-translations-docs.sql`.
- The site registers the box type `story` (module `blog`, method `story`, section `central`) at startup in
  `App\Application`, so API v2 reports it in `box_types` and `capabilities.boxes.write` is true. WBengine
  Admin can now add the article box to a page. The HTTP smoke test checks both. The README explains how to
  register your own box types.

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
