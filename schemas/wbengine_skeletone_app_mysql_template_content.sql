-- Demo content of the skeleton: the home page, the documentation pages, the menu, the blog article
-- and their Czech translations. Imported after the schema on the first start of an empty database.
-- The documentation pages are articles stored in the database: the Tailwind build scans this file.
SET NAMES utf8;

UPDATE `cms_sites` SET `title`='WBengine', `html_title`='WBengine', `html_description`='A fast, database driven PHP framework: sites, sections and boxes, native templates, Markdown, caching and a REST API.', `html_keywords`='wbengine,php,framework,cms' WHERE `site_id`=1;
UPDATE `cms_sites` SET `title`='Blog', `html_title`='Blog', `html_description`='An article shown by the bundled Article box, with translations and a view counter.', `html_keywords`='blog,article,box' WHERE `site_id`=2;
UPDATE `cms_sites` SET `title`='About', `html_title`='About', `html_description`='About WBengine and a static box example.', `html_keywords`='about,static box' WHERE `site_id`=3;
INSERT INTO `cms_sites` (`site_id`,`parent_id`,`left_id`,`right_id`,`strict`,`visible`,`link`,`title`,`html_title`,`html_description`,`html_keywords`,`acl`) VALUES
(10,1,0,0,1,1,'/docs/','Getting started','Getting started','Install the WBengine skeleton, sign in and add your first page in two minutes.','getting started,install,docker',0),
(11,1,0,0,1,1,'/docs/architecture/','Architecture','Architecture','How WBengine turns a URL into a page: sites, sections, boxes and the request lifecycle.','architecture,site,section,box',0),
(12,1,0,0,1,1,'/docs/boxes/','Boxes','Boxes','Static and dynamic boxes, models and the cms_boxes table.','boxes,model,cms_boxes',0),
(13,1,0,0,1,1,'/docs/templates/','Templates','Templates','Native templates, automatic escaping, direct Markdown sources, and compiled rendering.','templates,escaping,markdown',0),
(14,1,0,0,1,1,'/docs/languages/','Languages','Languages','Languages in WBengine: URL, cookie and header detection, catalogs, plurals and translated database content.','i18n,languages,translations',0),
(15,1,0,0,1,1,'/docs/caching/','Caching','Caching','The data cache and the page cache: what is stored, when, and how to invalidate it.','cache,performance,apcu',0),
(16,1,0,0,1,1,'/docs/security/','Security','Security','Bound parameters, escaping, password hashing, sessions, tokens, roles and rate limiting.','security,jwt,roles',0),
(17,1,0,0,1,1,'/docs/rest-api/','REST API','REST API','The CMS API and the separate server-to-server API v2, with authentication, scopes and roles.','rest,api,jwt',0),
(18,1,0,0,1,1,'/docs/administration/','Central administration','Central administration','A separate application for managing content on multiple WBengine sites through API v2.','administration,api,multi-site',0);

UPDATE `cms_menu` SET `visible`=1, `order`=1, `description`='Start page' WHERE `menu_id`=1;
UPDATE `cms_menu` SET `order`=3, `description`='Articles with the bundled box' WHERE `menu_id`=2;
UPDATE `cms_menu` SET `order`=4, `description`='About WBengine' WHERE `menu_id`=3;
INSERT INTO `cms_menu` (`menu_id`,`site_id`,`type`,`name`,`description`,`visible`,`order`,`parent`) VALUES (4,10,1,'Documentation','Guides and live demos',1,2,0);

UPDATE `cms_articles` SET `title`='Articles with the bundled box', `introtext`='WBengine renders article content through the bundled Article box. New articles can use safe Markdown, while existing HTML stays explicitly marked as legacy HTML.', `bodytext`='## What the Article box does

The framework box reads the article attached to the current site, applies its declared content format, and renders the result through its own template. Translated fields live in `cms_article_translations`; each translation has its own `content_format`.

New text should use Markdown. WBengine parses it without an extra package, escapes raw HTML, and permits only safe link schemes. Existing records default to `legacy_html` and are not converted automatically.

## Add an article

Store the Markdown source and label it explicitly:

```sql
INSERT INTO cms_articles (site_id, title, introtext, bodytext, content_format, published, author)
VALUES (18, ''A new page'', ''A short introduction.'', ''## Details

Write the body in Markdown.'', ''markdown'', UNIX_TIMESTAMP(), ''Editor'');
```

