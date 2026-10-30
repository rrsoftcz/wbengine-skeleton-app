-- Logging and audit page: the change feed over HTTP replaces the note that no such endpoint exists. Text only, safe to rerun.
SET NAMES utf8mb4;

UPDATE cms_articles
SET bodytext = REPLACE(REPLACE(bodytext, 'There is no HTTP endpoint for reading the change log yet.

## Retention and pruning', 'The central Admin reads the same data over HTTP, see the next section.

## Change feed over HTTP

`GET /api/v2/changes` returns the change log, newest first, without the before and after data. It needs HTTPS and an integration key with the scope `audit:read`. The central Admin shows the feed on the Activity page of a site, for site administrators only. A key without that scope must be replaced by a new key.

Query parameters: `page` and `per_page` (1 to 100, default 25); the exact-match filters `resource`, `resource_id`, `action`, `source` (`v2`, `v1` or `cli`) and `actor`; `since` and `until` as epoch seconds. An invalid filter is answered with 400. With `outcome=rejected` the feed lists rejected and failed writes from `cms_api_audit` instead, with the error code in `detail`.

Every entry has `change_id`, `created_at`, `resource`, `resource_id`, `action`, `source`, `actor`, `integration_id` and `local_user_id`. Reading the feed is itself recorded in the audit table as `changes.list`.

## Retention and pruning'), 'Čtení záznamu změn přes HTTP zatím neexistuje.

## Uchování a mazání', 'Centrální Admin čte tatáž data přes HTTP, viz další část.

## Přehled změn přes HTTP

`GET /api/v2/changes` vrací záznam změn od nejnovějších, bez dat před a po. Vyžaduje HTTPS a integrační klíč s oprávněním `audit:read`. Centrální Admin přehled zobrazuje na stránce Aktivita webu, a to jen správcům webu. Klíč bez tohoto oprávnění je třeba nahradit novým klíčem.

Parametry dotazu: `page` a `per_page` (1 až 100, výchozí 25); filtry s přesnou shodou `resource`, `resource_id`, `action`, `source` (`v2`, `v1` nebo `cli`) a `actor`; `since` a `until` jako epoch sekundy. Neplatný filtr vrací 400. S `outcome=rejected` přehled místo toho vypíše odmítnuté a neúspěšné zápisy z `cms_api_audit` s kódem chyby v `detail`.

Každý záznam má `change_id`, `created_at`, `resource`, `resource_id`, `action`, `source`, `actor`, `integration_id` a `local_user_id`. Samotné čtení přehledu se zapisuje do auditní tabulky jako `changes.list`.

## Uchování a mazání');

UPDATE cms_article_translations
SET bodytext = REPLACE(REPLACE(bodytext, 'There is no HTTP endpoint for reading the change log yet.

## Retention and pruning', 'The central Admin reads the same data over HTTP, see the next section.

## Change feed over HTTP

`GET /api/v2/changes` returns the change log, newest first, without the before and after data. It needs HTTPS and an integration key with the scope `audit:read`. The central Admin shows the feed on the Activity page of a site, for site administrators only. A key without that scope must be replaced by a new key.

Query parameters: `page` and `per_page` (1 to 100, default 25); the exact-match filters `resource`, `resource_id`, `action`, `source` (`v2`, `v1` or `cli`) and `actor`; `since` and `until` as epoch seconds. An invalid filter is answered with 400. With `outcome=rejected` the feed lists rejected and failed writes from `cms_api_audit` instead, with the error code in `detail`.

Every entry has `change_id`, `created_at`, `resource`, `resource_id`, `action`, `source`, `actor`, `integration_id` and `local_user_id`. Reading the feed is itself recorded in the audit table as `changes.list`.

## Retention and pruning'), 'Čtení záznamu změn přes HTTP zatím neexistuje.

## Uchování a mazání', 'Centrální Admin čte tatáž data přes HTTP, viz další část.

## Přehled změn přes HTTP

`GET /api/v2/changes` vrací záznam změn od nejnovějších, bez dat před a po. Vyžaduje HTTPS a integrační klíč s oprávněním `audit:read`. Centrální Admin přehled zobrazuje na stránce Aktivita webu, a to jen správcům webu. Klíč bez tohoto oprávnění je třeba nahradit novým klíčem.

Parametry dotazu: `page` a `per_page` (1 až 100, výchozí 25); filtry s přesnou shodou `resource`, `resource_id`, `action`, `source` (`v2`, `v1` nebo `cli`) a `actor`; `since` a `until` jako epoch sekundy. Neplatný filtr vrací 400. S `outcome=rejected` přehled místo toho vypíše odmítnuté a neúspěšné zápisy z `cms_api_audit` s kódem chyby v `detail`.

Každý záznam má `change_id`, `created_at`, `resource`, `resource_id`, `action`, `source`, `actor`, `integration_id` a `local_user_id`. Samotné čtení přehledu se zapisuje do auditní tabulky jako `changes.list`.

## Uchování a mazání');
