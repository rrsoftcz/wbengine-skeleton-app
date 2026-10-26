-- Refresh the existing Getting started article with the real Docker installer flow.
-- Safe to re-run: command replacements are idempotent and the guide section has a marker.
SET NAMES utf8mb4;

UPDATE `cms_articles`
SET `bodytext` = REPLACE(
    REPLACE(
      REPLACE(`bodytext`,
        'docker compose up -d --build\ndocker compose exec web sh bin/setup.sh',
        'docker compose up --build'),
      'composer install\nsh bin/setup.sh',
      'php bin/wbe install'),
    '## Manual setup',
    '## Manual setup')
WHERE `id` = 2;

UPDATE `cms_articles`
SET `bodytext` = IF(
    `bodytext` LIKE '%## Installer and startup diagnostics%',
    `bodytext`,
    CONCAT(`bodytext`, '\n\n## Installer and startup diagnostics\n\nOn Docker startup, the web container runs `bin/wbe install` before Apache. It creates `src/Config/Settings.json` with unique JWT keys when the file is missing, validates its JSON, prepares `src/View/Compiled`, and installs dependencies from `composer.lock`. Existing settings are preserved. Run `docker compose up --build`; host PHP and Composer are not needed.\n\nIf startup stops, read the `Install error:` output and run `docker compose logs web`. The installer reports missing defaults, malformed JSON, unreadable settings, an unwritable compiled-template directory, and Composer failures separately. Do not create JSON through shell-quoted `echo` commands.\n\nThe web process needs write access to `src/View/Compiled`. Docker configures this for Apache. For PHP-FPM, grant ownership or restricted group write access to the PHP-FPM user. Never use `chmod 777`.\n\nFor local debugging, set `debug` to `true` in `Settings.json`. If the file is missing or malformed, `WBENGINE_DEBUG=1` enables the detailed exception template only in a private development environment. Turn debugging off before publishing. Production errors show a safe explanation and reference code; full details are in the PHP or container error log under that code.'))
WHERE `id` = 2;

UPDATE `cms_article_translations`
SET `bodytext` = REPLACE(
    REPLACE(
      REPLACE(`bodytext`,
        'docker compose up -d --build\ndocker compose exec web sh bin/setup.sh',
        'docker compose up --build'),
      'composer install\nsh bin/setup.sh',
      'php bin/wbe install'),
    '## Ruční instalace',
    '## Ruční instalace')
WHERE `article_id` = 2 AND `locale` = 'cs';

UPDATE `cms_article_translations`
SET `bodytext` = IF(
    `bodytext` LIKE '%## Řešení chyb instalace a výjimek%',
    `bodytext`,
    CONCAT(`bodytext`, '\n\n## Řešení chyb instalace a výjimek\n\nPři startu Dockeru spustí webový kontejner před Apache `bin/wbe install`. Pokud chybí, vytvoří `src/Config/Settings.json` s jedinečnými JWT klíči, ověří JSON, připraví `src/View/Compiled` a nainstaluje závislosti podle `composer.lock`. Existující nastavení zachová. Stačí spustit `docker compose up --build`; PHP ani Composer na hostiteli nepotřebujete.\n\nPokud start skončí chybou, přečtěte výpis `Install error:` a použijte `docker compose logs web`. Instalátor zvlášť rozpozná chybějící výchozí soubor, chybný JSON, nečitelnou konfiguraci, nezapisovatelnou složku kompilovaných šablon i chybu Composeru. JSON nevytvářejte příkazem `echo` s escapovanými uvozovkami.\n\nWebový proces musí zapisovat do `src/View/Compiled`. Docker oprávnění připraví pro Apache. U PHP-FPM nastavte vlastnictví nebo omezené skupinové právo zápisu uživateli PHP-FPM. Nikdy nepoužívejte `chmod 777`.\n\nPro místní ladění nastavte `debug` na `true` v `Settings.json`. Pokud soubor chybí nebo obsahuje chybný JSON, podrobnou exception šablonu zapne `WBENGINE_DEBUG=1`, ale jen v soukromém vývojovém prostředí. Před zveřejněním ladění vypněte. Produkční stránka ukáže bezpečné vysvětlení a referenční kód; úplné podrobnosti jsou v PHP nebo kontejnerovém error logu pod stejným kódem.'))
WHERE `article_id` = 2 AND `locale` = 'cs';
