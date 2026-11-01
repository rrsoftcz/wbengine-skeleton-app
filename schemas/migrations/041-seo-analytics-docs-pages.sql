-- Documentation pages /docs/seo/ (search engines) and /docs/analytics/ (statistics), English and Czech.
-- Idempotent: every row is created only when it is missing, so edits made later in the Admin survive a rerun.
SET NAMES utf8mb4;

SET @seo_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/seo/' ORDER BY site_id LIMIT 1);
INSERT INTO cms_sites (parent_id, left_id, right_id, strict, visible, link, title, html_title, html_description, html_keywords, acl)
SELECT 1, 0, 0, 1, 1, '/docs/seo/', 'Search engines', 'Search engines: sitemap, robots.txt, canonical', 'What a WBengine site sends to search engines: titles, addresses, canonical and language links, the sitemap and robots.txt, and the settings for them.', 'seo,sitemap,robots.txt,canonical,hreflang', 0
WHERE @seo_site_id IS NULL;
SET @seo_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/seo/' ORDER BY site_id LIMIT 1);

INSERT INTO cms_site_translations (site_id, locale, title, html_title, html_description, html_keywords)
SELECT @seo_site_id, 'cs', 'Vyhledávače', 'Vyhledávače: sitemapa, robots.txt, canonical', 'Co web na WBengine sděluje vyhledávačům: titulky, adresy, odkazy canonical a jazykové odkazy, sitemapa a robots.txt a jejich nastavení.', 'seo,sitemapa,robots.txt,canonical,hreflang'
WHERE NOT EXISTS (SELECT 1 FROM cms_site_translations WHERE site_id = @seo_site_id AND locale = 'cs');

INSERT INTO cms_articles (site_id, grouped, futured, c_enabled, views, title, introtext, bodytext, content_format, published, author, source)
SELECT @seo_site_id, 0, 0, 0, 0, 'Search engines', 'The titles, addresses, canonical and language links, the sitemap and robots.txt of a WBengine site, and how to set them.', '## What a site tells search engines

| Signal | Where it comes from |
|---|---|
| Browser title and description | the fields of the page, translated per language. The title should have at most 60 characters and no site name, the template adds it. The description should have 120 to 160 characters. |
| Address | the link of the page: lowercase letters, digits and hyphens, with a trailing slash, for example `/blog/spring-opening-hours/`. |
| Canonical link | every page has one `<link rel="canonical">` with the absolute address of the page in its own language. |
| Language links | `hreflang` links to every language of the page and `x-default` for the default language, with absolute addresses. |
| `/sitemap.xml` | the list of pages a visitor can open, once per language, with links to the other languages. |
| `/robots.txt` | what crawlers may visit, and where the sitemap is. |

The canonical link and the `hreflang` links use the same addresses, so a page and its translations point at each other consistently.

## The public address

All absolute addresses are built from `i18n.baseUrl`, for example `https://www.example.org`. Set it in production. Without it the address is taken from the `Host` header of the request, which the visitor controls, and the page cache then keeps one copy per host. See [Languages](/docs/languages/) and the [settings reference](/docs/settings/).

## The sitemap

`/sitemap.xml` is generated for every request, so a page that was just published is there at once. It lists a page when a visitor can open it: the page is visible, does not need a login and has no hidden article. A language of a page is listed only when the page has a translation; the default language is always listed.

Only the address of the page itself is listed. A page that is not strict is a dynamic page: the box behind it receives the rest of the address as parameters and decides which are valid, so the framework cannot list those addresses and does not guess them. A strict page answers only its own address. See [Boxes](/docs/boxes/).

The date of a page (`lastmod`) is the date of the newest published article of the page, and is left out for a page without an article. `changefreq` and `priority` are never written, because crawlers ignore them. One file holds up to 50,000 addresses. The sitemap needs the public address; without it, it answers 404.

## robots.txt

`/robots.txt` allows everything, lists the paths you name, and names the sitemap with its absolute address:

```
User-agent: *
Disallow: /login/

Sitemap: https://www.example.org/sitemap.xml
```

## Settings

| Key | Effect |
|---|---|
| `seo.disallow` | a list of paths for `robots.txt`, each starting with `/` |
| `seo.sitemapExclude` | a list of page links to leave out of the sitemap, for example `["/login/"]` |
| `seo.allowIndexing` | `false` closes the whole site to crawlers: `robots.txt` says `Disallow: /` and the sitemap answers 404. Use it on a staging copy. |

The skeleton leaves the login page out of the sitemap and names it in `robots.txt`.

## For editors

Nothing needs to be done by hand. The assistant of the [MCP server](/docs/mcp/) proposes the address, the browser title and the description for a new article, checks them before publishing, and warns when a language has no translated title or description for the page. Publishing the page puts it into the sitemap.

## What it does not do

