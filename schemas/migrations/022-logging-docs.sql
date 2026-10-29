-- Logging and audit page (schemas/migrations/022-logging-docs.sql).
-- Idempotent: every row is created only when it is missing, so edits made later in the Admin survive a rerun.
SET NAMES utf8mb4;

SET @logging_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/logging/' ORDER BY site_id LIMIT 1);
INSERT INTO cms_sites (parent_id, left_id, right_id, strict, visible, link, title, html_title, html_description, html_keywords, acl)
SELECT 1, 0, 0, 1, 1, '/docs/logging/', 'Logging and audit', 'Logging and audit', 'What a WBengine site logs and where: error logs, web server logs, the API audit, the change log, retention and pruning, and privacy notes.', 'logging,audit,change log,privacy', 0
WHERE @logging_site_id IS NULL;
SET @logging_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/logging/' ORDER BY site_id LIMIT 1);

INSERT INTO cms_site_translations (site_id, locale, title, html_title, html_description, html_keywords)
SELECT @logging_site_id, 'cs', 'Logování a audit', 'Logování a audit', 'Co web na WBengine loguje a kam: chybové logy, logy webového serveru, audit API, záznam změn, uchování a mazání a poznámky k soukromí.', 'logování,audit,záznam změn,soukromí'
WHERE NOT EXISTS (SELECT 1 FROM cms_site_translations WHERE site_id = @logging_site_id AND locale = 'cs');

INSERT INTO cms_articles (site_id, grouped, futured, c_enabled, views, title, introtext, bodytext, content_format, published, author, source)
SELECT @logging_site_id, 0, 0, 0, 0, 'Logging and audit', 'What is logged where (PHP errors, web server logs, the API audit and the change log), what is not, who-what-when queries, retention and audit:prune, the framework migration 008 and privacy notes.', 'This page explains what a WBengine site records, where, for how long, and how to ask "who changed what and when". It describes WBengine 4.8.0 or newer with the skeleton migrations applied.

## What is logged where

| Source | Where | What |
|--------|-------|------|
| PHP and framework errors | PHP `error_log` | Warnings, exceptions, "cache disabled: ..." and one line with a short reference code for every 5xx failure of API v2. |
| Web server | Nginx or Apache access and error logs | Every HTTP request: time, address, URL, status. This is the only place with IP addresses. |
| API v2 requests | table `cms_api_audit` | One row per authenticated call: who, which operation, outcome. |
| Content and structure changes | table `cms_api_changes` | One row per write with actor, resource, action and the data before and after. |
| Article drafts | table `cms_api_revisions` | The draft history of an article, used for preview and restore. |

### PHP error log and reference codes

PHP writes through `error_log`: the file set by the ini value `error_log`, otherwise the web server error log (PHP-FPM log, Apache `ErrorLog`, the Nginx error log for FastCGI errors). Keep `display_errors = Off` and `log_errors = On` in production. When an API v2 call fails with a server error (5xx) the client gets a generic message with a short reference code, for example `ref:7f3a9c`. The same reference is written to `error_log` with the details and stored in the audit row, so you can search the log for exactly that code.

### Web server logs and containers

Nginx and Apache keep the access and error logs, typically `/var/log/nginx/` and `/var/log/apache2/`. In the Docker images Apache sends both logs and the PHP errors to the container output, so they are read with `docker compose logs web` (or `docker logs <container>`). The default `json-file` driver grows without a limit: set `max-size` and `max-file` in the Compose `logging` section or in `/etc/docker/daemon.json`, or ship the output to a log collector. Host Nginx in front of containers has its own logs in addition.

## The audit table `cms_api_audit`

Columns: `audit_id`, `integration_id` (the key), `central_actor` (the editor label sent by the central Admin, untrusted free text up to 128 characters), `local_user_id` (the local administrator for key management), `action`, `outcome`, `detail` and `created_at` (Unix time).

| `outcome` | Meaning |
|-----------|---------|
| `allowed` | The key was valid and had the scope. This includes reads, so reads of content leave a trace here (who, which operation, when) but never the data that was returned. |
| `unauthorized` | The key was missing, invalid or revoked (HTTP 401). `integration_id` is empty. |
| `forbidden` | The key is valid but lacks the required scope (HTTP 403). |
| `rejected` | An authenticated write was refused: validation, not found, conflict, failed `If-Match` precondition (412 or 428). `detail` holds the error code. |
| `error` | A server failure (5xx). `detail` is `ref:<reference>`, the same code as in `error_log`. |

