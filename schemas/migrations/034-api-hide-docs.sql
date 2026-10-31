-- The API page mentions hiding articles. Each UPDATE only changes text that is still present, so the migration is safe to rerun.
SET NAMES utf8mb4;

UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'It covers content, structure, users, translations, the cache flush and the change log.', 'It covers content (including hiding and showing a published article), structure, users, translations, the cache flush and the change log.') WHERE LOCATE('It covers content, structure, users, translations, the cache flush and the change log.', bodytext) > 0;

UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'Pokrývá obsah, strukturu, uživatele, překlady, vyprázdnění cache a záznam změn.', 'Pokrývá obsah (včetně skrytí a opětovného zobrazení publikovaného článku), strukturu, uživatele, překlady, vyprázdnění cache a záznam změn.') WHERE LOCATE('Pokrývá obsah, strukturu, uživatele, překlady, vyprázdnění cache a záznam změn.', bodytext) > 0;