Use bound parameters for application queries. Add the matching `cms_boxes` row to select the bundled `blog` box, then clear the page cache after publishing. See [Boxes](/docs/boxes/) for the page tree.', `content_format`='markdown', `author`='RRSOFT', `source`='https://github.com/rrsoftcz/wbengine' WHERE `id`=1;
INSERT INTO `cms_articles` (`id`,`site_id`,`grouped`,`futured`,`c_enabled`,`views`,`title`,`introtext`,`bodytext`,`content_format`,`published`,`author`,`source`) VALUES
(2,10,0,0,0,0,'Getting started','Install the WBengine skeleton, review its Composer requirements, and run the bundled site locally before changing its content.','## Requirements

- PHP 8.3 or newer with `mysqli` and the extensions required by Composer dependencies.
- MySQL 8 or MariaDB 10.6 or newer.
- Apache with `mod_rewrite`, or Nginx with PHP-FPM.
- Composer 2. Docker is optional.

The application requires the Composer package `wbengine/wbengine`. The framework brings `firebase/php-jwt`; its template engine and Markdown parser are included. Check the package metadata for the exact PHP requirements.

## Docker quick start

```bash
git clone https://github.com/rrsoftcz/wbengine-skeleton-app
cd wbengine-skeleton-app
docker compose up --build
```

Open `http://localhost:8080`. On startup, the web container runs `bin/wbe install`: it creates and validates `Settings.json`, prepares the compiled-template directory and installs locked dependencies. The demo login is `admin@example.com` with password `changeme`. Change it before exposing the site.

## Manual setup

Run `php bin/wbe install` to create and validate settings, prepare `src/View/Compiled`, and install dependencies from `composer.lock`. The command reports invalid JSON, unreadable settings, unwritable compiled cache and Composer failures. Never use `chmod 777`; grant write access to the PHP web-server user. For local debugging only, set `debug` to `true` or `WBENGINE_DEBUG=1`. Remove debug mode before going live.

```bash
php bin/wbe install
```

Create a database, import `schemas/wbengine_skeletone_app_mysql_template.sql` and then `schemas/wbengine_skeletone_app_mysql_template_content.sql`. Configure `src/Config/Settings.json` and point the web root to `public/`.

## Installation and exception troubleshooting

In development, set `debug` to `true` in `Settings.json` to show the WBengine exception template with the exception type, message, file, line and stack trace. If settings are missing or malformed, use `WBENGINE_DEBUG=1` only in a private development environment. Never expose debug output publicly. The production error page shows a safe explanation and reference code; find the full exception in the PHP or container error log under that code.

For upgrades, back up the database and apply pending scripts in `schemas/migrations/` in order. Docker imports the schema and seed files only when it initializes a new database volume. Rebuilding the web image does not update an existing database.','markdown',1761000000,NULL,NULL),
(3,11,0,0,0,0,'Architecture','WBengine is a request-driven PHP framework with a visible object tree. It keeps site structure and content in MySQL, reusable behavior in namespaced PHP boxes, and presentation in templates.','## The object tree

- **Application** is the root of one HTTP request. It loads configuration and provides shared services such as database access, routing, authentication, rendering, Markdown and cache. Services are created lazily when used.
- **Site** is the page selected for the current URL. It carries the site row, locale, access rules, metadata and navigation context.
- **Section** is a named region in the page layout, for example `header`, `central` or `footer`.
- **Box** is a small application component selected by a `cms_boxes` row. Its configured module and method map to a class in the application namespace, such as `App\\Box\\Central\\Docs`.
- **Model** contains reusable data access for a box. It uses the framework database layer and bound SQL parameters.
- **Renderer and template** turn the box data into output. Templates use the framework renderer; they do not replace the PHP object tree.

The parent links are real object references: a box can reach its section, site and application without a second global container. Keep new PHP features in the existing tree and namespaces. Do not put credentials or database logic in templates.

## One request from URL to HTML

```text
public/index.php
  load Composer and application bootstrap
  Application handles an explicit application route or enabled API route
  resolve language and match the request to a Site
  check access and whether a safe full-page cache entry can answer
  load active Sections for the Site
    read the configured Boxes for each Section
      create the namespaced Box with its parent objects
      Box calls a Model when it needs database content
      Renderer processes a .tpl file or a .md content source
  combine section output in the site layout
  return the HTTP response and optionally store a safe public page copy
```

The exact route and cache gates depend on application settings. The framework handles matching, access and rendering; application classes define what each box does.

## What lives in the database and in PHP

`cms_sites` describes URLs and page metadata. `cms_sections` defines layout regions. `cms_boxes` attaches a module and method to a section, controls order and can mark a box as shared. Article, menu and translation tables hold editable content. PHP classes provide behavior, models query data, and templates present it. An existing box can often be attached to a new site through data alone; new behavior requires an application box class.

## How to extend a site

For a content-only page, use an existing article or registered box and configure its site, section and box rows. For new behavior, add a class beneath `App\\Box\\<Section>`, extend `Wbengine\\Box\\WbengineBoxAbstract`, and use its parent accessors. Put reusable queries in a model and render a `.tpl` or `.md` source. The [Boxes](/docs/boxes/) guide walks through the code and database mapping.

Markdown, templates, locales, caching, the legacy CMS API and the separate server-to-server API v2 are described in their own guides. The optional [central administration](/docs/administration/) is a separate application connected through API v2; it is not part of the PHP request tree or Composer package.','markdown',1761000000,NULL,NULL),
(4,12,0,0,0,0,'Boxes','A box is a method in the application tree that returns rendered output. Database rows attach it to a site and section.','## Static and data-backed boxes

A static box renders a view. A data-backed box reads through a model and passes data to that view. Both extend `Wbengine\\Box\\WbengineBoxAbstract` and belong under `App\\Box\\<Section>`.

```php
<?php
namespace App\\Box\\Central;

use Wbengine\\Box\\WbengineBoxAbstract;

class Welcome extends WbengineBoxAbstract
{
    public function Welcome(): string
    {
        return $this->getRenderer()->render(
            $this->getBoxTemplatePath(),
            [''name'' => ''World'']
        );
    }
}
```

Create `src/View/Central/Welcome.tpl` and bind module `welcome`, method `welcome` to a section and site in `cms_boxes`. Pass SQL values as bound parameters. Keep database access in a model when the box needs reusable query logic.','markdown',1761000000,NULL,NULL),
(5,13,0,0,0,0,'Templates and Markdown','WBengine uses its own compiled template engine. Markdown can be a template source file or the explicit format of an article stored in the database.','## Native templates

The native engine compiles `.tpl` files to PHP and can use OPcache. `{$value}` is HTML-escaped by default; `|raw` is for HTML that the application has deliberately rendered or trusted.

```tpl
<h1>{$title}</h1>
{$bodyHtml|raw}
{include ''Shared/footer.tpl''}
```

## Markdown files

A `.md` file can be rendered directly by the native renderer or included in an HTML template:

```tpl
{include ''Central/notice.md''}
```

Markdown is parsed as content. PHP tags, template variables, and template directives inside it are not executed. The built-in parser escapes raw HTML and restricts link protocols.

From a box, use the shared service when you already have a Markdown string:

```php
$html = $this->getSite()->getParent()->getMarkdown()->render($source);
```

## Markdown in article rows

Set `content_format` to `markdown` in `cms_articles` or `cms_article_translations`. Existing rows remain `legacy_html` after migration. Do not mark old HTML as Markdown without converting and reviewing its content.','markdown',1761000000,NULL,NULL),
(6,14,0,0,0,0,'Languages','The application has English and Czech interface catalogs and translates site metadata, menu entries, and articles independently.','## Interface text

Catalogs live in `src/Locale/en.php` and `src/Locale/cs.php`. Templates use `{t ''key''}`. The URL prefix selects Czech at `/cs/`; the default English URL has no prefix. Add a locale in the application settings and provide its catalog before linking to it.

## Database content

Default-language fields remain in `cms_sites`, `cms_menu`, and `cms_articles`. Translation tables contain the other locale. Missing translated values fall back to the default field. Article translations also carry their own `content_format`, so English Markdown can coexist with Czech legacy HTML during a gradual migration.

After content changes, use the application''s normal cache invalidation path. For public production URLs, set `i18n.baseUrl` to a trusted HTTPS origin so alternate-language links do not depend on an untrusted Host header.','markdown',1761000000,NULL,NULL),
(7,15,0,0,0,0,'Caching','WBengine provides data caching and a page cache for eligible public requests. Measure the real deployment before changing cache drivers or lifetimes.','## Data and page caches

The data cache avoids repeating selected reads. The page cache stores eligible visitor-independent responses, separated by locale. Authenticated or request-specific output must not enter a shared public cache. Cache eligibility and invalidation are enforced by the framework.

For the demo, page caching is configured in `src/Config/settings.json.default`. Set a short TTL while editing. Clear cache after content or configuration changes; the API cache-flush endpoint requires an administrator token.

## Read-only diagnostics

The CLI can inspect configuration, deployment readiness, and migration state without running database DDL:

```bash
vendor/bin/wbengine.php config:check --config=src/Config/Settings.json --root=src
vendor/bin/wbengine.php doctor --config=src/Config/Settings.json --root=src
vendor/bin/wbengine.php migration:status --config=src/Config/Settings.json --root=src
```

CLI and web workers can use different PHP settings and filesystem permissions. Compare their OPcache and writable-directory configuration when results differ.','markdown',1761000000,NULL,NULL),
(8,16,0,0,0,0,'Security','Secure defaults depend on keeping trusted data boundaries explicit: parameterized SQL, escaped template output, protected secrets, and role checks.','## Data and output

- Use prepared statements for database values. Do not pre-escape request input with `addslashes()`.
- Native template values are escaped by default. Use raw HTML output only for trusted or safely rendered HTML.
- The Markdown renderer escapes raw HTML and allows only safe URL schemes. It does not execute PHP or template syntax.
- Keep `Settings.json`, JWT keys, passwords, and private keys out of version control.

## Deployment

Use HTTPS, keep debug output disabled, change the demo password, and restrict API routes by role. Configure trusted proxies explicitly before using forwarded IP headers for rate limits. Back up the database before applying schema migrations; the Markdown migration preserves existing article bytes as `legacy_html`.

The CLI `doctor` command reports deployment checks. It is read-only and does not apply migrations.','markdown',1761000000,NULL,NULL),
(9,17,0,0,0,0,'REST API','WBengine has two API layers: the application CMS API under `/api/` and an optional, separately enabled server-to-server content API under `/api/v2`. They have different clients, authentication and purposes.','## Choose the API for the job

- The **CMS API** under `/api/` exposes the routes registered by an application. The skeleton demonstrates user login, sections, translations and cache operations. Its bearer JWT represents an application user; each route checks the required role.
- The **API v2** under `/api/v2` is an optional integration interface for trusted servers such as the separate central administration. It uses a provisioned integration key and scopes, HTTPS, finite resource and field allowlists, strong ETags for edits and audit records. It does not expose its key to browser JavaScript and does not enable browser CORS.

Do not send an API v2 integration key from a user browser. The browser should call its own application server, which then contacts each WBengine site over verified HTTPS.

## CMS API example

```bash
curl -X POST -H ''Content-Type: application/json'' \\
  -d ''{"username":"admin@example.com","password":"changeme"}'' \\
  http://localhost:8080/api/auth/login

curl -H ''Authorization: Bearer <token>'' \\
  http://localhost:8080/api/sections
```

The demo credentials are for local use only. Replace them before exposing the app.

## Routes and roles

Login is public. User and section administration and cache flushing require an administrator. Translation reads and writes require the editor role or higher. A missing or invalid token returns `401`; an authenticated user without the required role receives `403`. Write routes validate allowed fields.

For deployment diagnostics use `vendor/bin/wbengine.php doctor`; it does not change the schema. The endpoint list and request console below this article show the CMS routes enabled by this skeleton. API v2 is enabled separately in application configuration and needs its database tables for protected content operations (see the Deployment page). Its discovery, capabilities, resources, scopes and concurrency rules are described in the [WBengine API v2 reference](https://github.com/rrsoftcz/wbengine/blob/main/ref-api-v2.md). See also the [central administration guide](/docs/administration/).','markdown',1761000000,NULL,NULL);

INSERT INTO `cms_articles` (`id`,`site_id`,`grouped`,`futured`,`c_enabled`,`views`,`title`,`introtext`,`bodytext`,`content_format`,`published`,`author`,`source`) VALUES
(10,18,0,0,0,0,'Central administration','The central administration is a separate SvelteKit application for managing content on multiple WBengine websites. It connects to each site through the optional API v2; it is not installed as a PHP or Composer dependency.','## Separate application, connected sites

Each WBengine website keeps its own PHP application, MySQL database, files and public pages. The central administration runs separately with its own Node.js service and database. It stores its administrator accounts, site registry and encrypted integration credentials. It does not connect directly to a remote website database and it does not copy the site code into the central service.

The connection is server to server over HTTPS. A site operator enables API v2, provisions an integration key with only the required scopes and securely provides it to the central service. The central service validates the destination and TLS certificate, keeps the key on the server, and calls only supported API operations. Browser pages never receive the remote key. A site can revoke its key, and a failure or shutdown of the central service does not take the public website offline.

## What an editor can manage

Depending on the site API capabilities and the central account role, an editor can work with articles, pages, menu entries, sections, registered boxes, translations and supported images across multiple sites. Article edits are saved as drafts. An editor can preview a private draft and publish it explicitly when ready. Existing revisions can be restored as a new draft.

The editor handles simultaneous changes safely. Every write includes the version it was based on. If another editor or local process changed the same content, the API reports a conflict instead of silently overwriting it. The editor preserves the typed text and lets the user review the current remote version before making a new explicit save.

Supported images are public raster media, not private draft attachments. Box choices come from a site-side allowlist. The central client cannot choose arbitrary PHP classes, methods, SQL statements, templates or filesystem paths.

## Site users and settings

For a site administrator, the central administration also covers the accounts that sign in on the site itself and two server-side actions, when the site allows it.

- **Site users:** list and search the accounts, create an account, change its role (user, editor or administrator), disable and enable it. A new account has no password: the administration shows a one-time link once, and the owner opens it on the login page of the site to choose a password. Passwords are never set, read or stored by the central administration, and the last active administrator of a site cannot be demoted or disabled.
- **Site settings:** the effective settings of the site, read only, with secret values shown only as set, and a button that flushes the site cache. The settings themselves are changed on the server.

Both pages need an integration key issued with the matching permissions; a key without them asks to be replaced.

## What it does not replace

The central service is an optional content client. It does not replace WBengine, the site database, source control, deployment pipeline or server administration. Developers still change PHP classes and templates in the site project and deploy them through the normal deployment workflow for that project. Sites continue serving pages independently if the central administration is unavailable.

The administration is distributed separately from the PHP framework. Its source is private and it is not a public Composer package or public container image. The public documentation describes its architecture and supported workflow; access to the tool is managed separately.','markdown',1761000000,NULL,'https://www.wbengine.org/');

INSERT INTO `cms_boxes` (`id`,`name`,`module`,`method`,`section_id`,`static`,`shared`,`device_min`,`device_strict`,`acl`,`order`,`sites`) VALUES
(7,'Features','staticBoxes','features',1,1,0,1,0,0,0,'["1"]'),
(8,'Docs: Getting started','docs','page',1,1,0,1,0,0,0,'["10"]'),
(9,'Docs: Architecture','docs','page',1,1,0,1,0,0,0,'["11"]'),
(10,'Docs: Boxes','docs','page',1,1,0,1,0,0,0,'["12"]'),
(11,'Docs: Templates','docs','page',1,1,0,1,0,0,0,'["13"]'),
(12,'Docs: Languages','docs','page',1,1,0,1,0,0,0,'["14"]'),
(13,'Docs: Caching','docs','page',1,1,0,1,0,0,0,'["15"]'),
(14,'Docs: Security','docs','page',1,1,0,1,0,0,0,'["16"]'),
(15,'Docs: REST API','docs','page',1,1,0,1,0,0,0,'["17"]'),
(21,'Docs: Central administration','docs','page',1,1,0,1,0,0,0,'["18"]'),
(16,'Demo: structure','demo','structure',1,1,0,1,0,0,1,'["11"]'),
(17,'Demo: templates','demo','templates',1,1,0,1,0,0,1,'["13"]'),
(18,'Demo: languages','demo','languages',1,1,0,1,0,0,1,'["14"]'),
(19,'Demo: caching','demo','caching',1,1,0,1,0,0,1,'["15"]'),
(20,'Demo: api','demo','api',1,1,0,1,0,0,1,'["17"]');

REPLACE INTO `cms_site_translations` (`site_id`,`locale`,`title`,`html_title`,`html_description`,`html_keywords`) VALUES
(1,'cs','Domů','WBengine','Rychlý PHP framework řízený databází: weby, sekce a boxy, nativní šablony, Markdown, cache a REST API.','wbengine,php,framework,cms'),
(2,'cs','Blog','Blog','Článek zobrazený dodávaným boxem Article, s překlady a počítadlem zobrazení.','blog,článek,box'),
(3,'cs','O nás','O nás','O WBengine a příklad statického boxu.','o nás,statický box'),
(10,'cs','Začínáme','Začínáme','Nainstalujte kostru WBengine, přihlaste se a za dvě minuty přidejte první stránku.','začínáme,instalace,docker'),
(11,'cs','Architektura','Architektura','Jak WBengine mění požadavek ve stránku pomocí aplikačního stromu, databáze, boxů, modelů, rendereru a cache.','architektura,web,sekce,box'),
(12,'cs','Boxy','Boxy','Statické a dynamické boxy, modely a tabulka cms_boxes.','boxy,model,cms_boxes'),
(13,'cs','Šablony','Šablony','Nativní šablony, automatické escapování a Markdown v souborech i databázi.','šablony,escapování,markdown'),
(14,'cs','Jazyky','Jazyky','Jazyky ve WBengine: detekce z URL, cookie a hlavičky, katalogy, množná čísla a překládaný obsah databáze.','i18n,jazyky,překlady'),
(15,'cs','Cache','Cache','Datová cache a cache stránek: co se ukládá, kdy a jak ji zneplatnit.','cache,výkon,apcu'),
(16,'cs','Zabezpečení','Zabezpečení','Vázané parametry, escapování, hashování hesel, session, tokeny, role a omezení pokusů.','zabezpečení,jwt,role'),
(17,'cs','REST API','REST API','CMS API a oddělené serverové integrační API v2, ověřování, scopes a role.','rest,api,jwt'),
(18,'cs','Centrální administrace','Centrální administrace','Samostatný nástroj pro správu obsahu více webů WBengine přes API v2.','administrace,api,více webů');

REPLACE INTO `cms_menu_translations` (`menu_id`,`locale`,`name`,`description`) VALUES
(1,'cs','Domů','Úvodní stránka'),
(2,'cs','Blog','Články s dodávaným boxem'),
(3,'cs','O nás','O WBengine'),
(4,'cs','Dokumentace','Průvodce a živé ukázky');

REPLACE INTO `cms_article_translations` (`article_id`,`locale`,`title`,`introtext`,`bodytext`,`content_format`) VALUES
(1,'cs','Články s dodávaným boxem','Články vykresluje box Article dodávaný s WBengine. Nový obsah může používat bezpečný Markdown, zatímco původní HTML zůstává označené jako legacy HTML.','## Co dělá box Article

Frameworkový box načte článek přiřazený k webu, zpracuje jeho výslovně zvolený formát a vykreslí výsledek vlastní šablonou. Přeložená pole jsou v `cms_article_translations`; každý překlad má vlastní `content_format`.

Nový text ukládejte v Markdownu. WBengine ho parsuje bez dalšího balíčku, escapuje syrové HTML a povoluje jen bezpečná schémata odkazů. Stávající záznamy zůstávají ve formátu `legacy_html`, bez automatického převodu.

## Přidání článku

Uložte zdrojový Markdown a formát označte výslovně:

```sql
INSERT INTO cms_articles (site_id, title, introtext, bodytext, content_format, published, author)
VALUES (18, ''Nová stránka'', ''Krátký úvod.'', ''## Podrobnosti\\n\\nText napište v Markdownu.'', ''markdown'', UNIX_TIMESTAMP(), ''Editor'');
```

V aplikačních dotazech používejte vázané parametry. Přidejte odpovídající řádek `cms_boxes` pro box `blog` a po publikaci zneplatněte cache stránky. Další informace jsou v části [Boxy](/cs/docs/boxes/).','markdown'),
(2,'cs','Začínáme','Nainstalujte skeleton WBengine, ověřte jeho Composer požadavky a spusťte web lokálně, než začnete měnit jeho obsah.','## Požadavky

- PHP 8.3 nebo novější s rozšířením `mysqli` a rozšířeními vyžadovanými Composer balíčky.
- MySQL 8 nebo MariaDB 10.6 a novější.
- Apache s `mod_rewrite` nebo Nginx s PHP-FPM.
- Composer 2. Docker je volitelný.

Aplikace vyžaduje balíček Composeru `wbengine/wbengine`. Framework přináší `firebase/php-jwt`; template engine i parser Markdownu jsou jeho součástí. Přesné požadavky na PHP ověřte v metadatech balíčku.

## Rychlé spuštění v Dockeru

```bash
git clone https://github.com/rrsoftcz/wbengine-skeleton-app
cd wbengine-skeleton-app
docker compose up --build
```

Otevřete `http://localhost:8080`. Při startu webový kontejner spustí `bin/wbe install`: vytvoří a ověří `Settings.json`, připraví složku kompilovaných šablon a nainstaluje uzamčené závislosti. Demo účet je `admin@example.com`, heslo `changeme`. Před zpřístupněním webu heslo změňte.

## Ruční instalace

Příkaz `php bin/wbe install` vytvoří a ověří nastavení, připraví `src/View/Compiled` a nainstaluje závislosti podle `composer.lock`. Oznámí chybný JSON, nečitelná nastavení, nezapisovatelnou cache šablon i chyby Composeru. Nepoužívejte `chmod 777`; právo zápisu přidělte uživateli PHP webserveru. Pro lokální diagnostiku nastavte `debug` na `true` nebo `WBENGINE_DEBUG=1`. Před nasazením debug vypněte.

```bash
php bin/wbe install
```

Vytvořte databázi, importujte `schemas/wbengine_skeletone_app_mysql_template.sql` a potom `schemas/wbengine_skeletone_app_mysql_template_content.sql`. Nastavte `src/Config/Settings.json` a jako kořen webu použijte `public/`.

## Řešení chyb instalace a výjimek

Při vývoji nastavte v `Settings.json` `debug` na `true`. Šablona WBengine zobrazí typ výjimky, zprávu, soubor, řádek a trasu volání. Pokud nastavení chybí nebo obsahuje neplatný JSON, použijte `WBENGINE_DEBUG=1` pouze v soukromém vývojovém prostředí. Ladicí výstup nikdy nezpřístupňujte veřejně. Produkční stránka zobrazí bezpečné vysvětlení a referenční kód; úplnou výjimku najdete v PHP nebo kontejnerovém error logu pod stejným kódem.

Před upgradem databázi zálohujte a dosud nepoužité skripty v `schemas/migrations/` aplikujte v pořadí. Docker importuje schéma a seed pouze při vytvoření nového databázového volume. Rebuild webového image existující databázi nezmění.','markdown'),
(3,'cs','Architektura','WBengine drží průchod požadavku malý a přehledný. Objekty Application, Site, Section a Box tvoří stejný strom jako aplikační kód.','## Strom objektů

- **Application** je kořen požadavku a vlastní sdílené služby.
- **Site** představuje nalezenou stránku, její metadata, přístupová pravidla a menu.
- **Section** je pojmenovaná oblast layoutu, například `header`, `central` nebo `api`.
- **Box** je PHP třída a metoda určená řádkem v `cms_boxes`.

Layout vykreslí výstup sekcí. Box může vykreslit šablonu přímo nebo nejdřív načíst model. Nové funkce zařazujte do tohoto stromu a používejte existující jmenné prostory `App\\Box\\<Section>`.

## Průběh požadavku

```text
public/index.php
  Application::run()
    nalezení Site podle URL
    kontrola přístupu a vhodnosti pro page cache
    sestavení aktivních Section
      nalezení nakonfigurovaných Box
        volání metody Box a vykreslení šablony
    vykreslení layoutu webu
```

Weby, sekce a boxy jsou konfigurační data. PHP třídy definují opakovaně použitelné chování. Jednoduché změny stránek tak nevyžadují úpravu routeru.','markdown'),
(4,'cs','Boxy','Box je metoda v aplikačním stromu, která vrací vykreslený výstup. Databázové řádky ji přiřazují webu a sekci.','## Statické a datové boxy

Statický box vykreslí pohled. Datový box nejprve načte data modelem a předá je pohledu. Oba rozšiřují `Wbengine\\Box\\WbengineBoxAbstract` a patří do `App\\Box\\<Section>`.

```php
<?php
namespace App\\Box\\Central;

use Wbengine\\Box\\WbengineBoxAbstract;

class Welcome extends WbengineBoxAbstract
{
    public function Welcome(): string
    {
        return $this->getRenderer()->render(
            $this->getBoxTemplatePath(),
            [''name'' => ''Svět'']
        );
    }
}
```

Vytvořte `src/View/Central/Welcome.tpl` a v `cms_boxes` spojte modul `welcome` a metodu `welcome` se sekcí a webem. Hodnoty SQL předávejte jako vázané parametry. Opakovaně použitelnou databázovou logiku umístěte do modelu.','markdown'),
(5,'cs','Šablony a Markdown','WBengine používá vlastní kompilovaný template engine. Markdown lze použít jako samostatný zdrojový soubor šablony i jako výslovný formát článku v databázi.','## Nativní šablony

Nativní engine kompiluje `.tpl` do PHP a může využívat OPcache. `{$value}` se standardně escapuje pro HTML; `|raw` používejte pouze pro HTML, které aplikace záměrně vykreslila nebo kterému důvěřuje.

```tpl
<h1>{$title}</h1>
{$bodyHtml|raw}
{include ''Shared/footer.tpl''}
```

## Markdown soubory

Soubor `.md` lze vykreslit nativním rendererem přímo nebo jej vložit do HTML šablony:

```tpl
{include ''Central/notice.md''}
```

Markdown se zpracuje jako obsah. PHP tagy, proměnné a direktivy šablony uvnitř se nevykonávají. Vestavěný parser escapuje syrové HTML a omezuje protokoly odkazů.

Když už máte řetězec Markdownu, použijte sdílenou službu:

```php
$html = $this->getSite()->getParent()->getMarkdown()->render($source);
```

## Markdown v článcích databáze

V `cms_articles` nebo `cms_article_translations` nastavte `content_format` na `markdown`. Existující řádky po migraci zůstávají `legacy_html`. Staré HTML neoznačujte jako Markdown bez převodu a kontroly.','markdown'),
(6,'cs','Jazyky','Aplikace má anglické a české katalogy rozhraní a nezávisle překládá metadata webu, položky menu i články.','## Texty rozhraní

Katalogy jsou v `src/Locale/en.php` a `src/Locale/cs.php`. Šablony používají `{t ''key''}`. Českou verzi vybere prefix `/cs/`; výchozí anglická adresa prefix nemá. Další jazyk přidejte do nastavení a vytvořte jeho katalog předtím, než na něj přidáte odkazy.

## Obsah databáze

Výchozí jazyk zůstává v `cms_sites`, `cms_menu` a `cms_articles`. Překladové tabulky obsahují další jazyk. Chybějící přeložené hodnoty se doplní z výchozího pole. Překlad článku má také vlastní `content_format`, takže anglický Markdown může během postupné migrace koexistovat s českým HTML.

Po změně obsahu použijte běžný mechanismus zneplatnění cache. Pro produkční web nastavte důvěryhodnou HTTPS adresu v `i18n.baseUrl`, aby alternativní jazykové odkazy nezávisely na nedůvěryhodné hlavičce Host.','markdown'),
(7,'cs','Cache','WBengine poskytuje datovou cache a cache stránek pro vhodné veřejné požadavky. Před změnou ovladače nebo platnosti měřte skutečné nasazení.','## Datová cache a cache stránek

Datová cache omezuje opakované čtení vybraných údajů. Cache stránek ukládá odpovědi, které jsou stejné pro všechny návštěvníky, a odděluje je podle jazyka. Přihlášený nebo na požadavku závislý obsah nesmí být uložen jako společná veřejná odpověď. Vhodnost a zneplatnění hlídá framework.

Vzorový web nastavuje page cache v `src/Config/settings.json.default`. Při úpravách použijte krátkou platnost. Po změně obsahu nebo nastavení cache vyčistěte; API endpoint pro vyprázdnění vyžaduje administrátorský token.

## Diagnostika bez zápisu

CLI může zkontrolovat nastavení, stav nasazení a migrace bez databázového DDL:

```bash
vendor/bin/wbengine.php config:check --config=src/Config/Settings.json --root=src
vendor/bin/wbengine.php doctor --config=src/Config/Settings.json --root=src
vendor/bin/wbengine.php migration:status --config=src/Config/Settings.json --root=src
```

CLI a webový worker mohou mít odlišná PHP nastavení a oprávnění. Pokud se výsledky liší, porovnejte konfiguraci OPcache a práva k zapisovatelným adresářům.','markdown'),
(8,'cs','Zabezpečení','Bezpečnost závisí na jasných hranicích důvěry: parametrizovaných SQL dotazech, escapovaném výstupu šablon, chráněných tajemstvích a kontrole rolí.','## Vstup a výstup

- Pro hodnoty v databázových dotazech používejte prepared statements. Vstup předem neošetřujte přes `addslashes()`.
- Nativní šablony hodnoty automaticky escapují. Raw HTML vypisujte jen tehdy, když je důvěryhodné nebo bezpečně vykreslené.
- Markdown parser escapuje syrové HTML a povoluje bezpečná schémata URL. PHP ani syntaxi šablon nevykonává.
- `Settings.json`, JWT klíče, hesla ani privátní klíče neukládejte do Gitu.

## Nasazení

Používejte HTTPS, vypněte debug výstup, změňte demo heslo a API chráníte podle rolí. Než začnete pro limity požadavků používat hlavičky s IP adresou, nastavte důvěryhodné proxy. Před migrací schématu databázi zálohujte; migrace Markdownu zachová původní bajty článků jako `legacy_html`.

Příkaz CLI `doctor` vypíše kontroly nasazení. Je pouze pro čtení a migrace nespouští.','markdown'),
(9,'cs','REST API','WBengine má dvě vrstvy API: aplikační CMS API pod `/api/` a volitelné serverové obsahové API v2 pod `/api/v2`. Mají odlišné klienty, autentizaci i účel.','## Vyberte správné API

- **CMS API** pod `/api/` vystavuje trasy zaregistrované aplikací. Skeleton ukazuje přihlášení uživatele, sekce, překlady a operace s cache. Bearer JWT zastupuje uživatele aplikace a každá trasa kontroluje jeho roli.
- **API v2** pod `/api/v2` je volitelné integrační rozhraní pro důvěryhodné servery, například samostatnou centrální administraci. Používá vydaný integrační klíč a scopes, HTTPS, konečný seznam zdrojů a polí, silné ETagy pro zápis a audit. Klíč se neposílá do JavaScriptu prohlížeče a API nezapíná CORS.

Integrační klíč API v2 neposílejte z prohlížeče. Prohlížeč má volat vlastní aplikační server, který se potom přes ověřené HTTPS připojí ke každému webu WBengine.

## Příklad CMS API

```bash
curl -X POST -H ''Content-Type: application/json'' \\
  -d ''{"username":"admin@example.com","password":"changeme"}'' \\
  http://localhost:8080/api/auth/login

curl -H ''Authorization: Bearer <token>'' \\
  http://localhost:8080/api/sections
```

Demo údaje používejte pouze lokálně. Před zveřejněním aplikace heslo změňte.

## Cesty a role

Přihlášení je veřejné. Správa uživatelů a sekcí i vyprázdnění cache vyžadují administrátora. Čtení a změna překladů vyžadují roli editor nebo vyšší. Chybějící či neplatný token vrací `401`; přihlášený uživatel bez potřebné role dostane `403`. Zapisovací cesty kontrolují povolená pole.

Pro diagnostiku nasazení použijte `vendor/bin/wbengine.php doctor`; příkaz schéma nemění. Seznam endpointů a konzole pod tímto článkem ukazují CMS trasy zapnuté v této aplikaci. API v2 se zapíná samostatně v konfiguraci a pro chráněné obsahové operace vyžaduje své databázové tabulky (viz stránka Nasazení). Discovery, capabilities, zdroje, scopes a pravidla souběžných změn popisuje [referenční dokumentace WBengine API v2](https://github.com/rrsoftcz/wbengine/blob/main/ref-api-v2.md). Viz také [centrální administrace](/cs/docs/administration/).','markdown');

REPLACE INTO `cms_article_translations` (`article_id`,`locale`,`title`,`introtext`,`bodytext`,`content_format`) VALUES
(10,'cs','Centrální administrace','Centrální administrace je samostatná aplikace SvelteKit pro správu obsahu na více webech WBengine. Ke každému webu se připojuje přes volitelné API v2; není součástí PHP ani Composer balíčku.','## Samostatná aplikace, připojené weby

Každý web WBengine si ponechává vlastní PHP aplikaci, databázi MySQL, soubory a veřejné stránky. Centrální administrace běží odděleně jako služba Node.js s vlastní databází. Ukládá účty správců, seznam připojených webů a zašifrované integrační údaje. Nepřipojuje se přímo do vzdálené databáze webu a nekopíruje jeho zdrojový kód.

Spojení probíhá mezi servery přes HTTPS. Provozovatel webu zapne API v2, vydá integrační klíč jen s potřebnými scopes a bezpečně jej předá centrální službě. Ta ověří cílovou adresu i TLS certifikát, ponechá klíč na serveru a volá pouze podporované operace API. Klíč se nikdy nedostane do prohlížeče. Web může klíč odvolat a výpadek centrální služby neodstaví veřejný web.

## Co může redaktor spravovat

Podle možností API daného webu a role centrálního účtu může redaktor spravovat články, stránky, položky menu, sekce, registrované boxy, překlady a podporované obrázky na více webech. Úpravy článků se ukládají jako koncepty. Redaktor si může zobrazit soukromý náhled a potom koncept výslovně publikovat. Starší revize lze obnovit jako nový koncept.

Každý zápis uvádí verzi, ze které vychází. Pokud stejný obsah změnil další redaktor nebo místní proces, API nahlásí konflikt místo tichého přepsání. Administrace zachová rozepsaný text a umožní porovnat aktuální vzdálenou verzi před novým výslovným uložením.

Podporované obrázky jsou veřejná rastrová média, nikoli soukromé přílohy konceptu. Nabídka boxů pochází z allowlistu na webu. Centrální klient nemůže vybírat libovolné PHP třídy, metody, SQL, šablony ani cesty k souborům.

## Uživatelé a nastavení webu

Pro správce webu centrální administrace pokrývá také účty, které se přihlašují přímo na webu, a dvě akce na straně serveru, pokud je web povolí.

- **Uživatelé webu:** seznam a hledání účtů, založení účtu, změna role (uživatel, editor nebo administrátor), zakázání a povolení. Nový účet nemá heslo: administrace jednou zobrazí jednorázový odkaz a majitel ho otevře na přihlašovací stránce webu a zvolí si heslo. Hesla centrální administrace nikdy nenastavuje, nečte ani neukládá a posledního aktivního administrátora webu nelze degradovat ani zakázat.
- **Nastavení webu:** platné nastavení webu pouze ke čtení, s tajnými hodnotami zobrazenými jen jako nastavené, a tlačítko, které vyprázdní cache webu. Samotné nastavení se mění na serveru.

Obě stránky vyžadují integrační klíč vydaný s odpovídajícími oprávněními; klíč bez nich vyzve k výměně.

## Co administrace nenahrazuje

Centrální služba je volitelný obsahový klient. Nenahrazuje WBengine, databázi webu, správu zdrojového kódu, nasazovací postup ani správu serveru. Vývojář mění PHP třídy a šablony v projektu webu a nasazuje je jeho běžným postupem. Weby dál fungují, i když centrální administrace není dostupná.

Administrace se distribuuje odděleně od PHP frameworku. Její zdrojový kód je soukromý a nejde o veřejný Composer balíček ani veřejný kontejner. Veřejná dokumentace popisuje architekturu a podporovaný postup; přístup k nástroji se řeší samostatně.','markdown');

UPDATE `cms_articles`
SET `introtext`='Learn which Markdown syntax WBengine supports, how source becomes safe HTML, and how file and database content differ.',
    `bodytext`=CONCAT(`bodytext`, '\n\n## Supported Markdown syntax\n\nThe bundled parser supports CommonMark 0.31.2 and GitHub Flavored Markdown tables, strikethrough, and task lists. Common block forms include headings, paragraphs, thematic breaks, blockquotes, ordered and unordered lists, indented code, and fenced code blocks. Tables use the pipe and delimiter-row syntax.\n\nInline forms include emphasis, strong emphasis, inline code, links, images, escaped punctuation, automatic links and email addresses, and hard line breaks. GFM adds `~~strikethrough~~` and task list markers such as `- [x] done`. A language after a fenced code marker is retained as a `language-*` class.\n\n````markdown\n## Heading\n\nA paragraph with **strong**, *emphasis*, `code`, and [a link](https://example.com).\n\n- first item\n- second item\n\n| Name | Value |\n| --- | --- |\n| site | WBengine |\n\n- [x] reviewed\n\n```php\necho "Hello";\n```\n````\n\n## How rendering works\n\nThe parser turns source into a document tree. The HTML renderer then emits a limited set of elements and escapes text and attributes. Raw HTML in Markdown is displayed as text, and links are limited to safe URL schemes such as relative URLs, HTTP, HTTPS, and mailto. Markdown never executes PHP or template directives. The output of the built-in renderer is safe to print with `|raw`; do not use `|raw` for arbitrary input.\n\nFor a `.md` file, the native renderer selects Markdown by the file extension, whether the file is rendered directly or included from a `.tpl` file. For database articles, `content_format` is stored separately on each article and translation row. When it is `markdown`, the Article box parses the article text fields before the template prints the generated HTML. Rows marked `legacy_html` keep the existing HTML behavior. Review and convert legacy HTML before changing its format.')
WHERE `id`=5 AND `title`='Templates and Markdown';

UPDATE `cms_article_translations`
SET `introtext`='Zjistěte, jakou syntaxi Markdownu WBengine podporuje, jak se zdroj převádí na bezpečné HTML a v čem se liší soubory od obsahu v databázi.',
    `bodytext`=CONCAT(`bodytext`, '\n\n## Podporovaná syntaxe Markdownu\n\nVestavěný parser podporuje CommonMark 0.31.2 a z GitHub Flavored Markdown tabulky, přeškrtnutí a úkolové seznamy. Mezi blokové prvky patří nadpisy, odstavce, vodorovné oddělovače, citace, číslované i nečíslované seznamy, odsazené bloky kódu a bloky kódu ohraničené zpětnými apostrofy nebo vlnovkami. Tabulky používají svislé čáry a oddělovací řádek.\n\nV textu lze použít kurzívu, tučné písmo, řádkový kód, odkazy, obrázky, escapování interpunkce, automatické odkazy a e-mailové adresy i pevné zalomení řádku. Rozšíření GFM přidává `~~přeškrtnutí~~` a značky úkolů jako `- [x] hotovo`. Jazyk uvedený za úvodní značkou bloku kódu se zachová jako třída `language-*`.\n\n````markdown\n## Nadpis\n\nOdstavec s **tučným písmem**, *kurzívou*, `kódem` a [odkazem](https://example.com).\n\n- první položka\n- druhá položka\n\n| Název | Hodnota |\n| --- | --- |\n| web | WBengine |\n\n- [x] zkontrolováno\n\n```php\necho "Ahoj";\n```\n````\n\n## Jak probíhá vykreslení\n\nParser převede zdroj na strom dokumentu. HTML renderer z něj vytvoří omezenou sadu prvků a escapuje text i atributy. Syrové HTML v Markdownu se zobrazí jako text a odkazy povolují jen bezpečná schémata, například relativní adresy, HTTP, HTTPS a mailto. Markdown nespouští PHP ani direktivy šablon. Výstup vestavěného rendereru lze bezpečně vypsat pomocí `|raw`; tento filtr nepoužívejte pro libovolný vstup.\n\nU souboru `.md` nativní renderer zvolí Markdown podle přípony, ať se soubor vykreslí přímo, nebo vloží do `.tpl`. U databázových článků je `content_format` uložen samostatně u článku i jeho překladu. Pokud má hodnotu `markdown`, box Article nejprve zpracuje textová pole a šablona vypíše vytvořené HTML. Řádky označené `legacy_html` zachovávají dosavadní chování. Staré HTML nejprve zkontrolujte a převeďte, než jeho formát změníte.')
WHERE `article_id`=5 AND `locale`='cs';
-- Add the clean Ubuntu VPS deployment procedure to the bilingual Getting started page.
-- The checks make this content-only migration safe to rerun.
SET NAMES utf8mb4;

UPDATE cms_articles
SET introtext = 'Install and run the WBengine skeleton locally, or deploy a clean instance to an Ubuntu VPS with Docker and HTTPS.',
    bodytext = CONCAT(bodytext, '\n\n## Clean VPS deployment with Docker\n\nThis procedure is for a new, empty Ubuntu server. It creates a new database from the schema and content committed to this repository. It does not copy a database from a development or existing website. Do not run the clean-install script against an existing database. For an existing site, first back it up and follow the upgrade procedure instead.\n\nThe PHP application and MySQL run in Docker. Nginx and Certbot run on the Ubuntu host. The application port is bound to `127.0.0.1:8080`, and MySQL is not published on a host port. The optional WBengine Admin is a separate SvelteKit application and is not installed by this procedure; it can remain on a development computer and connect through a separately configured API v2 integration.\n\n### 1. Prepare DNS and firewall\n\nPoint `www.wbengine.org` to the VPS IPv4 address. Allow inbound SSH on port 22 and web traffic on ports 80 and 443 in the VPS firewall. The apex domain `wbengine.org` may continue to redirect to `www` from its current DNS host. The sample Nginx configuration serves `www.wbengine.org`.\n\n### 2. Install Docker\n\nInstall Docker Engine and the Docker Compose plugin using the [official Ubuntu instructions](https://docs.docker.com/engine/install/ubuntu/). The host does not need PHP or Composer. PHP, Composer and MySQL are provided by the application containers.\n\n### 3. Create the clean application and database\n\nInstall Git, OpenSSL, Nginx and Certbot, then clone the repository and run the production installer:\n\n```bash\napt-get update\napt-get install -y git openssl nginx certbot\ngit clone https://github.com/rrsoftcz/wbengine-skeleton-app.git /opt/wbengine-skeleton-app\ncd /opt/wbengine-skeleton-app\n./bin/setup-production.sh\n```\n\nThe installer generates private database and JWT secrets on the server, builds the production PHP image, initializes a new MySQL volume from the tracked schema and content seed, creates the API and analytics tables, and replaces the documented demo password with a random unusable password. Keep `.env` and `src/Config/Settings.json` private. The script leaves analytics collection disabled. It does not import data from another database.\n\n### 4. Configure HTTPS in Nginx\n\nCreate the ACME webroot and enable the temporary HTTP-only configuration so Let''s Encrypt can verify the hostname:\n\n```bash\ninstall -d -m 755 /var/www/letsencrypt\nln -sfn /opt/wbengine-skeleton-app/deploy/nginx/www.wbengine.org-http.conf /etc/nginx/sites-enabled/www.wbengine.org.conf\nrm -f /etc/nginx/sites-enabled/default\nnginx -t && systemctl reload nginx\ncertbot certonly --webroot -w /var/www/letsencrypt -d www.wbengine.org\n```\n\nAfter the certificate is issued, switch to the TLS reverse-proxy configuration and verify renewal:\n\n```bash\nln -sfn /opt/wbengine-skeleton-app/deploy/nginx/www.wbengine.org.conf /etc/nginx/sites-enabled/www.wbengine.org.conf\nnginx -t && systemctl reload nginx\ncertbot renew --dry-run --no-random-sleep-on-renew\n```\n\n### 5. Verify and update\n\nCheck the public site and both container health states:\n\n```bash\ncurl -I https://www.wbengine.org/\ndocker compose -f docker-compose.production.yml ps\ndocker compose -f docker-compose.production.yml logs --tail=100 web db\n```\n\nFor a later application update, fetch the reviewed commit and rebuild the web image:\n\n```bash\ngit pull --ff-only\ndocker compose -f docker-compose.production.yml up -d --build --wait\n```\n\nThe database volume persists across image rebuilds. Database updates of a newer version must be applied once, after a backup (see the Deployment page). Never expose MySQL port 3306 publicly. The complete procedure is also in [the repository deployment guide](https://github.com/rrsoftcz/wbengine-skeleton-app/blob/main/docs/deploy-vps-docker.md).')
WHERE id = 2
  AND site_id = 10
  AND title = 'Getting started'
  AND LOCATE('## Clean VPS deployment with Docker', bodytext) = 0;

UPDATE cms_article_translations
SET introtext = 'Nainstalujte WBengine skeleton lokálně nebo nasaďte čistou instalaci na Ubuntu VPS pomocí Dockeru a HTTPS.',
    bodytext = CONCAT(bodytext, '\n\n## Čisté nasazení na VPS pomocí Dockeru\n\nTento postup je určený pro nový, prázdný server s Ubuntu. Vytvoří novou databázi z aktuálního schématu a obsahu v tomto repozitáři. Nekopíruje databázi z vývojového ani již provozovaného webu. Instalační skript pro čistou instalaci nespouštějte nad existující databází. Při upgradu existujícího webu nejprve vytvořte zálohu a postupujte podle postupu pro upgrade.\n\nPHP aplikace a MySQL poběží v Dockeru. Nginx a Certbot poběží přímo na serveru Ubuntu. Aplikační port bude dostupný pouze přes `127.0.0.1:8080` a MySQL nebude publikováno na port serveru. Volitelná administrace WBengine Admin je samostatná aplikace SvelteKit a tento postup ji neinstaluje. Může zůstat na vývojovém počítači a připojit se přes samostatně nastavenou integraci API v2.\n\n### 1. Připravte DNS a firewall\n\nNasměrujte `www.wbengine.org` na IPv4 adresu VPS. Ve firewallu povolte příchozí SSH na portu 22 a webový provoz na portech 80 a 443. Doména `wbengine.org` může dál přesměrovávat na `www` ze svého současného DNS hostingu. Přiložená konfigurace Nginx obsluhuje `www.wbengine.org`.\n\n### 2. Nainstalujte Docker\n\nNainstalujte Docker Engine a plugin Docker Compose podle [oficiálního návodu pro Ubuntu](https://docs.docker.com/engine/install/ubuntu/). Na hostiteli není potřeba PHP ani Composer. PHP, Composer a MySQL poskytují aplikační kontejnery.\n\n### 3. Vytvořte čistou aplikaci a databázi\n\nNainstalujte Git, OpenSSL, Nginx a Certbot, potom naklonujte repozitář a spusťte produkční instalátor:\n\n```bash\napt-get update\napt-get install -y git openssl nginx certbot\ngit clone https://github.com/rrsoftcz/wbengine-skeleton-app.git /opt/wbengine-skeleton-app\ncd /opt/wbengine-skeleton-app\n./bin/setup-production.sh\n```\n\nInstalátor na serveru vytvoří soukromé databázové a JWT klíče, sestaví produkční PHP image, naplní nový svazek MySQL schématem a obsahem, vytvoří tabulky API a analytiky a nahradí veřejně známé demo heslo náhodným nepoužitelným heslem. Soubory `.env` a `src/Config/Settings.json` chraňte jako tajné. Sběr vlastní analytiky zůstane vypnutý. Skript nepřenáší data z jiné databáze.\n\n### 4. Nastavte HTTPS v Nginx\n\nVytvořte webroot ACME a zapněte dočasnou HTTP konfiguraci, aby Let''s Encrypt ověřil doménu:\n\n```bash\ninstall -d -m 755 /var/www/letsencrypt\nln -sfn /opt/wbengine-skeleton-app/deploy/nginx/www.wbengine.org-http.conf /etc/nginx/sites-enabled/www.wbengine.org.conf\nrm -f /etc/nginx/sites-enabled/default\nnginx -t && systemctl reload nginx\ncertbot certonly --webroot -w /var/www/letsencrypt -d www.wbengine.org\n```\n\nPo vydání certifikátu přepněte na TLS reverse proxy a ověřte obnovu:\n\n```bash\nln -sfn /opt/wbengine-skeleton-app/deploy/nginx/www.wbengine.org.conf /etc/nginx/sites-enabled/www.wbengine.org.conf\nnginx -t && systemctl reload nginx\ncertbot renew --dry-run --no-random-sleep-on-renew\n```\n\n### 5. Ověřte a aktualizujte web\n\nZkontrolujte veřejný web a stav obou kontejnerů:\n\n```bash\ncurl -I https://www.wbengine.org/\ndocker compose -f docker-compose.production.yml ps\ndocker compose -f docker-compose.production.yml logs --tail=100 web db\n```\n\nPři pozdější aktualizaci aplikace stáhněte schválený commit a znovu sestavte webový image:\n\n```bash\ngit pull --ff-only\ndocker compose -f docker-compose.production.yml up -d --build --wait\n```\n\nDatabázový svazek zůstává zachovaný při sestavení nového image. Databázové aktualizace nové verze použijte jednou po záloze (viz stránka Nasazení). Nikdy veřejně nevystavujte port MySQL 3306. Kompletní postup je také v [produkčním návodu repozitáře](https://github.com/rrsoftcz/wbengine-skeleton-app/blob/main/docs/deploy-vps-docker.md).')
WHERE article_id = 2
  AND locale = 'cs'
  AND LOCATE('## Čisté nasazení na VPS pomocí Dockeru', bodytext) = 0;

-- Integrations page (schemas/migrations/013-integrations-page.sql), ids assigned by the database.
INSERT INTO cms_sites (parent_id, left_id, right_id, strict, visible, link, title, html_title, html_description, html_keywords, acl)
SELECT 1, 1, 1, 1, 1, '/integrations/', 'Integrations', 'Integrations', 'Integration keys for the central WBengine Admin', 'integrations,api', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cms_sites WHERE link = '/integrations/');

INSERT INTO cms_boxes (name, module, method, section_id, static, shared, device_min, device_strict, acl, `order`, sites)
SELECT 'Integrations', 'integrations', 'integrations', 1, 1, 0, 1, 0, 1, 1, JSON_ARRAY(CAST(site_id AS CHAR))
FROM cms_sites
WHERE link = '/integrations/'
  AND NOT EXISTS (SELECT 1 FROM cms_boxes WHERE module = 'integrations' AND method = 'integrations');

-- Users and the first login, Connecting a site (schemas/migrations/014-users-and-site-connection-docs.sql).

UPDATE cms_articles
SET bodytext = CONCAT(bodytext, '\n\n## Users and the first login\n\nEvery WBengine site keeps its accounts in the `cms_users` table. A user has one of three roles: `user` (signs in and uses the profile), `editor` and `admin`. The role is read from the database on every privileged request, so changing or deleting an account takes effect immediately. There is no public registration: accounts are managed with the `bin/wbe` command line tool.\n\n### What a fresh install contains\n\n- **Local Docker (`docker compose up`)**: the seed contains the demo account `admin@example.com` with the published password `changeme`. Use it only on your own computer.\n- **Production (`bin/setup-production.sh`)**: the installer replaces the demo password with a random one that nobody knows. Nobody can sign in until you create an administrator.\n\n### Create the first administrator\n\nRun the command inside the web container (use `docker compose exec web ...` for the local stack, `docker compose -f docker-compose.production.yml exec web ...` in production, or plain `php bin/wbe ...` without Docker):\n\n```bash\ndocker compose -f docker-compose.production.yml exec web php bin/wbe user:create --email=you@your-domain.tld --role=admin\n```\n\nThe command asks for the password twice and does not show it. The password is never accepted as an argument or an environment variable, so it does not end up in the shell history or in the process list. For automation, send one line on standard input (without a terminal, so use `exec -T`):\n\n```bash\nprintf ''%s\\n'' "$PASSWORD" | docker compose -f docker-compose.production.yml exec -T web php bin/wbe user:create --email=you@your-domain.tld --role=admin\n```\n\nThen sign in at `/login/` with the e-mail address and the password you chose.\n\n### Remove the demo account\n\n```bash\nbin/wbe user:delete --example --dry-run\nbin/wbe user:delete --example\n```\n\nThe first command only lists the accounts. The second deletes every account whose e-mail address is in a reserved example domain (`example.com`, `example.org`, `example.net` and their subdomains, and the `.example`, `.test`, `.invalid` and `.localhost` top-level domains). It refuses to run when no other administrator would remain, so create your own administrator first.\n\n### List users, change a password, delete a user\n\n```bash\nbin/wbe user:list\nbin/wbe user:password --email=you@your-domain.tld\nbin/wbe user:delete --email=someone@your-domain.tld\n```\n\nA forgotten password is reset with `user:password`, which also invalidates the user''s refresh tokens. The last administrator cannot be deleted. None of these commands prints a password or a password hash.\n\n### Next step\n\nTo manage this site from the central WBengine Admin, see the page Central administration, section Connecting a site step by step. It needs an account with the role `admin`.')
WHERE id = 2
  AND site_id = 10
  AND title = 'Getting started'
  AND LOCATE('## Users and the first login', bodytext) = 0;

UPDATE cms_article_translations
SET bodytext = CONCAT(bodytext, '\n\n## Uživatelé a první přihlášení\n\nKaždý web na WBengine ukládá účty do tabulky `cms_users`. Uživatel má jednu ze tří rolí: `user` (přihlásí se a používá profil), `editor` a `admin`. Role se čte z databáze při každém oprávněném požadavku, takže změna nebo smazání účtu platí okamžitě. Veřejná registrace neexistuje: účty se spravují nástrojem příkazové řádky `bin/wbe`.\n\n### Co obsahuje čistá instalace\n\n- **Lokální Docker (`docker compose up`)**: seed obsahuje demo účet `admin@example.com` se zveřejněným heslem `changeme`. Používejte jej jen na vlastním počítači.\n- **Produkce (`bin/setup-production.sh`)**: instalátor nahradí demo heslo náhodným, které nikdo nezná. Dokud nevytvoříte správce, nemůže se nikdo přihlásit.\n\n### Vytvoření prvního správce\n\nPříkaz spusťte uvnitř webového kontejneru (u lokálního stacku `docker compose exec web ...`, v produkci `docker compose -f docker-compose.production.yml exec web ...`, bez Dockeru prostě `php bin/wbe ...`):\n\n```bash\ndocker compose -f docker-compose.production.yml exec web php bin/wbe user:create --email=vy@vase-domena.cz --role=admin\n```\n\nPříkaz se na heslo zeptá dvakrát a nezobrazuje je. Heslo se nikdy nepřijímá jako argument ani proměnná prostředí, takže se nedostane do historie shellu ani do seznamu procesů. Pro automatizaci pošlete jediný řádek na standardní vstup (bez terminálu, proto `exec -T`):\n\n```bash\nprintf ''%s\\n'' "$HESLO" | docker compose -f docker-compose.production.yml exec -T web php bin/wbe user:create --email=vy@vase-domena.cz --role=admin\n```\n\nPoté se přihlaste na `/login/` e-mailovou adresou a zvoleným heslem.\n\n### Odstranění demo účtu\n\n```bash\nbin/wbe user:delete --example --dry-run\nbin/wbe user:delete --example\n```\n\nPrvní příkaz jen vypíše účty. Druhý smaže každý účet, jehož e-mail patří do rezervované příkladové domény (`example.com`, `example.org`, `example.net` a jejich subdomény a domény nejvyšší úrovně `.example`, `.test`, `.invalid` a `.localhost`). Odmítne se provést, pokud by nezůstal žádný jiný správce, proto nejdřív vytvořte vlastního správce.\n\n### Výpis uživatelů, změna hesla, smazání uživatele\n\n```bash\nbin/wbe user:list\nbin/wbe user:password --email=vy@vase-domena.cz\nbin/wbe user:delete --email=nekdo@vase-domena.cz\n```\n\nZapomenuté heslo se obnoví příkazem `user:password`, který zároveň zneplatní refresh tokeny uživatele. Posledního správce nelze smazat. Žádný z příkazů nevypisuje heslo ani jeho hash.\n\n### Další krok\n\nPro správu tohoto webu z centrální administrace WBengine Admin viz stránka Centrální administrace, část Připojení webu krok za krokem. Vyžaduje účet s rolí `admin`.')
WHERE article_id = 2
  AND locale = 'cs'
  AND LOCATE('## Uživatelé a první přihlášení', bodytext) = 0;

UPDATE cms_articles
SET bodytext = CONCAT(bodytext, '\n\n## Connecting a site step by step\n\nThe central WBengine Admin is a separate application (for example at https://admin.example.org) that manages many sites through the API v2. A site is connected once; afterwards editors work in the central application.\n\nRequirements on the site: `apiV2.enabled` set to `true` in `Settings.json`, HTTPS, the framework database updates applied (`sh bin/update-database.sh`, check with `vendor/bin/wbengine.php migration:status`) and an account with the role `admin` (see Users and the first login on the Getting started page).\n\n1. On the site, sign in as administrator and open `/integrations/`. If something is missing, the page lists what to fix before it issues a key.\n2. Confirm your password, keep the suggested name and issue the key. The key, the site address and the suggested name are shown once. The site stores only a hash of the key, so a lost key cannot be shown again: issue a new one.\n3. In the central Admin, sign in with your password and the one-time code from your authenticator app. Every central account uses multi-factor authentication. The operator creates accounts with `npm run admin -- invite EMAIL global` on the Admin server, and the person activates the account at `/accept`.\n4. Open Sites, choose Add site and enter the name, the HTTPS address and the key. Before anything is saved, the Admin verifies the key against the site (`capabilities` and `identity`, all 17 scopes of the Site management profile). The key is then stored encrypted and is never sent to the browser again.\n5. The site appears in the list at once. To rotate a key, issue a new one on the site, paste it under Replace integration key in the Admin and only then revoke the old key on the site''s `/integrations/` page.\n\nTypical problems and their meaning:\n\n- *The key is not valid or was revoked*: issue a new key on the site.\n- *The key lacks permissions*: issue the key again with the full Site management profile.\n- *API v2 is not available*: enable `apiV2` and apply the framework database updates, then reload.\n- *Too many failed attempts*: the site limits failures per address, wait a few minutes.\n- *The site is already registered*: the address is unique in the central Admin.')
WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1)
  AND title = 'Central administration'
  AND LOCATE('## Connecting a site step by step', bodytext) = 0;

UPDATE cms_article_translations
SET bodytext = CONCAT(bodytext, '\n\n## Připojení webu krok za krokem\n\nCentrální WBengine Admin je samostatná aplikace (například na https://admin.example.org), která spravuje více webů přes API v2. Web se připojuje jednou, poté redaktoři pracují v centrální aplikaci.\n\nPožadavky na webu: v `Settings.json` nastavené `apiV2.enabled` na `true`, HTTPS, použité databázové aktualizace frameworku (`sh bin/update-database.sh`, ověřte příkazem `vendor/bin/wbengine.php migration:status`) a účet s rolí `admin` (viz Uživatelé a první přihlášení na stránce Začínáme).\n\n1. Na webu se přihlaste jako správce a otevřete `/integrations/`. Pokud něco chybí, stránka vypíše, co je třeba opravit, než klíč vydá.\n2. Potvrďte heslo, ponechte navržený název a vydejte klíč. Klíč, adresa webu a navržený název se zobrazí jen jednou. Web ukládá pouze hash klíče, takže ztracený klíč nelze znovu zobrazit: vydejte nový.\n3. V centrálním Adminu se přihlaste heslem a jednorázovým kódem z autentizační aplikace. Každý centrální účet používá vícefázové ověření. Účty zakládá provozovatel na serveru Adminu příkazem `npm run admin -- invite EMAIL global`, osoba účet aktivuje na `/accept`.\n4. Otevřete Weby, zvolte Přidat web a vyplňte název, HTTPS adresu a klíč. Před uložením Admin klíč ověří proti webu (`capabilities` a `identity`, všech 17 oprávnění profilu Správa webu). Klíč se poté uloží šifrovaně a do prohlížeče se už nikdy nevrací.\n5. Web se ihned objeví v seznamu. Klíč vyměníte tak, že na webu vydáte nový, vložíte jej v Adminu do části Vyměnit integrační klíč a teprve potom odvoláte starý klíč na stránce `/integrations/` webu.\n\nTypické potíže a jejich význam:\n\n- *Klíč není platný nebo byl odvolán*: vydejte na webu nový klíč.\n- *Klíč nemá všechna oprávnění*: vydejte klíč znovu s úplným profilem Správa webu.\n- *API v2 není dostupné*: zapněte `apiV2`, použijte databázové aktualizace frameworku a načtěte stránku znovu.\n- *Příliš mnoho neúspěšných pokusů*: web omezuje neúspěchy podle adresy, počkejte několik minut.\n- *Web už je zaregistrovaný*: adresa je v centrálním Adminu jednoznačná.')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) AND title = 'Central administration' ORDER BY id LIMIT 1) AS a)
  AND locale = 'cs'
  AND LOCATE('## Připojení webu krok za krokem', bodytext) = 0;

-- Repair of the integrations page visibility (schemas/migrations/015-integrations-page-visible.sql).
UPDATE cms_sites SET visible = 1 WHERE link = '/integrations/' AND visible = 0;

-- Installer site address and trusted proxy (schemas/migrations/016-installer-site-url-and-proxy-docs.sql).

UPDATE cms_articles
SET bodytext = REPLACE(bodytext, './bin/setup-production.sh\n```\n\nThe installer generates private database and JWT secrets on the server,', './bin/setup-production.sh https://www.your-domain.tld\n```\n\nThe installer takes the public HTTPS address of the site as its argument, trusts the Docker network gateway as the proxy that forwards the HTTPS headers from host Nginx, generates private database and JWT secrets on the server,')
WHERE id = 2
  AND site_id = 10
  AND LOCATE('takes the public HTTPS address of the site', bodytext) = 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, './bin/setup-production.sh\n```\n\nInstalátor na serveru vytvoří soukromé databázové a JWT klíče,', './bin/setup-production.sh https://www.vase-domena.cz\n```\n\nInstalátor přijme veřejnou HTTPS adresu webu jako argument, nastaví bránu Docker sítě jako důvěryhodnou proxy pro HTTPS hlavičky předávané z Nginx na hostiteli, na serveru vytvoří soukromé databázové a JWT klíče,')
WHERE article_id = 2
  AND locale = 'cs'
  AND LOCATE('přijme veřejnou HTTPS adresu webu', bodytext) = 0;

-- Languages and translations documentation (schemas/migrations/017-languages-and-translations-docs.sql).

UPDATE cms_articles
SET bodytext = CONCAT(bodytext, '\n\n## Languages and translations\n\nA WBengine site can serve its content in several languages. The languages are **site configuration, not content**: they are defined in the `i18n` section of `src/Config/Settings.json` and nowhere else (not in the database and not through the API). The central Admin only reads them.\n\n```json\n"i18n": {\n    "enabled": true,\n    "default": "en",\n    "locales": ["en", "cs"],\n    "detect": ["url"]\n}\n```\n\n- `default` is the language of the original content. Articles, pages and menu items are stored in this language in their normal tables.\n- `locales` lists every language the site serves, including the default one. Use short codes such as `en`, `cs` or `pt_BR`.\n- `detect` says how the language of a request is chosen: `url` (a prefix such as `/cs/blog/`), `cookie` (the last choice) and `header` (the browser language), in this order of preference.\n\n### How translations are stored\n\nA translation is **not a new article and not a new URL**. It is one more row for the same article, page or menu item, identified by the record ID and the language code (tables `cms_article_translations`, `cms_site_translations` and `cms_menu_translations`). A field that is empty in the translation falls back to the default language, so a half translated record is still complete.\n\nThe default language is served without a prefix (`/blog/`) and every other language with its code as a prefix (`/cs/blog/`). Both versions use the same page and the same article.\n\n### Add a language\n\n1. Add the code to `locales` in `Settings.json` and reload the application. The central Admin offers the new language after its next connection to the site.\n2. If the templates and buttons of the site use translated interface texts, add a language file to the `Locale` directory (see the `dir` option of `i18n`). Without it the interface texts stay in the default language.\n3. Translate the content in the central Admin.\n\n### Change the default language\n\nEdit `default` in `Settings.json`. Keep in mind that all existing content is stored in the old default language, so after the change the same texts would be treated as the new language. Translate or copy the content first, then change `default`.\n\n### Translate content in the central Admin\n\nOpen an article, a page or a menu item. The right column shows **Language versions**: every language of the site with the state **Original**, **Translation exists** or **Translation missing**. Use **Edit original** for the large form, or **Edit translation** and **Add translation** for the language you chose. A translation is saved to the same record. Translations of articles are saved to the draft first and go live together with the article when you publish it.\n')
WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) AND title = 'Central administration' ORDER BY id LIMIT 1) AS a)
  AND LOCATE('## Languages and translations', bodytext) = 0;

UPDATE cms_article_translations
SET bodytext = CONCAT(bodytext, '\n\n## Jazyky a překlady\n\nWeb na WBengine může obsah nabízet ve více jazycích. Jazyky jsou **konfigurace webu, ne obsah**: definují se v sekci `i18n` souboru `src/Config/Settings.json` a nikde jinde (ne v databázi ani přes API). Centrální Admin je pouze čte.\n\n```json\n"i18n": {\n    "enabled": true,\n    "default": "en",\n    "locales": ["en", "cs"],\n    "detect": ["url"]\n}\n```\n\n- `default` je jazyk původního obsahu. Články, stránky a položky menu jsou v tomto jazyce uložené v běžných tabulkách.\n- `locales` je seznam všech jazyků, které web nabízí, včetně výchozího. Používejte krátké kódy jako `en`, `cs` nebo `pt_BR`.\n- `detect` určuje, jak se jazyk požadavku vybírá: `url` (předpona například `/cs/blog/`), `cookie` (poslední volba) a `header` (jazyk prohlížeče), v tomto pořadí důležitosti.\n\n### Jak jsou překlady uložené\n\nPřeklad **není nový článek ani nová adresa**. Je to další řádek ke stejnému článku, stránce nebo položce menu, určený ID záznamu a kódem jazyka (tabulky `cms_article_translations`, `cms_site_translations` a `cms_menu_translations`). Pole, které je v překladu prázdné, se zobrazí ve výchozím jazyce, takže i částečně přeložený záznam je kompletní.\n\nVýchozí jazyk se obsluhuje bez předpony (`/blog/`) a každý další s kódem jazyka jako předponou (`/cs/blog/`). Obě verze používají stejnou stránku a stejný článek.\n\n### Přidání jazyka\n\n1. Doplňte kód do `locales` v `Settings.json` a aplikaci znovu načtěte. Centrální Admin nový jazyk nabídne po dalším připojení k webu.\n2. Pokud šablony a tlačítka webu používají přeložené texty rozhraní, přidejte jazykový soubor do adresáře `Locale` (viz volba `dir` v `i18n`). Bez něj zůstanou texty rozhraní ve výchozím jazyce.\n3. Obsah přeložte v centrálním Adminu.\n\n### Změna výchozího jazyka\n\nUpravte `default` v `Settings.json`. Pozor: veškerý stávající obsah je uložený ve starém výchozím jazyce, takže po změně by se stejné texty považovaly za nový jazyk. Nejprve obsah přeložte nebo zkopírujte a teprve pak změňte `default`.\n\n### Překlad obsahu v centrálním Adminu\n\nOtevřete článek, stránku nebo položku menu. V pravém sloupci jsou **Jazykové verze**: každý jazyk webu se stavem **Originál**, **Překlad existuje** nebo **Překlad zatím chybí**. Pro velký formulář použijte **Upravit originál**, pro vybraný jazyk **Upravit překlad** nebo **Přidat překlad**. Překlad se ukládá ke stejnému záznamu. Překlady článků se ukládají nejprve do konceptu a s článkem se zveřejní při jeho publikování.\n')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) AND title = 'Central administration' ORDER BY id LIMIT 1) AS a)
  AND locale = 'cs'
  AND LOCATE('## Jazyky a překlady', bodytext) = 0;

-- Language selection in the central Admin (schemas/migrations/018-language-selection-docs.sql).
UPDATE cms_articles
SET bodytext = REPLACE(bodytext, 'Open an article, a page or a menu item. The right column shows **Language versions**: every language of the site with the state **Original**, **Translation exists** or **Translation missing**. Use **Edit original** for the large form, or **Edit translation** and **Add translation** for the language you chose.', 'The lists of articles, pages and menu items have a **Languages** column such as "3 of 20 languages"; expanding it shows which languages are missing. In a record, the **Content language** select above the form groups the languages as original, translated and missing. Choosing a language loads its content into the same form. The history of changes is hidden until you click **Show history**.')
WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) AND title = 'Central administration' ORDER BY id LIMIT 1) AS a)
  AND LOCATE('Content language', bodytext) = 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, 'Otevřete článek, stránku nebo položku menu. V pravém sloupci jsou **Jazykové verze**: každý jazyk webu se stavem **Originál**, **Překlad existuje** nebo **Překlad zatím chybí**. Pro velký formulář použijte **Upravit originál**, pro vybraný jazyk **Upravit překlad** nebo **Přidat překlad**.', 'V seznamech článků, stránek a menu je sloupec **Jazyky**, například „3 z 20 jazyků“. Po rozkliknutí se ukáže, které jazyky chybí. V záznamu je nad formulářem roletka **Jazyk obsahu**, která jazyky seskupuje na originál, přeloženo a chybí. Po výběru jazyka se jeho obsah načte do téhož formuláře. Historie změn je skrytá, dokud neklepnete na **Zobrazit historii**.')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) AND title = 'Central administration' ORDER BY id LIMIT 1) AS a)
  AND locale = 'cs'
  AND LOCATE('Jazyk obsahu', bodytext) = 0;

-- History panel documentation (schemas/migrations/019-history-panel-docs.sql).
UPDATE cms_articles
SET bodytext = REPLACE(bodytext, 'The history of changes is hidden until you click **Show history**.', 'The last five changes appear in the right panel; the full history with restore opens through **All changes and restore**.')
WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) AND title = 'Central administration' ORDER BY id LIMIT 1) AS a);

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, 'Historie změn je skrytá, dokud neklepnete na **Zobrazit historii**.', 'Posledních pět změn je v pravém panelu, úplná historie s obnovou se otevře odkazem **Všechny změny a obnova**.')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) AND title = 'Central administration' ORDER BY id LIMIT 1) AS a)
  AND locale = 'cs';