## The change log `cms_api_changes`

Every write path creates one row: `change_id`, `resource` (`pages`, `menu`, `sections`, `boxes`, `articles` for API v2), `resource_id`, `action`, `before_data` and `after_data` (JSON snapshots), `integration_id`, `central_actor`, `source`, `local_user_id` and `created_at`.

| `source` | Who wrote | Actor |
|----------|-----------|-------|
| `v2` | API v2 (the central Admin), in the same transaction as the content change | `integration_id` and `central_actor` |
| `v1` | Legacy API: users, sections, translations, cache flush | `local_user_id`, `integration_id` is 0 |
| `cli` | `bin/wbe user:create`, `user:password`, `user:delete` and `audit:prune` | `central_actor` is `cli:<operating system user>`, `integration_id` is 0 |

Rows of `v1` and `cli` use singular resource names (v2 uses plural ones) (`user`, `section`, `translation`, `cache`, `audit`), so they never show up in the `/changes` history of a v2 resource. Article drafts and restored versions live in `cms_api_revisions`: `revision_id`, `article_id`, `payload`, `action`, `integration_id`, `central_actor`, `created_at`. A revision that a draft still points to is never deleted.

## What is not logged

- Request bodies and response bodies. The audit holds the operation and the outcome, the change log holds the resulting data.
- IP addresses. They exist only in the web server access log.
- API keys, tokens and passwords. A password change is recorded as `passwordChanged: true` and nothing else.
- Public page views. Native analytics (see the settings reference) keeps anonymous daily totals only.

### Redaction

Rows written by `v1` and `cli` are redacted: any key named password, token, secret, key or hash (also `apiKey`, `key_hash`) is stored as `[redacted]`. Rows from `v2` store the data as given because structure recovery replays it, so do not put secrets in page, menu or article content.

## Who, what, when

All `created_at` values are Unix timestamps. Examples:

```sql
-- the last 20 changes with who and when
SELECT FROM_UNIXTIME(created_at) AS at, source, resource, resource_id, action,
       COALESCE(central_actor, local_user_id) AS actor, integration_id
FROM cms_api_changes ORDER BY change_id DESC LIMIT 20;

-- the history of one article, with the data
SELECT FROM_UNIXTIME(created_at) AS at, action, central_actor, before_data, after_data
FROM cms_api_changes WHERE resource = ''articles'' AND resource_id = ''12'' ORDER BY change_id;

-- everything one editor did in the last 7 days
SELECT FROM_UNIXTIME(created_at) AS at, resource, resource_id, action
FROM cms_api_changes WHERE central_actor = ''anna@example.com'' AND created_at > UNIX_TIMESTAMP() - 7 * 86400;

-- refused and failed calls today, and failed authentication
SELECT FROM_UNIXTIME(created_at) AS at, integration_id, central_actor, action, outcome, detail
FROM cms_api_audit WHERE outcome <> ''allowed'' AND created_at > UNIX_TIMESTAMP(CURDATE()) ORDER BY audit_id DESC;

-- which keys are used how often
SELECT integration_id, outcome, COUNT(*) FROM cms_api_audit GROUP BY integration_id, outcome;
```

From the command line, `audit:list` prints recent changes without their before and after data:

```sh
php vendor/bin/wbengine.php audit:list --limit=50 --resource=articles --actor=anna@example.com --config=src/Config/Settings.json --root=src
```

`--limit` is 1 to 500 (default 20), `--actor` matches the actor label exactly, or the local user id when it is numeric. There is no HTTP endpoint for reading the change log yet.

## Retention and pruning

Nothing is deleted automatically. The keys in `Settings.json` (both default to 365, allowed 30 to 3650, invalid values raise an error):

```json
"audit": { "retentionDays": 365, "revisionRetentionDays": 365 }
```

`audit.retentionDays` applies to `cms_api_audit` and `cms_api_changes`, `audit.revisionRetentionDays` to `cms_api_revisions`. Run the pruning from cron:

```cron
27 3 * * * www-data /usr/bin/php /var/www/wbengine-skeleton-app/vendor/bin/wbengine.php audit:prune --config=/var/www/wbengine-skeleton-app/src/Config/Settings.json --root=/var/www/wbengine-skeleton-app/src >> /var/log/wbengine-cron.log 2>&1
```

`audit:prune --dry-run` only counts, `--days=N` overrides both keys for one run. The newest change of every resource stays however old (its id is part of the structure ETag and of recovery) and so does every revision referenced by a draft. Each real run records itself as a `cli` change of the resource `audit`. In Docker run the command with `docker compose -f docker-compose.production.yml exec -T web php vendor/bin/wbengine.php audit:prune ...`, from the host cron.

