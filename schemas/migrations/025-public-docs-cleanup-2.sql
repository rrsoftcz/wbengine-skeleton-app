-- Public documentation wording, second pass: the deployment page of a site that took the earlier updates one by one
-- still named a migration file and migration numbers. Text-only and safe to rerun.
SET NAMES utf8mb4;

UPDATE cms_articles
SET introtext = REPLACE(REPLACE(REPLACE(introtext, 'sh bin/update-database.sh wbengine_skeleton_app
mysql wbengine_skeleton_app < vendor/wbengine/wbengine/migrations/4.8.0/008-change-log-source.sql
', 'sh bin/update-database.sh wbengine_skeleton_app
'), ' `001` (an optional index) and `003`/`004` (Markdown columns and a conversion ledger) are not needed on a fresh install because the skeleton schema already has `content_format`.', ''), ' Migrace `001` (volitelný index) a `003`/`004` (sloupce Markdown a záznam převodu) na čisté instalaci netřeba, protože schéma kostry už `content_format` má.', ''),
    bodytext = REPLACE(REPLACE(REPLACE(bodytext, 'sh bin/update-database.sh wbengine_skeleton_app
mysql wbengine_skeleton_app < vendor/wbengine/wbengine/migrations/4.8.0/008-change-log-source.sql
', 'sh bin/update-database.sh wbengine_skeleton_app
'), ' `001` (an optional index) and `003`/`004` (Markdown columns and a conversion ledger) are not needed on a fresh install because the skeleton schema already has `content_format`.', ''), ' Migrace `001` (volitelný index) a `003`/`004` (sloupce Markdown a záznam převodu) na čisté instalaci netřeba, protože schéma kostry už `content_format` má.', '');

UPDATE cms_article_translations
SET introtext = REPLACE(REPLACE(REPLACE(introtext, 'sh bin/update-database.sh wbengine_skeleton_app
mysql wbengine_skeleton_app < vendor/wbengine/wbengine/migrations/4.8.0/008-change-log-source.sql
', 'sh bin/update-database.sh wbengine_skeleton_app
'), ' `001` (an optional index) and `003`/`004` (Markdown columns and a conversion ledger) are not needed on a fresh install because the skeleton schema already has `content_format`.', ''), ' Migrace `001` (volitelný index) a `003`/`004` (sloupce Markdown a záznam převodu) na čisté instalaci netřeba, protože schéma kostry už `content_format` má.', ''),
    bodytext = REPLACE(REPLACE(REPLACE(bodytext, 'sh bin/update-database.sh wbengine_skeleton_app
mysql wbengine_skeleton_app < vendor/wbengine/wbengine/migrations/4.8.0/008-change-log-source.sql
', 'sh bin/update-database.sh wbengine_skeleton_app
'), ' `001` (an optional index) and `003`/`004` (Markdown columns and a conversion ledger) are not needed on a fresh install because the skeleton schema already has `content_format`.', ''), ' Migrace `001` (volitelný index) a `003`/`004` (sloupce Markdown a záznam převodu) na čisté instalaci netřeba, protože schéma kostry už `content_format` má.', '');
