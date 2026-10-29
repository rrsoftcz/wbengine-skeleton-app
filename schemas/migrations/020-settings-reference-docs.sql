-- Settings reference page (schemas/migrations/020-settings-reference-docs.sql).
-- Idempotent: every row is created only when it is missing, so edits made later in the Admin survive a rerun.
SET NAMES utf8mb4;

SET @settings_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/settings/' ORDER BY site_id LIMIT 1);
INSERT INTO cms_sites (parent_id, left_id, right_id, strict, visible, link, title, html_title, html_description, html_keywords, acl)
SELECT 1, 0, 0, 1, 1, '/docs/settings/', 'Settings reference', 'Settings reference', 'Every Settings.json key: type, default, effect and example, a production configuration and the Google Analytics setting.', 'settings,configuration,Settings.json', 0
WHERE @settings_site_id IS NULL;
SET @settings_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/settings/' ORDER BY site_id LIMIT 1);

INSERT INTO cms_site_translations (site_id, locale, title, html_title, html_description, html_keywords)
SELECT @settings_site_id, 'cs', 'Přehled nastavení', 'Přehled nastavení', 'Každý klíč Settings.json: typ, výchozí hodnota, účinek a příklad, produkční konfigurace a nastavení Google Analytics.', 'nastavení,konfigurace,Settings.json'
WHERE NOT EXISTS (SELECT 1 FROM cms_site_translations WHERE site_id = @settings_site_id AND locale = 'cs');

INSERT INTO cms_articles (site_id, grouped, futured, c_enabled, views, title, introtext, bodytext, content_format, published, author, source)
SELECT @settings_site_id, 0, 0, 0, 0, 'Settings reference', 'Every key of Settings.json with its type, default, effect and an example, the environment overrides, a complete production configuration and the Google Analytics measurement id.', '## Where the settings live

All configuration is one JSON object in `src/Config/Settings.json`. The file is not committed: `bin/wbe install` creates it from `src/Config/settings.json.default` with fresh JWT keys. The framework reads it once per request; a missing key falls back to the default listed below, and a malformed value in `http`, `analytics` or the page cache policy throws an error instead of being ignored. After changing the file clear the cache (`POST /api/cache/flush`) and, when `renderer.compileCheck` is off, the compiled template directory. Check the result with `vendor/bin/wbengine.php config:check --config=src/Config/Settings.json --root=src`.

Secrets can come from the environment instead of the file: `WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`, `WBENGINE_DEBUG` and `WBENGINE_IMAGE_DIR`. An environment variable that is set and not empty wins over the file.

## General

| Key | Type, default | Effect |
|-----|---------------|--------|
| `timeZone` | string, `Europe/Prague` | PHP time zone of the application. Required. |
| `codePage` | string, `utf8` | Charset sent in the HTML header. Keep `utf8`. |
| `debug` | bool, `false` | Shows the debug bar and detailed errors. Never `true` in production. `WBENGINE_DEBUG` overrides it. |
| `minimizeHtml` | bool, `false` | Deprecated and ignored by the dispatcher since 4.0. Kept in the default file for old templates. |
| `minimizeCss` | bool, `false` | Combines and minimizes the files listed in `cssFiles`. |
| `minimizeJs` | bool, `false` | Same for scripts. Not in older files: add it explicitly, the framework reads the key directly. |
| `cssFiles` | array, `[]` | CSS files combined when `minimizeCss` is on. |
| `cdnPath` | string, empty | Prefix for static asset URLs, for example `https://cdn.example.com`. |
| `ipAdmins` | array, `[]` | List of administrator IP addresses. |

## Renderer

| Key | Type, default | Effect |
|-----|---------------|--------|
| `renderer.adapterName` | string, `NativeRenderer` | `NativeRenderer` or the optional `SmartyRenderer`. |
| `renderer.autoEscape` | bool, `true` | Escapes the output of template variables. `false` is only a migration aid for old templates. |
| `renderer.templatesDir` | string, `/View/` | Template directory under `src/`. |
| `renderer.compiledDir` | string, `Compiled/` | Compiled templates, must be writable by the PHP user. |
| `renderer.configDir` | string, `/Config/` | Template configuration directory. |
| `renderer.compileCheck` | bool, `true` | Checks on every request whether a template changed. Set `false` in production and empty the compiled directory on deploy. |

