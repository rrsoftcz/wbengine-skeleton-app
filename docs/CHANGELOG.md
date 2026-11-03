# Changelog

## [Unreleased]

### Changed

- The site uses the official WBengine logo, the light icon from `Assets/svg/wbengine-03-icon-light.svg` on the logo purple (`#5723FC`): `Assets/favicon.svg` on a square canvas, a multi size `favicon.ico` (16, 32 and 48 px, also copied to the root), `apple-touch-icon.png` and the 192 and 512 px PNG icons of the web manifest. The browser theme colour and the manifest use the logo purple. The full set of logo files (SVG, PNG and favicon sets) is committed under `public/Assets/`. Replaces the earlier indigo W icon.
- The icon of the site is the W of the logo (the rounded square with the indigo to fuchsia gradient): `Assets/favicon.svg`, a multi size `favicon.ico` (16, 32 and 48 px, also copied to the root for clients that ask for `/favicon.ico`), `apple-touch-icon.png` and the 192 and 512 px PNG icons of the web manifest, which replace the old bird icon and two JPEG files. The manifest name and theme colour match the layout. The icons are requested with the content fingerprint, so a browser replaces a cached icon. `tests/http-smoke.php` checks the links, the served types and the manifest.

### Fixed

- The header and the footer show the official WBengine logo (`Assets/favicon.svg`) instead of a hand-drawn indigo W tile, so the logo on every page matches the favicon.
- A browser that had cached the stylesheet before a deployment kept showing the old one for a while (the footer with the version stacked in the middle instead of three columns). The stylesheet and the scripts of the layout are now requested with a fingerprint of their content (`?v=`, `Site::assetsVersion()`), so a changed file is loaded immediately. `tests/http-smoke.php` checks the fingerprint.

## [1.1.0] - 2026-11-03

### Fixed

- The version in the header had too little contrast (light grey on white, 2.6 to 1 where 4.5 to 1 is required), which Lighthouse reported as the only accessibility finding of the home page (96). It is now `text-slate-600`. Found by running Lighthouse on the live site.
- `package-lock.json`: `npm audit fix` updated the build tooling of the stylesheet (postcss, minimatch, glob, brace-expansion, nanoid, picomatch, source-map-js) and removed packages that are no longer needed; 14 reported vulnerabilities in development packages are gone (`npm audit` reports none). `package.json` is unchanged, Tailwind stays at 3.4.17 and the compiled `public/Css/output.min.css` is byte-identical. The packages were never part of the running site.
- The Changelog menu entry stands right after Blog instead of after About (migration `043-changelog-menu-order.sql`, guarded and mirrored in the content dump). `tests/http-smoke.php` checks the order.
- On a phone the version of the framework was hidden in the header; it is now always shown, right after the logo icon, and the header is tighter on a narrow phone so that the sign in button stays on one line (checked from 300 to 390 pixels), and the two footer columns, Documentation and Project, stand side by side instead of one under the other. Checked in Chrome at 320, 390 and 1280 pixels.
- The changelog page printed "This site runs WBengine v" without the number, because a box template does not see the layout variable `wbengine_version`: the box now passes the version. `tests/http-smoke.php` checks it.
- On a phone, long inline code (names of settings, files and classes) widened documentation pages and the changelog beyond the screen (`/docs/`, `/docs/settings/`, `/docs/deployment/`, `/docs/logging/`, `/docs/mcp-clients/`, `/changelog/`). Inline code now wraps, wide tables scroll inside themselves, and the changelog entries get the code style of the documentation. Measured in Chrome at 390 pixels with the new stylesheet: the five documentation pages no longer overflow. The stylesheet was rebuilt.

### Added