-- Settings reference page (schemas/migrations/020-settings-reference-docs.sql).
-- Idempotent: every row is created only when it is missing, so edits made later in the Admin survive a rerun.

SET @settings_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/settings/' ORDER BY site_id LIMIT 1);
INSERT INTO cms_sites (parent_id, left_id, right_id, strict, visible, link, title, html_title, html_description, html_keywords, acl)
SELECT 1, 0, 0, 1, 1, '/docs/settings/', 'Settings reference', 'Settings reference', 'Every Settings.json key: type, default, effect and example, a production configuration and the Google Analytics setting.', 'settings,configuration,Settings.json', 0
WHERE @settings_site_id IS NULL;
SET @settings_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/settings/' ORDER BY site_id LIMIT 1);

INSERT INTO cms_site_translations (site_id, locale, title, html_title, html_description, html_keywords)
SELECT @settings_site_id, 'cs', 'Přehled nastavení', 'Přehled nastavení', 'Každý klíč Settings.json: typ, výchozí hodnota, účinek a příklad, produkční konfigurace a nastavení Google Analytics.', 'nastavení,konfigurace,Settings.json'
WHERE NOT EXISTS (SELECT 1 FROM cms_site_translations WHERE site_id = @settings_site_id AND locale = 'cs');

INSERT INTO cms_articles (site_id, grouped, futured, c_enabled, views, title, introtext, bodytext, content_format, published, author, source)
SELECT @settings_site_id, 0, 0, 0, 0, 'Settings reference', 'Every key of Settings.json with its type, default, effect and an example, the environment overrides, a complete production configuration and the Google Analytics measurement id.', '## Where the settings live

