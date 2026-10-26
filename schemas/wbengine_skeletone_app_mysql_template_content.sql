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
(17,1,0,0,1,1,'/docs/rest-api/','REST API','REST API','The REST API: endpoints, tokens, roles and how to add a module, with a live console.','rest,api,jwt',0);

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

Create a database, import `schemas/wbengine_skeletone_app_mysql_template.sql` and then `schemas/wbengine_skeletone_app_mysql_template_content.sql`. Configure `src/Config/Settings.json` and point the web root to `public/`. ## Troubleshooting exceptions

In development, set `debug` to `true` in `Settings.json` to show the WBengine exception template with the exception type, message, file, line and stack trace. If settings are missing or malformed, use `WBENGINE_DEBUG=1` only in a private development environment. Never expose debug output publicly. The production error page shows a safe explanation and reference code; find the full exception in the PHP or container error log under that code.

For upgrades, back up the database and apply pending scripts in `schemas/migrations/` in order. Docker imports the schema and seed files only when it initializes a new database volume. Rebuilding the web image does not update an existing database.','markdown',1761000000,NULL,NULL),
(3,11,0,0,0,0,'Architecture','WBengine keeps the request path small and explicit. Application, Site, Section, and Box objects form the same tree used by the application code.','## The object tree

- **Application** is the request root and owns shared services.
- **Site** represents the matched page and its metadata, access rules, and menu.
- **Section** is a named layout region such as `header`, `central`, or `api`.
- **Box** is the PHP class and method selected by a `cms_boxes` row.

The layout renders section output. A box can render a template directly or load a model first. Keep new features in this tree and follow the existing `App\\Box\\<Section>` namespaces.

## Request outline

```text
public/index.php
  Application::run()
    match URL to Site
    check access and page-cache eligibility
    build active Sections
      resolve configured Boxes
        call Box method and render its template
    render the site layout
```

Sites, sections, and boxes are configuration data. PHP classes define reusable behavior. This keeps simple page changes out of the router while leaving application logic explicit.','markdown',1761000000,NULL,NULL),
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
(9,17,0,0,0,0,'REST API','The API is served under `/api/`. Authenticate with the login route, send the access token as a bearer token, and use the role required by each route.','## Example request

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

For deployment diagnostics use `vendor/bin/wbengine.php doctor`; it does not change the schema. The endpoint list and request console below this article show the routes enabled by this skeleton. Check the current route classes before relying on an example in another application.','markdown',1761000000,NULL,NULL);

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
(11,'cs','Architektura','Architektura','Jak WBengine mění URL ve stránku: weby, sekce, boxy a průběh požadavku.','architektura,web,sekce,box'),
(12,'cs','Boxy','Boxy','Statické a dynamické boxy, modely a tabulka cms_boxes.','boxy,model,cms_boxes'),
(13,'cs','Šablony','Šablony','Nativní šablony, automatické escapování a Markdown v souborech i databázi.','šablony,escapování,markdown'),
(14,'cs','Jazyky','Jazyky','Jazyky ve WBengine: detekce z URL, cookie a hlavičky, katalogy, množná čísla a překládaný obsah databáze.','i18n,jazyky,překlady'),
(15,'cs','Cache','Cache','Datová cache a cache stránek: co se ukládá, kdy a jak ji zneplatnit.','cache,výkon,apcu'),
(16,'cs','Zabezpečení','Zabezpečení','Vázané parametry, escapování, hashování hesel, session, tokeny, role a omezení pokusů.','zabezpečení,jwt,role'),
(17,'cs','REST API','REST API','REST API: koncové body, tokeny, role a přidání modulu, s živou konzolí.','rest,api,jwt');

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

Vytvořte databázi, importujte `schemas/wbengine_skeletone_app_mysql_template.sql` a potom `schemas/wbengine_skeletone_app_mysql_template_content.sql`. Nastavte `src/Config/Settings.json` a jako kořen webu použijte `public/`. ## Řešení výjimek

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
(9,'cs','REST API','API je dostupné pod `/api/`. Přihlaste se přes login endpoint, posílejte přístupový token jako bearer token a používejte roli vyžadovanou danou cestou.','## Ukázkový požadavek

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

Pro diagnostiku nasazení použijte `vendor/bin/wbengine.php doctor`; příkaz schéma nemění. Seznam endpointů a konzole pod tímto článkem ukazují trasy zapnuté v této aplikaci. Před použitím příkladů v jiném projektu zkontrolujte jeho aktuální třídy tras.','markdown');

UPDATE `cms_articles`
SET `introtext`='Learn which Markdown syntax WBengine supports, how source becomes safe HTML, and how file and database content differ.',
    `bodytext`=CONCAT(`bodytext`, '\n\n## Supported Markdown syntax\n\nThe bundled parser supports CommonMark 0.31.2 and GitHub Flavored Markdown tables, strikethrough, and task lists. Common block forms include headings, paragraphs, thematic breaks, blockquotes, ordered and unordered lists, indented code, and fenced code blocks. Tables use the pipe and delimiter-row syntax.\n\nInline forms include emphasis, strong emphasis, inline code, links, images, escaped punctuation, automatic links and email addresses, and hard line breaks. GFM adds `~~strikethrough~~` and task list markers such as `- [x] done`. A language after a fenced code marker is retained as a `language-*` class.\n\n````markdown\n## Heading\n\nA paragraph with **strong**, *emphasis*, `code`, and [a link](https://example.com).\n\n- first item\n- second item\n\n| Name | Value |\n| --- | --- |\n| site | WBengine |\n\n- [x] reviewed\n\n```php\necho "Hello";\n```\n````\n\n## How rendering works\n\nThe parser turns source into a document tree. The HTML renderer then emits a limited set of elements and escapes text and attributes. Raw HTML in Markdown is displayed as text, and links are limited to safe URL schemes such as relative URLs, HTTP, HTTPS, and mailto. Markdown never executes PHP or template directives. The output of the built-in renderer is safe to print with `|raw`; do not use `|raw` for arbitrary input.\n\nFor a `.md` file, the native renderer selects Markdown by the file extension, whether the file is rendered directly or included from a `.tpl` file. For database articles, `content_format` is stored separately on each article and translation row. When it is `markdown`, the Article box parses the article text fields before the template prints the generated HTML. Rows marked `legacy_html` keep the existing HTML behavior. Review and convert legacy HTML before changing its format.')
WHERE `id`=5 AND `title`='Templates and Markdown';

UPDATE `cms_article_translations`
SET `introtext`='Zjistěte, jakou syntaxi Markdownu WBengine podporuje, jak se zdroj převádí na bezpečné HTML a v čem se liší soubory od obsahu v databázi.',
    `bodytext`=CONCAT(`bodytext`, '\n\n## Podporovaná syntaxe Markdownu\n\nVestavěný parser podporuje CommonMark 0.31.2 a z GitHub Flavored Markdown tabulky, přeškrtnutí a úkolové seznamy. Mezi blokové prvky patří nadpisy, odstavce, vodorovné oddělovače, citace, číslované i nečíslované seznamy, odsazené bloky kódu a bloky kódu ohraničené zpětnými apostrofy nebo vlnovkami. Tabulky používají svislé čáry a oddělovací řádek.\n\nV textu lze použít kurzívu, tučné písmo, řádkový kód, odkazy, obrázky, escapování interpunkce, automatické odkazy a e-mailové adresy i pevné zalomení řádku. Rozšíření GFM přidává `~~přeškrtnutí~~` a značky úkolů jako `- [x] hotovo`. Jazyk uvedený za úvodní značkou bloku kódu se zachová jako třída `language-*`.\n\n````markdown\n## Nadpis\n\nOdstavec s **tučným písmem**, *kurzívou*, `kódem` a [odkazem](https://example.com).\n\n- první položka\n- druhá položka\n\n| Název | Hodnota |\n| --- | --- |\n| web | WBengine |\n\n- [x] zkontrolováno\n\n```php\necho "Ahoj";\n```\n````\n\n## Jak probíhá vykreslení\n\nParser převede zdroj na strom dokumentu. HTML renderer z něj vytvoří omezenou sadu prvků a escapuje text i atributy. Syrové HTML v Markdownu se zobrazí jako text a odkazy povolují jen bezpečná schémata, například relativní adresy, HTTP, HTTPS a mailto. Markdown nespouští PHP ani direktivy šablon. Výstup vestavěného rendereru lze bezpečně vypsat pomocí `|raw`; tento filtr nepoužívejte pro libovolný vstup.\n\nU souboru `.md` nativní renderer zvolí Markdown podle přípony, ať se soubor vykreslí přímo, nebo vloží do `.tpl`. U databázových článků je `content_format` uložen samostatně u článku i jeho překladu. Pokud má hodnotu `markdown`, box Article nejprve zpracuje textová pole a šablona vypíše vytvořené HTML. Řádky označené `legacy_html` zachovávají dosavadní chování. Staré HTML nejprve zkontrolujte a převeďte, než jeho formát změníte.')
WHERE `article_id`=5 AND `locale`='cs';