## Database

`dbAdapterDefinition` is an object: `adapterName` (`Mysqli`), `hostname`, `port`, `database`, `username`, `password`, `charset`. The default file points to the Docker host `db` with development credentials; replace all of them. Use `utf8mb4` as `charset` on a new installation. There is no environment override for the database password, so protect the file (`chmod 640`).

## Secrets

| Key | Type, default | Effect |
|-----|---------------|--------|
| `jwt.accessKey`, `jwt.refreshKey` | string, `CHANGE_ME` | Signing keys of login and API tokens, at least 32 characters and different. Overridden by `WBENGINE_JWT_KEY` and `WBENGINE_JWT_REFRESH_KEY`. Generate with `openssl rand -hex 32`. |
| `recaptcha.secretKey` | string, empty | Secret of the login form captcha. Empty means the captcha check fails closed. Overridden by `WBENGINE_RECAPTCHA_SECRET`. With `recaptcha.enabled: true` the `doctor` command requires it. |

## Proxies and HTTPS

| Key | Type, default | Effect |
|-----|---------------|--------|
| `http.trustedProxies` | array, `[]` | Exact addresses or CIDR ranges of reverse proxies whose forwarding headers are believed. Empty means every header is ignored. |
| `http.forwardedHeaders` | array, `[]` | Opt-in headers: `x-forwarded-for` (client address) and `x-forwarded-proto` (original scheme). Other values are rejected. |

Behind host Nginx or a load balancer set both, otherwise the site thinks every visitor has the proxy address and uses plain HTTP: session cookies are not secure, rate limit keys are shared and `/integrations/` refuses to issue a key. The proxy must overwrite `X-Forwarded-Proto` and build `X-Forwarded-For` from the real connection.

```json
"http": { "trustedProxies": ["172.18.0.1/32"], "forwardedHeaders": ["x-forwarded-for", "x-forwarded-proto"] }
```

## Languages

| Key | Type, default | Effect |
|-----|---------------|--------|
| `i18n.enabled` | bool, `false` (the skeleton sets `true`) | Turns languages on. |
| `i18n.default` | string, `en` | Language of unprefixed URLs and fallback for missing translations. |
| `i18n.locales` | array, `["en"]` | Offered languages, for example `["en", "cs"]`. The default is always included. |
| `i18n.detect` | array, `["url", "cookie", "header"]` | Detection order. The skeleton uses `["url"]` so unprefixed URLs are always English. Add `cookie` or `header` to let a saved choice or the browser language win. |
| `i18n.urlPrefix` | bool, `true` | Uses `/cs/...` prefixes for non-default languages. |
| `i18n.prefixDefault` | bool, `false` | Also prefixes the default language (`/en/...`). |
| `i18n.cookie` | string, `wb_locale` | Name of the preference cookie (letters, digits, underscore). |
| `i18n.cookieDays` | int, `365` | Lifetime of that cookie. |
| `i18n.dir` | string, `/Locale/` | Catalog directory under `src/`, with `en.php`, `cs.php`. |
| `i18n.baseUrl` | string, empty | Public address such as `https://example.com`. Used for absolute `hreflang` links instead of the `Host` header. Set it in production. |

## Caching

