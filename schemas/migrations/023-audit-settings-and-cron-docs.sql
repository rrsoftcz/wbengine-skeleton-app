-- Audit settings keys (framework 4.8.0) in the settings reference, audit:prune in the deployment cron section
-- and the framework migration 4.8.0/008 in the migration order (schemas/migrations/023-audit-settings-and-cron-docs.sql).
-- Each UPDATE runs only while its marker text is missing, so the migration is safe to rerun.
SET NAMES utf8mb4;

UPDATE cms_articles
SET bodytext = REPLACE(REPLACE(bodytext, '## Images and the API', '## Audit and change log

| Key | Type, default | Effect |
|-----|---------------|--------|
| `audit.retentionDays` | int, `365` | How long `cms_api_audit` and `cms_api_changes` rows are kept, 30 to 3650. Invalid values throw. |
| `audit.revisionRetentionDays` | int, `365` | How long `cms_api_revisions` (article draft history) are kept, 30 to 3650. |

Nothing is deleted automatically: run `audit:prune` from cron (`--dry-run` only counts, `--days=N` overrides both keys). The newest change of every resource and every revision a draft still uses are always kept. The tables need the framework migration `4.8.0/008-change-log-source.sql` when API v2 is enabled. What is recorded is described in [Logging and audit](/docs/logging/).

## Images and the API'), '  "googleAnalytics": { "measurementId": "" }
}', '  "audit": { "retentionDays": 365, "revisionRetentionDays": 365 },
  "googleAnalytics": { "measurementId": "" }
}')
WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/settings/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND LOCATE('## Audit and change log', bodytext) = 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(REPLACE(bodytext, '## Obrázky a API', '## Audit a záznam změn

| Klíč | Typ, výchozí hodnota | Účinek |
|------|----------------------|--------|
| `audit.retentionDays` | celé číslo, `365` | Jak dlouho se drží řádky `cms_api_audit` a `cms_api_changes`, 30 až 3650. Neplatná hodnota vyvolá chybu. |
| `audit.revisionRetentionDays` | celé číslo, `365` | Jak dlouho se drží `cms_api_revisions` (historie konceptů článků), 30 až 3650. |

Nic se nemaže automaticky: spouštějte `audit:prune` z cronu (`--dry-run` jen počítá, `--days=N` přepíše oba klíče). Nejnovější změna každého zdroje a každá revize, kterou koncept ještě používá, se vždy ponechá. Při zapnutém API v2 tabulky vyžadují migraci frameworku `4.8.0/008-change-log-source.sql`. Co se zaznamenává, popisuje [Logování a audit](/cs/docs/logging/).

## Obrázky a API'), '  "googleAnalytics": { "measurementId": "" }
}', '  "audit": { "retentionDays": 365, "revisionRetentionDays": 365 },
  "googleAnalytics": { "measurementId": "" }
}')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/settings/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND locale = 'cs'
  AND LOCATE('## Audit a záznam změn', bodytext) = 0;

UPDATE cms_articles
SET bodytext = REPLACE(REPLACE(bodytext, 'for m in 002-api-v2-integrations.sql 005-api-content.sql 006-analytics.sql 007-api-integration-last-used.sql; do
    mysql wbengine_skeleton_app < vendor/wbengine/wbengine/migrations/4.0.0/$m
done
```

These are the same four framework migrations the Docker installer applies.', 'for m in 002-api-v2-integrations.sql 005-api-content.sql 006-analytics.sql 007-api-integration-last-used.sql; do
    mysql wbengine_skeleton_app < vendor/wbengine/wbengine/migrations/4.0.0/$m
done
mysql wbengine_skeleton_app < vendor/wbengine/wbengine/migrations/4.8.0/008-change-log-source.sql
```

These are the same framework migrations the Docker installer applies. `4.8.0/008` (change log columns, framework 4.8.0 or newer) is required for sites that use API v2: `doctor` fails without it.'), 'The job reads the same environment secrets, so run it as the web user with the same variables (for example by sourcing a root-owned file in the crontab line). A matching `audit:prune` command arrives with framework 4.8.0 and will be added to this schedule then.', 'The job reads the same environment secrets, so run it as the web user with the same variables (for example by sourcing a root-owned file in the crontab line). Framework 4.8.0 adds the change log and audit tables, which also need daily pruning (`audit.retentionDays`, see [Logging and audit](/docs/logging/)):

```cron
27 3 * * * www-data /usr/bin/php /var/www/wbengine-skeleton-app/vendor/bin/wbengine.php audit:prune --config=/var/www/wbengine-skeleton-app/src/Config/Settings.json --root=/var/www/wbengine-skeleton-app/src >> /var/log/wbengine-cron.log 2>&1
```')
WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/deployment/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND LOCATE('4.8.0/008-change-log-source.sql', bodytext) = 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(REPLACE(bodytext, 'for m in 002-api-v2-integrations.sql 005-api-content.sql 006-analytics.sql 007-api-integration-last-used.sql; do
    mysql wbengine_skeleton_app < vendor/wbengine/wbengine/migrations/4.0.0/$m
done
```

Jsou to stejné čtyři migrace frameworku, které použije instalátor pro Docker.', 'for m in 002-api-v2-integrations.sql 005-api-content.sql 006-analytics.sql 007-api-integration-last-used.sql; do
    mysql wbengine_skeleton_app < vendor/wbengine/wbengine/migrations/4.0.0/$m
done
mysql wbengine_skeleton_app < vendor/wbengine/wbengine/migrations/4.8.0/008-change-log-source.sql
```

Jsou to stejné migrace frameworku, které použije instalátor pro Docker. `4.8.0/008` (sloupce záznamu změn, framework 4.8.0 nebo novější) je nutná pro weby s API v2: bez ní `doctor` selže.'), 'Úloha čte stejné tajné hodnoty z prostředí, proto ji spouštějte pod webovým uživatelem se stejnými proměnnými (například načtením souboru vlastněného rootem v řádku crontabu). Odpovídající příkaz `audit:prune` přijde s frameworkem 4.8.0 a do tohoto rozvrhu se přidá až tehdy.', 'Úloha čte stejné tajné hodnoty z prostředí, proto ji spouštějte pod webovým uživatelem se stejnými proměnnými (například načtením souboru vlastněného rootem v řádku crontabu). Framework 4.8.0 přidává tabulky záznamu změn a auditu, které je také třeba denně mazat (`audit.retentionDays`, viz [Logování a audit](/cs/docs/logging/)):

```cron
27 3 * * * www-data /usr/bin/php /var/www/wbengine-skeleton-app/vendor/bin/wbengine.php audit:prune --config=/var/www/wbengine-skeleton-app/src/Config/Settings.json --root=/var/www/wbengine-skeleton-app/src >> /var/log/wbengine-cron.log 2>&1
```')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/deployment/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND locale = 'cs'
  AND LOCATE('4.8.0/008-change-log-source.sql', bodytext) = 0;
