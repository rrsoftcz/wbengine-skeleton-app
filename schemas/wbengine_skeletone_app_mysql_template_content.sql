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

UPDATE `cms_articles` SET `title`='Articles with the bundled box', `introtext`='WBengine 4.0 renders article content through the bundled Article box. New articles can use safe Markdown, while existing HTML stays explicitly marked as legacy HTML.', `bodytext`='## What the Article box does

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
(2,10,0,0,0,0,'Getting started','Install the WBengine 4.0 skeleton, review its Composer requirements, and run the bundled site locally before changing its content.','## Requirements

- PHP 8.3 or newer with `mysqli` and the extensions required by Composer dependencies.
- MySQL 8 or MariaDB 10.6 or newer.
- Apache with `mod_rewrite`, or Nginx with PHP-FPM.
- Composer 2. Docker is optional.

The application requires `wbengine/wbengine:^4.0`. The framework currently brings `firebase/php-jwt`; its template engine and Markdown parser are included. Check package metadata for the exact PHP platform requirements of the release you install.

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
(5,13,0,0,0,0,'Templates and Markdown','WBengine 4.0 uses its own compiled template engine. Markdown can be a template source file or the explicit format of an article stored in the database.','## Native templates

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

For deployment diagnostics use `vendor/bin/wbengine.php doctor`; it does not change the schema. The endpoint list and request console below this article show the CMS routes enabled by this skeleton. API v2 is enabled separately in application configuration and needs its explicit schema migrations for protected content operations. Its discovery, capabilities, resources, scopes and concurrency rules are described in the [WBengine API v2 reference](https://github.com/rrsoftcz/wbengine/blob/main/ref-api-v2.md). See also the [central administration guide](/docs/administration/).','markdown',1761000000,NULL,NULL);

INSERT INTO `cms_articles` (`id`,`site_id`,`grouped`,`futured`,`c_enabled`,`views`,`title`,`introtext`,`bodytext`,`content_format`,`published`,`author`,`source`) VALUES
(10,18,0,0,0,0,'Central administration','The central administration is a separate SvelteKit application for managing content on multiple WBengine websites. It connects to each site through the optional API v2; it is not installed as a PHP or Composer dependency.','## Separate application, connected sites

Each WBengine website keeps its own PHP application, MySQL database, files and public pages. The central administration runs separately with its own Node.js service and database. It stores its administrator accounts, site registry and encrypted integration credentials. It does not connect directly to a remote website database and it does not copy the site code into the central service.

The connection is server to server over HTTPS. A site operator enables API v2, provisions an integration key with only the required scopes and securely provides it to the central service. The central service validates the destination and TLS certificate, keeps the key on the server, and calls only supported API operations. Browser pages never receive the remote key. A site can revoke its key, and a failure or shutdown of the central service does not take the public website offline.

## What an editor can manage

Depending on the site API capabilities and the central account role, an editor can work with articles, pages, menu entries, sections, registered boxes, translations and supported images across multiple sites. Article edits are saved as drafts. An editor can preview a private draft and publish it explicitly when ready. Existing revisions can be restored as a new draft.

The editor handles simultaneous changes safely. Every write includes the version it was based on. If another editor or local process changed the same content, the API reports a conflict instead of silently overwriting it. The editor preserves the typed text and lets the user review the current remote version before making a new explicit save.

Images supported by this release are public raster media, not private draft attachments. Box choices come from a site-side allowlist. The central client cannot choose arbitrary PHP classes, methods, SQL statements, templates or filesystem paths.

## What it does not replace

The central service is an optional content client. It does not replace WBengine, the site database, source control, deployment pipeline or server administration. Developers still change PHP classes and templates in the site project and deploy them through the normal deployment workflow for that project. Sites continue serving pages independently if the central administration is unavailable.

The administration is distributed separately from the PHP framework. Its current `v0.1.0` source release is private and is not a public Composer package or public container image. The public documentation describes its architecture and supported workflow; access to the tool is managed separately.','markdown',1761000000,NULL,'https://www.wbengine.org/');

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
(1,'cs','Články s dodávaným boxem','Články vykresluje box Article dodávaný s WBengine 4.0. Nový obsah může používat bezpečný Markdown, zatímco původní HTML zůstává označené jako legacy HTML.','## Co dělá box Article

Frameworkový box načte článek přiřazený k webu, zpracuje jeho výslovně zvolený formát a vykreslí výsledek vlastní šablonou. Přeložená pole jsou v `cms_article_translations`; každý překlad má vlastní `content_format`.

Nový text ukládejte v Markdownu. WBengine ho parsuje bez dalšího balíčku, escapuje syrové HTML a povoluje jen bezpečná schémata odkazů. Stávající záznamy zůstávají ve formátu `legacy_html`, bez automatického převodu.

## Přidání článku

Uložte zdrojový Markdown a formát označte výslovně:

```sql
INSERT INTO cms_articles (site_id, title, introtext, bodytext, content_format, published, author)
VALUES (18, ''Nová stránka'', ''Krátký úvod.'', ''## Podrobnosti\\n\\nText napište v Markdownu.'', ''markdown'', UNIX_TIMESTAMP(), ''Editor'');
```

V aplikačních dotazech používejte vázané parametry. Přidejte odpovídající řádek `cms_boxes` pro box `blog` a po publikaci zneplatněte cache stránky. Další informace jsou v části [Boxy](/cs/docs/boxes/).','markdown'),
(2,'cs','Začínáme','Nainstalujte skeleton WBengine 4.0, ověřte jeho Composer požadavky a spusťte web lokálně, než začnete měnit jeho obsah.','## Požadavky

- PHP 8.3 nebo novější s rozšířením `mysqli` a rozšířeními vyžadovanými Composer balíčky.
- MySQL 8 nebo MariaDB 10.6 a novější.
- Apache s `mod_rewrite` nebo Nginx s PHP-FPM.
- Composer 2. Docker je volitelný.

Aplikace vyžaduje `wbengine/wbengine:^4.0`. Framework aktuálně přináší `firebase/php-jwt`; template engine i parser Markdownu jsou jeho součástí. Přesné požadavky na PHP ověřte v metadatech instalované verze.

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
(5,'cs','Šablony a Markdown','WBengine 4.0 používá vlastní kompilovaný template engine. Markdown lze použít jako samostatný zdrojový soubor šablony i jako výslovný formát článku v databázi.','## Nativní šablony

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

Pro diagnostiku nasazení použijte `vendor/bin/wbengine.php doctor`; příkaz schéma nemění. Seznam endpointů a konzole pod tímto článkem ukazují CMS trasy zapnuté v této aplikaci. API v2 se zapíná samostatně v konfiguraci a pro chráněné obsahové operace vyžaduje explicitní migrace schématu. Discovery, capabilities, zdroje, scopes a pravidla souběžných změn popisuje [referenční dokumentace WBengine API v2](https://github.com/rrsoftcz/wbengine/blob/main/ref-api-v2.md). Viz také [centrální administrace](/cs/docs/administration/).','markdown');

REPLACE INTO `cms_article_translations` (`article_id`,`locale`,`title`,`introtext`,`bodytext`,`content_format`) VALUES
(10,'cs','Centrální administrace','Centrální administrace je samostatná aplikace SvelteKit pro správu obsahu na více webech WBengine. Ke každému webu se připojuje přes volitelné API v2; není součástí PHP ani Composer balíčku.','## Samostatná aplikace, připojené weby

Každý web WBengine si ponechává vlastní PHP aplikaci, databázi MySQL, soubory a veřejné stránky. Centrální administrace běží odděleně jako služba Node.js s vlastní databází. Ukládá účty správců, seznam připojených webů a zašifrované integrační údaje. Nepřipojuje se přímo do vzdálené databáze webu a nekopíruje jeho zdrojový kód.

Spojení probíhá mezi servery přes HTTPS. Provozovatel webu zapne API v2, vydá integrační klíč jen s potřebnými scopes a bezpečně jej předá centrální službě. Ta ověří cílovou adresu i TLS certifikát, ponechá klíč na serveru a volá pouze podporované operace API. Klíč se nikdy nedostane do prohlížeče. Web může klíč odvolat a výpadek centrální služby neodstaví veřejný web.

## Co může redaktor spravovat

Podle možností API daného webu a role centrálního účtu může redaktor spravovat články, stránky, položky menu, sekce, registrované boxy, překlady a podporované obrázky na více webech. Úpravy článků se ukládají jako koncepty. Redaktor si může zobrazit soukromý náhled a potom koncept výslovně publikovat. Starší revize lze obnovit jako nový koncept.

Každý zápis uvádí verzi, ze které vychází. Pokud stejný obsah změnil další redaktor nebo místní proces, API nahlásí konflikt místo tichého přepsání. Administrace zachová rozepsaný text a umožní porovnat aktuální vzdálenou verzi před novým výslovným uložením.

Obrázky podporované touto verzí jsou veřejná rastrová média, nikoli soukromé přílohy konceptu. Nabídka boxů pochází z allowlistu na webu. Centrální klient nemůže vybírat libovolné PHP třídy, metody, SQL, šablony ani cesty k souborům.

## Co administrace nenahrazuje

Centrální služba je volitelný obsahový klient. Nenahrazuje WBengine, databázi webu, správu zdrojového kódu, nasazovací postup ani správu serveru. Vývojář mění PHP třídy a šablony v projektu webu a nasazuje je jeho běžným postupem. Weby dál fungují, i když centrální administrace není dostupná.

Administrace se distribuuje odděleně od PHP frameworku. Její současné zdrojové vydání `v0.1.0` je soukromé a nejde o veřejný Composer balíček ani veřejný kontejner. Veřejná dokumentace popisuje architekturu a podporovaný postup; přístup k nástroji se řeší samostatně.','markdown');

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
    bodytext = CONCAT(bodytext, '\n\n## Clean VPS deployment with Docker\n\nThis procedure is for a new, empty Ubuntu server. It creates a new database from the schema and content committed to this repository. It does not copy a database from a development or existing website. Do not run the clean-install script against an existing database. For an existing site, first back it up and follow the versioned upgrade migrations instead.\n\nThe PHP application and MySQL run in Docker. Nginx and Certbot run on the Ubuntu host. The application port is bound to `127.0.0.1:8080`, and MySQL is not published on a host port. The optional WBengine Admin is a separate SvelteKit application and is not installed by this procedure; it can remain on a development computer and connect through a separately configured API v2 integration.\n\n### 1. Prepare DNS and firewall\n\nPoint `www.wbengine.org` to the VPS IPv4 address. Allow inbound SSH on port 22 and web traffic on ports 80 and 443 in the VPS firewall. The apex domain `wbengine.org` may continue to redirect to `www` from its current DNS host. The sample Nginx configuration serves `www.wbengine.org`.\n\n### 2. Install Docker\n\nInstall Docker Engine and the Docker Compose plugin using the [official Ubuntu instructions](https://docs.docker.com/engine/install/ubuntu/). The host does not need PHP or Composer. PHP, Composer and MySQL are provided by the application containers.\n\n### 3. Create the clean application and database\n\nInstall Git, OpenSSL, Nginx and Certbot, then clone the repository and run the production installer:\n\n```bash\napt-get update\napt-get install -y git openssl nginx certbot\ngit clone https://github.com/rrsoftcz/wbengine-skeleton-app.git /opt/wbengine-skeleton-app\ncd /opt/wbengine-skeleton-app\n./bin/setup-production.sh\n```\n\nThe installer generates private database and JWT secrets on the server, builds the production PHP image, initializes a new MySQL volume from the tracked schema and content seed, applies the API and analytics schema migrations, and replaces the documented demo password with a random unusable password. Keep `.env` and `src/Config/Settings.json` private. The script leaves analytics collection disabled. It does not import data from another database.\n\n### 4. Configure HTTPS in Nginx\n\nCreate the ACME webroot and enable the temporary HTTP-only configuration so Let''s Encrypt can verify the hostname:\n\n```bash\ninstall -d -m 755 /var/www/letsencrypt\nln -sfn /opt/wbengine-skeleton-app/deploy/nginx/www.wbengine.org-http.conf /etc/nginx/sites-enabled/www.wbengine.org.conf\nrm -f /etc/nginx/sites-enabled/default\nnginx -t && systemctl reload nginx\ncertbot certonly --webroot -w /var/www/letsencrypt -d www.wbengine.org\n```\n\nAfter the certificate is issued, switch to the TLS reverse-proxy configuration and verify renewal:\n\n```bash\nln -sfn /opt/wbengine-skeleton-app/deploy/nginx/www.wbengine.org.conf /etc/nginx/sites-enabled/www.wbengine.org.conf\nnginx -t && systemctl reload nginx\ncertbot renew --dry-run --no-random-sleep-on-renew\n```\n\n### 5. Verify and update\n\nCheck the public site and both container health states:\n\n```bash\ncurl -I https://www.wbengine.org/\ndocker compose -f docker-compose.production.yml ps\ndocker compose -f docker-compose.production.yml logs --tail=100 web db\n```\n\nFor a later application update, fetch the reviewed commit and rebuild the web image:\n\n```bash\ngit pull --ff-only\ndocker compose -f docker-compose.production.yml up -d --build --wait\n```\n\nThe database volume persists across image rebuilds. New database migrations must be reviewed and applied once as described by their release notes. Never expose MySQL port 3306 publicly. The complete versioned procedure is also in [the repository deployment guide](https://github.com/rrsoftcz/wbengine-skeleton-app/blob/main/docs/deploy-vps-docker.md).')
WHERE id = 2
  AND site_id = 10
  AND title = 'Getting started'
  AND LOCATE('## Clean VPS deployment with Docker', bodytext) = 0;

UPDATE cms_article_translations
SET introtext = 'Nainstalujte WBengine skeleton lokálně nebo nasaďte čistou instalaci na Ubuntu VPS pomocí Dockeru a HTTPS.',
    bodytext = CONCAT(bodytext, '\n\n## Čisté nasazení na VPS pomocí Dockeru\n\nTento postup je určený pro nový, prázdný server s Ubuntu. Vytvoří novou databázi z aktuálního schématu a obsahu v tomto repozitáři. Nekopíruje databázi z vývojového ani již provozovaného webu. Instalační skript pro čistou instalaci nespouštějte nad existující databází. Při upgradu existujícího webu nejprve vytvořte zálohu a postupujte podle verzovaných databázových migrací.\n\nPHP aplikace a MySQL poběží v Dockeru. Nginx a Certbot poběží přímo na serveru Ubuntu. Aplikační port bude dostupný pouze přes `127.0.0.1:8080` a MySQL nebude publikováno na port serveru. Volitelná administrace WBengine Admin je samostatná aplikace SvelteKit a tento postup ji neinstaluje. Může zůstat na vývojovém počítači a připojit se přes samostatně nastavenou integraci API v2.\n\n### 1. Připravte DNS a firewall\n\nNasměrujte `www.wbengine.org` na IPv4 adresu VPS. Ve firewallu povolte příchozí SSH na portu 22 a webový provoz na portech 80 a 443. Doména `wbengine.org` může dál přesměrovávat na `www` ze svého současného DNS hostingu. Přiložená konfigurace Nginx obsluhuje `www.wbengine.org`.\n\n### 2. Nainstalujte Docker\n\nNainstalujte Docker Engine a plugin Docker Compose podle [oficiálního návodu pro Ubuntu](https://docs.docker.com/engine/install/ubuntu/). Na hostiteli není potřeba PHP ani Composer. PHP, Composer a MySQL poskytují aplikační kontejnery.\n\n### 3. Vytvořte čistou aplikaci a databázi\n\nNainstalujte Git, OpenSSL, Nginx a Certbot, potom naklonujte repozitář a spusťte produkční instalátor:\n\n```bash\napt-get update\napt-get install -y git openssl nginx certbot\ngit clone https://github.com/rrsoftcz/wbengine-skeleton-app.git /opt/wbengine-skeleton-app\ncd /opt/wbengine-skeleton-app\n./bin/setup-production.sh\n```\n\nInstalátor na serveru vytvoří soukromé databázové a JWT klíče, sestaví produkční PHP image, naplní nový svazek MySQL verzovaným schématem a obsahem, aplikuje databázové migrace API a analytiky a nahradí veřejně známé demo heslo náhodným nepoužitelným heslem. Soubory `.env` a `src/Config/Settings.json` chraňte jako tajné. Sběr vlastní analytiky zůstane vypnutý. Skript nepřenáší data z jiné databáze.\n\n### 4. Nastavte HTTPS v Nginx\n\nVytvořte webroot ACME a zapněte dočasnou HTTP konfiguraci, aby Let''s Encrypt ověřil doménu:\n\n```bash\ninstall -d -m 755 /var/www/letsencrypt\nln -sfn /opt/wbengine-skeleton-app/deploy/nginx/www.wbengine.org-http.conf /etc/nginx/sites-enabled/www.wbengine.org.conf\nrm -f /etc/nginx/sites-enabled/default\nnginx -t && systemctl reload nginx\ncertbot certonly --webroot -w /var/www/letsencrypt -d www.wbengine.org\n```\n\nPo vydání certifikátu přepněte na TLS reverse proxy a ověřte obnovu:\n\n```bash\nln -sfn /opt/wbengine-skeleton-app/deploy/nginx/www.wbengine.org.conf /etc/nginx/sites-enabled/www.wbengine.org.conf\nnginx -t && systemctl reload nginx\ncertbot renew --dry-run --no-random-sleep-on-renew\n```\n\n### 5. Ověřte a aktualizujte web\n\nZkontrolujte veřejný web a stav obou kontejnerů:\n\n```bash\ncurl -I https://www.wbengine.org/\ndocker compose -f docker-compose.production.yml ps\ndocker compose -f docker-compose.production.yml logs --tail=100 web db\n```\n\nPři pozdější aktualizaci aplikace stáhněte schválený commit a znovu sestavte webový image:\n\n```bash\ngit pull --ff-only\ndocker compose -f docker-compose.production.yml up -d --build --wait\n```\n\nDatabázový svazek zůstává zachovaný při sestavení nového image. Nové databázové migrace nejprve zkontrolujte a aplikujte jednou podle poznámek konkrétní verze. Nikdy veřejně nevystavujte port MySQL 3306. Kompletní verzovaný postup je také v [produkčním návodu repozitáře](https://github.com/rrsoftcz/wbengine-skeleton-app/blob/main/docs/deploy-vps-docker.md).')
WHERE article_id = 2
  AND locale = 'cs'
  AND LOCATE('## Čisté nasazení na VPS pomocí Dockeru', bodytext) = 0;

-- Integrations page (schemas/migrations/013-integrations-page.sql), ids assigned by the database.
INSERT INTO cms_sites (parent_id, left_id, right_id, strict, visible, link, title, html_title, html_description, html_keywords, acl)
SELECT 1, 1, 1, 1, 0, '/integrations/', 'Integrations', 'Integrations', 'Integration keys for the central WBengine Admin', 'integrations,api', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cms_sites WHERE link = '/integrations/');

INSERT INTO cms_boxes (name, module, method, section_id, static, shared, device_min, device_strict, acl, `order`, sites)
SELECT 'Integrations', 'integrations', 'integrations', 1, 1, 0, 1, 0, 1, 1, JSON_ARRAY(CAST(site_id AS CHAR))
FROM cms_sites
WHERE link = '/integrations/'
  AND NOT EXISTS (SELECT 1 FROM cms_boxes WHERE module = 'integrations' AND method = 'integrations');