All configuration is one JSON object in `src/Config/Settings.json`. The file is not committed: `bin/wbe install` creates it from `src/Config/settings.json.default` with fresh JWT keys. The framework reads it once per request; a missing key falls back to the default listed below, and a malformed value in `http`, `analytics` or the page cache policy throws an error instead of being ignored. After changing the file clear the cache (`POST /api/cache/flush`) and, when `renderer.compileCheck` is off, the compiled template directory. Check the result with `vendor/bin/wbengine.php config:check --config=src/Config/Settings.json --root=src`.

Secrets can come from the environment instead of the file: `WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`, `WBENGINE_DEBUG` and `WBENGINE_IMAGE_DIR`. An environment variable that is set and not empty wins over the file.

## General

| Key | Type, default | Effect |
|-----|---------------|--------|
| `timeZone` | string, `Europe/Prague` | PHP time zone of the application. Required. |
| `codePage` | string, `utf8` | Charset sent in the HTML header. Keep `utf8`. |
| `debug` | bool, `false` | Shows the debug bar and detailed errors. Never `true` in production. `WBENGINE_DEBUG` overrides it. |
| `minimizeHtml` | bool, `false` | Deprecated and ignored by the dispatcher. Kept in the default file for old templates. |
| `minimizeCss` | bool, `false` | Combines and minimizes the files listed in `cssFiles`. |
| `minimizeJs` | bool, `false` | Same for scripts. Not in older files: add it explicitly, the framework reads the key directly. |
| `cssFiles` | array, `[]` | CSS files combined when `minimizeCss` is on. |
| `cdnPath` | string, empty | Prefix for static asset URLs, for example `https://cdn.example.com`. |
| `ipAdmins` | array, `[]` | List of administrator IP addresses. |

## Renderer

| Key | Type, default | Effect |
|-----|---------------|--------|
| `renderer.adapterName` | string, `NativeRenderer` | `NativeRenderer` or the optional `SmartyRenderer`. |
| `renderer.autoEscape` | bool, `true` | Escapes the output of template variables. `false` is only a migration aid for old templates. |
| `renderer.templatesDir` | string, `/View/` | Template directory under `src/`. |
| `renderer.compiledDir` | string, `Compiled/` | Compiled templates, must be writable by the PHP user. |
| `renderer.configDir` | string, `/Config/` | Template configuration directory. |
| `renderer.compileCheck` | bool, `true` | Checks on every request whether a template changed. Set `false` in production and empty the compiled directory on deploy. |

## Database

`dbAdapterDefinition` is an object: `adapterName` (`Mysqli`), `hostname`, `port`, `database`, `username`, `password`, `charset`. The default file points to the Docker host `db` with development credentials; replace all of them. Use `utf8mb4` as `charset` on a new installation. There is no environment override for the database password, so protect the file (`chmod 640`).

## Secrets

| Key | Type, default | Effect |
|-----|---------------|--------|
| `jwt.accessKey`, `jwt.refreshKey` | string, `CHANGE_ME` | Signing keys of login and API tokens, at least 32 characters and different. Overridden by `WBENGINE_JWT_KEY` and `WBENGINE_JWT_REFRESH_KEY`. Generate with `openssl rand -hex 32`. |
| `recaptcha.secretKey` | string, empty | Secret of the login form captcha. Empty means the captcha check fails closed. Overridden by `WBENGINE_RECAPTCHA_SECRET`. With `recaptcha.enabled: true` the `doctor` command requires it. |

## Proxies and HTTPS

| Key | Type, default | Effect |
|-----|---------------|--------|
| `http.trustedProxies` | array, `[]` | Exact addresses or CIDR ranges of reverse proxies whose forwarding headers are believed. Empty means every header is ignored. |
| `http.forwardedHeaders` | array, `[]` | Opt-in headers: `x-forwarded-for` (client address) and `x-forwarded-proto` (original scheme). Other values are rejected. |

Behind host Nginx or a load balancer set both, otherwise the site thinks every visitor has the proxy address and uses plain HTTP: session cookies are not secure, rate limit keys are shared and `/integrations/` refuses to issue a key. The proxy must overwrite `X-Forwarded-Proto` and build `X-Forwarded-For` from the real connection.

```json
"http": { "trustedProxies": ["172.18.0.1/32"], "forwardedHeaders": ["x-forwarded-for", "x-forwarded-proto"] }
```

## Languages

| Key | Type, default | Effect |
|-----|---------------|--------|
| `i18n.enabled` | bool, `false` (the skeleton sets `true`) | Turns languages on. |
| `i18n.default` | string, `en` | Language of unprefixed URLs and fallback for missing translations. |
| `i18n.locales` | array, `["en"]` | Offered languages, for example `["en", "cs"]`. The default is always included. |
| `i18n.detect` | array, `["url", "cookie", "header"]` | Detection order. The skeleton uses `["url"]` so unprefixed URLs are always English. Add `cookie` or `header` to let a saved choice or the browser language win. |
| `i18n.urlPrefix` | bool, `true` | Uses `/cs/...` prefixes for non-default languages. |
| `i18n.prefixDefault` | bool, `false` | Also prefixes the default language (`/en/...`). |
| `i18n.cookie` | string, `wb_locale` | Name of the preference cookie (letters, digits, underscore). |
| `i18n.cookieDays` | int, `365` | Lifetime of that cookie. |
| `i18n.dir` | string, `/Locale/` | Catalog directory under `src/`, with `en.php`, `cs.php`. |
| `i18n.baseUrl` | string, empty | Public address such as `https://example.com`. Used for absolute `hreflang` links instead of the `Host` header. Set it in production. |

## Caching

| Key | Type, default | Effect |
|-----|---------------|--------|
| `cache.enabled` | bool, `false` (the skeleton sets `true`) | Data and fragment cache. |
| `cache.driver` | string, `file` | `file` or `apcu`. `apcu` needs the extension and a PHP-FPM restart to clear. |
| `cache.ttl` | int seconds, `300` | Lifetime of data cache entries. |
| `cache.dir` | string, temp directory | Directory of the `file` driver. Default is a subdirectory of the system temp directory, which can vanish under `PrivateTmp`: set an absolute path. |
| `cache.pages.enabled` | bool, `false` | Whole-page cache for anonymous requests. |
| `cache.pages.ttl` | int seconds, `60` | Lifetime of cached pages. |
| `cache.pages.allowPaths` | array, omitted | Exact canonical paths allowed in the page cache. Omitted allows other eligible paths, empty `[]` disables page caching. |
| `cache.pages.denyPaths` | array, omitted | Paths never cached. Wins over `allowPaths`. |

Paths are compared ignoring case and a trailing slash, invalid policies fail closed. Private, `Set-Cookie` and personal responses are never stored whatever the policy says. Example: `"allowPaths": ["/", "/docs/", "/blog/"], "denyPaths": ["/profile/", "/login/"]`. A broken cache never takes the site down: it is disabled and logged.

## Rate limits and counters

| Key | Type, default | Effect |
|-----|---------------|--------|
| `rateLimit.login.enabled` | bool, `true` | Limits failed logins. |
| `rateLimit.login.maxAttempts` | int, `5` | Attempts per client address and account together. |
| `rateLimit.login.ipMaxAttempts` | int, `20` | Attempts per client address over all accounts. |
| `rateLimit.login.accountMaxAttempts` | int, `25` | Attempts per account from all addresses (distributed guessing). |
| `rateLimit.login.window` | int seconds, `900` | Length of the counting window. |
| `rateLimit.login.dir` | string, temp directory | Counter files. Set an absolute, writable path. |
| `counters.views.enabled` | bool, `false` | Batches the article view counter instead of one database write per view. |
| `counters.views.hits` | int, `50` | Hits per batch. |
| `counters.views.seconds` | int, `60` | Longest delay of a batch. |
| `counters.views.dir` | string, temp directory | Counter files. Set an absolute, writable path. |

The rate limit uses the client address, so it only works correctly when `http.trustedProxies` is right behind a proxy.

## Native analytics

| Key | Type, default | Effect |
|-----|---------------|--------|
| `analytics.enabled` | bool, `false` | Collects identity-free daily aggregates (no cookies, no addresses). Needs the analytics tables (see the Deployment page). |
| `analytics.timezone` | string, `UTC` | IANA time zone in which days are cut. Invalid values throw. |
| `analytics.retentionDays` | int, `62` | How long daily rows are kept, 31 to 365. Run `analytics:prune` from cron daily. |

This is the privacy-friendly first-party measurement. It is independent of Google Analytics below: you can run either, both or none. A policy that fits most sites: native analytics on with `retentionDays` 62 (it sets no cookies and stores no addresses), Google Analytics off unless the operator has a legal basis and a consent process. Decide the legal side for your own site.

## Google Analytics

| Key | Type, default | Effect |
|-----|---------------|--------|
| `googleAnalytics.measurementId` | string, empty | Measurement id such as `G-XXXXXXXXXX`. Empty, missing or malformed disables everything. |

The skeleton does not load Google''s tag on its own. When the id is set, the layout renders the cookie banner and the footer link "Cookie settings", and `public/cookie-consent.js` loads `gtag.js` only after the visitor presses "Allow analytics". The choice is kept in the browser (`localStorage`), "Reject" removes the analytics cookies, and the tag is never loaded without consent. With the key empty the layout contains no banner, no button and no script. The text of the banner is in the locale catalogs (`cookies.*`); adapt it to your policy. A page cached before you set the id keeps its old markup until the cache is flushed.

```json
"googleAnalytics": { "measurementId": "G-XXXXXXXXXX" }
```

## Images and the API

| Key | Type, default | Effect |
|-----|---------------|--------|
| `apiV2.enabled` | bool, `false` (the skeleton sets `true`) | Turns on the server-to-server API v2 used by the central Admin. Needs HTTPS and the API tables. |
| `apiV2.imageDirectory` | string, unset | Absolute directory for images uploaded through API v2. Unset means image upload is unavailable. Overridden by `WBENGINE_IMAGE_DIR`. Keep it outside `public/`, writable by PHP. Files are PNG, JPEG or WebP up to 512 KiB. |

## Production example

A complete file for a site behind host Nginx, with every secret in the environment (`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`) so the placeholders below are not real keys:

```json
{
  "timeZone": "Europe/Prague",
  "codePage": "utf8",
  "debug": false,
  "minimizeHtml": false,
  "minimizeCss": false,
  "minimizeJs": false,
  "cdnPath": "",
  "cssFiles": [],
  "ipAdmins": [],
  "apiV2": {
    "enabled": true,
    "imageDirectory": "/var/lib/wbengine/images"
  },
  "renderer": {
    "adapterName": "NativeRenderer",
    "autoEscape": true,
    "templatesDir": "/View/",
    "compiledDir": "Compiled/",
    "configDir": "/Config/",
    "compileCheck": false
  },
  "dbAdapterDefinition": {
    "adapterName": "Mysqli",
    "hostname": "127.0.0.1",
    "port": "3306",
    "database": "wbengine_skeleton_app",
    "username": "wbengine",
    "password": "SET-A-LONG-RANDOM-PASSWORD",
    "charset": "utf8mb4"
  },
  "jwt": { "accessKey": "", "refreshKey": "" },
  "recaptcha": { "secretKey": "" },
  "http": {
    "trustedProxies": ["127.0.0.1"],
    "forwardedHeaders": ["x-forwarded-for", "x-forwarded-proto"]
  },
  "cache": {
    "enabled": true,
    "driver": "file",
    "ttl": 300,
    "dir": "/var/cache/wbengine",
    "pages": {
      "enabled": true,
      "ttl": 60,
      "denyPaths": ["/login/", "/profile/", "/integrations/"]
    }
  },
  "i18n": {
    "enabled": true,
    "default": "en",
    "locales": ["en", "cs"],
    "detect": ["url"],
    "baseUrl": "https://example.com"
  },
  "rateLimit": { "login": { "dir": "/var/lib/wbengine/ratelimit" } },
  "counters": { "views": { "enabled": true, "dir": "/var/lib/wbengine/counters" } },
  "analytics": { "enabled": true, "timezone": "Europe/Prague", "retentionDays": 62 },
  "googleAnalytics": { "measurementId": "" }
}
```

Leaving `jwt` empty in the file is only valid when both JWT variables are set in the environment of PHP, including the cron user and the container. Without them, put real random keys in the file. Where each part is deployed (permissions of the directories, proxies, cron) is described in [Deployment](/docs/deployment/), and the caching behavior in [Caching](/docs/caching/).', 'markdown', UNIX_TIMESTAMP(), 'RRSOFT', 'https://www.wbengine.org/'
WHERE NOT EXISTS (SELECT 1 FROM cms_articles WHERE site_id = @settings_site_id);
SET @settings_article_id = (SELECT id FROM cms_articles WHERE site_id = @settings_site_id ORDER BY id LIMIT 1);

INSERT INTO cms_article_translations (article_id, locale, title, introtext, bodytext, content_format)
SELECT @settings_article_id, 'cs', 'Přehled nastavení', 'Každý klíč Settings.json s typem, výchozí hodnotou, účinkem a příkladem, přepisy z prostředí, kompletní produkční konfigurace a měřicí ID Google Analytics.', '## Kde nastavení leží

Veškerá konfigurace je jeden objekt JSON v `src/Config/Settings.json`. Soubor se nekomituje: `bin/wbe install` ho vytvoří ze `src/Config/settings.json.default` s novými klíči JWT. Framework ho čte jednou za požadavek, chybějící klíč má níže uvedenou výchozí hodnotu a chybná hodnota v `http`, `analytics` nebo v pravidlech cache stránek vyvolá chybu, nikoli tiché ignorování. Po změně souboru vyprázdněte cache (`POST /api/cache/flush`) a při vypnutém `renderer.compileCheck` i adresář zkompilovaných šablon. Výsledek ověříte příkazem `vendor/bin/wbengine.php config:check --config=src/Config/Settings.json --root=src`.

Tajné hodnoty mohou místo souboru pocházet z prostředí: `WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`, `WBENGINE_DEBUG` a `WBENGINE_IMAGE_DIR`. Nastavená a neprázdná proměnná prostředí má přednost před souborem.

## Obecné

| Klíč | Typ, výchozí hodnota | Účinek |
|------|----------------------|--------|
| `timeZone` | řetězec, `Europe/Prague` | Časové pásmo PHP aplikace. Povinné. |
| `codePage` | řetězec, `utf8` | Znaková sada v hlavičce HTML. Ponechte `utf8`. |
| `debug` | bool, `false` | Zobrazí ladicí lištu a podrobné chyby. V produkci nikdy `true`. Přepíše ho `WBENGINE_DEBUG`. |
| `minimizeHtml` | bool, `false` | Zastaralé, dispečer ho ignoruje. Zůstává ve výchozím souboru kvůli starým šablonám. |
| `minimizeCss` | bool, `false` | Spojí a zmenší soubory z `cssFiles`. |
| `minimizeJs` | bool, `false` | Totéž pro skripty. Ve starších souborech chybí: přidejte ho výslovně, framework klíč čte přímo. |
| `cssFiles` | pole, `[]` | Soubory CSS spojované při zapnutém `minimizeCss`. |
| `cdnPath` | řetězec, prázdný | Předpona URL statických souborů, například `https://cdn.example.com`. |
| `ipAdmins` | pole, `[]` | Seznam IP adres správců. |

## Renderer

| Klíč | Typ, výchozí hodnota | Účinek |
|------|----------------------|--------|
| `renderer.adapterName` | řetězec, `NativeRenderer` | `NativeRenderer` nebo volitelný `SmartyRenderer`. |
| `renderer.autoEscape` | bool, `true` | Escapuje výstup proměnných v šablonách. `false` je jen pomůcka při migraci starých šablon. |
| `renderer.templatesDir` | řetězec, `/View/` | Adresář šablon pod `src/`. |
| `renderer.compiledDir` | řetězec, `Compiled/` | Zkompilované šablony, uživatel PHP do něj musí smět zapisovat. |
| `renderer.configDir` | řetězec, `/Config/` | Adresář konfigurace šablon. |
| `renderer.compileCheck` | bool, `true` | Při každém požadavku kontroluje, zda se šablona změnila. V produkci nastavte `false` a při nasazení vyprázdněte adresář zkompilovaných šablon. |

## Databáze

`dbAdapterDefinition` je objekt: `adapterName` (`Mysqli`), `hostname`, `port`, `database`, `username`, `password`, `charset`. Výchozí soubor míří na hostitele Dockeru `db` s vývojovými údaji; všechny je vyměňte. Na nové instalaci použijte `utf8mb4` jako `charset`. Pro heslo k databázi není přepsání z prostředí, proto soubor chraňte (`chmod 640`).

## Tajné hodnoty

| Klíč | Typ, výchozí hodnota | Účinek |
|------|----------------------|--------|
| `jwt.accessKey`, `jwt.refreshKey` | řetězec, `CHANGE_ME` | Podpisové klíče přihlášení a tokenů API, nejméně 32 znaků a navzájem různé. Přepíší je `WBENGINE_JWT_KEY` a `WBENGINE_JWT_REFRESH_KEY`. Vygenerujte je příkazem `openssl rand -hex 32`. |
| `recaptcha.secretKey` | řetězec, prázdný | Tajný klíč captcha u přihlašovacího formuláře. Prázdný klíč znamená, že kontrola captcha selže (fail closed). Přepíše ho `WBENGINE_RECAPTCHA_SECRET`. Při `recaptcha.enabled: true` ho příkaz `doctor` vyžaduje. |

