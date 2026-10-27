-- WBengine 4 public documentation refresh.
-- Review local edits to built-in documentation articles before applying.
-- Adds a bilingual central-administration page and clarifies the architecture/API guides.
SET NAMES utf8mb4;
START TRANSACTION;

UPDATE cms_articles
SET title = 'Architecture',
    introtext = 'WBengine is a request-driven PHP framework with a visible object tree. It keeps site structure and content in MySQL, reusable behavior in namespaced PHP boxes, and presentation in templates.',
    bodytext = '## The object tree

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

Markdown, templates, locales, caching, the legacy CMS API and the separate server-to-server API v2 are described in their own guides. The optional [central administration](/docs/administration/) is a separate application connected through API v2; it is not part of the PHP request tree or Composer package.'
WHERE id = 3 AND site_id = 11;

UPDATE cms_article_translations
SET title = 'Architektura',
    introtext = 'WBengine je PHP framework řízený požadavky s přehledným objektovým stromem. Strukturu webu a obsah drží v MySQL, opakovaně použitelné chování v namespacovaných PHP boxech a prezentaci v šablonách.',
    bodytext = '## Strom objektů

- **Application** je kořen jednoho HTTP požadavku. Načítá konfiguraci a poskytuje sdílené služby pro databázi, routování, autentizaci, vykreslení, Markdown a cache. Služby vytváří až při použití.
- **Site** je stránka vybraná podle aktuální URL. Nese řádek webu, jazyk, pravidla přístupu, metadata a kontext navigace.
- **Section** je pojmenovaná oblast layoutu, například `header`, `central` nebo `footer`.
- **Box** je aplikační komponenta určená řádkem `cms_boxes`. Nastavený modul a metoda se propojí s třídou v namespace aplikace, například `App\\Box\\Central\\Docs`.
- **Model** obsahuje opakovaně použitelný přístup k datům pro box. Používá databázovou vrstvu frameworku a vázané SQL parametry.
- **Renderer a šablona** převedou data boxu na výstup. Šablony používají renderer frameworku, ale nenahrazují PHP objektový strom.

Vazby na rodiče jsou skutečné reference objektů: box má přístup ke své sekci, webu i aplikaci bez dalšího globálního kontejneru. Nové PHP funkce řaďte do existujícího stromu a namespaces. Do šablon nedávejte přihlašovací údaje ani databázovou logiku.

## Jeden požadavek od URL po HTML

```text
public/index.php
  načtení Composeru a bootstrapu aplikace
  Application obslouží vlastní aplikační trasu nebo zapnutou trasu API
  určení jazyka a výběr Site podle URL
  kontrola přístupu a možnosti bezpečně použít cache celé stránky
  načtení aktivních Section pro Site
    načtení nakonfigurovaných Box pro každou Section
      vytvoření namespacovaného Box s vazbami na rodiče
      Box podle potřeby zavolá Model
      Renderer zpracuje soubor .tpl nebo zdroj .md
  spojení výstupů sekcí v layoutu webu
  odeslání HTTP odpovědi a případné uložení bezpečné veřejné kopie
```

Přesné pořadí vlastních tras a kontrol cache závisí na nastavení aplikace. Framework řídí výběr webu, přístup a vykreslení; třídy aplikace určují chování boxů.

## Co je v databázi a co v PHP

`cms_sites` popisuje URL a metadata stránek. `cms_sections` určuje oblasti layoutu. `cms_boxes` připojuje modul a metodu k sekci, určuje pořadí a může box sdílet. Články, menu a překladové tabulky uchovávají upravitelný obsah. PHP třídy definují chování, modely načítají data a šablony je zobrazují. Existující box lze často připojit k novému webu jen pomocí dat; nové chování vyžaduje aplikační třídu.

Markdown, šablony, jazyky, cache, původní CMS API a samostatné serverové API v2 mají vlastní návody. Volitelná [centrální administrace](/cs/docs/administration/) je samostatná aplikace napojená přes API v2; není součástí PHP stromu ani Composer balíčku.'
WHERE article_id = 3 AND locale = 'cs';