| Key | Type, default | Effect |
|-----|---------------|--------|
| `cache.enabled` | bool, `false` (the skeleton sets `true`) | Data and fragment cache. |
| `cache.driver` | string, `file` | `file` or `apcu`. `apcu` needs the extension and a PHP-FPM restart to clear. |
| `cache.ttl` | int seconds, `300` | Lifetime of data cache entries. |
| `cache.dir` | string, temp directory | Directory of the `file` driver. Default is a subdirectory of the system temp directory, which can vanish under `PrivateTmp`: set an absolute path. |
| `cache.pages.enabled` | bool, `false` | Whole-page cache for anonymous requests. |
| `cache.pages.ttl` | int seconds, `60` | Lifetime of cached pages. |
| `cache.pages.allowPaths` | array, omitted | Exact canonical paths allowed in the page cache. Omitted allows other eligible paths, empty `[]` disables page caching. |
| `cache.pages.denyPaths` | array, omitted | Paths never cached. Wins over `allowPaths`. |

Paths are compared ignoring case and a trailing slash, invalid policies fail closed. Private, `Set-Cookie` and personal responses are never stored whatever the policy says. Example: `"allowPaths": ["/", "/docs/", "/blog/"], "denyPaths": ["/profile/", "/login/"]`. A broken cache never takes the site down: it is disabled and logged.

## Rate limits and counters

| Key | Type, default | Effect |
|-----|---------------|--------|
| `rateLimit.login.enabled` | bool, `true` | Limits failed logins. |
| `rateLimit.login.maxAttempts` | int, `5` | Attempts per client address and account together. |
| `rateLimit.login.ipMaxAttempts` | int, `20` | Attempts per client address over all accounts. |
| `rateLimit.login.accountMaxAttempts` | int, `25` | Attempts per account from all addresses (distributed guessing). |
| `rateLimit.login.window` | int seconds, `900` | Length of the counting window. |
| `rateLimit.login.dir` | string, temp directory | Counter files. Set an absolute, writable path. |
| `counters.views.enabled` | bool, `false` | Batches the article view counter instead of one database write per view. |
| `counters.views.hits` | int, `50` | Hits per batch. |
| `counters.views.seconds` | int, `60` | Longest delay of a batch. |
| `counters.views.dir` | string, temp directory | Counter files. Set an absolute, writable path. |

The rate limit uses the client address, so it only works correctly when `http.trustedProxies` is right behind a proxy.

## Native analytics

| Key | Type, default | Effect |
|-----|---------------|--------|
| `analytics.enabled` | bool, `false` | Collects identity-free daily aggregates (no cookies, no addresses). Needs the framework migration `006-analytics.sql`. |
| `analytics.timezone` | string, `UTC` | IANA time zone in which days are cut. Invalid values throw. |
| `analytics.retentionDays` | int, `62` | How long daily rows are kept, 31 to 365. Run `analytics:prune` from cron daily. |

This is the privacy-friendly first-party measurement. It is independent of Google Analytics below: you can run either, both or none. A policy that fits most sites: native analytics on with `retentionDays` 62 (it sets no cookies and stores no addresses), Google Analytics off unless the operator has a legal basis and a consent process. Decide the legal side for your own site.

## Google Analytics

| Key | Type, default | Effect |
|-----|---------------|--------|
| `googleAnalytics.measurementId` | string, empty | Measurement id such as `G-XXXXXXXXXX`. Empty, missing or malformed disables everything. |

The skeleton does not load Google''s tag on its own. When the id is set, the layout renders the cookie banner and the footer link "Cookie settings", and `public/cookie-consent.js` loads `gtag.js` only after the visitor presses "Allow analytics". The choice is kept in the browser (`localStorage`), "Reject" removes the analytics cookies, and the tag is never loaded without consent. With the key empty the layout contains no banner, no button and no script. The text of the banner is in the locale catalogs (`cookies.*`); adapt it to your policy. A page cached before you set the id keeps its old markup until the cache is flushed.

```json
"googleAnalytics": { "measurementId": "G-XXXXXXXXXX" }
```

## Images and the API

| Key | Type, default | Effect |
|-----|---------------|--------|
| `apiV2.enabled` | bool, `false` (the skeleton sets `true`) | Turns on the server-to-server API v2 used by the central Admin. Needs HTTPS and the framework migrations. |
| `apiV2.imageDirectory` | string, unset | Absolute directory for images uploaded through API v2. Unset means image upload is unavailable. Overridden by `WBENGINE_IMAGE_DIR`. Keep it outside `public/`, writable by PHP. Files are PNG, JPEG or WebP up to 512 KiB. |

