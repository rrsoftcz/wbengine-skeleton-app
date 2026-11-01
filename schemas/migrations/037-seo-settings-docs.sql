-- The settings reference documents the "seo" settings (robots.txt and sitemap.xml, framework 6.6). Each UPDATE only runs while its heading is missing, so the migration is safe to rerun.
SET NAMES utf8mb4;

UPDATE cms_articles
SET bodytext = REPLACE(bodytext, '## Images and the API', '## Search engines

| Key | Type, default | Effect |
|-----|---------------|--------|
| `seo.allowIndexing` | bool, `true` | `false` closes the whole site to crawlers, for a staging copy: `robots.txt` says `Disallow: /` and `/sitemap.xml` answers 404. |
| `seo.disallow` | list of paths, empty | Paths named in `robots.txt`, each starting with `/`. |
| `seo.sitemapExclude` | list of page links, empty | Pages left out of `/sitemap.xml`, each starting with `/`. |

`/robots.txt` and `/sitemap.xml` are generated for every request and registered in `public/index.php`. The sitemap lists the visible public pages once per language, with links to the other languages, and leaves out pages that need a login and pages with a hidden article. A language is listed only when the page has a translation. Pages that take parameters in the address are listed by their own address only.

## Images and the API')
WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/settings/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND LOCATE('## Search engines', bodytext) = 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, '## Obrázky a API', '## Vyhledávače

| Klíč | Typ, výchozí hodnota | Účinek |
|------|----------------------|--------|
| `seo.allowIndexing` | pravda/nepravda, `true` | `false` zavře celý web pro roboty, například u testovací kopie: `robots.txt` uvede `Disallow: /` a `/sitemap.xml` vrací 404. |
| `seo.disallow` | seznam cest, prázdný | Cesty uvedené v `robots.txt`, každá začíná `/`. |
| `seo.sitemapExclude` | seznam adres stránek, prázdný | Stránky vynechané z `/sitemap.xml`, každá adresa začíná `/`. |

`/robots.txt` a `/sitemap.xml` se generují pro každý požadavek a registrují se v `public/index.php`. Sitemapa uvádí viditelné veřejné stránky jednou pro každý jazyk, s odkazy na ostatní jazyky, a vynechává stránky, které vyžadují přihlášení, i stránky se skrytým článkem. Jazyk se uvede jen tehdy, když má stránka překlad. Stránky, které berou v adrese parametry, se uvádějí jen vlastní adresou.

## Obrázky a API')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/settings/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND locale = 'cs'
  AND LOCATE('## Vyhledávače', bodytext) = 0;