- It does not redirect an old address to a new one. Changing the address of a visible page breaks the old links, so the assistant asks for confirmation first.
- It has no setting to hide a single page from search engines while keeping it visible.
- It writes one sitemap file, not an index of several files, and no sitemap of images or news.
- It does not submit the sitemap to search engines. Name it in their webmaster tools.', 'markdown', UNIX_TIMESTAMP(), 'RRSOFT', 'https://www.wbengine.org/'
WHERE NOT EXISTS (SELECT 1 FROM cms_articles WHERE site_id = @seo_site_id);
SET @seo_article_id = (SELECT id FROM cms_articles WHERE site_id = @seo_site_id ORDER BY id LIMIT 1);

INSERT INTO cms_article_translations (article_id, locale, title, introtext, bodytext, content_format)
SELECT @seo_article_id, 'cs', 'Vyhledávače', 'Titulky, adresy, odkazy canonical a jazykové odkazy, sitemapa a robots.txt webu na WBengine a jejich nastavení.', '## Co web sděluje vyhledávačům

| Signál | Odkud pochází |
|---|---|
| Titulek prohlížeče a popis | pole stránky, překládaná po jazycích. Titulek by měl mít nejvýš 60 znaků a bez názvu webu, ten doplní šablona. Popis by měl mít 120 až 160 znaků. |
| Adresa | odkaz stránky: malá písmena, číslice a pomlčky, s lomítkem na konci, například `/blog/jarni-oteviraci-doba/`. |
| Odkaz canonical | každá stránka má jeden `<link rel="canonical">` s absolutní adresou stránky ve vlastním jazyce. |
| Jazykové odkazy | odkazy `hreflang` na každý jazyk stránky a `x-default` pro výchozí jazyk, s absolutními adresami. |
| `/sitemap.xml` | seznam stránek, které návštěvník může otevřít, jednou pro každý jazyk, s odkazy na ostatní jazyky. |
| `/robots.txt` | kam smějí roboty a kde je sitemapa. |

Odkaz canonical a odkazy `hreflang` používají stejné adresy, takže stránka a její překlady na sebe ukazují shodně.

## Veřejná adresa

Všechny absolutní adresy se skládají z `i18n.baseUrl`, například `https://www.example.org`. V ostrém provozu ji nastavte. Bez ní se adresa bere z hlavičky `Host` požadavku, kterou ovládá návštěvník, a cache stránek pak drží jednu kopii pro každého hostitele. Viz [Jazyky](/cs/docs/languages/) a [přehled nastavení](/cs/docs/settings/).

## Sitemapa

`/sitemap.xml` se generuje při každém požadavku, takže právě zveřejněná stránka je v ní hned. Stránka je uvedena, když ji návštěvník může otevřít: je viditelná, nevyžaduje přihlášení a nemá skrytý článek. Jazyk stránky je uveden jen tehdy, když má stránka překlad; výchozí jazyk je uveden vždy.

Uvádí se jen adresa samotné stránky. Stránka, která není striktní, je dynamická: box za ní dostane zbytek adresy jako parametry a sám rozhodne, které jsou platné, takže framework tyto adresy nemůže vypsat a nehádá je. Striktní stránka odpovídá jen na vlastní adresu. Viz [Boxy](/cs/docs/boxes/).

Datum stránky (`lastmod`) je datum nejnovějšího zveřejněného článku stránky a u stránky bez článku se vynechává. `changefreq` a `priority` se nikdy nepíšou, protože je roboty ignorují. Jeden soubor má nejvýš 50 000 adres. Sitemapa potřebuje veřejnou adresu; bez ní odpovídá 404.

## robots.txt

`/robots.txt` povoluje vše, vypíše cesty, které zvolíte, a uvede sitemapu s absolutní adresou:

```
User-agent: *
Disallow: /login/

Sitemap: https://www.example.org/sitemap.xml
```

## Nastavení

| Klíč | Účinek |
|---|---|
| `seo.disallow` | seznam cest pro `robots.txt`, každá začíná `/` |
| `seo.sitemapExclude` | seznam adres stránek vynechaných ze sitemapy, například `["/login/"]` |
| `seo.allowIndexing` | `false` zavře celý web pro roboty: `robots.txt` uvede `Disallow: /` a sitemapa odpovídá 404. Použijte u testovací kopie. |

Kostra vynechává přihlašovací stránku ze sitemapy a uvádí ji v `robots.txt`.

## Pro redaktory

Nic se nemusí dělat ručně. Asistent [MCP serveru](/cs/docs/mcp/) navrhne adresu, titulek prohlížeče a popis nového článku, před zveřejněním je zkontroluje a upozorní, když některý jazyk nemá přeložený titulek nebo popis stránky. Zveřejněním stránky se dostane do sitemapy.

## Co to neumí