## Production example

A complete file for a site behind host Nginx, with every secret in the environment (`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`) so the placeholders below are not real keys:

```json
{
  "timeZone": "Europe/Prague",
  "codePage": "utf8",
  "debug": false,
  "minimizeHtml": false,
  "minimizeCss": false,
  "minimizeJs": false,
  "cdnPath": "",
  "cssFiles": [],
  "ipAdmins": [],
  "apiV2": {
    "enabled": true,
    "imageDirectory": "/var/lib/wbengine/images"
  },
  "renderer": {
    "adapterName": "NativeRenderer",
    "autoEscape": true,
    "templatesDir": "/View/",
    "compiledDir": "Compiled/",
    "configDir": "/Config/",
    "compileCheck": false
  },
  "dbAdapterDefinition": {
    "adapterName": "Mysqli",
    "hostname": "127.0.0.1",
    "port": "3306",
    "database": "wbengine_skeleton_app",
    "username": "wbengine",
    "password": "SET-A-LONG-RANDOM-PASSWORD",
    "charset": "utf8mb4"
  },
  "jwt": { "accessKey": "", "refreshKey": "" },
  "recaptcha": { "secretKey": "" },
  "http": {
    "trustedProxies": ["127.0.0.1"],
    "forwardedHeaders": ["x-forwarded-for", "x-forwarded-proto"]
  },
  "cache": {
    "enabled": true,
    "driver": "file",
    "ttl": 300,
    "dir": "/var/cache/wbengine",
    "pages": {
      "enabled": true,
      "ttl": 60,
      "denyPaths": ["/login/", "/profile/", "/integrations/"]
    }
  },
  "i18n": {
    "enabled": true,
    "default": "en",
    "locales": ["en", "cs"],
    "detect": ["url"],
    "baseUrl": "https://example.com"
  },
  "rateLimit": { "login": { "dir": "/var/lib/wbengine/ratelimit" } },
  "counters": { "views": { "enabled": true, "dir": "/var/lib/wbengine/counters" } },
  "analytics": { "enabled": true, "timezone": "Europe/Prague", "retentionDays": 62 },
  "googleAnalytics": { "measurementId": "" }
}
```

Leaving `jwt` empty in the file is only valid when both JWT variables are set in the environment of PHP, including the cron user and the container. Without them, put real random keys in the file. Where each part is deployed (permissions of the directories, proxies, cron) is described in [Deployment](/docs/deployment/), and the caching behavior in [Caching](/docs/caching/).', 'markdown', UNIX_TIMESTAMP(), 'RRSOFT', 'https://www.wbengine.org/'
WHERE NOT EXISTS (SELECT 1 FROM cms_articles WHERE site_id = @settings_site_id);
SET @settings_article_id = (SELECT id FROM cms_articles WHERE site_id = @settings_site_id ORDER BY id LIMIT 1);

INSERT INTO cms_article_translations (article_id, locale, title, introtext, bodytext, content_format)
SELECT @settings_article_id, 'cs', 'Přehled nastavení', 'Každý klíč Settings.json s typem, výchozí hodnotou, účinkem a příkladem, přepisy z prostředí, kompletní produkční konfigurace a měřicí ID Google Analytics.', '## Kde nastavení leží

Veškerá konfigurace je jeden objekt JSON v `src/Config/Settings.json`. Soubor se nekomituje: `bin/wbe install` ho vytvoří ze `src/Config/settings.json.default` s novými klíči JWT. Framework ho čte jednou za požadavek, chybějící klíč má níže uvedenou výchozí hodnotu a chybná hodnota v `http`, `analytics` nebo v pravidlech cache stránek vyvolá chybu, nikoli tiché ignorování. Po změně souboru vyprázdněte cache (`POST /api/cache/flush`) a při vypnutém `renderer.compileCheck` i adresář zkompilovaných šablon. Výsledek ověříte příkazem `vendor/bin/wbengine.php config:check --config=src/Config/Settings.json --root=src`.