UPDATE cms_articles
SET introtext = 'WBengine has two API layers: the application CMS API under `/api/` and an optional, separately enabled server-to-server content API under `/api/v2`. They have different clients, authentication and purposes.',
    bodytext = '## Choose the API for the job

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

For deployment diagnostics use `vendor/bin/wbengine.php doctor`; it does not change the schema. The endpoint list and request console below this article show the CMS routes enabled by this skeleton. API v2 is enabled separately in application configuration and needs its explicit schema migrations for protected content operations. Its discovery, capabilities, resources, scopes and concurrency rules are described in the [WBengine API v2 reference](https://github.com/rrsoftcz/wbengine/blob/main/ref-api-v2.md). See also the [central administration guide](/docs/administration/).'
WHERE id = 9 AND site_id = 17;

UPDATE cms_article_translations
SET introtext = 'WBengine má dvě vrstvy API: aplikační CMS API pod `/api/` a volitelné serverové obsahové API v2 pod `/api/v2`. Mají odlišné klienty, autentizaci i účel.',
    bodytext = '## Vyberte správné API

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

Pro diagnostiku nasazení použijte `vendor/bin/wbengine.php doctor`; příkaz schéma nemění. Seznam endpointů a konzole pod tímto článkem ukazují CMS trasy zapnuté v této aplikaci. API v2 se zapíná samostatně v konfiguraci a pro chráněné obsahové operace vyžaduje explicitní migrace schématu. Discovery, capabilities, zdroje, scopes a pravidla souběžných změn popisuje [referenční dokumentace WBengine API v2](https://github.com/rrsoftcz/wbengine/blob/main/ref-api-v2.md). Viz také [centrální administrace](/cs/docs/administration/).'
WHERE article_id = 9 AND locale = 'cs';

SET @admin_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1);
INSERT INTO cms_sites (parent_id, left_id, right_id, strict, visible, link, title, html_title, html_description, html_keywords, acl)
SELECT 1, 0, 0, 1, 1, '/docs/administration/', 'Central administration', 'Central administration', 'A separate application for managing content on multiple WBengine sites through API v2.', 'administration,api,multi-site', 0
WHERE @admin_site_id IS NULL;
SET @admin_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1);

REPLACE INTO cms_site_translations (site_id, locale, title, html_title, html_description, html_keywords)
VALUES (@admin_site_id, 'cs', 'Centrální administrace', 'Centrální administrace', 'Samostatný nástroj pro správu obsahu více webů WBengine přes API v2.', 'administrace,api,více webů');

INSERT INTO cms_articles (site_id, grouped, futured, c_enabled, views, title, introtext, bodytext, content_format, published, author, source)
SELECT @admin_site_id, 0, 0, 0, 0, 'Central administration', 'The central administration is a separate SvelteKit application for managing content on multiple WBengine websites. It connects to each site through the optional API v2; it is not installed as a PHP or Composer dependency.', '## Separate application, connected sites

Each WBengine website keeps its own PHP application, MySQL database, files and public pages. The central administration runs separately with its own Node.js service and database. It stores its administrator accounts, site registry and encrypted integration credentials. It does not connect directly to a remote website database and it does not copy the site code into the central service.

The connection is server to server over HTTPS. A site operator enables API v2, provisions an integration key with only the required scopes and securely provides it to the central service. The central service validates the destination and TLS certificate, keeps the key on the server, and calls only supported API operations. Browser pages never receive the remote key. A site can revoke its key, and a failure or shutdown of the central service does not take the public website offline.

## What an editor can manage

Depending on the site API capabilities and the central account role, an editor can work with articles, pages, menu entries, sections, registered boxes, translations and supported images across multiple sites. Article edits are saved as drafts. An editor can preview a private draft and publish it explicitly when ready. Existing revisions can be restored as a new draft.

The editor handles simultaneous changes safely. Every write includes the version it was based on. If another editor or local process changed the same content, the API reports a conflict instead of silently overwriting it. The editor preserves the typed text and lets the user review the current remote version before making a new explicit save.

Images supported by this release are public raster media, not private draft attachments. Box choices come from a site-side allowlist. The central client cannot choose arbitrary PHP classes, methods, SQL statements, templates or filesystem paths.