## Proxy a HTTPS

| Klíč | Typ, výchozí hodnota | Účinek |
|------|----------------------|--------|
| `http.trustedProxies` | pole, `[]` | Přesné adresy nebo rozsahy CIDR reverzních proxy, jejichž předávací hlavičky se berou vážně. Prázdné pole znamená, že se všechny hlavičky ignorují. |
| `http.forwardedHeaders` | pole, `[]` | Povolené hlavičky: `x-forwarded-for` (adresa klienta) a `x-forwarded-proto` (původní schéma). Jiné hodnoty se odmítnou. |

Za hostitelským Nginxem nebo load balancerem nastavte obojí, jinak web považuje každého návštěvníka za adresu proxy a komunikaci za prosté HTTP: cookies relace nejsou zabezpečená, limity pokusů se sdílejí a `/integrations/` odmítne vydat klíč. Proxy musí přepsat `X-Forwarded-Proto` a sestavit `X-Forwarded-For` ze skutečného spojení.

```json
"http": { "trustedProxies": ["172.18.0.1/32"], "forwardedHeaders": ["x-forwarded-for", "x-forwarded-proto"] }
```

## Jazyky

| Klíč | Typ, výchozí hodnota | Účinek |
|------|----------------------|--------|
| `i18n.enabled` | bool, `false` (kostra nastavuje `true`) | Zapne jazyky. |
| `i18n.default` | řetězec, `en` | Jazyk adres bez předpony a záloha pro chybějící překlady. |
| `i18n.locales` | pole, `["en"]` | Nabízené jazyky, například `["en", "cs"]`. Výchozí jazyk je vždy zahrnut. |
| `i18n.detect` | pole, `["url", "cookie", "header"]` | Pořadí detekce. Kostra používá `["url"]`, takže adresy bez předpony jsou vždy anglicky. Přidáním `cookie` nebo `header` necháte rozhodovat uloženou volbu nebo jazyk prohlížeče. |
| `i18n.urlPrefix` | bool, `true` | Používá předpony `/cs/...` pro jazyky jiné než výchozí. |
| `i18n.prefixDefault` | bool, `false` | Předponu dostane i výchozí jazyk (`/en/...`). |
| `i18n.cookie` | řetězec, `wb_locale` | Název cookie s volbou jazyka (písmena, číslice, podtržítko). |
| `i18n.cookieDays` | celé číslo, `365` | Platnost této cookie ve dnech. |
| `i18n.dir` | řetězec, `/Locale/` | Adresář katalogů pod `src/`, soubory `en.php`, `cs.php`. |
| `i18n.baseUrl` | řetězec, prázdný | Veřejná adresa, například `https://example.com`. Používá se pro absolutní odkazy `hreflang` místo hlavičky `Host`. V produkci ji nastavte. |

## Cache

| Klíč | Typ, výchozí hodnota | Účinek |
|------|----------------------|--------|
| `cache.enabled` | bool, `false` (kostra nastavuje `true`) | Datová cache a cache fragmentů. |
| `cache.driver` | řetězec, `file` | `file` nebo `apcu`. `apcu` vyžaduje rozšíření a k vyprázdnění restart PHP-FPM. |
| `cache.ttl` | sekundy, `300` | Platnost záznamů datové cache. |
| `cache.dir` | řetězec, dočasný adresář | Adresář ovladače `file`. Výchozí je podadresář systémového dočasného adresáře, který může při `PrivateTmp` zmizet: nastavte absolutní cestu. |
| `cache.pages.enabled` | bool, `false` | Cache celých stránek pro anonymní požadavky. |
| `cache.pages.ttl` | sekundy, `60` | Platnost stránek v cache. |
| `cache.pages.allowPaths` | pole, vynecháno | Přesné kanonické cesty povolené v cache stránek. Vynechané povolí ostatní vhodné cesty, prázdné `[]` cache stránek vypne. |
| `cache.pages.denyPaths` | pole, vynecháno | Cesty, které se nikdy neukládají. Má přednost před `allowPaths`. |

Cesty se porovnávají bez ohledu na velikost písmen a koncové lomítko, neplatná pravidla selžou bezpečně (fail closed). Soukromé odpovědi, odpovědi s `Set-Cookie` a osobní odpovědi se neukládají nikdy, ať pravidlo říká cokoli. Příklad: `"allowPaths": ["/", "/docs/", "/blog/"], "denyPaths": ["/profile/", "/login/"]`. Rozbitá cache web neshodí: vypne se a zaloguje.

## Limity pokusů a počítadla

| Klíč | Typ, výchozí hodnota | Účinek |
|------|----------------------|--------|
| `rateLimit.login.enabled` | bool, `true` | Omezuje neúspěšná přihlášení. |
| `rateLimit.login.maxAttempts` | celé číslo, `5` | Pokusy na adresu klienta a účet dohromady. |
| `rateLimit.login.ipMaxAttempts` | celé číslo, `20` | Pokusy na adresu klienta napříč všemi účty. |
| `rateLimit.login.accountMaxAttempts` | celé číslo, `25` | Pokusy na účet ze všech adres (rozprostřené hádání). |
| `rateLimit.login.window` | sekundy, `900` | Délka počítacího okna. |
| `rateLimit.login.dir` | řetězec, dočasný adresář | Soubory počítadel. Nastavte absolutní zapisovatelnou cestu. |
| `counters.views.enabled` | bool, `false` | Dávkuje počítadlo zobrazení článků místo jednoho zápisu do databáze na zobrazení. |
| `counters.views.hits` | celé číslo, `50` | Počet zobrazení v dávce. |
| `counters.views.seconds` | celé číslo, `60` | Nejdelší zpoždění dávky. |
| `counters.views.dir` | řetězec, dočasný adresář | Soubory počítadel. Nastavte absolutní zapisovatelnou cestu. |

Limit pokusů používá adresu klienta, proto za proxy funguje správně jen při správném `http.trustedProxies`.

## Vlastní analytika

| Klíč | Typ, výchozí hodnota | Účinek |
|------|----------------------|--------|
| `analytics.enabled` | bool, `false` | Sbírá denní souhrny bez identity (žádné cookies, žádné adresy). Vyžaduje tabulky analytiky (viz stránka Nasazení). |
| `analytics.timezone` | řetězec, `UTC` | Časové pásmo IANA, ve kterém se dny dělí. Neplatná hodnota vyvolá chybu. |
| `analytics.retentionDays` | celé číslo, `62` | Jak dlouho se denní řádky drží, 31 až 365. Spouštějte `analytics:prune` z cronu denně. |

Jde o měření vlastním nástrojem šetrné k soukromí. Je nezávislé na Google Analytics níže: můžete provozovat jedno, obojí i žádné. Rozumná politika pro většinu webů: vlastní analytika zapnutá s `retentionDays` 62 (nenastavuje cookies a neukládá adresy), Google Analytics vypnuté, dokud provozovatel nemá právní důvod a proces souhlasu. Právní stránku posuďte pro vlastní web.

## Google Analytics

| Klíč | Typ, výchozí hodnota | Účinek |
|------|----------------------|--------|
| `googleAnalytics.measurementId` | řetězec, prázdný | Měřicí ID, například `G-XXXXXXXXXX`. Prázdné, chybějící nebo chybně zapsané ID vše vypne. |

Kostra značku Google sama nenačítá. Po nastavení ID layout zobrazí lištu s cookies i odkaz „Nastavení cookies“ v patičce a `public/cookie-consent.js` načte `gtag.js` až poté, co návštěvník stiskne „Povolit analytiku“. Volba se pamatuje v prohlížeči (`localStorage`), „Odmítnout“ odstraní analytické cookies a bez souhlasu se značka nenačte nikdy. Při prázdném klíči layout neobsahuje lištu, tlačítko ani skript. Text lišty je v katalozích jazyků (`cookies.*`); upravte ho podle svých zásad. Stránka uložená v cache před nastavením ID si staré značení drží, dokud cache nevyprázdníte.

```json
"googleAnalytics": { "measurementId": "G-XXXXXXXXXX" }
```

## Obrázky a API

| Klíč | Typ, výchozí hodnota | Účinek |
|------|----------------------|--------|
| `apiV2.enabled` | bool, `false` (kostra nastavuje `true`) | Zapne serverové API v2, které používá centrální Admin. Vyžaduje HTTPS a tabulky API. |
| `apiV2.imageDirectory` | řetězec, nenastaveno | Absolutní adresář pro obrázky nahrané přes API v2. Nenastaveno znamená, že nahrávání obrázků není dostupné. Přepíše ho `WBENGINE_IMAGE_DIR`. Držte ho mimo `public/` a zapisovatelný pro PHP. Soubory PNG, JPEG nebo WebP do 512 KiB. |

## Produkční příklad

Kompletní soubor pro web za hostitelským Nginxem, všechna tajemství v prostředí (`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`), takže zástupné hodnoty níže nejsou skutečné klíče:

```json
{
  "timeZone": "Europe/Prague",
  "codePage": "utf8",
  "debug": false,
  "minimizeHtml": false,
  "minimizeCss": false,
  "minimizeJs": false,
  "cdnPath": "",
  "cssFiles": [],
  "ipAdmins": [],
  "apiV2": {
    "enabled": true,
    "imageDirectory": "/var/lib/wbengine/images"
  },
  "renderer": {
    "adapterName": "NativeRenderer",
    "autoEscape": true,
    "templatesDir": "/View/",
    "compiledDir": "Compiled/",
    "configDir": "/Config/",
    "compileCheck": false
  },
  "dbAdapterDefinition": {
    "adapterName": "Mysqli",
    "hostname": "127.0.0.1",
    "port": "3306",
    "database": "wbengine_skeleton_app",
    "username": "wbengine",
    "password": "SET-A-LONG-RANDOM-PASSWORD",
    "charset": "utf8mb4"
  },
  "jwt": { "accessKey": "", "refreshKey": "" },
  "recaptcha": { "secretKey": "" },
  "http": {
    "trustedProxies": ["127.0.0.1"],
    "forwardedHeaders": ["x-forwarded-for", "x-forwarded-proto"]
  },
  "cache": {
    "enabled": true,
    "driver": "file",
    "ttl": 300,
    "dir": "/var/cache/wbengine",
    "pages": {
      "enabled": true,
      "ttl": 60,
      "denyPaths": ["/login/", "/profile/", "/integrations/"]
    }
  },
  "i18n": {
    "enabled": true,
    "default": "en",
    "locales": ["en", "cs"],
    "detect": ["url"],
    "baseUrl": "https://example.com"
  },
  "rateLimit": { "login": { "dir": "/var/lib/wbengine/ratelimit" } },
  "counters": { "views": { "enabled": true, "dir": "/var/lib/wbengine/counters" } },
  "analytics": { "enabled": true, "timezone": "Europe/Prague", "retentionDays": 62 },
  "googleAnalytics": { "measurementId": "" }
}
```

Prázdné `jwt` v souboru platí jen tehdy, když jsou obě proměnné JWT nastavené v prostředí PHP, včetně uživatele cronu a kontejneru. Jinak do souboru vložte skutečné náhodné klíče. Kde co nasadit (oprávnění adresářů, proxy, cron) popisuje [Nasazení](/cs/docs/deployment/), chování cache stránka [Cache](/cs/docs/caching/).', 'markdown'
WHERE @settings_article_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cms_article_translations WHERE article_id = @settings_article_id AND locale = 'cs');

INSERT INTO cms_boxes (name, module, method, section_id, static, shared, device_min, device_strict, acl, `order`, sites)
SELECT 'Docs: Settings reference', 'docs', 'page', 1, 1, 0, 1, 0, 0, 0, JSON_ARRAY(CAST(@settings_site_id AS CHAR))
WHERE NOT EXISTS (SELECT 1 FROM cms_boxes WHERE name = 'Docs: Settings reference');

-- Deployment page (schemas/migrations/021-deployment-docs.sql).
-- Idempotent: every row is created only when it is missing, so edits made later in the Admin survive a rerun.

SET @deployment_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/deployment/' ORDER BY site_id LIMIT 1);
INSERT INTO cms_sites (parent_id, left_id, right_id, strict, visible, link, title, html_title, html_description, html_keywords, acl)
SELECT 1, 0, 0, 1, 1, '/docs/deployment/', 'Deployment', 'Deployment', 'Install the skeleton without Docker: PHP-FPM with Nginx, Apache, permissions, database updates, cron, HTTPS, backups, and built container images.', 'deployment,nginx,apache,php-fpm', 0
WHERE @deployment_site_id IS NULL;
SET @deployment_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/deployment/' ORDER BY site_id LIMIT 1);

INSERT INTO cms_site_translations (site_id, locale, title, html_title, html_description, html_keywords)
SELECT @deployment_site_id, 'cs', 'Nasazení', 'Nasazení', 'Instalace kostry bez Dockeru: PHP-FPM s Nginxem, Apache, oprávnění, aktualizace databáze, cron, HTTPS, zálohy a sestavené image kontejnerů.', 'nasazení,nginx,apache,php-fpm'
WHERE NOT EXISTS (SELECT 1 FROM cms_site_translations WHERE site_id = @deployment_site_id AND locale = 'cs');

INSERT INTO cms_articles (site_id, grouped, futured, c_enabled, views, title, introtext, bodytext, content_format, published, author, source)
SELECT @deployment_site_id, 0, 0, 0, 0, 'Deployment', 'Install and run the skeleton on a server you manage yourself: requirements, PHP-FPM with Nginx or Apache, writable paths, database and updates, cron, HTTPS and proxies, backups, health checks, hybrid layouts and published container images.', 'This page mirrors `docs/deploy-bare-metal.md` in the repository. It installs the site on a server where you manage PHP, the web server and the database yourself: a VPS, a dedicated machine or a managed host. The Docker route has its own guide: [Deploy to a clean Ubuntu VPS with Docker](https://github.com/rrsoftcz/wbengine-skeleton-app/blob/main/docs/deploy-vps-docker.md). Every key of `Settings.json` is explained in the [settings reference](/docs/settings/).

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

## 2. Database

Create an empty database with the `utf8mb4` character set and a user that has rights only on it:

```sql
CREATE DATABASE wbengine_skeleton_app CHARACTER SET utf8mb4;
CREATE USER ''wbengine''@''127.0.0.1'' IDENTIFIED BY ''a long random password'';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX, DROP ON wbengine_skeleton_app.* TO ''wbengine''@''127.0.0.1'';
```

The schema and the content dump are imported in this order, then the framework tables (API, analytics and change log) are created from the files shipped with the installed framework, so they always match its version:

```sh
mysql wbengine_skeleton_app < schemas/wbengine_skeletone_app_mysql_template.sql
mysql wbengine_skeleton_app < schemas/wbengine_skeletone_app_mysql_template_content.sql
sh bin/update-database.sh wbengine_skeleton_app
```

The script applies the same framework updates as the Docker installer and is safe to run again. The content dump is a fresh-install seed: it is not idempotent, so never import it into a database that already has content.

An existing installation takes the database updates of a newer version after a backup: the new files from `schemas/migrations/`, once and in order, and the framework updates with `sh bin/update-database.sh DATABASE`. `vendor/bin/wbengine.php migration:status` shows whether the framework tables are complete.

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