Tajné hodnoty mohou místo souboru pocházet z prostředí: `WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`, `WBENGINE_DEBUG` a `WBENGINE_IMAGE_DIR`. Nastavená a neprázdná proměnná prostředí má přednost před souborem.

## Obecné

| Klíč | Typ, výchozí hodnota | Účinek |
|------|----------------------|--------|
| `timeZone` | řetězec, `Europe/Prague` | Časové pásmo PHP aplikace. Povinné. |
| `codePage` | řetězec, `utf8` | Znaková sada v hlavičce HTML. Ponechte `utf8`. |
| `debug` | bool, `false` | Zobrazí ladicí lištu a podrobné chyby. V produkci nikdy `true`. Přepíše ho `WBENGINE_DEBUG`. |
| `minimizeHtml` | bool, `false` | Zastaralé, od verze 4.0 ho dispečer ignoruje. Zůstává ve výchozím souboru kvůli starým šablonám. |
| `minimizeCss` | bool, `false` | Spojí a zmenší soubory z `cssFiles`. |
| `minimizeJs` | bool, `false` | Totéž pro skripty. Ve starších souborech chybí: přidejte ho výslovně, framework klíč čte přímo. |
| `cssFiles` | pole, `[]` | Soubory CSS spojované při zapnutém `minimizeCss`. |
| `cdnPath` | řetězec, prázdný | Předpona URL statických souborů, například `https://cdn.example.com`. |
| `ipAdmins` | pole, `[]` | Seznam IP adres správců. |

## Renderer

| Klíč | Typ, výchozí hodnota | Účinek |
|------|----------------------|--------|
| `renderer.adapterName` | řetězec, `NativeRenderer` | `NativeRenderer` nebo volitelný `SmartyRenderer`. |
| `renderer.autoEscape` | bool, `true` | Escapuje výstup proměnných v šablonách. `false` je jen pomůcka při migraci starých šablon. |
| `renderer.templatesDir` | řetězec, `/View/` | Adresář šablon pod `src/`. |
| `renderer.compiledDir` | řetězec, `Compiled/` | Zkompilované šablony, uživatel PHP do něj musí smět zapisovat. |
| `renderer.configDir` | řetězec, `/Config/` | Adresář konfigurace šablon. |
| `renderer.compileCheck` | bool, `true` | Při každém požadavku kontroluje, zda se šablona změnila. V produkci nastavte `false` a při nasazení vyprázdněte adresář zkompilovaných šablon. |

## Databáze

`dbAdapterDefinition` je objekt: `adapterName` (`Mysqli`), `hostname`, `port`, `database`, `username`, `password`, `charset`. Výchozí soubor míří na hostitele Dockeru `db` s vývojovými údaji; všechny je vyměňte. Na nové instalaci použijte `utf8mb4` jako `charset`. Pro heslo k databázi není přepsání z prostředí, proto soubor chraňte (`chmod 640`).

## Tajné hodnoty

| Klíč | Typ, výchozí hodnota | Účinek |
|------|----------------------|--------|
| `jwt.accessKey`, `jwt.refreshKey` | řetězec, `CHANGE_ME` | Podpisové klíče přihlášení a tokenů API, nejméně 32 znaků a navzájem různé. Přepíší je `WBENGINE_JWT_KEY` a `WBENGINE_JWT_REFRESH_KEY`. Vygenerujte je příkazem `openssl rand -hex 32`. |
| `recaptcha.secretKey` | řetězec, prázdný | Tajný klíč captcha u přihlašovacího formuláře. Prázdný klíč znamená, že kontrola captcha selže (fail closed). Přepíše ho `WBENGINE_RECAPTCHA_SECRET`. Při `recaptcha.enabled: true` ho příkaz `doctor` vyžaduje. |

## Proxy a HTTPS

