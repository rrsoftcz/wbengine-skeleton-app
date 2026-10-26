-- Refresh only the built-in English and Czech Getting started articles.
-- Repeatable by design. Review custom edits to article 2 before applying.
SET NAMES utf8mb4;
START TRANSACTION;

UPDATE cms_articles
SET title = 'Getting started',
    introtext = 'Install the WBengine 4.0 skeleton, review its Composer requirements, and run the bundled site locally before changing its content.',
    bodytext = '## Requirements

- PHP 8.3 or newer with `mysqli` and the extensions required by Composer dependencies.
- MySQL 8 or MariaDB 10.6 or newer.
- Apache with `mod_rewrite`, or Nginx with PHP-FPM.
- Composer 2. Docker is optional.

The application requires `wbengine/wbengine:^4.0`. The framework currently brings `firebase/php-jwt`; its template engine and Markdown parser are included. Check package metadata for the exact PHP platform requirements of the release you install.

## Docker quick start

```bash
git clone https://github.com/rrsoftcz/wbengine-skeleton-app
cd wbengine-skeleton-app
docker compose up --build
```

Open `http://localhost:8080`. On startup, the web container runs `bin/wbe install`: it creates and validates `Settings.json`, prepares the compiled-template directory and installs locked dependencies. The demo login is `admin@example.com` with password `changeme`. Change it before exposing the site.

## Manual setup

Run `php bin/wbe install` to create and validate settings, prepare `src/View/Compiled`, and install dependencies from `composer.lock`. The command reports invalid JSON, unreadable settings, unwritable compiled cache and Composer failures. Never use `chmod 777`; grant write access to the PHP web-server user. For local debugging only, set `debug` to `true` or `WBENGINE_DEBUG=1`. Remove debug mode before going live.

```bash
php bin/wbe install
```

Create a database, import `schemas/wbengine_skeletone_app_mysql_template.sql` and then `schemas/wbengine_skeletone_app_mysql_template_content.sql`. Configure `src/Config/Settings.json` and point the web root to `public/`.

## Installation and exception troubleshooting

In development, set `debug` to `true` in `Settings.json` to show the WBengine exception template with the exception type, message, file, line and stack trace. If settings are missing or malformed, use `WBENGINE_DEBUG=1` only in a private development environment. Never expose debug output publicly. The production error page shows a safe explanation and reference code; find the full exception in the PHP or container error log under that code.

For upgrades, back up the database and apply pending scripts in `schemas/migrations/` in order. Docker imports the schema and seed files only when it initializes a new database volume. Rebuilding the web image does not update an existing database.',
    content_format = 'markdown'
WHERE id = 2;

INSERT INTO cms_article_translations
    (article_id, locale, title, introtext, bodytext, content_format)
VALUES
    (2, 'cs', 'Začínáme', 'Nainstalujte skeleton WBengine 4.0, ověřte jeho Composer požadavky a spusťte web lokálně, než začnete měnit jeho obsah.', '## Požadavky

- PHP 8.3 nebo novější s rozšířením `mysqli` a rozšířeními vyžadovanými Composer balíčky.
- MySQL 8 nebo MariaDB 10.6 a novější.
- Apache s `mod_rewrite` nebo Nginx s PHP-FPM.
- Composer 2. Docker je volitelný.

Aplikace vyžaduje `wbengine/wbengine:^4.0`. Framework aktuálně přináší `firebase/php-jwt`; template engine i parser Markdownu jsou jeho součástí. Přesné požadavky na PHP ověřte v metadatech instalované verze.

## Rychlé spuštění v Dockeru

```bash
git clone https://github.com/rrsoftcz/wbengine-skeleton-app
cd wbengine-skeleton-app
docker compose up --build
```

Otevřete `http://localhost:8080`. Při startu webový kontejner spustí `bin/wbe install`: vytvoří a ověří `Settings.json`, připraví složku kompilovaných šablon a nainstaluje uzamčené závislosti. Demo účet je `admin@example.com`, heslo `changeme`. Před zpřístupněním webu heslo změňte.

## Ruční instalace

Příkaz `php bin/wbe install` vytvoří a ověří nastavení, připraví `src/View/Compiled` a nainstaluje závislosti podle `composer.lock`. Oznámí chybný JSON, nečitelná nastavení, nezapisovatelnou cache šablon i chyby Composeru. Nepoužívejte `chmod 777`; právo zápisu přidělte uživateli PHP webserveru. Pro lokální diagnostiku nastavte `debug` na `true` nebo `WBENGINE_DEBUG=1`. Před nasazením debug vypněte.

```bash
php bin/wbe install
```

Vytvořte databázi, importujte `schemas/wbengine_skeletone_app_mysql_template.sql` a potom `schemas/wbengine_skeletone_app_mysql_template_content.sql`. Nastavte `src/Config/Settings.json` a jako kořen webu použijte `public/`.

## Řešení chyb instalace a výjimek

Při vývoji nastavte v `Settings.json` `debug` na `true`. Šablona WBengine zobrazí typ výjimky, zprávu, soubor, řádek a trasu volání. Pokud nastavení chybí nebo obsahuje neplatný JSON, použijte `WBENGINE_DEBUG=1` pouze v soukromém vývojovém prostředí. Ladicí výstup nikdy nezpřístupňujte veřejně. Produkční stránka zobrazí bezpečné vysvětlení a referenční kód; úplnou výjimku najdete v PHP nebo kontejnerovém error logu pod stejným kódem.

Před upgradem databázi zálohujte a dosud nepoužité skripty v `schemas/migrations/` aplikujte v pořadí. Docker importuje schéma a seed pouze při vytvoření nového databázového volume. Rebuild webového image existující databázi nezmění.', 'markdown')
ON DUPLICATE KEY UPDATE
    title = VALUES(title),
    introtext = VALUES(introtext),
    bodytext = VALUES(bodytext),
    content_format = VALUES(content_format);

COMMIT;