- Nepřesměruje starou adresu na novou. Změna adresy viditelné stránky rozbije staré odkazy, proto se asistent napřed zeptá na potvrzení.
- Nemá nastavení, které by jednu stránku skrylo před vyhledávači a ponechalo ji viditelnou.
- Píše jeden soubor sitemapy, ne index více souborů, a žádnou sitemapu obrázků ani zpráv.
- Sitemapu vyhledávačům neodesílá. Uveďte ji v jejich nástrojích pro webmastery.', 'markdown'
WHERE @seo_article_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cms_article_translations WHERE article_id = @seo_article_id AND locale = 'cs');

INSERT INTO cms_boxes (name, module, method, section_id, static, shared, device_min, device_strict, acl, `order`, sites)
SELECT 'Docs: Search engines', 'docs', 'page', 1, 1, 0, 1, 0, 0, 0, JSON_ARRAY(CAST(@seo_site_id AS CHAR))
WHERE NOT EXISTS (SELECT 1 FROM cms_boxes WHERE name = 'Docs: Search engines');

SET @analytics_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/analytics/' ORDER BY site_id LIMIT 1);
INSERT INTO cms_sites (parent_id, left_id, right_id, strict, visible, link, title, html_title, html_description, html_keywords, acl)
SELECT 1, 0, 0, 1, 1, '/docs/analytics/', 'Statistics', 'Statistics: how views are counted', 'How a WBengine site counts page views, article views and box appearances without identifying visitors, by language, and how to switch it on and read the numbers.', 'analytics,statistics,page views', 0
WHERE @analytics_site_id IS NULL;
SET @analytics_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/analytics/' ORDER BY site_id LIMIT 1);

INSERT INTO cms_site_translations (site_id, locale, title, html_title, html_description, html_keywords)
SELECT @analytics_site_id, 'cs', 'Statistiky', 'Statistiky: jak se počítají zobrazení', 'Jak web na WBengine počítá zobrazení stránek, článků a boxů bez identifikace návštěvníků, po jazycích, a jak statistiky zapnout a číst.', 'analytika,statistiky,zobrazení'
WHERE NOT EXISTS (SELECT 1 FROM cms_site_translations WHERE site_id = @analytics_site_id AND locale = 'cs');

INSERT INTO cms_articles (site_id, grouped, futured, c_enabled, views, title, introtext, bodytext, content_format, published, author, source)
SELECT @analytics_site_id, 0, 0, 0, 0, 'Statistics', 'What the native statistics count and do not count, the split by language, how to switch them on and how to read the numbers.', '## What is counted

The site counts, per day and per language:

- page views: an anonymous visitor opens a public page and the answer is an HTML page with status 200,
- article views, for the article shown on the page,
- box appearances, for the boxes shown on the page.

It also keeps totals since counting began. The day is cut in the time zone you set, `UTC` by default.

## What is not counted

- Requests of a logged-in user and pages that need a login.
- Answers other than a normal HTML page: errors, redirects, the API, `/robots.txt` and `/sitemap.xml`.
- Anything about the visitor. There are no cookies, no addresses and no identifiers, so there are page views and no unique visitors.

A page view is a request. A robot that loads a page is counted like a person, so the numbers are not a count of people.

## By language

Views are recorded with the language of the page that was shown, and the totals are the sum of all languages. A site that records the language needs the database update `6.7.0/013-analytics-locale.sql`. Views counted before that update belong to no language: they are in the totals and shown as not recorded per language, and they are never assigned to a language by guess. A site that has not applied the update keeps counting as before, without the split.

## Switching it on

1. Apply the analytics tables and the language update with `sh bin/update-database.sh` (see [Deployment](/docs/deployment/)). Each file is safe to run again.
2. Set `analytics.enabled` to `true` in `Settings.json`, and the time zone (`analytics.timezone`) and the retention (`analytics.retentionDays`, 62 by default, 31 to 365). See the [settings reference](/docs/settings/).
3. Run `analytics:prune` from cron once a day, to remove daily rows older than the retention.
4. To read the numbers through the API, the Admin or the MCP server, issue a key with the Analytics choice on the Integrations page.

## Reading the numbers

- The central Admin has an analytics page per site: totals with the trend, a chart, the most viewed pages, articles and boxes, and the views by language. See [Central administration](/docs/administration/).
- The API returns the overview at `GET /api/v2/analytics/overview` with `from`, `to`, `granularity` (`day`, `week`, `month`) and an optional `locale`, for a key with the scope `analytics:read`. See [API](/docs/rest-api/).
- The [MCP server](/docs/mcp/) gives an assistant the same figures and writes a ready report with the change against the period before.

## Limits of the numbers