## Applying the framework migration 008

Sites that use API v2 must apply `vendor/wbengine/wbengine/migrations/4.8.0/008-change-log-source.sql` once, after the framework migrations 002 and 005 and after a backup. It adds `source`, `local_user_id`, `detail` and the `created_at` indexes and is safe to run again. `vendor/bin/wbengine.php doctor` reports `migration.008` as failed until it is applied; until then the new columns are skipped and nothing else changes.

```sh
mysql wbengine_skeleton_app < vendor/wbengine/wbengine/migrations/4.8.0/008-change-log-source.sql
docker compose -f docker-compose.production.yml exec -T web cat vendor/wbengine/wbengine/migrations/4.8.0/008-change-log-source.sql \\
  | docker compose -f docker-compose.production.yml exec -T db sh -c ''MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot wbengine_skeleton_app''
```

The first command is for a database on the host, the second for the production Compose stack.

## Privacy notes

- Actor labels, user rows and content snapshots can contain personal data such as e-mail addresses and names. Treat the audit tables as personal data: restrict database access, and include them in your records of processing.
- Choose a retention that matches your policy, and note that database backups keep rows longer than the retention setting.
- The IP address lives only in web server logs. Set their rotation and retention separately (`logrotate`, the Docker log options).
- The audit is a trace of who did what, not of what visitors read: public page views are not recorded per visitor.', 'markdown', UNIX_TIMESTAMP(), 'RRSOFT', 'https://www.wbengine.org/'
WHERE NOT EXISTS (SELECT 1 FROM cms_articles WHERE site_id = @logging_site_id);
SET @logging_article_id = (SELECT id FROM cms_articles WHERE site_id = @logging_site_id ORDER BY id LIMIT 1);

INSERT INTO cms_article_translations (article_id, locale, title, introtext, bodytext, content_format)
SELECT @logging_article_id, 'cs', 'Logování a audit', 'Co se loguje kam (chyby PHP, logy webového serveru, audit API a záznam změn), co ne, dotazy kdo-co-kdy, uchování a audit:prune, migrace frameworku 008 a poznámky k soukromí.', 'Tato stránka vysvětluje, co web na WBengine zaznamenává, kam, jak dlouho a jak se zeptat „kdo, co a kdy změnil“. Popisuje WBengine 4.8.0 nebo novější s použitými migracemi kostry.

## Co se loguje kam

| Zdroj | Kam | Co |
|-------|-----|----|
| Chyby PHP a frameworku | PHP `error_log` | Varování, výjimky, „cache disabled: ...“ a řádek s krátkým referenčním kódem u každé chyby 5xx v API v2. |
| Webový server | přístupové a chybové logy Nginxu nebo Apache | Každý požadavek HTTP: čas, adresa, URL, stav. Jediné místo s IP adresami. |
| Požadavky API v2 | tabulka `cms_api_audit` | Jeden řádek za každé ověřené volání: kdo, jaká operace, výsledek. |
| Změny obsahu a struktury | tabulka `cms_api_changes` | Jeden řádek za každý zápis s aktérem, zdrojem, akcí a daty před a po. |
| Koncepty článků | tabulka `cms_api_revisions` | Historie konceptů článku pro náhled a obnovu. |

### Chybový log PHP a referenční kódy

PHP zapisuje přes `error_log`: do souboru z ini hodnoty `error_log`, jinak do chybového logu webového serveru (log PHP-FPM, `ErrorLog` Apache, chybový log Nginxu u chyb FastCGI). V produkci ponechte `display_errors = Off` a `log_errors = On`. Když volání API v2 skončí chybou serveru (5xx), klient dostane obecnou zprávu s krátkým referenčním kódem, například `ref:7f3a9c`. Stejný kód se zapíše i s podrobnostmi do `error_log` a do auditního řádku, takže v logu hledáte přesně tento kód.

### Logy webového serveru a kontejnery

Nginx a Apache mají přístupové a chybové logy, obvykle v `/var/log/nginx/` a `/var/log/apache2/`. V dockerových image posílá Apache oba logy i chyby PHP na výstup kontejneru, čtou se příkazem `docker compose logs web` (nebo `docker logs <kontejner>`). Výchozí ovladač `json-file` roste bez omezení: nastavte `max-size` a `max-file` v sekci `logging` souboru Compose nebo v `/etc/docker/daemon.json`, případně výstup posílejte do sběrače logů. Hostitelský Nginx před kontejnery má navíc vlastní logy.