| Klíč | Typ, výchozí hodnota | Účinek |
|------|----------------------|--------|
| `http.trustedProxies` | pole, `[]` | Přesné adresy nebo rozsahy CIDR reverzních proxy, jejichž předávací hlavičky se berou vážně. Prázdné pole znamená, že se všechny hlavičky ignorují. |
| `http.forwardedHeaders` | pole, `[]` | Povolené hlavičky: `x-forwarded-for` (adresa klienta) a `x-forwarded-proto` (původní schéma). Jiné hodnoty se odmítnou. |

Za hostitelským Nginxem nebo load balancerem nastavte obojí, jinak web považuje každého návštěvníka za adresu proxy a komunikaci za prosté HTTP: cookies relace nejsou zabezpečená, limity pokusů se sdílejí a `/integrations/` odmítne vydat klíč. Proxy musí přepsat `X-Forwarded-Proto` a sestavit `X-Forwarded-For` ze skutečného spojení.

```json
"http": { "trustedProxies": ["172.18.0.1/32"], "forwardedHeaders": ["x-forwarded-for", "x-forwarded-proto"] }
```

## Jazyky

| Klíč | Typ, výchozí hodnota | Účinek |
|------|----------------------|--------|
| `i18n.enabled` | bool, `false` (kostra nastavuje `true`) | Zapne jazyky. |
| `i18n.default` | řetězec, `en` | Jazyk adres bez předpony a záloha pro chybějící překlady. |
| `i18n.locales` | pole, `["en"]` | Nabízené jazyky, například `["en", "cs"]`. Výchozí jazyk je vždy zahrnut. |
| `i18n.detect` | pole, `["url", "cookie", "header"]` | Pořadí detekce. Kostra používá `["url"]`, takže adresy bez předpony jsou vždy anglicky. Přidáním `cookie` nebo `header` necháte rozhodovat uloženou volbu nebo jazyk prohlížeče. |
| `i18n.urlPrefix` | bool, `true` | Používá předpony `/cs/...` pro jazyky jiné než výchozí. |
| `i18n.prefixDefault` | bool, `false` | Předponu dostane i výchozí jazyk (`/en/...`). |
| `i18n.cookie` | řetězec, `wb_locale` | Název cookie s volbou jazyka (písmena, číslice, podtržítko). |
| `i18n.cookieDays` | celé číslo, `365` | Platnost této cookie ve dnech. |
| `i18n.dir` | řetězec, `/Locale/` | Adresář katalogů pod `src/`, soubory `en.php`, `cs.php`. |
| `i18n.baseUrl` | řetězec, prázdný | Veřejná adresa, například `https://example.com`. Používá se pro absolutní odkazy `hreflang` místo hlavičky `Host`. V produkci ji nastavte. |

## Cache

| Klíč | Typ, výchozí hodnota | Účinek |
|------|----------------------|--------|
| `cache.enabled` | bool, `false` (kostra nastavuje `true`) | Datová cache a cache fragmentů. |
| `cache.driver` | řetězec, `file` | `file` nebo `apcu`. `apcu` vyžaduje rozšíření a k vyprázdnění restart PHP-FPM. |
| `cache.ttl` | sekundy, `300` | Platnost záznamů datové cache. |
| `cache.dir` | řetězec, dočasný adresář | Adresář ovladače `file`. Výchozí je podadresář systémového dočasného adresáře, který může při `PrivateTmp` zmizet: nastavte absolutní cestu. |
| `cache.pages.enabled` | bool, `false` | Cache celých stránek pro anonymní požadavky. |
| `cache.pages.ttl` | sekundy, `60` | Platnost stránek v cache. |
| `cache.pages.allowPaths` | pole, vynecháno | Přesné kanonické cesty povolené v cache stránek. Vynechané povolí ostatní vhodné cesty, prázdné `[]` cache stránek vypne. |
| `cache.pages.denyPaths` | pole, vynecháno | Cesty, které se nikdy neukládají. Má přednost před `allowPaths`. |

