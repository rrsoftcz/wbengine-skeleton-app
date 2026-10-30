-- Central administration documentation: how a site gets the integrations page. Each UPDATE runs only while the text is missing, so the migration is safe to rerun.
SET NAMES utf8mb4;

UPDATE cms_articles
SET bodytext = REPLACE(bodytext, 'Typical problems and their meaning:', 'A site that does not have the integrations page yet gets it with one command, run in the site directory: `vendor/bin/wbengine.php integrations:install --root=src --config=src/Config/Settings.json`. Without further options it only lists what it would create. With `--apply` it creates the application class, the page `/integrations/` (for signed-in users only), the section and the box record. Existing records and files are never changed, so the command can be run again. It also lists what still prevents issuing a key, for example API v2 being disabled or missing database updates.

Typical problems and their meaning:')
WHERE LOCATE('Typical problems and their meaning:', bodytext) > 0 AND LOCATE('integrations:install', bodytext) = 0;

UPDATE cms_articles
SET bodytext = REPLACE(bodytext, 'Typické potíže a jejich význam:', 'Web, který stránku integrací ještě nemá, ji získá jedním příkazem spuštěným v adresáři webu: `vendor/bin/wbengine.php integrations:install --root=src --config=src/Config/Settings.json`. Bez dalších voleb jen vypíše, co by vytvořil. S volbou `--apply` vytvoří aplikační třídu, stránku `/integrations/` (jen pro přihlášené), sekci a záznam boxu. Existující záznamy a soubory nikdy nemění, takže příkaz lze spustit opakovaně. Vypíše také, co ještě brání vydání klíče, například vypnuté API v2 nebo chybějící databázové aktualizace.

Typické potíže a jejich význam:')
WHERE LOCATE('Typické potíže a jejich význam:', bodytext) > 0 AND LOCATE('integrations:install', bodytext) = 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, 'Typical problems and their meaning:', 'A site that does not have the integrations page yet gets it with one command, run in the site directory: `vendor/bin/wbengine.php integrations:install --root=src --config=src/Config/Settings.json`. Without further options it only lists what it would create. With `--apply` it creates the application class, the page `/integrations/` (for signed-in users only), the section and the box record. Existing records and files are never changed, so the command can be run again. It also lists what still prevents issuing a key, for example API v2 being disabled or missing database updates.

Typical problems and their meaning:')
WHERE LOCATE('Typical problems and their meaning:', bodytext) > 0 AND LOCATE('integrations:install', bodytext) = 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, 'Typické potíže a jejich význam:', 'Web, který stránku integrací ještě nemá, ji získá jedním příkazem spuštěným v adresáři webu: `vendor/bin/wbengine.php integrations:install --root=src --config=src/Config/Settings.json`. Bez dalších voleb jen vypíše, co by vytvořil. S volbou `--apply` vytvoří aplikační třídu, stránku `/integrations/` (jen pro přihlášené), sekci a záznam boxu. Existující záznamy a soubory nikdy nemění, takže příkaz lze spustit opakovaně. Vypíše také, co ještě brání vydání klíče, například vypnuté API v2 nebo chybějící databázové aktualizace.

Typické potíže a jejich význam:')
WHERE LOCATE('Typické potíže a jejich význam:', bodytext) > 0 AND LOCATE('integrations:install', bodytext) = 0;