## Auditní tabulka `cms_api_audit`

Sloupce: `audit_id`, `integration_id` (klíč), `central_actor` (označení redaktora od centrálního Adminu, nedůvěryhodný volný text do 128 znaků), `local_user_id` (místní správce při správě klíčů), `action`, `outcome`, `detail` a `created_at` (čas Unix).

| `outcome` | Význam |
|-----------|--------|
| `allowed` | Klíč byl platný a měl scope. Patří sem i čtení, takže čtení obsahu zanechá stopu (kdo, jaká operace, kdy), nikdy však vrácená data. |
| `unauthorized` | Klíč chyběl, byl neplatný nebo odvolaný (HTTP 401). `integration_id` je prázdné. |
| `forbidden` | Klíč je platný, ale nemá požadovaný scope (HTTP 403). |
| `rejected` | Ověřený zápis byl odmítnut: validace, nenalezeno, konflikt, neúspěšná podmínka `If-Match` (412 nebo 428). `detail` obsahuje kód chyby. |
| `error` | Chyba serveru (5xx). `detail` je `ref:<reference>`, tentýž kód jako v `error_log`. |

## Záznam změn `cms_api_changes`

Každá cesta zápisu vytvoří jeden řádek: `change_id`, `resource` (`pages`, `menu`, `sections`, `boxes`, `articles` u API v2), `resource_id`, `action`, `before_data` a `after_data` (snímky JSON), `integration_id`, `central_actor`, `source`, `local_user_id` a `created_at`.

| `source` | Kdo zapsal | Aktér |
|----------|------------|-------|
| `v2` | API v2 (centrální Admin), ve stejné transakci jako změna obsahu | `integration_id` a `central_actor` |
| `v1` | Původní API: uživatelé, sekce, překlady, vyprázdnění cache | `local_user_id`, `integration_id` je 0 |
| `cli` | `bin/wbe user:create`, `user:password`, `user:delete` a `audit:prune` | `central_actor` je `cli:<uživatel operačního systému>`, `integration_id` je 0 |

Řádky `v1` a `cli` používají na rozdíl od množných názvů v2 jednotné číslo (`user`, `section`, `translation`, `cache`, `audit`), takže se nikdy neobjeví v historii `/changes` zdroje v2. Koncepty článků a obnovené verze jsou v `cms_api_revisions`: `revision_id`, `article_id`, `payload`, `action`, `integration_id`, `central_actor`, `created_at`. Revize, na kterou koncept stále odkazuje, se nikdy nesmaže.

## Co se neloguje

- Těla požadavků a odpovědí. Audit drží operaci a výsledek, záznam změn výsledná data.
- IP adresy. Existují jen v přístupovém logu webového serveru.
- Klíče API, tokeny a hesla. Změna hesla se zapíše jako `passwordChanged: true` a nic víc.
- Zobrazení veřejných stránek. Vlastní analytika (viz přehled nastavení) drží jen anonymní denní součty.

### Redakce

Řádky zapsané přes `v1` a `cli` se redigují: každý klíč nazvaný password, token, secret, key nebo hash (také `apiKey`, `key_hash`) se uloží jako `[redacted]`. Řádky `v2` ukládají data tak, jak přišla, protože je přehrává obnova struktury, proto nedávejte tajné hodnoty do obsahu stránek, menu ani článků.

## Kdo, co, kdy

Všechny hodnoty `created_at` jsou časy Unix. Příklady:

```sql
-- posledních 20 změn s tím, kdo a kdy
SELECT FROM_UNIXTIME(created_at) AS at, source, resource, resource_id, action,
       COALESCE(central_actor, local_user_id) AS actor, integration_id
FROM cms_api_changes ORDER BY change_id DESC LIMIT 20;

-- historie jednoho článku i s daty
SELECT FROM_UNIXTIME(created_at) AS at, action, central_actor, before_data, after_data
FROM cms_api_changes WHERE resource = ''articles'' AND resource_id = ''12'' ORDER BY change_id;

-- vše, co jeden redaktor udělal za posledních 7 dní
SELECT FROM_UNIXTIME(created_at) AS at, resource, resource_id, action
FROM cms_api_changes WHERE central_actor = ''anna@example.com'' AND created_at > UNIX_TIMESTAMP() - 7 * 86400;

-- odmítnutá a selhaná volání dnes a neúspěšné ověření
SELECT FROM_UNIXTIME(created_at) AS at, integration_id, central_actor, action, outcome, detail
FROM cms_api_audit WHERE outcome <> ''allowed'' AND created_at > UNIX_TIMESTAMP(CURDATE()) ORDER BY audit_id DESC;

-- jak často se které klíče používají
SELECT integration_id, outcome, COUNT(*) FROM cms_api_audit GROUP BY integration_id, outcome;
```

