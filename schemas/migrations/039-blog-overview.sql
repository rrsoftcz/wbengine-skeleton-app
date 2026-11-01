-- The blog overview on /blog/ and a new demo article.
-- The article that was the content of /blog/ (a 2017 example of the bundled box) moves to its own page
-- /blog/what-wbengine-gives-a-site/ and is rewritten to describe what the framework gives a site, English and Czech.
-- /blog/ shows the overview box (the newest posts with an excerpt, the most read ones, all posts), which lists
-- the posts under /blog/. Each step runs only while it is still needed, so the migration is safe to rerun.
SET NAMES utf8mb4;
START TRANSACTION;

SET @blog_site_id = (SELECT site_id FROM cms_sites WHERE link = '/blog/' ORDER BY site_id LIMIT 1);

INSERT INTO cms_sites (parent_id, left_id, right_id, strict, visible, link, title, html_title, html_description, html_keywords, acl)
SELECT 1, 1, 1, 1, 1, '/blog/what-wbengine-gives-a-site/', 'What WBengine gives a site', 'What WBengine gives a site', 'Pages and boxes in a database, built-in languages, a keyed API and an MCP server for editors, a page cache and statistics without tracking.', 'wbengine,features,cms', 0
FROM DUAL
WHERE @blog_site_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cms_sites WHERE link = '/blog/what-wbengine-gives-a-site/');

SET @post_site_id = (SELECT site_id FROM cms_sites WHERE link = '/blog/what-wbengine-gives-a-site/' ORDER BY site_id LIMIT 1);

INSERT INTO cms_site_translations (site_id, locale, title, html_title, html_description, html_keywords)
SELECT @post_site_id, 'cs', 'Co WBengine webu dává', 'Co WBengine webu dává', 'Stránky a boxy v databázi, jazyky v základu, API s klíči a MCP server pro redaktory, cache stránek a statistiky bez sledování lidí.', 'wbengine,funkce,cms'
FROM DUAL
WHERE @post_site_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cms_site_translations WHERE site_id = @post_site_id AND locale = 'cs');

-- The demo article moves to its own page and is rewritten, once: while it is still on /blog/.
UPDATE cms_articles
SET site_id = @post_site_id,
    title = 'What WBengine gives a site',
    introtext = 'A WBengine site keeps its pages, boxes, menu and articles in a database and serves them in several languages. Editors and AI assistants work through a keyed API, and the framework takes care of the cache, the statistics and the signals for search engines.',
    bodytext = '## Pages and boxes live in the database

A page is a row, and the boxes it shows (a navigation, an article, a list, your own PHP class with a template) are rows too. You add a page, move a box to another section or hide a page without deploying code. A page can be strict and answer only its own address, or dynamic: the box behind it then receives the rest of the address as parameters and decides itself what is valid. See [Boxes](/docs/boxes/).

## Languages are built in

Every page, menu entry and article can be translated. A language has its own address prefix (`/cs/`), the layout gets the links to the other languages, and the search engine signals follow: `hreflang`, a canonical link and a [sitemap](/docs/settings/) that lists each language of a page. See [Languages](/docs/languages/).

## It is managed from outside, safely

The API lets the central Admin and your own tools manage content with keys that carry only the permissions you chose, can be limited to certain addresses and leave a change log of who changed what. An article can be hidden and shown again. For an editor who is not technical there is an MCP server: an AI assistant plans the address and the search fields, checks that the page is complete and publishes only when asked. See [REST API](/docs/rest-api/) and [Central administration](/docs/administration/).

## Fast without extra work

Anonymous pages are served from a full page cache that keeps a copy per language and device, templates are compiled to PHP, and the framework has no runtime dependencies to load. See [Caching](/docs/caching/).

## Numbers without tracking people

The native statistics count page views, article views and box appearances per day and per language, and never identify a visitor. They are read through the API, in the Admin and in a ready report. See [Logging and audit](/docs/logging/).

## What it asks of you