- Only the ten most viewed items of each list are returned, so a page that is not listed may still have views.
- Counting started on the day it was switched on. A period that starts earlier is marked as incomplete, because earlier days show zero only because nothing was counted.
- Daily rows are kept for the retention period only. A longer period is refused.
- The totals since counting began cover pages and boxes; the article total is the view counter of the articles.', 'markdown', UNIX_TIMESTAMP(), 'RRSOFT', 'https://www.wbengine.org/'
WHERE NOT EXISTS (SELECT 1 FROM cms_articles WHERE site_id = @analytics_site_id);
SET @analytics_article_id = (SELECT id FROM cms_articles WHERE site_id = @analytics_site_id ORDER BY id LIMIT 1);

INSERT INTO cms_article_translations (article_id, locale, title, introtext, bodytext, content_format)
SELECT @analytics_article_id, 'cs', 'Statistiky', 'Co vlastní statistiky počítají a nepočítají, rozpis po jazycích, jak je zapnout a jak číst čísla.', '## Co se počítá

Web počítá za každý den a po jazycích:

- zobrazení stránek: anonymní návštěvník otevře veřejnou stránku a odpovědí je stránka HTML se stavem 200,
- zobrazení článků, pro článek zobrazený na stránce,
- zobrazení boxů, pro boxy zobrazené na stránce.

Drží také součty od začátku počítání. Den se ukrajuje v časovém pásmu, které nastavíte, výchozí je `UTC`.

## Co se nepočítá

- Požadavky přihlášeného uživatele a stránky, které vyžadují přihlášení.
- Odpovědi, které nejsou běžná stránka HTML: chyby, přesměrování, API, `/robots.txt` a `/sitemap.xml`.
- Cokoli o návštěvníkovi. Žádné cookies, žádné adresy a žádné identifikátory, takže jsou zobrazení stránek a ne jedineční návštěvníci.

Zobrazení stránky je požadavek. Robot, který stránku načte, se počítá jako člověk, takže čísla nejsou počet lidí.

## Po jazycích

Zobrazení se zapisují s jazykem zobrazené stránky a součty jsou součtem všech jazyků. Web, který jazyk zaznamenává, potřebuje databázovou aktualizaci `6.7.0/013-analytics-locale.sql`. Zobrazení započtená před touto aktualizací nepatří žádnému jazyku: jsou v součtech a ukazují se jako bez záznamu jazyka a nikdy se jazyku nepřiřazují odhadem. Web, který aktualizaci nepoužil, počítá dál jako dřív, bez rozpisu.

## Zapnutí

1. Použijte tabulky analytiky a aktualizaci jazyka příkazem `sh bin/update-database.sh` (viz [Nasazení](/cs/docs/deployment/)). Každý soubor lze bezpečně spustit znovu.
2. V `Settings.json` nastavte `analytics.enabled` na `true`, časové pásmo (`analytics.timezone`) a uchování (`analytics.retentionDays`, výchozí 62, 31 až 365). Viz [přehled nastavení](/cs/docs/settings/).
3. Jednou denně spouštějte z cronu `analytics:prune`, který smaže denní řádky starší než uchování.
4. Aby šla čísla číst přes API, administraci nebo MCP server, vydejte na stránce Integrace klíč s volbou Analytika.

## Čtení čísel

- Centrální administrace má pro každý web stránku analytiky: součty s trendem, graf, nejzobrazovanější stránky, články a boxy a zobrazení po jazycích. Viz [Centrální administrace](/cs/docs/administration/).
- API vrací přehled na `GET /api/v2/analytics/overview` s parametry `from`, `to`, `granularity` (`day`, `week`, `month`) a volitelně `locale`, pro klíč s oprávněním `analytics:read`. Viz [API](/cs/docs/rest-api/).
- [MCP server](/cs/docs/mcp/) dává asistentovi stejná čísla a píše hotový report se změnou proti předchozímu období.

## Meze čísel

- Vrací se jen deset nejzobrazovanějších položek každého seznamu, takže stránka, která v seznamu není, může mít zobrazení.
- Počítání začalo v den zapnutí. Období, které začíná dříve, je označeno jako neúplné, protože dřívější dny ukazují nulu jen proto, že se nepočítalo.
- Denní řádky se drží jen po dobu uchování. Delší období je odmítnuto.
- Součty od začátku počítání se týkají stránek a boxů; součet článků je čítač zobrazení článků.', 'markdown'
WHERE @analytics_article_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cms_article_translations WHERE article_id = @analytics_article_id AND locale = 'cs');

INSERT INTO cms_boxes (name, module, method, section_id, static, shared, device_min, device_strict, acl, `order`, sites)
SELECT 'Docs: Statistics', 'docs', 'page', 1, 1, 0, 1, 0, 0, 0, JSON_ARRAY(CAST(@analytics_site_id AS CHAR))
WHERE NOT EXISTS (SELECT 1 FROM cms_boxes WHERE name = 'Docs: Statistics');