Z příkazové řádky vypíše `audit:list` poslední změny bez dat před a po:

```sh
php vendor/bin/wbengine.php audit:list --limit=50 --resource=articles --actor=anna@example.com --config=src/Config/Settings.json --root=src
```

`--limit` je 1 až 500 (výchozí 20), `--actor` odpovídá označení aktéra přesně, nebo místnímu ID uživatele, je-li číselné. Čtení záznamu změn přes HTTP zatím neexistuje.

## Uchování a mazání

Nic se nemaže automaticky. Klíče v `Settings.json` (oba mají výchozí hodnotu 365, povoleno 30 až 3650, neplatná hodnota vyvolá chybu):

```json
"audit": { "retentionDays": 365, "revisionRetentionDays": 365 }
```

`audit.retentionDays` platí pro `cms_api_audit` a `cms_api_changes`, `audit.revisionRetentionDays` pro `cms_api_revisions`. Mazání spouštějte z cronu:

```cron
27 3 * * * www-data /usr/bin/php /var/www/wbengine-skeleton-app/vendor/bin/wbengine.php audit:prune --config=/var/www/wbengine-skeleton-app/src/Config/Settings.json --root=/var/www/wbengine-skeleton-app/src >> /var/log/wbengine-cron.log 2>&1
```

`audit:prune --dry-run` jen spočítá, `--days=N` přepíše oba klíče pro jedno spuštění. Nejnovější změna každého zdroje zůstává, ať je jakkoli stará (její id je součástí ETagu struktury a obnovy), stejně jako každá revize, na kterou odkazuje koncept. Každé skutečné spuštění se zapíše jako změna `cli` zdroje `audit`. V Dockeru spusťte příkaz z cronu na hostiteli jako `docker compose -f docker-compose.production.yml exec -T web php vendor/bin/wbengine.php audit:prune ...`.

## Použití migrace frameworku 008

Weby, které používají API v2, musí jednou použít `vendor/wbengine/wbengine/migrations/4.8.0/008-change-log-source.sql`, po migracích frameworku 002 a 005 a po záloze. Přidá `source`, `local_user_id`, `detail` a indexy `created_at` a lze ji bezpečně spustit znovu. `vendor/bin/wbengine.php doctor` hlásí `migration.008` jako neúspěšnou, dokud není použita; do té doby se nové sloupce přeskakují a nic jiného se nemění.

```sh
mysql wbengine_skeleton_app < vendor/wbengine/wbengine/migrations/4.8.0/008-change-log-source.sql
docker compose -f docker-compose.production.yml exec -T web cat vendor/wbengine/wbengine/migrations/4.8.0/008-change-log-source.sql \\
  | docker compose -f docker-compose.production.yml exec -T db sh -c ''MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot wbengine_skeleton_app''
```

První příkaz je pro databázi na hostiteli, druhý pro produkční Compose.

## Poznámky k soukromí

- Označení aktérů, řádky uživatelů a snímky obsahu mohou obsahovat osobní údaje, například e-mailové adresy a jména. Auditní tabulky berte jako osobní údaje: omezte přístup k databázi a zahrňte je do záznamů o zpracování.
- Zvolte uchování podle svých zásad a pamatujte, že zálohy databáze drží řádky déle, než říká nastavení.
- IP adresa žije jen v logách webového serveru. Jejich rotaci a uchování nastavte zvlášť (`logrotate`, volby logů Dockeru).
- Audit je stopa toho, kdo co udělal, nikoli toho, co návštěvníci četli: zobrazení veřejných stránek se po návštěvnících nezaznamenávají.', 'markdown'
WHERE @logging_article_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cms_article_translations WHERE article_id = @logging_article_id AND locale = 'cs');

INSERT INTO cms_boxes (name, module, method, section_id, static, shared, device_min, device_strict, acl, `order`, sites)
SELECT 'Docs: Logging and audit', 'docs', 'page', 1, 1, 0, 1, 0, 0, 0, JSON_ARRAY(CAST(@logging_site_id AS CHAR))
WHERE NOT EXISTS (SELECT 1 FROM cms_boxes WHERE name = 'Docs: Logging and audit');
