-- Documentation page /docs/performance/: how fast the framework core assembles a page, measured in an isolated local environment, English and Czech.
-- Idempotent: every row is created only when it is missing, so edits made later in the Admin survive a rerun.
SET NAMES utf8mb4;

SET @performance_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/performance/' ORDER BY site_id LIMIT 1);
INSERT INTO cms_sites (parent_id, left_id, right_id, strict, visible, link, title, html_title, html_description, html_keywords, acl)
SELECT 1, 0, 0, 1, 1, '/docs/performance/', 'Performance', 'Performance: how fast the core assembles a page', 'How long the WBengine core needs to assemble a page, with and without caches: measured in an isolated local environment, with the method, the limits and how to repeat it.', 'performance,benchmark,cache', 0
WHERE @performance_site_id IS NULL;
SET @performance_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/performance/' ORDER BY site_id LIMIT 1);

INSERT INTO cms_site_translations (site_id, locale, title, html_title, html_description, html_keywords)
SELECT @performance_site_id, 'cs', 'Výkon', 'Výkon: jak rychle jádro sestaví stránku', 'Jak dlouho jádro WBengine sestavuje stránku, s cache i bez nich: změřeno v izolovaném lokálním prostředí, s postupem, mezemi a návodem, jak měření zopakovat.', 'výkon,benchmark,cache'
WHERE NOT EXISTS (SELECT 1 FROM cms_site_translations WHERE site_id = @performance_site_id AND locale = 'cs');

INSERT INTO cms_articles (site_id, grouped, futured, c_enabled, views, title, introtext, bodytext, content_format, published, author, source)
SELECT @performance_site_id, 0, 0, 0, 0, 'Performance', 'How long the framework core needs to assemble a page, measured in an isolated local environment. Not a website speed test.', '## What is measured

The time the framework core needs to assemble a page: from the start of the request script, through the autoloader, the route, the Site, its Sections, Boxes and Models and the Renderer, to the moment the response is ready to be sent.

It is not the speed of a website. It leaves out the network, the web server, the hosting and the browser. How fast a website feels also depends on its content, images, scripts, the hosting and the visitor''s connection, so WBengine claims no number for it. A measurement of the browser, such as the largest contentful paint, is much larger than the time below: it includes the network and the painting.

## Results

The time in PHP until the response is ready, in an isolated local environment, and the number of SQL queries of that request.

| Case | Median | 95th percentile | Requests per second | SQL queries |
|---|---:|---:|---:|---:|
| Anonymous visitor, no cache at all | 7.1 ms | 10.7 ms | 428 | 6 |
| Anonymous visitor, data cache warm | 5.7 ms | 7.6 ms | 488 | 2 |
| Anonymous visitor, full-page cache hit | 1.8 ms | 2.2 ms | 1,308 | 0 |
| Logged-in user, no cache at all | 12.4 ms | 13.0 ms | 284 | 10 |
| Logged-in user, data cache warm | 10.3 ms | 11.4 ms | 345 | 6 |
| Route that answers without a page | 1.6 ms | 1.8 ms | 1,466 | 0 |

The home page of this skeleton is assembled in about 7 ms with every cache off, in about 6 ms with the data cache warm and in about 2 ms from the full-page cache. A logged-in user is never served from the full-page cache. The requests per second are for four clients at once.

## How it was measured

On 1 November 2026 with WBengine 6.7.0, PHP 8.4.27 and MySQL 8.4.13, in an isolated Docker Compose project on a developer laptop. A PHP built-in server with four workers, the client on the same machine (no network), OPcache enabled as on a production server, 20 requests per case, each on a new connection. The data was the one of this skeleton: 24 pages, 17 articles and 29 boxes. All SQL of the framework is counted.

A run with OPcache switched off gave medians that differed by about a millisecond at most (7.1 ms for an anonymous visitor with no cache in both runs), so these numbers do not depend on OPcache. The whole HTTP request, including the connection and the transfer, took about 0.4 ms longer than the time in PHP.

## How to repeat it

In an environment prepared as for the smoke test of the skeleton (see the README):

```sh
docker compose -p wbengine-skeleton-modernization -f compose.smoke.yml run --rm -T tools php tests/benchmark-cms.php
```

The result is printed as JSON. With `-e WB_BENCHMARK_OPCACHE=0` the server runs without OPcache. The recorded result of the run above is in `tests/benchmark-cms-result.json`.

## What to keep in mind

- A test on a laptop is not a promise for your server. The hardware, the size of the database, the number of boxes on a page and the PHP settings decide.
- Each case has 20 samples, so the 95th percentile is close to the slowest request. Repeat the test on your own hardware before you rely on it.
- A page with more boxes and queries takes longer than the home page of this skeleton. The caches exist for that: see [Caching](/docs/caching/).
- This is not a comparison with other frameworks.', 'markdown', UNIX_TIMESTAMP(), 'RRSOFT', 'https://www.wbengine.org/'
WHERE NOT EXISTS (SELECT 1 FROM cms_articles WHERE site_id = @performance_site_id);
SET @performance_article_id = (SELECT id FROM cms_articles WHERE site_id = @performance_site_id ORDER BY id LIMIT 1);