Cesty se porovnávají bez ohledu na velikost písmen a koncové lomítko, neplatná pravidla selžou bezpečně (fail closed). Soukromé odpovědi, odpovědi s `Set-Cookie` a osobní odpovědi se neukládají nikdy, ať pravidlo říká cokoli. Příklad: `"allowPaths": ["/", "/docs/", "/blog/"], "denyPaths": ["/profile/", "/login/"]`. Rozbitá cache web neshodí: vypne se a zaloguje.

## Limity pokusů a počítadla

| Klíč | Typ, výchozí hodnota | Účinek |
|------|----------------------|--------|
| `rateLimit.login.enabled` | bool, `true` | Omezuje neúspěšná přihlášení. |
| `rateLimit.login.maxAttempts` | celé číslo, `5` | Pokusy na adresu klienta a účet dohromady. |
| `rateLimit.login.ipMaxAttempts` | celé číslo, `20` | Pokusy na adresu klienta napříč všemi účty. |
| `rateLimit.login.accountMaxAttempts` | celé číslo, `25` | Pokusy na účet ze všech adres (rozprostřené hádání). |
| `rateLimit.login.window` | sekundy, `900` | Délka počítacího okna. |
| `rateLimit.login.dir` | řetězec, dočasný adresář | Soubory počítadel. Nastavte absolutní zapisovatelnou cestu. |
| `counters.views.enabled` | bool, `false` | Dávkuje počítadlo zobrazení článků místo jednoho zápisu do databáze na zobrazení. |
| `counters.views.hits` | celé číslo, `50` | Počet zobrazení v dávce. |
| `counters.views.seconds` | celé číslo, `60` | Nejdelší zpoždění dávky. |
| `counters.views.dir` | řetězec, dočasný adresář | Soubory počítadel. Nastavte absolutní zapisovatelnou cestu. |

Limit pokusů používá adresu klienta, proto za proxy funguje správně jen při správném `http.trustedProxies`.

## Vlastní analytika

| Klíč | Typ, výchozí hodnota | Účinek |
|------|----------------------|--------|
| `analytics.enabled` | bool, `false` | Sbírá denní souhrny bez identity (žádné cookies, žádné adresy). Vyžaduje migraci frameworku `006-analytics.sql`. |
| `analytics.timezone` | řetězec, `UTC` | Časové pásmo IANA, ve kterém se dny dělí. Neplatná hodnota vyvolá chybu. |
| `analytics.retentionDays` | celé číslo, `62` | Jak dlouho se denní řádky drží, 31 až 365. Spouštějte `analytics:prune` z cronu denně. |

Jde o měření vlastním nástrojem šetrné k soukromí. Je nezávislé na Google Analytics níže: můžete provozovat jedno, obojí i žádné. Rozumná politika pro většinu webů: vlastní analytika zapnutá s `retentionDays` 62 (nenastavuje cookies a neukládá adresy), Google Analytics vypnuté, dokud provozovatel nemá právní důvod a proces souhlasu. Právní stránku posuďte pro vlastní web.

## Google Analytics

| Klíč | Typ, výchozí hodnota | Účinek |
|------|----------------------|--------|
| `googleAnalytics.measurementId` | řetězec, prázdný | Měřicí ID, například `G-XXXXXXXXXX`. Prázdné, chybějící nebo chybně zapsané ID vše vypne. |

Kostra značku Google sama nenačítá. Po nastavení ID layout zobrazí lištu s cookies i odkaz „Nastavení cookies“ v patičce a `public/cookie-consent.js` načte `gtag.js` až poté, co návštěvník stiskne „Povolit analytiku“. Volba se pamatuje v prohlížeči (`localStorage`), „Odmítnout“ odstraní analytické cookies a bez souhlasu se značka nenačte nikdy. Při prázdném klíči layout neobsahuje lištu, tlačítko ani skript. Text lišty je v katalozích jazyků (`cookies.*`); upravte ho podle svých zásad. Stránka uložená v cache před nastavením ID si staré značení drží, dokud cache nevyprázdníte.