- The footer shows the version of the skeleton application at the bottom right (`WBengine Skeleton App v1.1.0`), the cookie settings button stays in the middle. The number comes from the new `VERSION` file in the project root (`Site::skeletonVersion()`, hidden when the file is missing or malformed) and is raised by hand with each release. The compiled stylesheet gets the three layout utilities of the footer. `tests/http-smoke.php` checks the shown version against the file.
- The documentation page `/docs/administration/` (Central administration, English and Czech) is extended with the installation and operation of the central administration WBengine Admin: a short list of its sections at the top and three new parts. Installing and configuring (requirements, every environment variable including the `MAIL_*` settings, the start with Docker Compose and the migrations, the HTTPS reverse proxy, the first administrator), Accounts and access (signing in with two-step verification, roles, users and invitations, the optional invitation email through SMTP with the steps for a Google account and an app password, what "sent" means and the failure reasons) and Operating the administration (the master key and backups, the command line, updating). The page also says now that the source of the administration is public under the MIT license, that the first account is created on the server and later people are invited on the Users page, and the start page of the documentation points to it. Migration `046-administration-docs-extension.sql` (guarded, mirrored in the content dump). `tests/http-smoke.php` checks the settings and the invitation section on the page in both languages.
- The documentation page `/docs/performance/` (English and Czech): what is measured (the time of the core, not the speed of a website), the results per case, how and in what environment it was measured, how to repeat it and what to keep in mind. Migration `045-performance-docs-page.sql` (guarded, mirrored in the content dump).
- The footer links to the GitHub project of the central administration, next to the framework, Packagist and RRSOFT.
- Sections added to five documentation pages, English and Czech: Boxes (strict and dynamic pages and how a box refuses an address, sections, order and device limits, managing boxes without code), Caching (the page cache per path, language and device, what is never stored, the header `X-WBengine-Cache`), Languages (addresses, `alternates` and `hreflangs`, translations, statistics per language), Templates (a table of the layout variables including `wbengine_version`) and API (hiding and showing an article, limiting a key to addresses, the change feed, images, statistics, presets and the MCP server). Migration `042-docs-extensions.sql` appends each section once (guarded, mirrored in the content dump).
- Documentation pages `/docs/seo/` (what a site tells search engines: titles, addresses, canonical and language links, the sitemap, `robots.txt`, the `seo` settings, what it does not do) and `/docs/analytics/` (what the statistics count and do not count, the split by language, switching them on, reading the numbers, their limits), English and Czech, in the sidebar. Migration `041-seo-analytics-docs-pages.sql` (guarded, mirrored in the content dump).
- Documentation pages `/docs/mcp/` (the MCP server for editors: what it does and never does, which key to issue, the tools in plain words, updating, troubleshooting) and `/docs/mcp-clients/` (connecting a client on Linux, macOS and Windows with WSL2 as the recommended way, checking the download, the configuration, what was checked), English and Czech. They are in the sidebar (`Docs::PAGES`). Migration `040-mcp-docs-pages.sql` (guarded, mirrored in the content dump). `tests/http-smoke.php` now requests every documentation page in both languages.
- The overview of the blog on `/blog/` (`Blog::Overview()`, `src/View/Central/Overview.tpl`): the newest posts as cards with an excerpt, the most read ones by view count, and the list of all posts, in the language of the visitor. A post is an article on a page under `/blog/` that a visitor can open. `App\Blog\Excerpt` makes the plain-text excerpt, cut at a whole word. The list is limited to 100 posts. Migration `039-blog-overview.sql` (guarded, mirrored in the content dump) moves the demo article that was the content of `/blog/` to its own page `/blog/what-wbengine-gives-a-site/` and rewrites it, in English and Czech, to describe what the framework gives a site, and puts the overview box on `/blog/`. `tests/blog-excerpt.php` and the HTTP smoke test check it. The stylesheet was rebuilt.
- The page `/changelog/` with a menu entry (English and Czech): the releases of the framework that renders the site, newest first, with their groups of changes. The box `App\Box\Central\Changelog` reads `CHANGELOG.md` from the installed framework package (no network), `App\Changelog\Parser` reads its sections and the entries go through the safe Markdown renderer. Releases before 5.0.0 are collapsed. The version in the header links to the page. Migration `038-changelog-page.sql` (guarded, mirrored in the content dump) adds the page, the box and the menu entry; it needs framework 6.7 or newer. `tests/changelog-parser.php` checks the parser on a sample and on the installed changelog, `tests/http-smoke.php` checks the page in both languages. The stylesheet was rebuilt. The release notes stay in English in both languages.
- WBengine 6.7.0 (`composer.json` `^6.7`, `composer.lock`): the header shows the version of the framework that renders the site in a small font beside the site name (`src/View/site.tpl`, the layout variable `wbengine_version`, `dev` when it is not a release), with the string `nav.version` in English and Czech. `bin/update-database.sh` and `bin/setup-production.sh` apply `6.7.0/013-analytics-locale.sql`, which records the views of a page per language. A site that has analytics switched on applies it once (`sh bin/update-database.sh DATABASE`, safe to rerun); counting continues without it. `tests/http-smoke.php` checks that the shown version equals the locked one.
- WBengine 6.6.0 (`composer.json` `^6.6`, `composer.lock`): `public/index.php` registers `/robots.txt` and `/sitemap.xml`, and `settings.json.default` gets `seo.disallow` and `seo.sitemapExclude` for the login page. The sitemap lists the visible public pages once per language with links to the other languages. `tests/http-smoke.php` checks both files. Migration `037-seo-settings-docs.sql` documents the `seo` settings in the settings reference (English and Czech, mirrored in the content dump). A site with its own `Settings.json` adds the `seo` keys if it wants the login page left out.
- `src/View/site.tpl`: every page has a `<link rel="canonical">` with the absolute address of the page in its own language, the same address as its `hreflang` link. `tests/http-smoke.php` checks it for the English and Czech home page.

