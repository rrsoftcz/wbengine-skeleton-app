-- API v2 is the only API: the public documentation no longer describes the JWT login, the former routes or the signing keys, and the live request console is removed. Each UPDATE only replaces text that is still present, so the migration is safe to rerun.
SET NAMES utf8mb4;

UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'The framework brings `firebase/php-jwt`; its template engine and Markdown parser are included.', 'The framework has no further Composer dependencies; its template engine and Markdown parser are included.') WHERE LOCATE('The framework brings `firebase/php-jwt`; its template engine and Markdown parser are included.', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'generates private database and JWT secrets on the server', 'generates private database passwords on the server') WHERE LOCATE('generates private database and JWT secrets on the server', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'which also invalidates the user''s refresh tokens.', 'which also ends the user''s web sessions.') WHERE LOCATE('which also invalidates the user''s refresh tokens.', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'Keep `Settings.json`, JWT keys, passwords, and private keys', 'Keep `Settings.json`, passwords, and private keys') WHERE LOCATE('Keep `Settings.json`, JWT keys, passwords, and private keys', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'creates it from `src/Config/settings.json.default` with fresh JWT keys.', 'creates it from `src/Config/settings.json.default`.') WHERE LOCATE('creates it from `src/Config/settings.json.default` with fresh JWT keys.', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`, `WBENGINE_DEBUG`', '`WBENGINE_RECAPTCHA_SECRET`, `WBENGINE_DEBUG`') WHERE LOCATE('`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`, `WBENGINE_DEBUG`', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '(`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`)', '(`WBENGINE_RECAPTCHA_SECRET`)') WHERE LOCATE('(`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`)', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '  "jwt": { "accessKey": "", "refreshKey": "" },
', '') WHERE LOCATE('  "jwt": { "accessKey": "", "refreshKey": "" },
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'Leaving `jwt` empty in the file is only valid when both JWT variables are set in the environment of PHP, including the cron user and the container. Without them, put real random keys in the file. Where each', 'Where each') WHERE LOCATE('Leaving `jwt` empty in the file is only valid when both JWT variables are set in the environment of PHP, including the cron user and the container. Without them, put real random keys in the file. Where each', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'with fresh random JWT keys when the file is missing', 'when the file is missing') WHERE LOCATE('with fresh random JWT keys when the file is missing', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY` (at least 32 characters each, `openssl rand -hex 32`), `WBENGINE_RECAPTCHA_SECRET`', '`WBENGINE_RECAPTCHA_SECRET`') WHERE LOCATE('`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY` (at least 32 characters each, `openssl rand -hex 32`), `WBENGINE_RECAPTCHA_SECRET`', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'env[WBENGINE_JWT_KEY] = "..."
env[WBENGINE_JWT_REFRESH_KEY] = "..."', 'env[WBENGINE_RECAPTCHA_SECRET] = "..."') WHERE LOCATE('env[WBENGINE_JWT_KEY] = "..."
env[WBENGINE_JWT_REFRESH_KEY] = "..."', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '-e WBENGINE_JWT_KEY="..." -e WBENGINE_JWT_REFRESH_KEY="..." \\', '-e WBENGINE_RECAPTCHA_SECRET="..." \\') WHERE LOCATE('-e WBENGINE_JWT_KEY="..." -e WBENGINE_JWT_REFRESH_KEY="..." \\', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'Flush the cache with `POST /api/cache/flush` (administrator)', 'Flush the cache with `POST /api/v2/cache/flush` (an integration key with the `cache:write` scope, for example from the central administration)') WHERE LOCATE('Flush the cache with `POST /api/cache/flush` (administrator)', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '| `v1` | Legacy API: users, sections, translations, cache flush |', '| `v1` | Older entries written by a retired interface (no new ones) |') WHERE LOCATE('| `v1` | Legacy API: users, sections, translations, cache flush |', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '| `jwt.accessKey`, `jwt.refreshKey` | string, `CHANGE_ME` | Signing keys of login and API tokens, at least 32 characters and different. Overridden by `WBENGINE_JWT_KEY` and `WBENGINE_JWT_REFRESH_KEY`. Generate with `openssl rand -hex 32`. |
', '') WHERE LOCATE('| `jwt.accessKey`, `jwt.refreshKey` | string, `CHANGE_ME` | Signing keys of login and API tokens, at least 32 characters and different. Overridden by `WBENGINE_JWT_KEY` and `WBENGINE_JWT_REFRESH_KEY`. Generate with `openssl rand -hex 32`. |
', bodytext) > 0;
UPDATE cms_articles SET bodytext = '## The API

The **API v2** under `/api/v2` is the integration interface for trusted servers such as the separate central administration. It uses an issued integration key and scopes, HTTPS, finite resource and field allowlists, strong ETags for edits and audit records. It does not expose its key to browser JavaScript and does not enable browser CORS. It covers content, structure, users, translations, the cache flush and the change log. There is no login through the API: people sign in on the web at `/login/`.

Do not send an integration key from a user browser. The browser should call its own application server, which then contacts each WBengine site over verified HTTPS.

## API example

```bash
curl -H ''Authorization: Bearer <integration key>'' \\
  https://example.com/api/v2/identity
```

An administrator issues the key on the `/integrations/` page of the site.

## Keys and scopes

A key carries scopes that decide what it may do. A missing or invalid key returns `401`; a key without the required scope receives `403`. Write routes validate allowed fields.

For deployment diagnostics use `vendor/bin/wbengine.php doctor`; it does not change the schema. API v2 is enabled separately in application configuration and needs its database tables for protected content operations (see the Deployment page). Its discovery, capabilities, resources, scopes and concurrency rules are described in the [WBengine API v2 reference](https://github.com/rrsoftcz/wbengine/blob/main/ref-api-v2.md). See also the [central administration guide](/docs/administration/).' WHERE id = 9 AND LOCATE('/api/auth/login', bodytext) > 0;

UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'Framework přináší `firebase/php-jwt`; template engine i parser Markdownu jsou jeho součástí.', 'Framework nemá další závislosti v Composeru; template engine i parser Markdownu jsou jeho součástí.') WHERE LOCATE('Framework přináší `firebase/php-jwt`; template engine i parser Markdownu jsou jeho součástí.', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'na serveru vytvoří soukromé databázové a JWT klíče', 'na serveru vytvoří soukromá hesla databáze') WHERE LOCATE('na serveru vytvoří soukromé databázové a JWT klíče', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'který zároveň zneplatní refresh tokeny uživatele', 'který zároveň ukončí webové relace uživatele') WHERE LOCATE('který zároveň zneplatní refresh tokeny uživatele', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '`Settings.json`, JWT klíče, hesla ani privátní klíče', '`Settings.json`, hesla ani privátní klíče') WHERE LOCATE('`Settings.json`, JWT klíče, hesla ani privátní klíče', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'ho vytvoří ze `src/Config/settings.json.default` s novými klíči JWT.', 'ho vytvoří ze `src/Config/settings.json.default`.') WHERE LOCATE('ho vytvoří ze `src/Config/settings.json.default` s novými klíči JWT.', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`, `WBENGINE_DEBUG`', '`WBENGINE_RECAPTCHA_SECRET`, `WBENGINE_DEBUG`') WHERE LOCATE('`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`, `WBENGINE_DEBUG`', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '(`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`)', '(`WBENGINE_RECAPTCHA_SECRET`)') WHERE LOCATE('(`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`)', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '  "jwt": { "accessKey": "", "refreshKey": "" },
', '') WHERE LOCATE('  "jwt": { "accessKey": "", "refreshKey": "" },
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'Prázdné `jwt` v souboru platí jen tehdy, když jsou obě proměnné JWT nastavené v prostředí PHP, včetně uživatele cronu a kontejneru. Jinak do souboru vložte skutečné náhodné klíče. Kde co', 'Kde co') WHERE LOCATE('Prázdné `jwt` v souboru platí jen tehdy, když jsou obě proměnné JWT nastavené v prostředí PHP, včetně uživatele cronu a kontejneru. Jinak do souboru vložte skutečné náhodné klíče. Kde co', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 's novými náhodnými klíči JWT, pokud soubor chybí', 'pokud soubor chybí') WHERE LOCATE('s novými náhodnými klíči JWT, pokud soubor chybí', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY` (každý nejméně 32 znaků, `openssl rand -hex 32`), `WBENGINE_RECAPTCHA_SECRET`', '`WBENGINE_RECAPTCHA_SECRET`') WHERE LOCATE('`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY` (každý nejméně 32 znaků, `openssl rand -hex 32`), `WBENGINE_RECAPTCHA_SECRET`', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'env[WBENGINE_JWT_KEY] = "..."
env[WBENGINE_JWT_REFRESH_KEY] = "..."', 'env[WBENGINE_RECAPTCHA_SECRET] = "..."') WHERE LOCATE('env[WBENGINE_JWT_KEY] = "..."
env[WBENGINE_JWT_REFRESH_KEY] = "..."', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '-e WBENGINE_JWT_KEY="..." -e WBENGINE_JWT_REFRESH_KEY="..." \\', '-e WBENGINE_RECAPTCHA_SECRET="..." \\') WHERE LOCATE('-e WBENGINE_JWT_KEY="..." -e WBENGINE_JWT_REFRESH_KEY="..." \\', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'voláním `POST /api/cache/flush` (správce)', 'voláním `POST /api/v2/cache/flush` (integrační klíč s oprávněním `cache:write`, například z centrální administrace)') WHERE LOCATE('voláním `POST /api/cache/flush` (správce)', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '| `v1` | Původní API: uživatelé, sekce, překlady, vyprázdnění cache |', '| `v1` | Starší záznamy zapsané již zrušeným rozhraním (nové nevznikají) |') WHERE LOCATE('| `v1` | Původní API: uživatelé, sekce, překlady, vyprázdnění cache |', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '| `jwt.accessKey`, `jwt.refreshKey` | řetězec, `CHANGE_ME` | Podpisové klíče přihlášení a tokenů API, nejméně 32 znaků a navzájem různé. Přepíší je `WBENGINE_JWT_KEY` a `WBENGINE_JWT_REFRESH_KEY`. Vygenerujte je příkazem `openssl rand -hex 32`. |
', '') WHERE LOCATE('| `jwt.accessKey`, `jwt.refreshKey` | řetězec, `CHANGE_ME` | Podpisové klíče přihlášení a tokenů API, nejméně 32 znaků a navzájem různé. Přepíší je `WBENGINE_JWT_KEY` a `WBENGINE_JWT_REFRESH_KEY`. Vygenerujte je příkazem `openssl rand -hex 32`. |
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = '## API

**API v2** pod `/api/v2` je integrační rozhraní pro důvěryhodné servery, například samostatnou centrální administraci. Používá vydaný integrační klíč a scopes, HTTPS, konečný seznam zdrojů a polí, silné ETagy pro zápis a audit. Klíč se neposílá do JavaScriptu prohlížeče a API nezapíná CORS. Pokrývá obsah, strukturu, uživatele, překlady, vyprázdnění cache a záznam změn. Přihlášení přes API neexistuje: lidé se přihlašují na webu na `/login/`.

Integrační klíč neposílejte z prohlížeče. Prohlížeč má volat vlastní aplikační server, který se potom přes ověřené HTTPS připojí ke každému webu WBengine.

## Příklad API

```bash
curl -H ''Authorization: Bearer <integrační klíč>'' \\
  https://example.com/api/v2/identity
```

Klíč vydá administrátor na stránce `/integrations/` webu.

## Klíče a scopes

Klíč nese scopes, které určují, co smí. Chybějící či neplatný klíč vrací `401`; klíč bez potřebného scope dostane `403`. Zapisovací cesty kontrolují povolená pole.

Pro diagnostiku nasazení použijte `vendor/bin/wbengine.php doctor`; příkaz schéma nemění. API v2 se zapíná samostatně v konfiguraci a pro chráněné obsahové operace vyžaduje své databázové tabulky (viz stránka Nasazení). Discovery, capabilities, zdroje, scopes a pravidla souběžných změn popisuje [referenční dokumentace WBengine API v2](https://github.com/rrsoftcz/wbengine/blob/main/ref-api-v2.md). Viz také [centrální administrace](/cs/docs/administration/).' WHERE article_id = 9 AND locale = 'cs' AND LOCATE('/api/auth/login', bodytext) > 0;

DELETE FROM cms_boxes WHERE module = 'demo' AND method = 'api';
DELETE FROM cms_boxes WHERE module = 'restapi' AND method = 'restapi';
DELETE FROM cms_sites WHERE link = '/api/';
DELETE FROM cms_sections WHERE `key` = 'api';