```json
"googleAnalytics": { "measurementId": "G-XXXXXXXXXX" }
```

## Obrázky a API

| Klíč | Typ, výchozí hodnota | Účinek |
|------|----------------------|--------|
| `apiV2.enabled` | bool, `false` (kostra nastavuje `true`) | Zapne serverové API v2, které používá centrální Admin. Vyžaduje HTTPS a migrace frameworku. |
| `apiV2.imageDirectory` | řetězec, nenastaveno | Absolutní adresář pro obrázky nahrané přes API v2. Nenastaveno znamená, že nahrávání obrázků není dostupné. Přepíše ho `WBENGINE_IMAGE_DIR`. Držte ho mimo `public/` a zapisovatelný pro PHP. Soubory PNG, JPEG nebo WebP do 512 KiB. |

## Produkční příklad

Kompletní soubor pro web za hostitelským Nginxem, všechna tajemství v prostředí (`WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`), takže zástupné hodnoty níže nejsou skutečné klíče:

```json
{
  "timeZone": "Europe/Prague",
  "codePage": "utf8",
  "debug": false,
  "minimizeHtml": false,
  "minimizeCss": false,
  "minimizeJs": false,
  "cdnPath": "",
  "cssFiles": [],
  "ipAdmins": [],
  "apiV2": {
    "enabled": true,
    "imageDirectory": "/var/lib/wbengine/images"
  },
  "renderer": {
    "adapterName": "NativeRenderer",
    "autoEscape": true,
    "templatesDir": "/View/",
    "compiledDir": "Compiled/",
    "configDir": "/Config/",
    "compileCheck": false
  },
  "dbAdapterDefinition": {
    "adapterName": "Mysqli",
    "hostname": "127.0.0.1",
    "port": "3306",
    "database": "wbengine_skeleton_app",
    "username": "wbengine",
    "password": "SET-A-LONG-RANDOM-PASSWORD",
    "charset": "utf8mb4"
  },
  "jwt": { "accessKey": "", "refreshKey": "" },
  "recaptcha": { "secretKey": "" },
  "http": {
    "trustedProxies": ["127.0.0.1"],
    "forwardedHeaders": ["x-forwarded-for", "x-forwarded-proto"]
  },
  "cache": {
    "enabled": true,
    "driver": "file",
    "ttl": 300,
    "dir": "/var/cache/wbengine",
    "pages": {
      "enabled": true,
      "ttl": 60,
      "denyPaths": ["/login/", "/profile/", "/integrations/"]
    }
  },
  "i18n": {
    "enabled": true,
    "default": "en",
    "locales": ["en", "cs"],
    "detect": ["url"],
    "baseUrl": "https://example.com"
  },
  "rateLimit": { "login": { "dir": "/var/lib/wbengine/ratelimit" } },
  "counters": { "views": { "enabled": true, "dir": "/var/lib/wbengine/counters" } },
  "analytics": { "enabled": true, "timezone": "Europe/Prague", "retentionDays": 62 },
  "googleAnalytics": { "measurementId": "" }
}
```

Prázdné `jwt` v souboru platí jen tehdy, když jsou obě proměnné JWT nastavené v prostředí PHP, včetně uživatele cronu a kontejneru. Jinak do souboru vložte skutečné náhodné klíče. Kde co nasadit (oprávnění adresářů, proxy, cron) popisuje [Nasazení](/cs/docs/deployment/), chování cache stránka [Cache](/cs/docs/caching/).', 'markdown'
WHERE @settings_article_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cms_article_translations WHERE article_id = @settings_article_id AND locale = 'cs');

INSERT INTO cms_boxes (name, module, method, section_id, static, shared, device_min, device_strict, acl, `order`, sites)
SELECT 'Docs: Settings reference', 'docs', 'page', 1, 1, 0, 1, 0, 0, 0, JSON_ARRAY(CAST(@settings_site_id AS CHAR))
WHERE NOT EXISTS (SELECT 1 FROM cms_boxes WHERE name = 'Docs: Settings reference');
