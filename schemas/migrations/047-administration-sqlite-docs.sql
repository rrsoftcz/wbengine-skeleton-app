-- The documentation page /docs/administration/ (English and Czech) describes the SQLite database of the central administration: the settings table without database passwords, the start without a database container, the backup command and the single instance.
-- Idempotent: every text edit runs only while the old text is present, so edits made later in the Admin survive a rerun.
SET NAMES utf8mb4;

UPDATE cms_articles
SET bodytext = REPLACE(bodytext, '| `MYSQL_ROOT_PASSWORD` | yes | Password of the MySQL root user in the bundled database container. |
| `MYSQL_PASSWORD` | yes | Password of the database user `wbadmin` that the application uses. |
| `MYSQL_PORT` | no, `13384` | Port on `127.0.0.1` of the host under which the bundled database is published, for the command line and local checks. |
| `DATABASE_URL` | yes | Connection of the application, for example `mysql://wbadmin:PASSWORD@db:3306/wbengine_admin` (the host `db` is the Compose service; the password is `MYSQL_PASSWORD`). For the command line run directly on the host use `127.0.0.1` and the published port. |
', '| `DATABASE_PATH` | set by Compose | The path of the SQLite file, `/app/data/admin.sqlite` in the `admin-data` volume. There is no database server and no database password to set. |
')
WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND LOCATE('| `MYSQL_ROOT_PASSWORD` | yes | Password of the MySQL root user in the bundled database container. |
| `MYSQL_PASSWORD` | yes | Password of the database user `wbadmin` that the application uses. |
| `MYSQL_PORT` | no, `13384` | Port on `127.0.0.1` of the host under which the bundled database is published, for the command line and local checks. |
| `DATABASE_URL` | yes | Connection of the application, for example `mysql://wbadmin:PASSWORD@db:3306/wbengine_admin` (the host `db` is the Compose service; the password is `MYSQL_PASSWORD`). For the command line run directly on the host use `127.0.0.1` and the published port. |
', bodytext) > 0;

UPDATE cms_articles
SET bodytext = REPLACE(bodytext, 'a SvelteKit application with its own MySQL 8.4 database, started with Docker Compose', 'a SvelteKit application with its own SQLite database (one file, no database server), started with Docker Compose')
WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND LOCATE('a SvelteKit application with its own MySQL 8.4 database, started with Docker Compose', bodytext) > 0;

UPDATE cms_articles
SET bodytext = REPLACE(bodytext, 'which starts the application and a MySQL 8.4 database.', 'which starts the application with one volume for its data.')
WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND LOCATE('which starts the application and a MySQL 8.4 database.', bodytext) > 0;

UPDATE cms_articles
SET bodytext = REPLACE(bodytext, 'cp .env.example .env        # fill in the passwords, MASTER_KEY and ORIGIN
docker compose up -d db
', 'cp .env.example .env        # fill in MASTER_KEY and ORIGIN
')
WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND LOCATE('cp .env.example .env        # fill in the passwords, MASTER_KEY and ORIGIN
docker compose up -d db
', bodytext) > 0;

UPDATE cms_articles
SET bodytext = REPLACE(bodytext, 'docker compose run --rm app npm run admin -- revoke USER_ID SITE_ID
', 'docker compose run --rm app npm run admin -- revoke USER_ID SITE_ID
docker compose run --rm app npm run admin -- backup /app/data/backups/admin.sqlite
')
WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND LOCATE('docker compose run --rm app npm run admin -- revoke USER_ID SITE_ID
', bodytext) > 0;

UPDATE cms_articles
SET bodytext = REPLACE(bodytext, 'removes the permission of an account for a site. `site-add`', 'removes the permission of an account for a site. `backup` writes a consistent copy of the database (see above). `site-add`')
WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND LOCATE('removes the permission of an account for a site. `site-add`', bodytext) > 0;

UPDATE cms_articles
SET bodytext = REPLACE(bodytext, 'The database of the administration holds', 'The database of the administration is one SQLite file, `admin.sqlite`, in the `admin-data` volume of the container. It holds')
WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND LOCATE('The database of the administration holds', bodytext) > 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, '| `MYSQL_ROOT_PASSWORD` | ano | Heslo uživatele root v přibaleném kontejneru s databází MySQL. |
| `MYSQL_PASSWORD` | ano | Heslo databázového uživatele `wbadmin`, kterého používá aplikace. |
| `MYSQL_PORT` | ne, `13384` | Port na `127.0.0.1` hostitele, na kterém je přibalená databáze zveřejněná, pro příkazový řádek a místní kontroly. |
| `DATABASE_URL` | ano | Připojení aplikace, například `mysql://wbadmin:HESLO@db:3306/wbengine_admin` (hostitel `db` je služba Compose, heslo je `MYSQL_PASSWORD`). Pro příkazový řádek spouštěný přímo na hostiteli použijte `127.0.0.1` a zveřejněný port. |
', '| `DATABASE_PATH` | nastaví Compose | Cesta k souboru SQLite, `/app/data/admin.sqlite` ve svazku `admin-data`. Žádný databázový server ani heslo k databázi se nenastavuje. |
')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND locale = 'cs' AND LOCATE('| `MYSQL_ROOT_PASSWORD` | ano | Heslo uživatele root v přibaleném kontejneru s databází MySQL. |
| `MYSQL_PASSWORD` | ano | Heslo databázového uživatele `wbadmin`, kterého používá aplikace. |
| `MYSQL_PORT` | ne, `13384` | Port na `127.0.0.1` hostitele, na kterém je přibalená databáze zveřejněná, pro příkazový řádek a místní kontroly. |
| `DATABASE_URL` | ano | Připojení aplikace, například `mysql://wbadmin:HESLO@db:3306/wbengine_admin` (hostitel `db` je služba Compose, heslo je `MYSQL_PASSWORD`). Pro příkazový řádek spouštěný přímo na hostiteli použijte `127.0.0.1` a zveřejněný port. |
', bodytext) > 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, 'aplikace v SvelteKitu s vlastní databází MySQL 8.4, spouštěná pomocí Docker Compose', 'aplikace v SvelteKitu s vlastní databází SQLite (jeden soubor, žádný databázový server), spouštěná pomocí Docker Compose')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND locale = 'cs' AND LOCATE('aplikace v SvelteKitu s vlastní databází MySQL 8.4, spouštěná pomocí Docker Compose', bodytext) > 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, 'který spustí aplikaci a databázi MySQL 8.4.', 'který spustí aplikaci s jedním svazkem pro její data.')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND locale = 'cs' AND LOCATE('který spustí aplikaci a databázi MySQL 8.4.', bodytext) > 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, 'cp .env.example .env        # vyplňte hesla, MASTER_KEY a ORIGIN
docker compose up -d db
', 'cp .env.example .env        # vyplňte MASTER_KEY a ORIGIN
')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND locale = 'cs' AND LOCATE('cp .env.example .env        # vyplňte hesla, MASTER_KEY a ORIGIN
docker compose up -d db
', bodytext) > 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, 'docker compose run --rm app npm run admin -- revoke ID_UZIVATELE ID_WEBU
', 'docker compose run --rm app npm run admin -- revoke ID_UZIVATELE ID_WEBU
docker compose run --rm app npm run admin -- backup /app/data/backups/admin.sqlite
')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND locale = 'cs' AND LOCATE('docker compose run --rm app npm run admin -- revoke ID_UZIVATELE ID_WEBU
', bodytext) > 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, 'odebere účtu oprávnění k webu. `site-add`', 'odebere účtu oprávnění k webu. `backup` zapíše konzistentní kopii databáze (viz výše). `site-add`')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND locale = 'cs' AND LOCATE('odebere účtu oprávnění k webu. `site-add`', bodytext) > 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, 'Databáze administrace obsahuje', 'Databáze administrace je jeden soubor SQLite, `admin.sqlite`, ve svazku `admin-data` kontejneru. Obsahuje')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND locale = 'cs' AND LOCATE('Databáze administrace obsahuje', bodytext) > 0;

UPDATE cms_articles
SET bodytext = REPLACE(bodytext, '- Back up the database regularly, for example with `docker compose exec db sh -c \'mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --single-transaction wbengine_admin\' > backup.sql`.', '- Back up the database regularly with `docker compose run --rm app npm run admin -- backup /app/data/backups/admin.sqlite`. It writes a consistent copy while the application keeps running; only its owner can read the copy. The copy holds encrypted keys and password hashes, so never store it together with `MASTER_KEY`. To restore, stop the application, put the copy in place of `admin.sqlite` in the `admin-data` volume and start it again.
- Run exactly one instance of the application. The database file belongs on a local volume, not on a network share.')
WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND LOCATE('- Back up the database regularly, for example with `docker compose exec db sh -c \'mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --single-transaction wbengine_admin\' > backup.sql`.', bodytext) > 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, '- Databázi pravidelně zálohujte, například `docker compose exec db sh -c \'mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --single-transaction wbengine_admin\' > backup.sql`.', '- Databázi pravidelně zálohujte příkazem `docker compose run --rm app npm run admin -- backup /app/data/backups/admin.sqlite`. Zapíše konzistentní kopii za běhu aplikace; kopii může číst jen její vlastník. Kopie obsahuje zašifrované klíče a hashe hesel, proto ji nikdy neukládejte společně s `MASTER_KEY`. Při obnově aplikaci zastavte, kopii vložte na místo `admin.sqlite` ve svazku `admin-data` a aplikaci znovu spusťte.
- Provozujte vždy právě jednu instanci aplikace. Soubor databáze patří na místní svazek, ne na síťové sdílení.')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND locale = 'cs' AND LOCATE('- Databázi pravidelně zálohujte, například `docker compose exec db sh -c \'mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --single-transaction wbengine_admin\' > backup.sql`.', bodytext) > 0;