### Changed

- The documentation page `/docs/administration/` (English and Czech) describes the SQLite database of the central administration: the settings table without database passwords, the start without a database container, the backup command and the rule of one instance (migration `047-administration-sqlite-docs.sql`, guarded and mirrored in the content dump).
- WBengine 6.7.1 (`composer.lock`, the smoke workflow ref): the Composer package metadata has the live site as its homepage, and the stale built MCP phar is no longer in the package. No database update and no setting. The changelog page lists the new release.
- The statistic Runtime packages (0) of the hero on the home page is replaced by the time the core needs to assemble the home page without any cache (7 ms, median), the cached page shows its time (2 ms) instead of 0 SQL, and a note says what is measured, that it is not a website speed test and links to the method. Both numbers come from `tests/benchmark-cms-result.json`, which the smoke test compares with the home page and the Performance page.
- `tests/benchmark-cms.php` runs its server with OPcache on (`WB_BENCHMARK_OPCACHE=0` for off) and reports `php_ms`, the time in PHP until the response is ready, next to the HTTP time (`tests/benchmark-router.php` adds the header `X-WB-Benchmark-PHP-Ms`). The recorded result was renewed on 2026-11-01 with WBengine 6.7.0: anonymous page without any cache 7.1 ms median, with the data cache warm 5.7 ms, from the full-page cache 1.8 ms.
- The section One request from URL to HTML of the Architecture page shows the path of a request as a diagram (`public/Assets/request-flow.en.svg` and `request-flow.cs.svg`) with the same steps as a numbered list under it, instead of a text block: six steps, the chain Section, Box, Model, Renderer, and the shortcut of a full-page cache hit. The diagram is an image with a text alternative and a description inside; articles cannot embed HTML or SVG. Pictures in articles are as wide as their column at most (`.doc img`), the stylesheet was rebuilt. Migration `044-request-flow-diagram.sql` replaces the old text block once (guarded, mirrored in the content dump).
- The license text moved from `docs/LICENSE.md` to `LICENSE` in the root of the repository, where GitHub looks for it, so the repository page now shows the MIT license. The text is unchanged and the same as in the framework.
- WBengine 6.5.3 (`composer.lock`): the MCP server generates cleaner addresses, browser titles and menu names, warns about missing page and menu translations and reports no comparison against a period before counting.
- WBengine 6.5.2 (`composer.lock`): the MCP server says on stderr how it started and how it ends.
- WBengine 6.5.1 (`composer.lock`): the text of an MCP tool result is also in its structured result, so clients that show only that part get the guide texts and warnings.
- WBengine 6.5.0 (`composer.json` `^6.5`, `composer.lock`): the MCP server reads statistics, builds reports from them and analyzes the change log. No database update.
- WBengine 6.4.1 (`composer.lock`): the MCP server tries IPv4 first, so a broken IPv6 route does not slow every call.
- WBengine 6.4.0 (`composer.json` `^6.4`, `composer.lock`): the MCP server manages pages, menu, boxes and images and guides an editor who is not technical. `src/Application.php` registers the box type `story` as a renderer of articles (`['renders' => 'article']`), so an agent knows that a page with this box shows its article and can add the box to a new page; the smoke test checks it. `schemas/migrations/036-mcp-editor-docs.sql` names the editor preset in the Connecting a site section of the public documentation, in English and Czech; mirrored in the content dump.
- `docker-compose.production.yml` and `Dockerfile.production`: the volume `images_data` is mounted at `/var/lib/wbengine/images` and `WBENGINE_IMAGE_DIR` points to it, so images uploaded through API v2 are stored outside the web root and survive a container rebuild. Back this volume up with the database.
- WBengine 6.3.1 (`composer.lock`): the MCP server warns when the page of an article has no box that shows articles.
- WBengine 6.3.0 (`composer.json` `^6.3`, `composer.lock`): the framework contains an MCP server for AI assistants (`wbengine-mcp.phar`, attached to the framework releases) and the Integrations page offers key presets for agents and a client configuration. No database update is needed. `schemas/migrations/035-mcp-server-docs.sql` describes it in the Connecting a site section of the public documentation, in English and Czech; mirrored in the content dump.
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