The job reads the same environment secrets, so run it as the web user with the same variables (for example by sourcing a root-owned file in the crontab line).

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
# apply new files from schemas/migrations/ (in order), then the framework updates:
sh bin/update-database.sh wbengine_skeleton_app
rm -f src/View/Compiled/*
php vendor/bin/wbengine.php doctor --config=src/Config/Settings.json --root=src
systemctl reload php8.4-fpm
```

Flush the cache with `POST /api/cache/flush` (administrator), or remove the files in `cache.dir`. For APCu cache restart PHP-FPM.

Rollback: check out the previous tag, run `composer install --no-dev`, empty the compiled directory, reload PHP-FPM. Database updates are not reversed automatically: if one changed the schema, restore the database dump taken before the deploy. Content updates only change text and are safe to leave in place.

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

Point `dbAdapterDefinition.hostname` at the managed MySQL or MariaDB service and import the schema, content and framework updates of section 2 with the `mysql` client from a machine that can reach it (the `docker-entrypoint-initdb.d` import only exists for the bundled database). Use a dedicated user and database, allow connections only from the application host, and enable TLS on the server side when it crosses a network. In a Compose file, remove the `db` service and the `depends_on` entry. Check that the database version meets the requirements (`JSON_SEARCH`).

### Shared hosting

It works when the host offers PHP 8.3 or newer with the extensions above, MySQL or MariaDB, `mod_rewrite` and `.htaccess`, and lets you set the document root to `public/` (otherwise the project cannot be installed safely). Limits to expect: no shell or cron, so run `composer install --no-dev` locally and upload the whole tree including `vendor/`; import the SQL files through the host''s database tool; no environment variables, so secrets must live in `Settings.json` (out of version control, with the most restrictive permissions the host allows); no `analytics:prune` unless the panel offers cron; write access to `src/View/Compiled` and the runtime directories must be arranged through the panel. If the host cannot do these, use a VPS.

## Built images

Container images are published as `ghcr.io/rrsoftcz/wbengine-skeleton-app` tagged with the version (`1.2.3`, `1.2`) and `latest`. The image contains the code and the production Composer dependencies and no secrets. Pull and run it with `Settings.json` mounted read-only and a volume for the compiled templates:

```sh
docker pull ghcr.io/rrsoftcz/wbengine-skeleton-app:1.2.3
docker run -d --name wbengine --restart unless-stopped \\
  -p 127.0.0.1:8080:80 \\
  -v /etc/wbengine/Settings.json:/var/www/html/src/Config/Settings.json:ro \\
  -v wbengine_compiled:/var/www/html/src/View/Compiled \\
  -e WBENGINE_JWT_KEY="..." -e WBENGINE_JWT_REFRESH_KEY="..." \\
  ghcr.io/rrsoftcz/wbengine-skeleton-app:1.2.3
```

Pin a version tag in production rather than `latest`. The container serves plain HTTP on port 80: put host Nginx in front (see the VPS guide) and set `http.trustedProxies` to the address the container sees the proxy from. The database is not part of the image; use the bundled Compose file or an external database as described above. To update, pull the new tag, apply the database updates, then `docker rm -f wbengine` and run again; the compiled volume is reused (empty it when `compileCheck` is `false`).', 'markdown', UNIX_TIMESTAMP(), 'RRSOFT', 'https://www.wbengine.org/'
WHERE NOT EXISTS (SELECT 1 FROM cms_articles WHERE site_id = @deployment_site_id);
SET @deployment_article_id = (SELECT id FROM cms_articles WHERE site_id = @deployment_site_id ORDER BY id LIMIT 1);

INSERT INTO cms_article_translations (article_id, locale, title, introtext, bodytext, content_format)
SELECT @deployment_article_id, 'cs', 'Nasazení', 'Instalace a provoz kostry na vlastním serveru: požadavky, PHP-FPM s Nginxem nebo Apache, zapisovatelné cesty, databáze a aktualizace, cron, HTTPS a proxy, zálohy, kontroly stavu, hybridní uspořádání a publikované image kontejnerů.', 'Tento návod instaluje web na server, kde si PHP, webový server a databázi spravujete sami: VPS, vyhrazený stroj nebo spravovaný hosting. Postup s Dockerem má vlastní návod: [Nasazení na čisté VPS s Ubuntu pomocí Dockeru](https://github.com/rrsoftcz/wbengine-skeleton-app/blob/main/docs/deploy-vps-docker.md). Každý klíč `Settings.json` vysvětluje [přehled nastavení](/cs/docs/settings/).

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

## 2. Databáze

Vytvořte prázdnou databázi se znakovou sadou `utf8mb4` a uživatele s právy jen na ni:

```sql
CREATE DATABASE wbengine_skeleton_app CHARACTER SET utf8mb4;
CREATE USER ''wbengine''@''127.0.0.1'' IDENTIFIED BY ''dlouhé náhodné heslo'';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX, DROP ON wbengine_skeleton_app.* TO ''wbengine''@''127.0.0.1'';
```

Schéma a obsah se importují v tomto pořadí, poté se z přibalených souborů nainstalovaného frameworku vytvoří jeho tabulky (API, analytika a záznam změn), takže vždy sedí na jeho verzi:

```sh
mysql wbengine_skeleton_app < schemas/wbengine_skeletone_app_mysql_template.sql
mysql wbengine_skeleton_app < schemas/wbengine_skeletone_app_mysql_template_content.sql
sh bin/update-database.sh wbengine_skeleton_app
```

Skript použije stejné aktualizace frameworku jako instalátor pro Docker a lze ho bezpečně spustit znovu. Soubor s obsahem je počáteční naplnění nové instalace: není idempotentní, proto ho nikdy neimportujte do databáze, která už obsah má.

Existující instalace po záloze použije databázové aktualizace novější verze: nové soubory ze `schemas/migrations/` jednou a v pořadí a aktualizace frameworku příkazem `sh bin/update-database.sh DATABASE`. Příkaz `vendor/bin/wbengine.php migration:status` ukáže, zda jsou tabulky frameworku úplné.

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

Úloha čte stejné tajné hodnoty z prostředí, proto ji spouštějte pod webovým uživatelem se stejnými proměnnými (například načtením souboru vlastněného rootem v řádku crontabu).

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
# spusťte nové soubory ze schemas/migrations/ (v pořadí), potom aktualizace frameworku:
sh bin/update-database.sh wbengine_skeleton_app
rm -f src/View/Compiled/*
php vendor/bin/wbengine.php doctor --config=src/Config/Settings.json --root=src
systemctl reload php8.4-fpm
```

Cache vyprázdníte voláním `POST /api/cache/flush` (správce) nebo smazáním souborů v `cache.dir`. U cache APCu restartujte PHP-FPM.

Návrat: přepněte na předchozí značku, spusťte `composer install --no-dev`, vyprázdněte adresář zkompilovaných šablon a reloadujte PHP-FPM. Databázové aktualizace se automaticky nevracejí: pokud některá změnila schéma, obnovte zálohu databáze pořízenou před nasazením. Obsahové aktualizace mění jen text a lze je ponechat.

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

Nasměrujte `dbAdapterDefinition.hostname` na spravovanou službu MySQL nebo MariaDB a importujte schéma, obsah a aktualizace frameworku z části 2 klientem `mysql` ze stroje, který na ni dosáhne (import přes `docker-entrypoint-initdb.d` existuje jen pro přibalenou databázi). Použijte vyhrazeného uživatele a databázi, povolte připojení jen z hostitele aplikace a při přenosu po síti zapněte TLS na straně serveru. V souboru Compose odeberte službu `db` a položku `depends_on`. Ověřte, že verze databáze splňuje požadavky (`JSON_SEARCH`).

### Sdílený hosting

Funguje, pokud hosting nabízí PHP 8.3 nebo novější s výše uvedenými rozšířeními, MySQL nebo MariaDB, `mod_rewrite` a `.htaccess` a dovolí nastavit kořen webu na `public/` (jinak projekt nelze bezpečně nainstalovat). Čeho se držet: bez shellu a cronu, proto spusťte `composer install --no-dev` lokálně a nahrajte celý strom včetně `vendor/`; SQL soubory importujte nástrojem hostingu; bez proměnných prostředí, proto tajné hodnoty musí být v `Settings.json` (mimo správu verzí, s co nejpřísnějšími oprávněními, jaká hosting dovolí); bez `analytics:prune`, pokud panel nenabízí cron; zápis do `src/View/Compiled` a běhových adresářů je nutné zařídit přes panel. Pokud to hosting nezvládne, použijte VPS.

## Sestavené image

Image kontejneru se publikuje jako `ghcr.io/rrsoftcz/wbengine-skeleton-app` se značkami verze (`1.2.3`, `1.2`) a `latest`. Image obsahuje kód a produkční závislosti Composeru a žádná tajemství. Stáhněte a spusťte ho s `Settings.json` připojeným jen pro čtení a svazkem pro zkompilované šablony:

```sh
docker pull ghcr.io/rrsoftcz/wbengine-skeleton-app:1.2.3
docker run -d --name wbengine --restart unless-stopped \\
  -p 127.0.0.1:8080:80 \\
  -v /etc/wbengine/Settings.json:/var/www/html/src/Config/Settings.json:ro \\
  -v wbengine_compiled:/var/www/html/src/View/Compiled \\
  -e WBENGINE_JWT_KEY="..." -e WBENGINE_JWT_REFRESH_KEY="..." \\
  ghcr.io/rrsoftcz/wbengine-skeleton-app:1.2.3
```

V produkci připněte značku verze, ne `latest`. Kontejner obsluhuje prosté HTTP na portu 80: postavte před něj hostitelský Nginx (viz návod pro VPS) a nastavte `http.trustedProxies` na adresu, ze které kontejner proxy vidí. Databáze součástí image není; použijte přibalený soubor Compose nebo externí databázi popsanou výše. Při aktualizaci stáhněte novou značku, použijte databázové aktualizace, pak `docker rm -f wbengine` a spusťte znovu; svazek se zkompilovanými šablonami se použije znovu (při `compileCheck` na `false` ho vyprázdněte).', 'markdown'
WHERE @deployment_article_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cms_article_translations WHERE article_id = @deployment_article_id AND locale = 'cs');

INSERT INTO cms_boxes (name, module, method, section_id, static, shared, device_min, device_strict, acl, `order`, sites)
SELECT 'Docs: Deployment', 'docs', 'page', 1, 1, 0, 1, 0, 0, 0, JSON_ARRAY(CAST(@deployment_site_id AS CHAR))
WHERE NOT EXISTS (SELECT 1 FROM cms_boxes WHERE name = 'Docs: Deployment');

-- Logging and audit page (schemas/migrations/022-logging-docs.sql).
-- Idempotent: every row is created only when it is missing, so edits made later in the Admin survive a rerun.

SET @logging_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/logging/' ORDER BY site_id LIMIT 1);
INSERT INTO cms_sites (parent_id, left_id, right_id, strict, visible, link, title, html_title, html_description, html_keywords, acl)
SELECT 1, 0, 0, 1, 1, '/docs/logging/', 'Logging and audit', 'Logging and audit', 'What a WBengine site logs and where: error logs, web server logs, the API audit, the change log, retention and pruning, and privacy notes.', 'logging,audit,change log,privacy', 0
WHERE @logging_site_id IS NULL;
SET @logging_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/logging/' ORDER BY site_id LIMIT 1);

INSERT INTO cms_site_translations (site_id, locale, title, html_title, html_description, html_keywords)
SELECT @logging_site_id, 'cs', 'Logování a audit', 'Logování a audit', 'Co web na WBengine loguje a kam: chybové logy, logy webového serveru, audit API, záznam změn, uchování a mazání a poznámky k soukromí.', 'logování,audit,záznam změn,soukromí'
WHERE NOT EXISTS (SELECT 1 FROM cms_site_translations WHERE site_id = @logging_site_id AND locale = 'cs');

INSERT INTO cms_articles (site_id, grouped, futured, c_enabled, views, title, introtext, bodytext, content_format, published, author, source)
SELECT @logging_site_id, 0, 0, 0, 0, 'Logging and audit', 'What is logged where (PHP errors, web server logs, the API audit and the change log), what is not, who-what-when queries, retention and audit:prune, the change log tables and privacy notes.', 'This page explains what a WBengine site records, where, for how long, and how to ask "who changed what and when".

## What is logged where

| Source | Where | What |
|--------|-------|------|
| PHP and framework errors | PHP `error_log` | Warnings, exceptions, "cache disabled: ..." and one line with a short reference code for every 5xx failure of API v2. |
| Web server | Nginx or Apache access and error logs | Every HTTP request: time, address, URL, status. This is the only place with IP addresses. |
| API v2 requests | table `cms_api_audit` | One row per authenticated call: who, which operation, outcome. |
| Content and structure changes | table `cms_api_changes` | One row per write with actor, resource, action and the data before and after. |
| Article drafts | table `cms_api_revisions` | The draft history of an article, used for preview and restore. |

### PHP error log and reference codes

PHP writes through `error_log`: the file set by the ini value `error_log`, otherwise the web server error log (PHP-FPM log, Apache `ErrorLog`, the Nginx error log for FastCGI errors). Keep `display_errors = Off` and `log_errors = On` in production. When an API v2 call fails with a server error (5xx) the client gets a generic message with a short reference code, for example `ref:7f3a9c`. The same reference is written to `error_log` with the details and stored in the audit row, so you can search the log for exactly that code.

### Web server logs and containers

Nginx and Apache keep the access and error logs, typically `/var/log/nginx/` and `/var/log/apache2/`. In the Docker images Apache sends both logs and the PHP errors to the container output, so they are read with `docker compose logs web` (or `docker logs <container>`). The default `json-file` driver grows without a limit: set `max-size` and `max-file` in the Compose `logging` section or in `/etc/docker/daemon.json`, or ship the output to a log collector. Host Nginx in front of containers has its own logs in addition.

## The audit table `cms_api_audit`

Columns: `audit_id`, `integration_id` (the key), `central_actor` (the editor label sent by the central Admin, untrusted free text up to 128 characters), `local_user_id` (the local administrator for key management), `action`, `outcome`, `detail` and `created_at` (Unix time).

| `outcome` | Meaning |
|-----------|---------|
| `allowed` | The key was valid and had the scope. This includes reads, so reads of content leave a trace here (who, which operation, when) but never the data that was returned. |
| `unauthorized` | The key was missing, invalid or revoked (HTTP 401). `integration_id` is empty. |
| `forbidden` | The key is valid but lacks the required scope (HTTP 403). |
| `rejected` | An authenticated write was refused: validation, not found, conflict, failed `If-Match` precondition (412 or 428). `detail` holds the error code. |
| `error` | A server failure (5xx). `detail` is `ref:<reference>`, the same code as in `error_log`. |

## The change log `cms_api_changes`

Every write path creates one row: `change_id`, `resource` (`pages`, `menu`, `sections`, `boxes`, `articles` for API v2), `resource_id`, `action`, `before_data` and `after_data` (JSON snapshots), `integration_id`, `central_actor`, `source`, `local_user_id` and `created_at`.

| `source` | Who wrote | Actor |
|----------|-----------|-------|
| `v2` | API v2 (the central Admin), in the same transaction as the content change | `integration_id` and `central_actor` |
| `v1` | Legacy API: users, sections, translations, cache flush | `local_user_id`, `integration_id` is 0 |
| `cli` | `bin/wbe user:create`, `user:password`, `user:delete` and `audit:prune` | `central_actor` is `cli:<operating system user>`, `integration_id` is 0 |

Rows of `v1` and `cli` use singular resource names (v2 uses plural ones) (`user`, `section`, `translation`, `cache`, `audit`), so they never show up in the `/changes` history of a v2 resource. Article drafts and restored versions live in `cms_api_revisions`: `revision_id`, `article_id`, `payload`, `action`, `integration_id`, `central_actor`, `created_at`. A revision that a draft still points to is never deleted.

## What is not logged

- Request bodies and response bodies. The audit holds the operation and the outcome, the change log holds the resulting data.
- IP addresses. They exist only in the web server access log.
- API keys, tokens and passwords. A password change is recorded as `passwordChanged: true` and nothing else.
- Public page views. Native analytics (see the settings reference) keeps anonymous daily totals only.

### Redaction

Rows written by `v1` and `cli` are redacted: any key named password, token, secret, key or hash (also `apiKey`, `key_hash`) is stored as `[redacted]`. Rows from `v2` store the data as given because structure recovery replays it, so do not put secrets in page, menu or article content.

## Who, what, when

All `created_at` values are Unix timestamps. Examples:

```sql
-- the last 20 changes with who and when
SELECT FROM_UNIXTIME(created_at) AS at, source, resource, resource_id, action,
       COALESCE(central_actor, local_user_id) AS actor, integration_id
FROM cms_api_changes ORDER BY change_id DESC LIMIT 20;

-- the history of one article, with the data
SELECT FROM_UNIXTIME(created_at) AS at, action, central_actor, before_data, after_data
FROM cms_api_changes WHERE resource = ''articles'' AND resource_id = ''12'' ORDER BY change_id;

-- everything one editor did in the last 7 days
SELECT FROM_UNIXTIME(created_at) AS at, resource, resource_id, action
FROM cms_api_changes WHERE central_actor = ''anna@example.com'' AND created_at > UNIX_TIMESTAMP() - 7 * 86400;

-- refused and failed calls today, and failed authentication
SELECT FROM_UNIXTIME(created_at) AS at, integration_id, central_actor, action, outcome, detail
FROM cms_api_audit WHERE outcome <> ''allowed'' AND created_at > UNIX_TIMESTAMP(CURDATE()) ORDER BY audit_id DESC;

-- which keys are used how often
SELECT integration_id, outcome, COUNT(*) FROM cms_api_audit GROUP BY integration_id, outcome;
```

From the command line, `audit:list` prints recent changes without their before and after data:

```sh
php vendor/bin/wbengine.php audit:list --limit=50 --resource=articles --actor=anna@example.com --config=src/Config/Settings.json --root=src
```

`--limit` is 1 to 500 (default 20), `--actor` matches the actor label exactly, or the local user id when it is numeric. The central Admin reads the same data over HTTP, see the next section.

## Change feed over HTTP

`GET /api/v2/changes` returns the change log, newest first, without the before and after data. It needs HTTPS and an integration key with the scope `audit:read`. The central Admin shows the feed on the Activity page of a site, for site administrators only. A key without that scope must be replaced by a new key.

Query parameters: `page` and `per_page` (1 to 100, default 25); the exact-match filters `resource`, `resource_id`, `action`, `source` (`v2`, `v1` or `cli`) and `actor`; `since` and `until` as epoch seconds. An invalid filter is answered with 400. With `outcome=rejected` the feed lists rejected and failed writes from `cms_api_audit` instead, with the error code in `detail`.

Every entry has `change_id`, `created_at`, `resource`, `resource_id`, `action`, `source`, `actor`, `integration_id` and `local_user_id`. Reading the feed is itself recorded in the audit table as `changes.list`.

## Retention and pruning

Nothing is deleted automatically. The keys in `Settings.json` (both default to 365, allowed 30 to 3650, invalid values raise an error):

```json
"audit": { "retentionDays": 365, "revisionRetentionDays": 365 }
```

`audit.retentionDays` applies to `cms_api_audit` and `cms_api_changes`, `audit.revisionRetentionDays` to `cms_api_revisions`. Run the pruning from cron:

```cron
27 3 * * * www-data /usr/bin/php /var/www/wbengine-skeleton-app/vendor/bin/wbengine.php audit:prune --config=/var/www/wbengine-skeleton-app/src/Config/Settings.json --root=/var/www/wbengine-skeleton-app/src >> /var/log/wbengine-cron.log 2>&1
```

`audit:prune --dry-run` only counts, `--days=N` overrides both keys for one run. The newest change of every resource stays however old (its id is part of the structure ETag and of recovery) and so does every revision referenced by a draft. Each real run records itself as a `cli` change of the resource `audit`. In Docker run the command with `docker compose -f docker-compose.production.yml exec -T web php vendor/bin/wbengine.php audit:prune ...`, from the host cron.

## Preparing the change log tables

Sites that use API v2 need the change log columns `source`, `local_user_id` and `detail` and the `created_at` indexes. Run `sh bin/update-database.sh DATABASE` once, after a backup; it is safe to run again. `vendor/bin/wbengine.php doctor` reports a failed check until the columns exist; until then they are skipped and nothing else changes.

```sh
sh bin/update-database.sh wbengine_skeleton_app
docker compose -f docker-compose.production.yml exec -T web sh bin/update-database.sh --print \\
  | docker compose -f docker-compose.production.yml exec -T db sh -c ''MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot wbengine_skeleton_app''
```

The first command is for a database on the host, the second for the production Compose stack.

## Privacy notes

- Actor labels, user rows and content snapshots can contain personal data such as e-mail addresses and names. Treat the audit tables as personal data: restrict database access, and include them in your records of processing.
- Choose a retention that matches your policy, and note that database backups keep rows longer than the retention setting.
- The IP address lives only in web server logs. Set their rotation and retention separately (`logrotate`, the Docker log options).
- The audit is a trace of who did what, not of what visitors read: public page views are not recorded per visitor.', 'markdown', UNIX_TIMESTAMP(), 'RRSOFT', 'https://www.wbengine.org/'
WHERE NOT EXISTS (SELECT 1 FROM cms_articles WHERE site_id = @logging_site_id);
SET @logging_article_id = (SELECT id FROM cms_articles WHERE site_id = @logging_site_id ORDER BY id LIMIT 1);

INSERT INTO cms_article_translations (article_id, locale, title, introtext, bodytext, content_format)
SELECT @logging_article_id, 'cs', 'Logování a audit', 'Co se loguje kam (chyby PHP, logy webového serveru, audit API a záznam změn), co ne, dotazy kdo-co-kdy, uchování a audit:prune, tabulky záznamu změn a poznámky k soukromí.', 'Tato stránka vysvětluje, co web na WBengine zaznamenává, kam, jak dlouho a jak se zeptat „kdo, co a kdy změnil“.

## Co se loguje kam

| Zdroj | Kam | Co |
|-------|-----|----|
| Chyby PHP a frameworku | PHP `error_log` | Varování, výjimky, „cache disabled: ...“ a řádek s krátkým referenčním kódem u každé chyby 5xx v API v2. |
| Webový server | přístupové a chybové logy Nginxu nebo Apache | Každý požadavek HTTP: čas, adresa, URL, stav. Jediné místo s IP adresami. |
| Požadavky API v2 | tabulka `cms_api_audit` | Jeden řádek za každé ověřené volání: kdo, jaká operace, výsledek. |
| Změny obsahu a struktury | tabulka `cms_api_changes` | Jeden řádek za každý zápis s aktérem, zdrojem, akcí a daty před a po. |
| Koncepty článků | tabulka `cms_api_revisions` | Historie konceptů článku pro náhled a obnovu. |

### Chybový log PHP a referenční kódy

PHP zapisuje přes `error_log`: do souboru z ini hodnoty `error_log`, jinak do chybového logu webového serveru (log PHP-FPM, `ErrorLog` Apache, chybový log Nginxu u chyb FastCGI). V produkci ponechte `display_errors = Off` a `log_errors = On`. Když volání API v2 skončí chybou serveru (5xx), klient dostane obecnou zprávu s krátkým referenčním kódem, například `ref:7f3a9c`. Stejný kód se zapíše i s podrobnostmi do `error_log` a do auditního řádku, takže v logu hledáte přesně tento kód.

### Logy webového serveru a kontejnery

Nginx a Apache mají přístupové a chybové logy, obvykle v `/var/log/nginx/` a `/var/log/apache2/`. V dockerových image posílá Apache oba logy i chyby PHP na výstup kontejneru, čtou se příkazem `docker compose logs web` (nebo `docker logs <kontejner>`). Výchozí ovladač `json-file` roste bez omezení: nastavte `max-size` a `max-file` v sekci `logging` souboru Compose nebo v `/etc/docker/daemon.json`, případně výstup posílejte do sběrače logů. Hostitelský Nginx před kontejnery má navíc vlastní logy.

## Auditní tabulka `cms_api_audit`

Sloupce: `audit_id`, `integration_id` (klíč), `central_actor` (označení redaktora od centrálního Adminu, nedůvěryhodný volný text do 128 znaků), `local_user_id` (místní správce při správě klíčů), `action`, `outcome`, `detail` a `created_at` (čas Unix).

| `outcome` | Význam |
|-----------|--------|
| `allowed` | Klíč byl platný a měl scope. Patří sem i čtení, takže čtení obsahu zanechá stopu (kdo, jaká operace, kdy), nikdy však vrácená data. |
| `unauthorized` | Klíč chyběl, byl neplatný nebo odvolaný (HTTP 401). `integration_id` je prázdné. |
| `forbidden` | Klíč je platný, ale nemá požadovaný scope (HTTP 403). |
| `rejected` | Ověřený zápis byl odmítnut: validace, nenalezeno, konflikt, neúspěšná podmínka `If-Match` (412 nebo 428). `detail` obsahuje kód chyby. |
| `error` | Chyba serveru (5xx). `detail` je `ref:<reference>`, tentýž kód jako v `error_log`. |

## Záznam změn `cms_api_changes`

Každá cesta zápisu vytvoří jeden řádek: `change_id`, `resource` (`pages`, `menu`, `sections`, `boxes`, `articles` u API v2), `resource_id`, `action`, `before_data` a `after_data` (snímky JSON), `integration_id`, `central_actor`, `source`, `local_user_id` a `created_at`.

| `source` | Kdo zapsal | Aktér |
|----------|------------|-------|
| `v2` | API v2 (centrální Admin), ve stejné transakci jako změna obsahu | `integration_id` a `central_actor` |
| `v1` | Původní API: uživatelé, sekce, překlady, vyprázdnění cache | `local_user_id`, `integration_id` je 0 |
| `cli` | `bin/wbe user:create`, `user:password`, `user:delete` a `audit:prune` | `central_actor` je `cli:<uživatel operačního systému>`, `integration_id` je 0 |

Řádky `v1` a `cli` používají na rozdíl od množných názvů v2 jednotné číslo (`user`, `section`, `translation`, `cache`, `audit`), takže se nikdy neobjeví v historii `/changes` zdroje v2. Koncepty článků a obnovené verze jsou v `cms_api_revisions`: `revision_id`, `article_id`, `payload`, `action`, `integration_id`, `central_actor`, `created_at`. Revize, na kterou koncept stále odkazuje, se nikdy nesmaže.

## Co se neloguje

- Těla požadavků a odpovědí. Audit drží operaci a výsledek, záznam změn výsledná data.
- IP adresy. Existují jen v přístupovém logu webového serveru.
- Klíče API, tokeny a hesla. Změna hesla se zapíše jako `passwordChanged: true` a nic víc.
- Zobrazení veřejných stránek. Vlastní analytika (viz přehled nastavení) drží jen anonymní denní součty.

### Redakce

Řádky zapsané přes `v1` a `cli` se redigují: každý klíč nazvaný password, token, secret, key nebo hash (také `apiKey`, `key_hash`) se uloží jako `[redacted]`. Řádky `v2` ukládají data tak, jak přišla, protože je přehrává obnova struktury, proto nedávejte tajné hodnoty do obsahu stránek, menu ani článků.

## Kdo, co, kdy

Všechny hodnoty `created_at` jsou časy Unix. Příklady:

```sql
-- posledních 20 změn s tím, kdo a kdy
SELECT FROM_UNIXTIME(created_at) AS at, source, resource, resource_id, action,
       COALESCE(central_actor, local_user_id) AS actor, integration_id
FROM cms_api_changes ORDER BY change_id DESC LIMIT 20;

-- historie jednoho článku i s daty
SELECT FROM_UNIXTIME(created_at) AS at, action, central_actor, before_data, after_data
FROM cms_api_changes WHERE resource = ''articles'' AND resource_id = ''12'' ORDER BY change_id;

-- vše, co jeden redaktor udělal za posledních 7 dní
SELECT FROM_UNIXTIME(created_at) AS at, resource, resource_id, action
FROM cms_api_changes WHERE central_actor = ''anna@example.com'' AND created_at > UNIX_TIMESTAMP() - 7 * 86400;

-- odmítnutá a selhaná volání dnes a neúspěšné ověření
SELECT FROM_UNIXTIME(created_at) AS at, integration_id, central_actor, action, outcome, detail
FROM cms_api_audit WHERE outcome <> ''allowed'' AND created_at > UNIX_TIMESTAMP(CURDATE()) ORDER BY audit_id DESC;

-- jak často se které klíče používají
SELECT integration_id, outcome, COUNT(*) FROM cms_api_audit GROUP BY integration_id, outcome;
```

Z příkazové řádky vypíše `audit:list` poslední změny bez dat před a po:

```sh
php vendor/bin/wbengine.php audit:list --limit=50 --resource=articles --actor=anna@example.com --config=src/Config/Settings.json --root=src
```

`--limit` je 1 až 500 (výchozí 20), `--actor` odpovídá označení aktéra přesně, nebo místnímu ID uživatele, je-li číselné. Centrální Admin čte tatáž data přes HTTP, viz další část.

## Přehled změn přes HTTP

`GET /api/v2/changes` vrací záznam změn od nejnovějších, bez dat před a po. Vyžaduje HTTPS a integrační klíč s oprávněním `audit:read`. Centrální Admin přehled zobrazuje na stránce Aktivita webu, a to jen správcům webu. Klíč bez tohoto oprávnění je třeba nahradit novým klíčem.

Parametry dotazu: `page` a `per_page` (1 až 100, výchozí 25); filtry s přesnou shodou `resource`, `resource_id`, `action`, `source` (`v2`, `v1` nebo `cli`) a `actor`; `since` a `until` jako epoch sekundy. Neplatný filtr vrací 400. S `outcome=rejected` přehled místo toho vypíše odmítnuté a neúspěšné zápisy z `cms_api_audit` s kódem chyby v `detail`.

Každý záznam má `change_id`, `created_at`, `resource`, `resource_id`, `action`, `source`, `actor`, `integration_id` a `local_user_id`. Samotné čtení přehledu se zapisuje do auditní tabulky jako `changes.list`.

## Uchování a mazání

Nic se nemaže automaticky. Klíče v `Settings.json` (oba mají výchozí hodnotu 365, povoleno 30 až 3650, neplatná hodnota vyvolá chybu):

```json
"audit": { "retentionDays": 365, "revisionRetentionDays": 365 }
```

`audit.retentionDays` platí pro `cms_api_audit` a `cms_api_changes`, `audit.revisionRetentionDays` pro `cms_api_revisions`. Mazání spouštějte z cronu:

```cron
27 3 * * * www-data /usr/bin/php /var/www/wbengine-skeleton-app/vendor/bin/wbengine.php audit:prune --config=/var/www/wbengine-skeleton-app/src/Config/Settings.json --root=/var/www/wbengine-skeleton-app/src >> /var/log/wbengine-cron.log 2>&1
```

`audit:prune --dry-run` jen spočítá, `--days=N` přepíše oba klíče pro jedno spuštění. Nejnovější změna každého zdroje zůstává, ať je jakkoli stará (její id je součástí ETagu struktury a obnovy), stejně jako každá revize, na kterou odkazuje koncept. Každé skutečné spuštění se zapíše jako změna `cli` zdroje `audit`. V Dockeru spusťte příkaz z cronu na hostiteli jako `docker compose -f docker-compose.production.yml exec -T web php vendor/bin/wbengine.php audit:prune ...`.

## Příprava tabulek záznamu změn

Weby, které používají API v2, potřebují sloupce záznamu změn `source`, `local_user_id` a `detail` a indexy `created_at`. Jednou po záloze spusťte `sh bin/update-database.sh DATABASE`; lze ho bezpečně spustit znovu. `vendor/bin/wbengine.php doctor` hlásí neúspěšnou kontrolu, dokud sloupce neexistují; do té doby se přeskakují a nic jiného se nemění.

```sh
sh bin/update-database.sh wbengine_skeleton_app
docker compose -f docker-compose.production.yml exec -T web sh bin/update-database.sh --print \\
  | docker compose -f docker-compose.production.yml exec -T db sh -c ''MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot wbengine_skeleton_app''
```

První příkaz je pro databázi na hostiteli, druhý pro produkční Compose.

## Poznámky k soukromí

- Označení aktérů, řádky uživatelů a snímky obsahu mohou obsahovat osobní údaje, například e-mailové adresy a jména. Auditní tabulky berte jako osobní údaje: omezte přístup k databázi a zahrňte je do záznamů o zpracování.
- Zvolte uchování podle svých zásad a pamatujte, že zálohy databáze drží řádky déle, než říká nastavení.
- IP adresa žije jen v logách webového serveru. Jejich rotaci a uchování nastavte zvlášť (`logrotate`, volby logů Dockeru).
- Audit je stopa toho, kdo co udělal, nikoli toho, co návštěvníci četli: zobrazení veřejných stránek se po návštěvnících nezaznamenávají.', 'markdown'
WHERE @logging_article_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cms_article_translations WHERE article_id = @logging_article_id AND locale = 'cs');

INSERT INTO cms_boxes (name, module, method, section_id, static, shared, device_min, device_strict, acl, `order`, sites)
SELECT 'Docs: Logging and audit', 'docs', 'page', 1, 1, 0, 1, 0, 0, 0, JSON_ARRAY(CAST(@logging_site_id AS CHAR))
WHERE NOT EXISTS (SELECT 1 FROM cms_boxes WHERE name = 'Docs: Logging and audit');

-- Audit settings keys (framework 4.8.0) in the settings reference, audit:prune in the deployment cron section
-- and the framework migration 4.8.0/008 in the migration order (schemas/migrations/023-audit-settings-and-cron-docs.sql).
-- Each UPDATE runs only while its marker text is missing, so the migration is safe to rerun.
UPDATE cms_articles
SET bodytext = REPLACE(REPLACE(bodytext, '## Images and the API', '## Audit and change log

| Key | Type, default | Effect |
|-----|---------------|--------|
| `audit.retentionDays` | int, `365` | How long `cms_api_audit` and `cms_api_changes` rows are kept, 30 to 3650. Invalid values throw. |
| `audit.revisionRetentionDays` | int, `365` | How long `cms_api_revisions` (article draft history) are kept, 30 to 3650. |

Nothing is deleted automatically: run `audit:prune` from cron (`--dry-run` only counts, `--days=N` overrides both keys). The newest change of every resource and every revision a draft still uses are always kept. The tables need the change log columns (`sh bin/update-database.sh DATABASE`) when API v2 is enabled. What is recorded is described in [Logging and audit](/docs/logging/).

## Images and the API'), '  "googleAnalytics": { "measurementId": "" }
}', '  "audit": { "retentionDays": 365, "revisionRetentionDays": 365 },
  "googleAnalytics": { "measurementId": "" }
}')
WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/settings/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND LOCATE('## Audit and change log', bodytext) = 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(REPLACE(bodytext, '## Obrázky a API', '## Audit a záznam změn

| Klíč | Typ, výchozí hodnota | Účinek |
|------|----------------------|--------|
| `audit.retentionDays` | celé číslo, `365` | Jak dlouho se drží řádky `cms_api_audit` a `cms_api_changes`, 30 až 3650. Neplatná hodnota vyvolá chybu. |
| `audit.revisionRetentionDays` | celé číslo, `365` | Jak dlouho se drží `cms_api_revisions` (historie konceptů článků), 30 až 3650. |

Nic se nemaže automaticky: spouštějte `audit:prune` z cronu (`--dry-run` jen počítá, `--days=N` přepíše oba klíče). Nejnovější změna každého zdroje a každá revize, kterou koncept ještě používá, se vždy ponechá. Při zapnutém API v2 tabulky vyžadují sloupce záznamu změn (`sh bin/update-database.sh DATABASE`). Co se zaznamenává, popisuje [Logování a audit](/cs/docs/logging/).

## Obrázky a API'), '  "googleAnalytics": { "measurementId": "" }
}', '  "audit": { "retentionDays": 365, "revisionRetentionDays": 365 },
  "googleAnalytics": { "measurementId": "" }
}')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/settings/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND locale = 'cs'
  AND LOCATE('## Audit a záznam změn', bodytext) = 0;

UPDATE cms_articles
SET bodytext = REPLACE(REPLACE(bodytext, 'sh bin/update-database.sh wbengine_skeleton_app
```

The script applies the same framework updates as the Docker installer and is safe to run again.', 'sh bin/update-database.sh wbengine_skeleton_app
```

The script applies the same framework updates as the Docker installer and is safe to run again. The change log columns are required for sites that use API v2: `doctor` fails without them.'), 'The job reads the same environment secrets, so run it as the web user with the same variables (for example by sourcing a root-owned file in the crontab line).', 'The job reads the same environment secrets, so run it as the web user with the same variables (for example by sourcing a root-owned file in the crontab line). The change log and audit tables also need daily pruning (`audit.retentionDays`, see [Logging and audit](/docs/logging/)):

```cron
27 3 * * * www-data /usr/bin/php /var/www/wbengine-skeleton-app/vendor/bin/wbengine.php audit:prune --config=/var/www/wbengine-skeleton-app/src/Config/Settings.json --root=/var/www/wbengine-skeleton-app/src >> /var/log/wbengine-cron.log 2>&1
```')
WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/deployment/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND LOCATE('4.8.0/008-change-log-source.sql', bodytext) = 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(REPLACE(bodytext, 'sh bin/update-database.sh wbengine_skeleton_app
```

Skript použije stejné aktualizace frameworku jako instalátor pro Docker a lze ho bezpečně spustit znovu.', 'sh bin/update-database.sh wbengine_skeleton_app
```

Skript použije stejné aktualizace frameworku jako instalátor pro Docker a lze ho bezpečně spustit znovu. Sloupce záznamu změn jsou nutné pro weby s API v2: bez nich `doctor` selže.'), 'Úloha čte stejné tajné hodnoty z prostředí, proto ji spouštějte pod webovým uživatelem se stejnými proměnnými (například načtením souboru vlastněného rootem v řádku crontabu).', 'Úloha čte stejné tajné hodnoty z prostředí, proto ji spouštějte pod webovým uživatelem se stejnými proměnnými (například načtením souboru vlastněného rootem v řádku crontabu). Tabulky záznamu změn a auditu je také třeba denně mazat (`audit.retentionDays`, viz [Logování a audit](/cs/docs/logging/)):

```cron
27 3 * * * www-data /usr/bin/php /var/www/wbengine-skeleton-app/vendor/bin/wbengine.php audit:prune --config=/var/www/wbengine-skeleton-app/src/Config/Settings.json --root=/var/www/wbengine-skeleton-app/src >> /var/log/wbengine-cron.log 2>&1
```')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/deployment/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND locale = 'cs'
  AND LOCATE('4.8.0/008-change-log-source.sql', bodytext) = 0;


-- Integrations page setup command (schemas/migrations/028-integrations-install-docs.sql).
UPDATE cms_articles
SET bodytext = REPLACE(bodytext, 'Typical problems and their meaning:', 'A site that does not have the integrations page yet gets it with one command, run in the site directory: `vendor/bin/wbengine.php integrations:install --root=src --config=src/Config/Settings.json`. Without further options it only lists what it would create. With `--apply` it creates the application class, the page `/integrations/` (for signed-in users only), the section and the box record. Existing records and files are never changed, so the command can be run again. It also lists what still prevents issuing a key, for example API v2 being disabled or missing database updates.

Typical problems and their meaning:')
WHERE LOCATE('Typical problems and their meaning:', bodytext) > 0 AND LOCATE('integrations:install', bodytext) = 0;

UPDATE cms_articles
SET bodytext = REPLACE(bodytext, 'Typické potíže a jejich význam:', 'Web, který stránku integrací ještě nemá, ji získá jedním příkazem spuštěným v adresáři webu: `vendor/bin/wbengine.php integrations:install --root=src --config=src/Config/Settings.json`. Bez dalších voleb jen vypíše, co by vytvořil. S volbou `--apply` vytvoří aplikační třídu, stránku `/integrations/` (jen pro přihlášené), sekci a záznam boxu. Existující záznamy a soubory nikdy nemění, takže příkaz lze spustit opakovaně. Vypíše také, co ještě brání vydání klíče, například vypnuté API v2 nebo chybějící databázové aktualizace.

Typické potíže a jejich význam:')
WHERE LOCATE('Typické potíže a jejich význam:', bodytext) > 0 AND LOCATE('integrations:install', bodytext) = 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, 'Typical problems and their meaning:', 'A site that does not have the integrations page yet gets it with one command, run in the site directory: `vendor/bin/wbengine.php integrations:install --root=src --config=src/Config/Settings.json`. Without further options it only lists what it would create. With `--apply` it creates the application class, the page `/integrations/` (for signed-in users only), the section and the box record. Existing records and files are never changed, so the command can be run again. It also lists what still prevents issuing a key, for example API v2 being disabled or missing database updates.

Typical problems and their meaning:')
WHERE LOCATE('Typical problems and their meaning:', bodytext) > 0 AND LOCATE('integrations:install', bodytext) = 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, 'Typické potíže a jejich význam:', 'Web, který stránku integrací ještě nemá, ji získá jedním příkazem spuštěným v adresáři webu: `vendor/bin/wbengine.php integrations:install --root=src --config=src/Config/Settings.json`. Bez dalších voleb jen vypíše, co by vytvořil. S volbou `--apply` vytvoří aplikační třídu, stránku `/integrations/` (jen pro přihlášené), sekci a záznam boxu. Existující záznamy a soubory nikdy nemění, takže příkaz lze spustit opakovaně. Vypíše také, co ještě brání vydání klíče, například vypnuté API v2 nebo chybějící databázové aktualizace.

Typické potíže a jejich význam:')
WHERE LOCATE('Typické potíže a jejich význam:', bodytext) > 0 AND LOCATE('integrations:install', bodytext) = 0;


-- API v2 is the only API (schemas/migrations/029-api-v2-only-docs.sql).
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'The framework brings `firebase/php-jwt`; its template engine and Markdown parser are included.', 'The framework has no further Composer dependencies; its template engine and Markdown parser are included.') WHERE LOCATE('The framework brings `firebase/php-jwt`; its template engine and Markdown parser are included.', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'generates private database and JWT secrets on the server', 'generates private database passwords on the server') WHERE LOCATE('generates private database and JWT secrets on the server', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'which also invalidates the user''s refresh tokens.', 'which also ends the user''s web sessions.') WHERE LOCATE('which also invalidates the user''s refresh tokens.', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'Keep `Settings.json`, JWT keys, passwords, and private keys', 'Keep `Settings.json`, passwords, and private keys') WHERE LOCATE('Keep `Settings.json`, JWT keys, passwords, and private keys', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'creates it from `src/Config/settings.json.default` with fresh JWT keys.', 'creates it from `src/Config/settings.json.default`.') WHERE LOCATE('creates it from `src/Config/settings.json.default` with fresh JWT keys.', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`, `WBENGINE_DEBUG`', '`WBENGINE_RECAPTCHA_SECRET`, `WBENGINE_DEBUG`') WHERE LOCATE('`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`, `WBENGINE_DEBUG`', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '(`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`)', '(`WBENGINE_RECAPTCHA_SECRET`)') WHERE LOCATE('(`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`)', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '  "jwt": { "accessKey": "", "refreshKey": "" },
', '') WHERE LOCATE('  "jwt": { "accessKey": "", "refreshKey": "" },
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'Leaving `jwt` empty in the file is only valid when both JWT variables are set in the environment of PHP, including the cron user and the container. Without them, put real random keys in the file. Where each', 'Where each') WHERE LOCATE('Leaving `jwt` empty in the file is only valid when both JWT variables are set in the environment of PHP, including the cron user and the container. Without them, put real random keys in the file. Where each', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'with fresh random JWT keys when the file is missing', 'when the file is missing') WHERE LOCATE('with fresh random JWT keys when the file is missing', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY` (at least 32 characters each, `openssl rand -hex 32`), `WBENGINE_RECAPTCHA_SECRET`', '`WBENGINE_RECAPTCHA_SECRET`') WHERE LOCATE('`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY` (at least 32 characters each, `openssl rand -hex 32`), `WBENGINE_RECAPTCHA_SECRET`', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'env[WBENGINE_JWT_KEY] = "..."
env[WBENGINE_JWT_REFRESH_KEY] = "..."', 'env[WBENGINE_RECAPTCHA_SECRET] = "..."') WHERE LOCATE('env[WBENGINE_JWT_KEY] = "..."
env[WBENGINE_JWT_REFRESH_KEY] = "..."', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '-e WBENGINE_JWT_KEY="..." -e WBENGINE_JWT_REFRESH_KEY="..." \\', '-e WBENGINE_RECAPTCHA_SECRET="..." \\') WHERE LOCATE('-e WBENGINE_JWT_KEY="..." -e WBENGINE_JWT_REFRESH_KEY="..." \\', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'Flush the cache with `POST /api/cache/flush` (administrator)', 'Flush the cache with `POST /api/v2/cache/flush` (an integration key with the `cache:write` scope, for example from the central administration)') WHERE LOCATE('Flush the cache with `POST /api/cache/flush` (administrator)', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '| `v1` | Legacy API: users, sections, translations, cache flush |', '| `v1` | Older entries written by a retired interface (no new ones) |') WHERE LOCATE('| `v1` | Legacy API: users, sections, translations, cache flush |', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '| `jwt.accessKey`, `jwt.refreshKey` | string, `CHANGE_ME` | Signing keys of login and API tokens, at least 32 characters and different. Overridden by `WBENGINE_JWT_KEY` and `WBENGINE_JWT_REFRESH_KEY`. Generate with `openssl rand -hex 32`. |
', '') WHERE LOCATE('| `jwt.accessKey`, `jwt.refreshKey` | string, `CHANGE_ME` | Signing keys of login and API tokens, at least 32 characters and different. Overridden by `WBENGINE_JWT_KEY` and `WBENGINE_JWT_REFRESH_KEY`. Generate with `openssl rand -hex 32`. |
', bodytext) > 0;
UPDATE cms_articles SET bodytext = '## The API

The **API v2** under `/api/v2` is the integration interface for trusted servers such as the separate central administration. It uses an issued integration key and scopes, HTTPS, finite resource and field allowlists, strong ETags for edits and audit records. It does not expose its key to browser JavaScript and does not enable browser CORS. It covers content, structure, users, translations, the cache flush and the change log. There is no login through the API: people sign in on the web at `/login/`.

Do not send an integration key from a user browser. The browser should call its own application server, which then contacts each WBengine site over verified HTTPS.

## API example

```bash
curl -H ''Authorization: Bearer <integration key>'' \\
  https://example.com/api/v2/identity
```

An administrator issues the key on the `/integrations/` page of the site.

## Keys and scopes

A key carries scopes that decide what it may do. A missing or invalid key returns `401`; a key without the required scope receives `403`. Write routes validate allowed fields.

For deployment diagnostics use `vendor/bin/wbengine.php doctor`; it does not change the schema. API v2 is enabled separately in application configuration and needs its database tables for protected content operations (see the Deployment page). Its discovery, capabilities, resources, scopes and concurrency rules are described in the [WBengine API v2 reference](https://github.com/rrsoftcz/wbengine/blob/main/ref-api-v2.md). See also the [central administration guide](/docs/administration/).' WHERE id = 9 AND LOCATE('/api/auth/login', bodytext) > 0;

UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'Framework přináší `firebase/php-jwt`; template engine i parser Markdownu jsou jeho součástí.', 'Framework nemá další závislosti v Composeru; template engine i parser Markdownu jsou jeho součástí.') WHERE LOCATE('Framework přináší `firebase/php-jwt`; template engine i parser Markdownu jsou jeho součástí.', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'na serveru vytvoří soukromé databázové a JWT klíče', 'na serveru vytvoří soukromá hesla databáze') WHERE LOCATE('na serveru vytvoří soukromé databázové a JWT klíče', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'který zároveň zneplatní refresh tokeny uživatele', 'který zároveň ukončí webové relace uživatele') WHERE LOCATE('který zároveň zneplatní refresh tokeny uživatele', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '`Settings.json`, JWT klíče, hesla ani privátní klíče', '`Settings.json`, hesla ani privátní klíče') WHERE LOCATE('`Settings.json`, JWT klíče, hesla ani privátní klíče', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'ho vytvoří ze `src/Config/settings.json.default` s novými klíči JWT.', 'ho vytvoří ze `src/Config/settings.json.default`.') WHERE LOCATE('ho vytvoří ze `src/Config/settings.json.default` s novými klíči JWT.', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`, `WBENGINE_DEBUG`', '`WBENGINE_RECAPTCHA_SECRET`, `WBENGINE_DEBUG`') WHERE LOCATE('`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`, `WBENGINE_DEBUG`', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '(`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`)', '(`WBENGINE_RECAPTCHA_SECRET`)') WHERE LOCATE('(`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`)', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '  "jwt": { "accessKey": "", "refreshKey": "" },
', '') WHERE LOCATE('  "jwt": { "accessKey": "", "refreshKey": "" },
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'Prázdné `jwt` v souboru platí jen tehdy, když jsou obě proměnné JWT nastavené v prostředí PHP, včetně uživatele cronu a kontejneru. Jinak do souboru vložte skutečné náhodné klíče. Kde co', 'Kde co') WHERE LOCATE('Prázdné `jwt` v souboru platí jen tehdy, když jsou obě proměnné JWT nastavené v prostředí PHP, včetně uživatele cronu a kontejneru. Jinak do souboru vložte skutečné náhodné klíče. Kde co', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 's novými náhodnými klíči JWT, pokud soubor chybí', 'pokud soubor chybí') WHERE LOCATE('s novými náhodnými klíči JWT, pokud soubor chybí', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY` (každý nejméně 32 znaků, `openssl rand -hex 32`), `WBENGINE_RECAPTCHA_SECRET`', '`WBENGINE_RECAPTCHA_SECRET`') WHERE LOCATE('`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY` (každý nejméně 32 znaků, `openssl rand -hex 32`), `WBENGINE_RECAPTCHA_SECRET`', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'env[WBENGINE_JWT_KEY] = "..."
env[WBENGINE_JWT_REFRESH_KEY] = "..."', 'env[WBENGINE_RECAPTCHA_SECRET] = "..."') WHERE LOCATE('env[WBENGINE_JWT_KEY] = "..."
env[WBENGINE_JWT_REFRESH_KEY] = "..."', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '-e WBENGINE_JWT_KEY="..." -e WBENGINE_JWT_REFRESH_KEY="..." \\', '-e WBENGINE_RECAPTCHA_SECRET="..." \\') WHERE LOCATE('-e WBENGINE_JWT_KEY="..." -e WBENGINE_JWT_REFRESH_KEY="..." \\', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'voláním `POST /api/cache/flush` (správce)', 'voláním `POST /api/v2/cache/flush` (integrační klíč s oprávněním `cache:write`, například z centrální administrace)') WHERE LOCATE('voláním `POST /api/cache/flush` (správce)', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '| `v1` | Původní API: uživatelé, sekce, překlady, vyprázdnění cache |', '| `v1` | Starší záznamy zapsané již zrušeným rozhraním (nové nevznikají) |') WHERE LOCATE('| `v1` | Původní API: uživatelé, sekce, překlady, vyprázdnění cache |', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '| `jwt.accessKey`, `jwt.refreshKey` | řetězec, `CHANGE_ME` | Podpisové klíče přihlášení a tokenů API, nejméně 32 znaků a navzájem různé. Přepíší je `WBENGINE_JWT_KEY` a `WBENGINE_JWT_REFRESH_KEY`. Vygenerujte je příkazem `openssl rand -hex 32`. |
', '') WHERE LOCATE('| `jwt.accessKey`, `jwt.refreshKey` | řetězec, `CHANGE_ME` | Podpisové klíče přihlášení a tokenů API, nejméně 32 znaků a navzájem různé. Přepíší je `WBENGINE_JWT_KEY` a `WBENGINE_JWT_REFRESH_KEY`. Vygenerujte je příkazem `openssl rand -hex 32`. |
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = '## API

**API v2** pod `/api/v2` je integrační rozhraní pro důvěryhodné servery, například samostatnou centrální administraci. Používá vydaný integrační klíč a scopes, HTTPS, konečný seznam zdrojů a polí, silné ETagy pro zápis a audit. Klíč se neposílá do JavaScriptu prohlížeče a API nezapíná CORS. Pokrývá obsah, strukturu, uživatele, překlady, vyprázdnění cache a záznam změn. Přihlášení přes API neexistuje: lidé se přihlašují na webu na `/login/`.

Integrační klíč neposílejte z prohlížeče. Prohlížeč má volat vlastní aplikační server, který se potom přes ověřené HTTPS připojí ke každému webu WBengine.

## Příklad API

```bash
curl -H ''Authorization: Bearer <integrační klíč>'' \\
  https://example.com/api/v2/identity
```

Klíč vydá administrátor na stránce `/integrations/` webu.

## Klíče a scopes

Klíč nese scopes, které určují, co smí. Chybějící či neplatný klíč vrací `401`; klíč bez potřebného scope dostane `403`. Zapisovací cesty kontrolují povolená pole.

Pro diagnostiku nasazení použijte `vendor/bin/wbengine.php doctor`; příkaz schéma nemění. API v2 se zapíná samostatně v konfiguraci a pro chráněné obsahové operace vyžaduje své databázové tabulky (viz stránka Nasazení). Discovery, capabilities, zdroje, scopes a pravidla souběžných změn popisuje [referenční dokumentace WBengine API v2](https://github.com/rrsoftcz/wbengine/blob/main/ref-api-v2.md). Viz také [centrální administrace](/cs/docs/administration/).' WHERE article_id = 9 AND locale = 'cs' AND LOCATE('/api/auth/login', bodytext) > 0;

DELETE FROM cms_boxes WHERE module = 'demo' AND method = 'api';
DELETE FROM cms_boxes WHERE module = 'restapi' AND method = 'restapi';
DELETE FROM cms_sites WHERE link = '/api/';
DELETE FROM cms_sections WHERE `key` = 'api';

-- Public documentation follows WBengine 5 (schemas/migrations/030-framework-5-docs.sql).
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '- PHP 8.3 or newer with `mysqli` and the extensions required by Composer dependencies.', '- PHP 8.3 or newer with the extensions `mysqli`, `json` and `mbstring`.') WHERE id = 2 AND LOCATE('- PHP 8.3 or newer with `mysqli` and the extensions required by Composer dependencies.', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '- PHP 8.3 nebo novější s rozšířením `mysqli` a rozšířeními vyžadovanými Composer balíčky.', '- PHP 8.3 nebo novější s rozšířeními `mysqli`, `json` a `mbstring`.') WHERE article_id = 2 AND locale = 'cs' AND LOCATE('- PHP 8.3 nebo novější s rozšířením `mysqli` a rozšířeními vyžadovanými Composer balíčky.', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'Markdown, templates, locales, caching, the legacy CMS API and the separate server-to-server API v2 are described', 'Markdown, templates, locales, caching and the server-to-server API v2 are described') WHERE id = 3 AND LOCATE('Markdown, templates, locales, caching, the legacy CMS API and the separate server-to-server API v2 are described', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'the API cache-flush endpoint requires an administrator token.', 'the API v2 cache flush (`POST /api/v2/cache/flush`) needs an integration key with the `cache:write` scope.') WHERE id = 7 AND LOCATE('the API cache-flush endpoint requires an administrator token.', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'API endpoint pro vyprázdnění vyžaduje administrátorský token.', 'vyprázdnění cache přes API v2 (`POST /api/v2/cache/flush`) vyžaduje integrační klíč s oprávněním `cache:write`.') WHERE article_id = 7 AND locale = 'cs' AND LOCATE('API endpoint pro vyprázdnění vyžaduje administrátorský token.', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'and restrict API routes by role.', 'and issue integration keys only with the scopes they need.') WHERE id = 8 AND LOCATE('and restrict API routes by role.', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'a API chráníte podle rolí.', 'a integrační klíče vydávejte jen s oprávněními, která potřebují.') WHERE article_id = 8 AND locale = 'cs' AND LOCATE('a API chráníte podle rolí.', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'blob/main/ref-api-v2.md', 'blob/master/ref-api-v2.md') WHERE id = 9 AND LOCATE('blob/main/ref-api-v2.md', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'blob/main/ref-api-v2.md', 'blob/master/ref-api-v2.md') WHERE article_id = 9 AND locale = 'cs' AND LOCATE('blob/main/ref-api-v2.md', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '(`capabilities` and `identity`, all 17 scopes of the Site management profile)', '(`capabilities` and `identity`, and the permissions of the Site management profile)') WHERE id = 10 AND LOCATE('(`capabilities` and `identity`, all 17 scopes of the Site management profile)', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '(`capabilities` a `identity`, všech 17 oprávnění profilu Správa webu)', '(`capabilities` a `identity` i oprávnění profilu Správa webu)') WHERE article_id = 10 AND locale = 'cs' AND LOCATE('(`capabilities` a `identity`, všech 17 oprávnění profilu Správa webu)', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'Both pages need an integration key issued with the matching permissions; a key without them asks to be replaced.', 'Both pages need an integration key issued with the matching permissions; a key without them asks to be replaced.

The **Activity** page lists the changes made on the site (who changed what and when) from its change log, read only. It needs the `audit:read` permission. The interface of the central administration is available in English, Czech, German and Polish, and each person chooses the language in their profile.') WHERE id = 10 AND LOCATE('Both pages need an integration key issued with the matching permissions; a key without them asks to be replaced.', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'Obě stránky vyžadují integrační klíč vydaný s odpovídajícími oprávněními; klíč bez nich vyzve k výměně.', 'Obě stránky vyžadují integrační klíč vydaný s odpovídajícími oprávněními; klíč bez nich vyzve k výměně.

Stránka **Aktivita** pouze pro čtení vypisuje změny provedené na webu (kdo co a kdy změnil) z jeho záznamu změn. Vyžaduje oprávnění `audit:read`. Rozhraní centrální administrace je dostupné v angličtině, češtině, němčině a polštině a každý si jazyk volí ve svém profilu.') WHERE article_id = 10 AND locale = 'cs' AND LOCATE('Obě stránky vyžadují integrační klíč vydaný s odpovídajícími oprávněními; klíč bez nich vyzve k výměně.', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '(`POST /api/cache/flush`)', '(`POST /api/v2/cache/flush`, an integration key with the `cache:write` scope)') WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/settings/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a) AND LOCATE('(`POST /api/cache/flush`)', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '(`POST /api/cache/flush`)', '(`POST /api/v2/cache/flush`, integrační klíč s oprávněním `cache:write`)') WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/settings/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a) AND locale = 'cs' AND LOCATE('(`POST /api/cache/flush`)', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'Container images are published as `ghcr.io/rrsoftcz/wbengine-skeleton-app` tagged with the version (`1.2.3`, `1.2`) and `latest`. The image contains the code and the production Composer dependencies and no secrets. Pull and run it with `Settings.json` mounted read-only and a volume for the compiled templates:', '`Dockerfile.production` builds the production image: the code and the production Composer dependencies, no secrets. Build it, then run it with `Settings.json` mounted read-only and a volume for the compiled templates:') WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/deployment/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a) AND LOCATE('Container images are published as `ghcr.io/rrsoftcz/wbengine-skeleton-app` tagged with the version (`1.2.3`, `1.2`) and `latest`. The image contains the code and the production Composer dependencies and no secrets. Pull and run it with `Settings.json` mounted read-only and a volume for the compiled templates:', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'docker pull ghcr.io/rrsoftcz/wbengine-skeleton-app:1.2.3
', 'docker build -f Dockerfile.production -t wbengine-skeleton-app:1.2.3 .
') WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/deployment/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a) AND LOCATE('docker pull ghcr.io/rrsoftcz/wbengine-skeleton-app:1.2.3
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '  ghcr.io/rrsoftcz/wbengine-skeleton-app:1.2.3
', '  wbengine-skeleton-app:1.2.3
') WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/deployment/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a) AND LOCATE('  ghcr.io/rrsoftcz/wbengine-skeleton-app:1.2.3
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'Pin a version tag in production rather than `latest`.', 'Tag every build with a version and run that tag in production rather than `latest`.') WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/deployment/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a) AND LOCATE('Pin a version tag in production rather than `latest`.', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'To update, pull the new tag, apply the database updates,', 'To update, build the new tag, apply the database updates,') WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/deployment/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a) AND LOCATE('To update, pull the new tag, apply the database updates,', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'Image kontejneru se publikuje jako `ghcr.io/rrsoftcz/wbengine-skeleton-app` se značkami verze (`1.2.3`, `1.2`) a `latest`. Image obsahuje kód a produkční závislosti Composeru a žádná tajemství. Stáhněte a spusťte ho s `Settings.json` připojeným jen pro čtení a svazkem pro zkompilované šablony:', '`Dockerfile.production` sestaví produkční image: kód a produkční závislosti Composeru, žádná tajemství. Sestavte ho a spusťte s `Settings.json` připojeným jen pro čtení a svazkem pro zkompilované šablony:') WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/deployment/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a) AND locale = 'cs' AND LOCATE('Image kontejneru se publikuje jako `ghcr.io/rrsoftcz/wbengine-skeleton-app` se značkami verze (`1.2.3`, `1.2`) a `latest`. Image obsahuje kód a produkční závislosti Composeru a žádná tajemství. Stáhněte a spusťte ho s `Settings.json` připojeným jen pro čtení a svazkem pro zkompilované šablony:', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'docker pull ghcr.io/rrsoftcz/wbengine-skeleton-app:1.2.3
', 'docker build -f Dockerfile.production -t wbengine-skeleton-app:1.2.3 .
') WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/deployment/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a) AND locale = 'cs' AND LOCATE('docker pull ghcr.io/rrsoftcz/wbengine-skeleton-app:1.2.3
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '  ghcr.io/rrsoftcz/wbengine-skeleton-app:1.2.3
', '  wbengine-skeleton-app:1.2.3
') WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/deployment/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a) AND locale = 'cs' AND LOCATE('  ghcr.io/rrsoftcz/wbengine-skeleton-app:1.2.3
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'V produkci připněte značku verze, ne `latest`.', 'Každý build označte verzí a v produkci spouštějte tuto značku, ne `latest`.') WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/deployment/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a) AND locale = 'cs' AND LOCATE('V produkci připněte značku verze, ne `latest`.', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'Při aktualizaci stáhněte novou značku,', 'Při aktualizaci sestavte novou značku,') WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/deployment/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a) AND locale = 'cs' AND LOCATE('Při aktualizaci stáhněte novou značku,', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '`resource` (`pages`, `menu`, `sections`, `boxes`, `articles` for API v2)', '`resource` (`pages`, `menu`, `sections`, `boxes` and `articles` for content, `user`, `cache` and `audit` for the other operations)') WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/logging/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a) AND LOCATE('`resource` (`pages`, `menu`, `sections`, `boxes`, `articles` for API v2)', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '`resource` (`pages`, `menu`, `sections`, `boxes`, `articles` u API v2)', '`resource` (`pages`, `menu`, `sections`, `boxes` a `articles` u obsahu, `user`, `cache` a `audit` u ostatních operací)') WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/logging/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a) AND locale = 'cs' AND LOCATE('`resource` (`pages`, `menu`, `sections`, `boxes`, `articles` u API v2)', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'Rows of `v1` and `cli` use singular resource names (v2 uses plural ones) (`user`, `section`, `translation`, `cache`, `audit`), so they never show up in the `/changes` history of a v2 resource.', 'Content resources use plural names (`pages`, `menu`, `sections`, `boxes`, `articles`); users, the cache flush and audit pruning use the singular names `user`, `cache` and `audit`, so they never show up in the `/changes` history of a content resource.') WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/logging/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a) AND LOCATE('Rows of `v1` and `cli` use singular resource names (v2 uses plural ones) (`user`, `section`, `translation`, `cache`, `audit`), so they never show up in the `/changes` history of a v2 resource.', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'Řádky `v1` a `cli` používají na rozdíl od množných názvů v2 jednotné číslo (`user`, `section`, `translation`, `cache`, `audit`), takže se nikdy neobjeví v historii `/changes` zdroje v2.', 'Obsahové zdroje mají množná čísla (`pages`, `menu`, `sections`, `boxes`, `articles`); uživatelé, vyprázdnění cache a mazání záznamů používají jednotná čísla `user`, `cache` a `audit`, takže se nikdy neobjeví v historii `/changes` obsahového zdroje.') WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/logging/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a) AND locale = 'cs' AND LOCATE('Řádky `v1` a `cli` používají na rozdíl od množných názvů v2 jednotné číslo (`user`, `section`, `translation`, `cache`, `audit`), takže se nikdy neobjeví v historii `/changes` zdroje v2.', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'Rows written by `v1` and `cli` are redacted:', 'Rows written by `cli` (and older `v1` rows) are redacted:') WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/logging/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a) AND LOCATE('Rows written by `v1` and `cli` are redacted:', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'Řádky zapsané přes `v1` a `cli` se redigují:', 'Řádky zapsané přes `cli` (a starší řádky `v1`) se redigují:') WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/logging/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a) AND locale = 'cs' AND LOCATE('Řádky zapsané přes `v1` a `cli` se redigují:', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = '## Strom objektů

- **Application** je kořen jednoho HTTP požadavku. Načítá konfiguraci a poskytuje sdílené služby, například přístup k databázi, směrování, autentizaci, vykreslování, Markdown a cache. Služby se vytvářejí líně, až když jsou potřeba.
- **Site** je stránka vybraná pro aktuální URL. Nese řádek webu, jazyk, přístupová pravidla, metadata a kontext navigace.
- **Section** je pojmenovaná oblast layoutu stránky, například `header`, `central` nebo `footer`.
- **Box** je malá komponenta aplikace vybraná řádkem v `cms_boxes`. Nastavený modul a metoda určují třídu v jmenném prostoru aplikace, například `App\\Box\\Central\\Docs`.
- **Model** obsahuje opakovaně použitelný přístup k datům pro box. Používá databázovou vrstvu frameworku a vázané parametry SQL.
- **Renderer a šablona** mění data boxu na výstup. Šablony používají renderer frameworku; strom objektů PHP nenahrazují.

Rodičovské odkazy jsou skutečné odkazy na objekty: box se dostane ke své sekci, webu i aplikaci bez dalšího globálního kontejneru. Nové funkce PHP držte ve stávajícím stromu a jmenných prostorech. Do šablon nedávejte přihlašovací údaje ani databázovou logiku.

## Jeden požadavek od URL po HTML

```text
public/index.php
  načte Composer a bootstrap aplikace
  Application obslouží explicitní trasu aplikace nebo zapnuté API
  určí jazyk a přiřadí požadavek ke Site
  zkontroluje přístup a zda může odpovědět bezpečná cache celé stránky
  načte aktivní Section pro Site
    přečte nakonfigurované Box každé Section
      vytvoří Box ve svém jmenném prostoru s rodičovskými objekty
      Box zavolá Model, když potřebuje obsah z databáze
      Renderer zpracuje soubor .tpl nebo zdroj obsahu .md
  složí výstupy sekcí v layoutu webu
  vrátí odpověď HTTP a volitelně uloží bezpečnou veřejnou kopii stránky
```

Přesné brány směrování a cache závisejí na nastavení aplikace. Framework řeší přiřazení, přístup a vykreslování; aplikační třídy určují, co každý box dělá.

## Co je v databázi a co v PHP

`cms_sites` popisuje URL a metadata stránek. `cms_sections` definuje oblasti layoutu. `cms_boxes` připojuje modul a metodu k sekci, řídí pořadí a umí označit box jako sdílený. Tabulky článků, menu a překladů drží upravitelný obsah. PHP třídy poskytují chování, modely čtou data a šablony je zobrazují. Existující box lze často připojit k novému webu jen daty; nové chování vyžaduje třídu boxu v aplikaci.

## Jak web rozšířit

Pro stránku jen s obsahem použijte existující článek nebo registrovaný box a nastavte řádky webu, sekce a boxu. Pro nové chování přidejte třídu pod `App\\Box\\<Section>`, rozšiřte `Wbengine\\Box\\WbengineBoxAbstract` a používejte její rodičovské přístupové metody. Opakovaně použitelné dotazy dejte do modelu a vykreslete zdroj `.tpl` nebo `.md`. Průvodce [Boxy](/cs/docs/boxes/) ukazuje kód i mapování na databázi.

Markdown, šablony, jazyky, cache a serverové integrační API v2 jsou popsány ve vlastních průvodcích. Volitelná [centrální administrace](/cs/docs/administration/) je samostatná aplikace připojená přes API v2; není součástí stromu požadavku PHP ani balíčku Composeru.' WHERE article_id = 3 AND locale = 'cs' AND LOCATE('nebo `api`.', bodytext) > 0;
UPDATE cms_sites SET html_description = REPLACE(html_description, 'caching and a REST API.', 'caching and an API for integrations.') WHERE link = '/' AND LOCATE('caching and a REST API.', html_description) > 0;
UPDATE cms_site_translations SET html_description = REPLACE(html_description, 'cache a REST API.', 'cache a API pro integrace.') WHERE locale = 'cs' AND site_id = (SELECT site_id FROM cms_sites WHERE link = '/') AND LOCATE('cache a REST API.', html_description) > 0;
UPDATE cms_sites SET title = 'API', html_title = 'API', html_description = 'The server-to-server API v2 with integration keys, scopes and an audit trail.', html_keywords = 'api,integration,scopes' WHERE link = '/docs/rest-api/' AND title = 'REST API';
UPDATE cms_site_translations SET title = 'API', html_title = 'API', html_description = 'Serverové integrační API v2 s klíči, oprávněními a auditem.', html_keywords = 'api,integrace,scopes' WHERE locale = 'cs' AND title = 'REST API' AND site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/rest-api/');
UPDATE cms_articles SET title = 'API' WHERE id = 9 AND title = 'REST API';
UPDATE cms_article_translations SET title = 'API' WHERE article_id = 9 AND locale = 'cs' AND title = 'REST API';

-- Permission groups of an integration key (schemas/migrations/031-key-groups-docs.sql).
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '2. Confirm your password, keep the suggested name and issue the key.', '2. Choose the permission groups the key may use (Content, Publishing, Structure, Images, Site administration, History and optionally Analytics; the default grants all of them), confirm your password, keep the suggested name and issue the key.') WHERE LOCATE('2. Confirm your password, keep the suggested name and issue the key.', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '(`capabilities` and `identity`, and the permissions of the Site management profile)', '(`capabilities` and `identity`, and that the key allows at least one permission group)') WHERE LOCATE('(`capabilities` and `identity`, and the permissions of the Site management profile)', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'With `--apply` it creates the application class, the page `/integrations/` (for signed-in users only), the section and the box record. Existing records and files are never changed,', 'With `--apply` it creates the page `/integrations/` (for signed-in users only), the section and the box record. No class in the application is needed: the box ships with the framework. Existing records are never changed,') WHERE LOCATE('With `--apply` it creates the application class, the page `/integrations/` (for signed-in users only), the section and the box record. Existing records and files are never changed,', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '`vendor/bin/wbengine.php integrations:install --root=src --config=src/Config/Settings.json`', '`vendor/bin/wbengine.php integrations:install --config=src/Config/Settings.json`') WHERE LOCATE('`vendor/bin/wbengine.php integrations:install --root=src --config=src/Config/Settings.json`', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '- *The key lacks permissions*: issue the key again with the full Site management profile.', '- *The key does not allow anything the Admin can manage*: issue a new key with at least one permission group. A page the key does not cover asks for a new key with the missing group.') WHERE LOCATE('- *The key lacks permissions*: issue the key again with the full Site management profile.', bodytext) > 0;

UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '2. Potvrďte heslo, ponechte navržený název a vydejte klíč.', '2. Zvolte skupiny oprávnění, které smí klíč používat (Obsah, Publikování, Struktura, Obrázky, Správa webu, Historie a volitelně Analytika; výchozí volba povolí všechny), potvrďte heslo, ponechte navržený název a vydejte klíč.') WHERE LOCATE('2. Potvrďte heslo, ponechte navržený název a vydejte klíč.', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '(`capabilities` a `identity` i oprávnění profilu Správa webu)', '(`capabilities` a `identity` a že klíč povoluje alespoň jednu skupinu oprávnění)') WHERE LOCATE('(`capabilities` a `identity` i oprávnění profilu Správa webu)', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'S volbou `--apply` vytvoří aplikační třídu, stránku `/integrations/` (jen pro přihlášené), sekci a záznam boxu. Existující záznamy a soubory nikdy nemění,', 'S volbou `--apply` vytvoří stránku `/integrations/` (jen pro přihlášené), sekci a záznam boxu. Třída v aplikaci není potřeba: box je součástí frameworku. Existující záznamy nikdy nemění,') WHERE LOCATE('S volbou `--apply` vytvoří aplikační třídu, stránku `/integrations/` (jen pro přihlášené), sekci a záznam boxu. Existující záznamy a soubory nikdy nemění,', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '`vendor/bin/wbengine.php integrations:install --root=src --config=src/Config/Settings.json`', '`vendor/bin/wbengine.php integrations:install --config=src/Config/Settings.json`') WHERE LOCATE('`vendor/bin/wbengine.php integrations:install --root=src --config=src/Config/Settings.json`', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '- *Klíč nemá všechna oprávnění*: vydejte klíč znovu s úplným profilem Správa webu.', '- *Klíč nepovoluje nic, co by Admin mohl spravovat*: vydejte nový klíč s alespoň jednou skupinou oprávnění. Stránka, kterou klíč nepokrývá, vyzve k novému klíči s chybějící skupinou.') WHERE LOCATE('- *Klíč nemá všechna oprávnění*: vydejte klíč znovu s úplným profilem Správa webu.', bodytext) > 0;

-- Unused settings removed (schemas/migrations/032-unused-settings-docs.sql).
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '| `codePage` | string, `utf8` | Charset sent in the HTML header. Keep `utf8`. |
', '') WHERE LOCATE('| `codePage` | string, `utf8` | Charset sent in the HTML header. Keep `utf8`. |
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '| `minimizeHtml` | bool, `false` | Deprecated and ignored by the dispatcher. Kept in the default file for old templates. |
', '') WHERE LOCATE('| `minimizeHtml` | bool, `false` | Deprecated and ignored by the dispatcher. Kept in the default file for old templates. |
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '| `minimizeCss` | bool, `false` | Combines and minimizes the files listed in `cssFiles`. |
', '') WHERE LOCATE('| `minimizeCss` | bool, `false` | Combines and minimizes the files listed in `cssFiles`. |
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '| `minimizeJs` | bool, `false` | Same for scripts. Not in older files: add it explicitly, the framework reads the key directly. |
', '') WHERE LOCATE('| `minimizeJs` | bool, `false` | Same for scripts. Not in older files: add it explicitly, the framework reads the key directly. |
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '| `cssFiles` | array, `[]` | CSS files combined when `minimizeCss` is on. |
', '') WHERE LOCATE('| `cssFiles` | array, `[]` | CSS files combined when `minimizeCss` is on. |
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '| `cdnPath` | string, empty | Prefix for static asset URLs, for example `https://cdn.example.com`. |
', '') WHERE LOCATE('| `cdnPath` | string, empty | Prefix for static asset URLs, for example `https://cdn.example.com`. |
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '| `ipAdmins` | array, `[]` | List of administrator IP addresses. |
', '') WHERE LOCATE('| `ipAdmins` | array, `[]` | List of administrator IP addresses. |
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '  "codePage": "utf8",
', '') WHERE LOCATE('  "codePage": "utf8",
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '  "minimizeHtml": false,
', '') WHERE LOCATE('  "minimizeHtml": false,
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '  "minimizeCss": false,
', '') WHERE LOCATE('  "minimizeCss": false,
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '  "minimizeJs": false,
', '') WHERE LOCATE('  "minimizeJs": false,
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '  "cdnPath": "",
', '') WHERE LOCATE('  "cdnPath": "",
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '  "cssFiles": [],
', '') WHERE LOCATE('  "cssFiles": [],
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '  "ipAdmins": [],
', '') WHERE LOCATE('  "ipAdmins": [],
', bodytext) > 0;

UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '| `codePage` | řetězec, `utf8` | Znaková sada v hlavičce HTML. Ponechte `utf8`. |
', '') WHERE LOCATE('| `codePage` | řetězec, `utf8` | Znaková sada v hlavičce HTML. Ponechte `utf8`. |
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '| `minimizeHtml` | bool, `false` | Zastaralé, dispečer ho ignoruje. Zůstává ve výchozím souboru kvůli starým šablonám. |
', '') WHERE LOCATE('| `minimizeHtml` | bool, `false` | Zastaralé, dispečer ho ignoruje. Zůstává ve výchozím souboru kvůli starým šablonám. |
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '| `minimizeCss` | bool, `false` | Spojí a zmenší soubory z `cssFiles`. |
', '') WHERE LOCATE('| `minimizeCss` | bool, `false` | Spojí a zmenší soubory z `cssFiles`. |
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '| `minimizeJs` | bool, `false` | Totéž pro skripty. Ve starších souborech chybí: přidejte ho výslovně, framework klíč čte přímo. |
', '') WHERE LOCATE('| `minimizeJs` | bool, `false` | Totéž pro skripty. Ve starších souborech chybí: přidejte ho výslovně, framework klíč čte přímo. |
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '| `cssFiles` | pole, `[]` | Soubory CSS spojované při zapnutém `minimizeCss`. |
', '') WHERE LOCATE('| `cssFiles` | pole, `[]` | Soubory CSS spojované při zapnutém `minimizeCss`. |
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '| `cdnPath` | řetězec, prázdný | Předpona URL statických souborů, například `https://cdn.example.com`. |
', '') WHERE LOCATE('| `cdnPath` | řetězec, prázdný | Předpona URL statických souborů, například `https://cdn.example.com`. |
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '| `ipAdmins` | pole, `[]` | Seznam IP adres správců. |
', '') WHERE LOCATE('| `ipAdmins` | pole, `[]` | Seznam IP adres správců. |
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '  "codePage": "utf8",
', '') WHERE LOCATE('  "codePage": "utf8",
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '  "minimizeHtml": false,
', '') WHERE LOCATE('  "minimizeHtml": false,
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '  "minimizeCss": false,
', '') WHERE LOCATE('  "minimizeCss": false,
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '  "minimizeJs": false,
', '') WHERE LOCATE('  "minimizeJs": false,
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '  "cdnPath": "",
', '') WHERE LOCATE('  "cdnPath": "",
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '  "cssFiles": [],
', '') WHERE LOCATE('  "cssFiles": [],
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '  "ipAdmins": [],
', '') WHERE LOCATE('  "ipAdmins": [],
', bodytext) > 0;

