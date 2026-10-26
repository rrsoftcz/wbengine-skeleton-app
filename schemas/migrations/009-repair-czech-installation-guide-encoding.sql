-- Repair the Czech text appended by migration 008 when mysql connected as latin1.
-- SET NAMES is required for the UTF-8 literals in this file.
SET NAMES utf8mb4;

UPDATE `cms_article_translations`
SET `bodytext` = CONCAT(
    LEFT(
      `bodytext`,
      LOCATE('## Å˜eÅ¡enÃ­ chyb instalace a vÃ½jimek', `bodytext`) - 1
    ),
    '\n\n## Řešení chyb instalace a výjimek\n\nPři startu Dockeru spustí webový kontejner před Apache `bin/wbe install`. Pokud chybí, vytvoří `src/Config/Settings.json` s jedinečnými JWT klíči, ověří JSON, připraví `src/View/Compiled` a nainstaluje závislosti podle `composer.lock`. Existující nastavení zachová. Stačí spustit `docker compose up --build`; PHP ani Composer na hostiteli nepotřebujete.\n\nPokud start skončí chybou, přečtěte výpis `Install error:` a použijte `docker compose logs web`. Instalátor zvlášť rozpozná chybějící výchozí soubor, chybný JSON, nečitelnou konfiguraci, nezapisovatelnou složku kompilovaných šablon i chybu Composeru. JSON nevytvářejte příkazem `echo` s escapovanými uvozovkami.\n\nWebový proces musí zapisovat do `src/View/Compiled`. Docker oprávnění připraví pro Apache. U PHP-FPM nastavte vlastnictví nebo omezené skupinové právo zápisu uživateli PHP-FPM. Nikdy nepoužívejte `chmod 777`.\n\nPro místní ladění nastavte `debug` na `true` v `Settings.json`. Pokud soubor chybí nebo obsahuje chybný JSON, podrobnou exception šablonu zapne `WBENGINE_DEBUG=1`, ale jen v soukromém vývojovém prostředí. Před zveřejněním ladění vypněte. Produkční stránka ukáže bezpečné vysvětlení a referenční kód; podrobnosti jsou v PHP nebo kontejnerovém error logu pod stejným kódem.'
  )
WHERE `article_id` = 2
  AND `locale` = 'cs'
  AND LOCATE('## Å˜eÅ¡enÃ­ chyb instalace a vÃ½jimek', `bodytext`) > 0;