PHP 8.3 or newer, MySQL or MariaDB, and a Composer install. The rest of this site is the documentation: start with [Getting started](/docs/).',
    content_format = 'markdown',
    published = 1793534400
WHERE @post_site_id IS NOT NULL AND site_id = @blog_site_id AND title = 'Articles with the bundled box';

SET @post_article_id = (SELECT id FROM cms_articles WHERE site_id = @post_site_id ORDER BY id LIMIT 1);

UPDATE cms_article_translations
SET title = 'Co WBengine webu dává',
    introtext = 'Web na WBengine drží stránky, boxy, menu i články v databázi a nabízí je ve více jazycích. Redaktoři i AI asistenti pracují přes API s klíči a o cache, statistiky a signály pro vyhledávače se stará framework.',
    bodytext = '## Stránky a boxy jsou v databázi

Stránka je řádek a boxy, které zobrazuje (navigace, článek, seznam, vaše vlastní třída v PHP se šablonou), jsou také řádky. Stránku přidáte, box přesunete do jiné sekce nebo stránku skryjete bez nasazování kódu. Stránka může být striktní a odpovídat jen na vlastní adresu, nebo dynamická: box za ní pak dostane zbytek adresy jako parametry a sám rozhodne, co je platné. Viz [Boxy](/cs/docs/boxes/).

## Jazyky jsou součástí

Každou stránku, položku menu i článek lze přeložit. Jazyk má vlastní prefix adresy (`/cs/`), šablona dostane odkazy na ostatní jazyky a navazují signály pro vyhledávače: `hreflang`, odkaz canonical a [sitemapa](/cs/docs/settings/), která uvádí každý jazyk stránky. Viz [Jazyky](/cs/docs/languages/).

## Řídí se zvenku a bezpečně

API umožňuje centrální administraci i vašim nástrojům spravovat obsah klíči, které mají jen zvolená oprávnění, lze je omezit na určité adresy a zanechávají záznam změn, kdo co změnil. Článek lze skrýt a znovu zobrazit. Pro redaktora, který není technik, je tu MCP server: AI asistent navrhne adresu a pole pro vyhledávače, zkontroluje, že je stránka úplná, a publikuje jen na požádání. Viz [REST API](/cs/docs/rest-api/) a [Centrální administrace](/cs/docs/administration/).

## Rychlé bez práce navíc

Anonymní stránky se podávají z plné cache stránek, která drží kopii pro každý jazyk a zařízení, šablony se překládají do PHP a framework nemá žádné závislosti, které by se za běhu načítaly. Viz [Cache](/cs/docs/caching/).

## Čísla bez sledování lidí

Vlastní statistiky počítají zobrazení stránek, články i boxů za den a po jazycích a nikdy neidentifikují návštěvníka. Čtou se přes API, v administraci a v hotovém reportu. Viz [Logování a audit](/cs/docs/logging/).

## Co od vás chce

PHP 8.3 nebo novější, MySQL nebo MariaDB a instalaci přes Composer. Zbytek tohoto webu je dokumentace: začněte [Začínáme](/cs/docs/).',
    content_format = 'markdown'
WHERE @post_article_id IS NOT NULL AND article_id = @post_article_id AND locale = 'cs' AND title = 'Články s dodávaným boxem';

-- The article box now shows the article on its own page, and /blog/ gets the overview box.
UPDATE cms_boxes
SET sites = JSON_ARRAY(CAST(@post_site_id AS CHAR))
WHERE @post_site_id IS NOT NULL AND name = 'Article blog box' AND JSON_CONTAINS(sites, JSON_QUOTE(CAST(@blog_site_id AS CHAR)));

INSERT INTO cms_boxes (name, module, method, section_id, static, shared, device_min, device_strict, acl, `order`, sites)
SELECT 'Blog overview', 'blog', 'overview', 1, 1, 0, 1, 0, 0, 0, JSON_ARRAY(CAST(@blog_site_id AS CHAR))
FROM DUAL
WHERE @blog_site_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cms_boxes WHERE name = 'Blog overview');

COMMIT;