INSERT INTO cms_article_translations (article_id, locale, title, introtext, bodytext, content_format)
SELECT @performance_article_id, 'cs', 'Výkon', 'Jak dlouho jádro frameworku sestavuje stránku, změřeno v izolovaném lokálním prostředí. Není to test rychlosti webu.', '## Co se měří

Doba, kterou jádro frameworku potřebuje k sestavení stránky: od začátku skriptu požadavku přes autoloader, trasu, Site, její Section, Box a Model a Renderer až po okamžik, kdy je odpověď připravená k odeslání.

Není to rychlost webu. Měření vynechává síť, webový server, hosting i prohlížeč. Jak rychle web působí, závisí také na jeho obsahu, obrázcích, skriptech, hostingu a připojení návštěvníka, a proto WBengine žádné číslo pro to neuvádí. Měření prohlížeče, například vykreslení největšího prvku (LCP), je mnohem větší než doba níže: zahrnuje síť a vykreslení.

## Výsledky

Doba v PHP do okamžiku, kdy je odpověď připravená, v izolovaném lokálním prostředí, a počet SQL dotazů tohoto požadavku.

| Případ | Medián | 95. percentil | Požadavků za sekundu | SQL dotazů |
|---|---:|---:|---:|---:|
| Anonymní návštěvník, žádná cache | 7,1 ms | 10,7 ms | 428 | 6 |
| Anonymní návštěvník, zahřátá cache dat | 5,7 ms | 7,6 ms | 488 | 2 |
| Anonymní návštěvník, zásah cache celé stránky | 1,8 ms | 2,2 ms | 1 308 | 0 |
| Přihlášený uživatel, žádná cache | 12,4 ms | 13,0 ms | 284 | 10 |
| Přihlášený uživatel, zahřátá cache dat | 10,3 ms | 11,4 ms | 345 | 6 |
| Trasa, která odpovídá bez stránky | 1,6 ms | 1,8 ms | 1 466 | 0 |

Úvodní stránka této kostry se sestaví asi za 7 ms s vypnutými cache, asi za 6 ms se zahřátou cache dat a asi za 2 ms z cache celé stránky. Přihlášený uživatel se z cache celé stránky nikdy nepodává. Požadavky za sekundu platí pro čtyři klienty najednou.

## Jak se měřilo

1. listopadu 2026 s WBengine 6.7.0, PHP 8.4.27 a MySQL 8.4.13, v izolovaném projektu Docker Compose na vývojářském notebooku. Vestavěný server PHP se čtyřmi procesy, klient na stejném počítači (bez sítě), OPcache zapnutý jako na produkčním serveru, 20 požadavků na případ, každý na novém spojení. Data byla z této kostry: 24 stránek, 17 článků a 29 boxů. Počítají se všechny SQL dotazy frameworku.

Běh s vypnutým OPcache dal mediány, které se lišily nejvýše asi o milisekundu (v obou během 7,1 ms pro anonymního návštěvníka bez cache), takže tato čísla na OPcache nezávisejí. Celý požadavek HTTP včetně spojení a přenosu trval asi o 0,4 ms déle než doba v PHP.

## Jak to zopakovat

V prostředí připraveném jako pro smoke test kostry (viz README):

```sh
docker compose -p wbengine-skeleton-modernization -f compose.smoke.yml run --rm -T tools php tests/benchmark-cms.php
```

Výsledek se vypíše jako JSON. S `-e WB_BENCHMARK_OPCACHE=0` běží server bez OPcache. Zaznamenaný výsledek běhu výše je v `tests/benchmark-cms-result.json`.

## Na co pamatovat

- Test na notebooku není příslib pro váš server. Rozhoduje hardware, velikost databáze, počet boxů na stránce a nastavení PHP.
- Každý případ má 20 vzorků, takže 95. percentil je blízko nejpomalejšímu požadavku. Než se na čísla spolehnete, zopakujte test na vlastním hardwaru.
- Stránka s více boxy a dotazy trvá déle než úvodní stránka této kostry. Právě pro to existují cache: viz [Cache](/cs/docs/caching/).
- Není to srovnání s jinými frameworky.', 'markdown'
WHERE @performance_article_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cms_article_translations WHERE article_id = @performance_article_id AND locale = 'cs');

INSERT INTO cms_boxes (name, module, method, section_id, static, shared, device_min, device_strict, acl, `order`, sites)
SELECT 'Docs: Performance', 'docs', 'page', 1, 1, 0, 1, 0, 0, 0, JSON_ARRAY(CAST(@performance_site_id AS CHAR))
WHERE NOT EXISTS (SELECT 1 FROM cms_boxes WHERE name = 'Docs: Performance');