## What it does not replace

The central service is an optional content client. It does not replace WBengine, the site database, source control, deployment pipeline or server administration. Developers still change PHP classes and templates in the site project and deploy them through the normal deployment workflow for that project. Sites continue serving pages independently if the central administration is unavailable.

The administration is distributed separately from the PHP framework. Its current `v0.1.0` source release is private and is not a public Composer package or public container image. The public documentation describes its architecture and supported workflow; access to the tool is managed separately.', 'markdown', UNIX_TIMESTAMP(), 'RRSOFT', 'https://www.wbengine.org/'
WHERE NOT EXISTS (SELECT 1 FROM cms_articles WHERE site_id = @admin_site_id);
SET @admin_article_id = (SELECT id FROM cms_articles WHERE site_id = @admin_site_id ORDER BY id LIMIT 1);

REPLACE INTO cms_article_translations (article_id, locale, title, introtext, bodytext, content_format)
VALUES (@admin_article_id, 'cs', 'Centrální administrace', 'Centrální administrace je samostatná aplikace SvelteKit pro správu obsahu na více webech WBengine. Ke každému webu se připojuje přes volitelné API v2; není součástí PHP ani Composer balíčku.', '## Samostatná aplikace, připojené weby

Každý web WBengine si ponechává vlastní PHP aplikaci, databázi MySQL, soubory a veřejné stránky. Centrální administrace běží odděleně jako služba Node.js s vlastní databází. Ukládá účty správců, seznam připojených webů a zašifrované integrační údaje. Nepřipojuje se přímo do vzdálené databáze webu a nekopíruje jeho zdrojový kód.

Spojení probíhá mezi servery přes HTTPS. Provozovatel webu zapne API v2, vydá integrační klíč jen s potřebnými scopes a bezpečně jej předá centrální službě. Ta ověří cílovou adresu i TLS certifikát, ponechá klíč na serveru a volá pouze podporované operace API. Klíč se nikdy nedostane do prohlížeče. Web může klíč odvolat a výpadek centrální služby neodstaví veřejný web.

## Co může redaktor spravovat

Podle možností API daného webu a role centrálního účtu může redaktor spravovat články, stránky, položky menu, sekce, registrované boxy, překlady a podporované obrázky na více webech. Úpravy článků se ukládají jako koncepty. Redaktor si může zobrazit soukromý náhled a potom koncept výslovně publikovat. Starší revize lze obnovit jako nový koncept.

Každý zápis uvádí verzi, ze které vychází. Pokud stejný obsah změnil další redaktor nebo místní proces, API nahlásí konflikt místo tichého přepsání. Administrace zachová rozepsaný text a umožní porovnat aktuální vzdálenou verzi před novým výslovným uložením.

Obrázky podporované touto verzí jsou veřejná rastrová média, nikoli soukromé přílohy konceptu. Nabídka boxů pochází z allowlistu na webu. Centrální klient nemůže vybírat libovolné PHP třídy, metody, SQL, šablony ani cesty k souborům.

## Co administrace nenahrazuje

Centrální služba je volitelný obsahový klient. Nenahrazuje WBengine, databázi webu, správu zdrojového kódu, nasazovací postup ani správu serveru. Vývojář mění PHP třídy a šablony v projektu webu a nasazuje je jeho běžným postupem. Weby dál fungují, i když centrální administrace není dostupná.

Administrace se distribuuje odděleně od PHP frameworku. Její současné zdrojové vydání `v0.1.0` je soukromé a nejde o veřejný Composer balíček ani veřejný kontejner. Veřejná dokumentace popisuje architekturu a podporovaný postup; přístup k nástroji se řeší samostatně.', 'markdown');

INSERT INTO cms_boxes (name, module, method, section_id, static, shared, device_min, device_strict, acl, `order`, sites)
SELECT 'Docs: Central administration', 'docs', 'page', 1, 1, 0, 1, 0, 0, 0, JSON_ARRAY(CAST(@admin_site_id AS CHAR))
WHERE NOT EXISTS (SELECT 1 FROM cms_boxes WHERE name = 'Docs: Central administration');

COMMIT;
