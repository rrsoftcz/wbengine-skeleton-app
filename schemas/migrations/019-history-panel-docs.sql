-- History of changes moved to the side panel in the central Admin.
-- Content-only migration; REPLACE is a no-op when the text is already updated.
SET NAMES utf8mb4;

UPDATE cms_articles
SET bodytext = REPLACE(bodytext, 'The history of changes is hidden until you click **Show history**.', 'The last five changes appear in the right panel; the full history with restore opens through **All changes and restore**.')
WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) AND title = 'Central administration' ORDER BY id LIMIT 1) AS a);

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, 'Historie změn je skrytá, dokud neklepnete na **Zobrazit historii**.', 'Posledních pět změn je v pravém panelu, úplná historie s obnovou se otevře odkazem **Všechny změny a obnova**.')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) AND title = 'Central administration' ORDER BY id LIMIT 1) AS a)
  AND locale = 'cs';
