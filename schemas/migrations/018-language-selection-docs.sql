-- Language selection in the central Admin (lists, language select, hidden history).
-- Content-only migration; the LOCATE checks make it safe to rerun. Back up before applying.
SET NAMES utf8mb4;

UPDATE cms_articles
SET bodytext = REPLACE(bodytext, 'Open an article, a page or a menu item. The right column shows **Language versions**: every language of the site with the state **Original**, **Translation exists** or **Translation missing**. Use **Edit original** for the large form, or **Edit translation** and **Add translation** for the language you chose.', 'The lists of articles, pages and menu items have a **Languages** column such as "3 of 20 languages"; expanding it shows which languages are missing. In a record, the **Content language** select above the form groups the languages as original, translated and missing. Choosing a language loads its content into the same form. The history of changes is hidden until you click **Show history**. The status of translations needs WBengine 4.7.0 or newer on the site.')
WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) AND title = 'Central administration' ORDER BY id LIMIT 1) AS a)
  AND LOCATE('Content language', bodytext) = 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, 'Otevřete článek, stránku nebo položku menu. V pravém sloupci jsou **Jazykové verze**: každý jazyk webu se stavem **Originál**, **Překlad existuje** nebo **Překlad zatím chybí**. Pro velký formulář použijte **Upravit originál**, pro vybraný jazyk **Upravit překlad** nebo **Přidat překlad**.', 'V seznamech článků, stránek a menu je sloupec **Jazyky**, například „3 z 20 jazyků“. Po rozkliknutí se ukáže, které jazyky chybí. V záznamu je nad formulářem roletka **Jazyk obsahu**, která jazyky seskupuje na originál, přeloženo a chybí. Po výběru jazyka se jeho obsah načte do téhož formuláře. Historie změn je skrytá, dokud neklepnete na **Zobrazit historii**. Stav překladů vyžaduje na webu WBengine 4.7.0 nebo novější.')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) AND title = 'Central administration' ORDER BY id LIMIT 1) AS a)
  AND locale = 'cs'
  AND LOCATE('Jazyk obsahu', bodytext) = 0;
