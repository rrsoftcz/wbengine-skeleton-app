-- Extends the documentation page /docs/administration/ (English and Czech): installing and configuring the central administration (WBengine Admin) with every setting, accounts and access, the optional invitation email, the master key and backups, the command line and updating.
-- Also corrects the page (the source of the administration is public, the first account and later invitations) and points the start page of the documentation to it.
-- Idempotent: every text edit runs only while the old text is present and its new text is missing, so edits made later in the Admin survive a rerun.
SET NAMES utf8mb4;

UPDATE cms_articles
SET bodytext = REPLACE(bodytext, '## Languages and translations', '## Installing and configuring

This part is about running the administration itself: a SvelteKit application with its own MySQL 8.4 database, started with Docker Compose from the source on GitHub.

### Requirements

- Docker with Docker Compose. The repository contains the `Dockerfile` (Node 24) and `compose.yaml`, which starts the application and a MySQL 8.4 database.
- A host name for the administration and an HTTPS reverse proxy in front of it (see below).
- Node.js 22.18 or newer only when you run the tests or the command line outside Docker.

### Settings (environment variables)

All settings are environment variables. Copy `.env.example` to `.env` next to `compose.yaml` and fill it in. The file contains secrets: keep it out of Git and readable only by the user who deploys (on a server, mode `0600`). Compose passes the variables to the application.

| Variable | Required | Meaning |
|----------|----------|---------|
| `MYSQL_ROOT_PASSWORD` | yes | Password of the MySQL root user in the bundled database container. |
| `MYSQL_PASSWORD` | yes | Password of the database user `wbadmin` that the application uses. |
| `MYSQL_PORT` | no, `13384` | Port on `127.0.0.1` of the host under which the bundled database is published, for the command line and local checks. |
| `DATABASE_URL` | yes | Connection of the application, for example `mysql://wbadmin:PASSWORD@db:3306/wbengine_admin` (the host `db` is the Compose service; the password is `MYSQL_PASSWORD`). For the command line run directly on the host use `127.0.0.1` and the published port. |
| `MASTER_KEY` | yes | 32 random bytes as 64 hexadecimal characters, for example from `openssl rand -hex 32`. It encrypts the integration keys of the sites and the secrets of two-step verification in the database. |
| `ORIGIN` | yes | The exact HTTPS address of the administration without a trailing slash, for example `https://admin.example.com`. The application compares requests with it, and the link in an invitation email is built from it. |
| `REMOTE_IP_ALLOWLIST` | no, empty | Exact IP addresses, separated by commas, of sites on a private network that the operator has approved. No ranges and no host names. Without it only sites on public addresses can be registered. |
| `MAIL_SMTP_HOST` | no | SMTP server for invitation emails, for Google `smtp.gmail.com`. |
| `MAIL_SMTP_PORT` | no, `587` | `587` (STARTTLS) or `465` (TLS from the start). |
| `MAIL_SMTP_USER` | no | The account used to sign in to the SMTP server, for Google the full address. |
| `MAIL_SMTP_PASSWORD` | no | Its password, for Google an app password. |
| `MAIL_FROM` | no | The sender address of the invitation email. |

Compose also sets the listening address and port inside the container and the limit of a request body (1 MiB); there is nothing to configure. The `MAIL_*` variables work together: see Invitation by email below.

### Start with Docker Compose

```sh
git clone https://github.com/rrsoftcz/wbengine-admin.git
cd wbengine-admin
cp .env.example .env        # fill in the passwords, MASTER_KEY and ORIGIN
docker compose up -d db
docker compose run --rm app npm run admin -- migrate
docker compose up -d --build app
```

The application does not change the database on its own. The `migrate` command applies every file of `migrations/` once and records it, so run it before you start a version that contains a new migration. The application listens on `127.0.0.1:13000`.

### HTTPS reverse proxy

The application assumes that a reverse proxy (Nginx, Caddy or similar) terminates HTTPS and forwards to `127.0.0.1:13000`. `ORIGIN` must be exactly the address the visitors use. The proxy must pass the correct `Host` header and must remove or overwrite the forwarded headers it receives, because the application does not trust proxy headers. Cookies are always `Secure`, in development too, so even a local run needs an HTTPS proxy in front of it.

### First administrator

There is no public registration and no default account. The first global admin is created on the server with the command line:

```sh
docker compose run --rm app npm run admin -- invite you@example.com global
```

The command prints a one-time code valid for 48 hours. Open `/accept` of the administration, enter the code and choose a password (14 to 256 characters). The next step is the setup of two-step verification.

## Accounts and access

Who can sign in, what each role may do and how people are invited.

### Signing in

- A password and a code from an authenticator app (TOTP, 6 digits, 30 seconds). Two-step verification is mandatory for every account.
- Ten backup codes are shown once when the verification is set up. A backup code replaces the code from the phone when the phone is lost. Verification cannot be switched off on the web, and a password alone never replaces it.
- Failed attempts are limited: 8 password attempts and 12 verification attempts per 15 minutes.
- A session lasts 8 hours.
- A forgotten password is recovered with a one-time code valid for 30 minutes that a global admin issues for the account (the Users page or the command `recover`). A new password signs the account out everywhere and keeps the verification.

### Roles

A person has a role per site. Every operation also needs a matching permission of the site\'s integration key and a capability of the site.

| Role | What the person can do |
|------|------------------------|
| Editor | Read the site, edit article drafts and their translations, upload images. |
| Site admin | Everything an editor can, and change the structure (pages, menu, sections, boxes), publish and remove content, and see the site users, the settings and the Activity page of the site. |
| Global admin | Everything above on all sites, and manage the registry of sites (add a site, replace a key) and the accounts of the administration. |

### Users and invitations

A global admin manages the accounts at `/users`: search, invite, disable and enable, promote and demote global admins, issue a recovery code, reset two-step verification and revoke access to a site. Nobody can change their own role or status there, and the last global admin is kept.

To invite someone, enter the email, choose the level (team member or global admin) and, for a team member, optionally the first site and the role on it (editor or site admin). The administration shows a one-time code valid for 48 hours, once. Hand it over through a secure channel. The person opens `/accept`, enters the code, chooses a password and sets up the verification. An email that already has an account cannot be invited again.

### Invitation by email

By default the code is handed over by hand. When an SMTP server is configured, the invite form gets a second button, Create and send by email. It sends the person a welcome text, the link to the invitation page (built from `ORIGIN`), the code and the information that the code is valid once for 48 hours. The code is still shown on the screen, so you can always pass it on yourself. The email is written in the interface language of the administrator who sends it (English, Czech, German or Polish). Without the configuration the button is not shown and nothing else changes.

Set `MAIL_SMTP_HOST`, `MAIL_SMTP_USER`, `MAIL_SMTP_PASSWORD` and `MAIL_FROM` together; `MAIL_SMTP_PORT` is `587` unless you set it. If some of them are missing, the feature stays off and the administration logs one warning at start. The connection is always encrypted and the certificate of the server is always verified.

With Google (a Google Workspace account on your own domain is preferable, a personal Google account works too):

1. Turn on two-step verification for the sending account.
2. Create an app password for it and use that, never the password of the account. Google can change its rules for app passwords and limits, so check its current documentation.
3. Put the values into `.env` on the server: `MAIL_SMTP_HOST=smtp.gmail.com`, `MAIL_SMTP_PORT=587`, `MAIL_SMTP_USER` the address of the account, `MAIL_SMTP_PASSWORD` the app password and `MAIL_FROM` the address of the account or an alias verified in Google as Send mail as (Google replaces any other sender).
4. Restart the application: `docker compose up -d --build app`.

"Sent" means that the SMTP server accepted the message. It does not promise that the email reaches the inbox: that depends on the mail setup of the sender domain (SPF, DKIM and DMARC). If sending fails, the page says why: the mail server rejected the login, the address was rejected, there is no connection to the mail server, the mail server did not answer in time, or an unknown error (the details are in the server log). The invitation stays valid in every case, so the code can be handed over by hand. The password of the mail account is never written to the log or shown. Both the sent and the failed attempt are recorded in the audit.

## Operating the administration

Secrets, backups, the command line and updates.

### Master key and backups

The database of the administration holds the accounts, the registry of sites, the permissions and the audit. Integration keys of the sites and the secrets of two-step verification are stored encrypted with `MASTER_KEY`.

- Keep `MASTER_KEY` in a secret store outside the database and outside the backups of the database. A restored database is readable only with the same key.
- Changing the key is a controlled re-encryption of the stored data. The administration has no automatic rotation.
- Back up the database regularly, for example with `docker compose exec db sh -c \'mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --single-transaction wbengine_admin\' > backup.sql`.
- If a site\'s key is ever lost or exposed, issue a new one on the site, enter it under Replace integration key and only then revoke the old one on the site.

### Command line

The command line works directly on the server with the environment of the application. Access to it is privileged. It never sends email.

```sh
docker compose run --rm app npm run admin -- migrate
docker compose run --rm app npm run admin -- invite EMAIL global
docker compose run --rm app npm run admin -- invite EMAIL member SITE_ID editor
docker compose run --rm app npm run admin -- recover EMAIL
docker compose run --rm app npm run admin -- users
docker compose run --rm app npm run admin -- revoke USER_ID SITE_ID
printf \'%s\' "$KEY" | docker compose run --rm -T app npm run admin -- site-add \'Site name\' https://example.com/
```

`migrate` applies the database migrations. `invite` and `recover` print a one-time code (48 hours and 30 minutes). `users` lists the accounts. `revoke` removes the permission of an account for a site. `site-add` registers a site; the integration key is read from the standard input so that it never appears in the command line or the shell history. The usual way to add a site is the Sites page of the administration.

### Updating

Fetch the new version (`git pull`), run `migrate` as above, then `docker compose up -d --build app`.

## Languages and translations')
WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND LOCATE('## Languages and translations', bodytext) > 0 AND LOCATE('## Installing and configuring', bodytext) = 0;

UPDATE cms_articles
SET bodytext = REPLACE(bodytext, '## Separate application, connected sites', 'This page describes what the central administration does and how a site is connected, then how to install and run it. The sections, in order:

- Separate application, connected sites; what an editor can manage; site users and settings; what it does not replace
- Connecting a site step by step
- Installing and configuring: requirements, settings (environment variables), start with Docker Compose, HTTPS reverse proxy, first administrator
- Accounts and access: signing in, roles, users and invitations, invitation by email
- Operating the administration: master key and backups, command line, updating
- Languages and translations

## Separate application, connected sites')
WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND LOCATE('## Separate application, connected sites', bodytext) > 0 AND LOCATE('The sections, in order:', bodytext) = 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, '## Jazyky a překlady', '## Instalace a nastavení

Tato část je o provozu samotné administrace: aplikace v SvelteKitu s vlastní databází MySQL 8.4, spouštěná pomocí Docker Compose ze zdrojového kódu na GitHubu.

### Požadavky

- Docker s Docker Compose. Repozitář obsahuje `Dockerfile` (Node 24) a `compose.yaml`, který spustí aplikaci a databázi MySQL 8.4.
- Doménové jméno administrace a před ní reverzní proxy s HTTPS (viz níže).
- Node.js 22.18 nebo novější jen tehdy, když spouštíte testy nebo příkazový řádek mimo Docker.

### Nastavení (proměnné prostředí)

Všechna nastavení jsou proměnné prostředí. Zkopírujte `.env.example` na `.env` vedle `compose.yaml` a vyplňte ho. Soubor obsahuje tajné údaje: nedávejte ho do Gitu a nechte ho čitelný jen pro uživatele, který nasazuje (na serveru s právy `0600`). Compose proměnné předá aplikaci.

| Proměnná | Povinná | Význam |
|----------|---------|--------|
| `MYSQL_ROOT_PASSWORD` | ano | Heslo uživatele root v přibaleném kontejneru s databází MySQL. |
| `MYSQL_PASSWORD` | ano | Heslo databázového uživatele `wbadmin`, kterého používá aplikace. |
| `MYSQL_PORT` | ne, `13384` | Port na `127.0.0.1` hostitele, na kterém je přibalená databáze zveřejněná, pro příkazový řádek a místní kontroly. |
| `DATABASE_URL` | ano | Připojení aplikace, například `mysql://wbadmin:HESLO@db:3306/wbengine_admin` (hostitel `db` je služba Compose, heslo je `MYSQL_PASSWORD`). Pro příkazový řádek spouštěný přímo na hostiteli použijte `127.0.0.1` a zveřejněný port. |
| `MASTER_KEY` | ano | 32 náhodných bajtů jako 64 hexadecimálních znaků, například z `openssl rand -hex 32`. Šifruje v databázi integrační klíče webů a tajné údaje dvoufázového ověření. |
| `ORIGIN` | ano | Přesná adresa administrace s HTTPS bez lomítka na konci, například `https://admin.example.com`. Aplikace s ní porovnává požadavky a odkaz v pozvánce emailem se staví z ní. |
| `REMOTE_IP_ALLOWLIST` | ne, prázdná | Přesné IP adresy, oddělené čárkami, webů v privátní síti, které provozovatel schválil. Žádné rozsahy a žádná jména hostitelů. Bez ní lze zaregistrovat jen weby na veřejných adresách. |
| `MAIL_SMTP_HOST` | ne | Server SMTP pro pozvánky emailem, u Googlu `smtp.gmail.com`. |
| `MAIL_SMTP_PORT` | ne, `587` | `587` (STARTTLS) nebo `465` (TLS od začátku). |
| `MAIL_SMTP_USER` | ne | Účet pro přihlášení k serveru SMTP, u Googlu celá adresa. |
| `MAIL_SMTP_PASSWORD` | ne | Jeho heslo, u Googlu heslo aplikace. |
| `MAIL_FROM` | ne | Adresa odesílatele pozvánky. |

Compose navíc nastavuje adresu a port, na kterých aplikace v kontejneru naslouchá, a limit těla požadavku (1 MiB); není co konfigurovat. Proměnné `MAIL_*` fungují společně: viz Pozvánka emailem níže.

### Spuštění pomocí Docker Compose

```sh
git clone https://github.com/rrsoftcz/wbengine-admin.git
cd wbengine-admin
cp .env.example .env        # vyplňte hesla, MASTER_KEY a ORIGIN
docker compose up -d db
docker compose run --rm app npm run admin -- migrate
docker compose up -d --build app
```

Aplikace databázi sama nemění. Příkaz `migrate` použije každý soubor z `migrations/` jednou a zaznamená ho, proto ho spusťte před spuštěním verze, která novou migraci obsahuje. Aplikace naslouchá na `127.0.0.1:13000`.

### Reverzní proxy s HTTPS

Aplikace předpokládá, že reverzní proxy (Nginx, Caddy a podobně) ukončuje HTTPS a předává požadavky na `127.0.0.1:13000`. `ORIGIN` musí být přesně adresa, kterou používají návštěvníci. Proxy musí předávat správnou hlavičku `Host` a přijaté předávací hlavičky odstranit nebo přepsat, protože aplikace hlavičkám proxy nevěří. Cookies jsou vždy `Secure`, i při vývoji, takže i místní běh potřebuje před sebou proxy s HTTPS.

### První správce

Neexistuje veřejná registrace ani výchozí účet. První globální správce se vytvoří na serveru příkazovým řádkem:

```sh
docker compose run --rm app npm run admin -- invite you@example.com global
```

Příkaz vypíše jednorázový kód s platností 48 hodin. Otevřete `/accept` administrace, zadejte kód a zvolte heslo (14 až 256 znaků). Dalším krokem je nastavení dvoufázového ověření.

## Účty a přístup

Kdo se může přihlásit, co smí která role a jak se lidé zvou.

### Přihlášení

- Heslo a kód z autentizační aplikace (TOTP, 6 číslic, 30 sekund). Dvoufázové ověření je povinné pro každý účet.
- Deset záložních kódů se zobrazí jednou při nastavení ověření. Záložní kód nahradí kód z telefonu, když telefon ztratíte. Ověření nelze na webu vypnout a samotné heslo ho nikdy nenahradí.
- Neúspěšné pokusy jsou omezené: 8 pokusů s heslem a 12 pokusů s ověřením za 15 minut.
- Relace trvá 8 hodin.
- Zapomenuté heslo se obnoví jednorázovým kódem s platností 30 minut, který pro účet vydá globální správce (stránka Uživatelé nebo příkaz `recover`). Nové heslo odhlásí účet všude a ověření zachová.

### Role

Člověk má roli pro každý web zvlášť. Každá operace navíc vyžaduje odpovídající oprávnění integračního klíče webu a schopnost webu.

| Role | Co smí |
|------|--------|
| Redaktor | Číst web, upravovat koncepty článků a jejich překlady, nahrávat obrázky. |
| Správce webu | Vše, co redaktor, a navíc měnit strukturu (stránky, menu, sekce, boxy), publikovat a odstraňovat obsah a vidět uživatele, nastavení a stránku Aktivita webu. |
| Globální správce | Vše výše na všech webech a navíc spravovat seznam webů (přidat web, vyměnit klíč) a účty administrace. |

### Uživatelé a pozvánky

Globální správce spravuje účty na `/users`: hledání, pozvání, zakázání a povolení, povýšení a degradace globálních správců, vydání obnovovacího kódu, reset dvoufázového ověření a odebrání přístupu k webu. Nikdo si tam nemůže změnit vlastní roli ani stav a poslední globální správce zůstává zachován.

Pozvání: zadejte email, zvolte úroveň (člen týmu nebo globální správce) a u člena týmu volitelně první web a roli na něm (redaktor nebo správce webu). Administrace jednou ukáže jednorázový kód s platností 48 hodin. Předejte ho bezpečným kanálem. Osoba otevře `/accept`, zadá kód, zvolí heslo a nastaví ověření. Email, který už má účet, nelze pozvat znovu.

### Pozvánka emailem

Ve výchozím stavu se kód předává ručně. Je-li nastavený server SMTP, formulář pozvánky dostane druhé tlačítko, Vytvořit a odeslat emailem. Pošle osobě uvítací text, odkaz na stránku pozvánky (sestavený z `ORIGIN`), kód a informaci, že kód platí jednou a 48 hodin. Kód se dál zobrazí i na obrazovce, takže ho můžete vždy předat sami. Email je napsaný v jazyce rozhraní správce, který ho odesílá (angličtina, čeština, němčina nebo polština). Bez nastavení se tlačítko nezobrazí a nic jiného se nemění.

Nastavte `MAIL_SMTP_HOST`, `MAIL_SMTP_USER`, `MAIL_SMTP_PASSWORD` a `MAIL_FROM` společně; `MAIL_SMTP_PORT` je `587`, pokud ho nenastavíte. Chybí-li některá, funkce zůstane vypnutá a administrace při startu zapíše jedno varování. Spojení je vždy šifrované a certifikát serveru se vždy ověřuje.

S Googlem (výhodnější je účet Google Workspace na vlastní doméně, funguje i osobní účet Google):

1. Zapněte dvoufázové ověření odesílajícího účtu.
2. Vytvořte pro něj heslo aplikace a použijte ho, nikdy ne heslo účtu. Google může pravidla hesel aplikací i limity měnit, proto zkontrolujte jeho aktuální dokumentaci.
3. Hodnoty vložte do `.env` na serveru: `MAIL_SMTP_HOST=smtp.gmail.com`, `MAIL_SMTP_PORT=587`, `MAIL_SMTP_USER` adresa účtu, `MAIL_SMTP_PASSWORD` heslo aplikace a `MAIL_FROM` adresa účtu nebo alias ověřený v Googlu jako alias pro odesílání (jinou adresu odesílatele Google nahradí).
4. Restartujte aplikaci: `docker compose up -d --build app`.

"Odesláno" znamená, že server SMTP zprávu přijal. Neslibuje, že email dorazí do schránky: to závisí na poštovním nastavení domény odesílatele (SPF, DKIM a DMARC). Když odeslání selže, stránka řekne proč: poštovní server odmítl přihlášení, adresa byla odmítnuta, nelze se připojit k poštovnímu serveru, poštovní server neodpověděl včas, nebo neznámá chyba (podrobnosti jsou v logu serveru). Pozvánka zůstává platná v každém případě, takže kód lze předat ručně. Heslo poštovního účtu se nikdy nezapisuje do logu ani nezobrazuje. Odeslání i neúspěšný pokus se zapisují do auditu.

## Provoz administrace

Tajné údaje, zálohy, příkazový řádek a aktualizace.

### Hlavní klíč a zálohy

Databáze administrace obsahuje účty, seznam webů, oprávnění a audit. Integrační klíče webů a tajné údaje dvoufázového ověření jsou uložené zašifrované pomocí `MASTER_KEY`.

- `MASTER_KEY` uchovávejte v úložišti tajných údajů mimo databázi i mimo zálohy databáze. Obnovená databáze je čitelná jen se stejným klíčem.
- Změna klíče je řízené přešifrování uložených dat. Administrace nemá automatickou rotaci.
- Databázi pravidelně zálohujte, například `docker compose exec db sh -c \'mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --single-transaction wbengine_admin\' > backup.sql`.
- Když se klíč webu ztratí nebo unikne, vydejte na webu nový, zadejte ho v Adminu pod Vyměnit integrační klíč a teprve potom na webu zrušte starý.

### Příkazový řádek

Příkazový řádek pracuje přímo na serveru s prostředím aplikace. Přístup k němu je privilegovaný. Nikdy neposílá email.

```sh
docker compose run --rm app npm run admin -- migrate
docker compose run --rm app npm run admin -- invite EMAIL global
docker compose run --rm app npm run admin -- invite EMAIL member ID_WEBU editor
docker compose run --rm app npm run admin -- recover EMAIL
docker compose run --rm app npm run admin -- users
docker compose run --rm app npm run admin -- revoke ID_UZIVATELE ID_WEBU
printf \'%s\' "$KLIC" | docker compose run --rm -T app npm run admin -- site-add \'Název webu\' https://example.com/
```

`migrate` použije databázové migrace. `invite` a `recover` vypíšou jednorázový kód (48 hodin a 30 minut). `users` vypíše účty. `revoke` odebere účtu oprávnění k webu. `site-add` zaregistruje web; integrační klíč se čte ze standardního vstupu, aby se nikdy neobjevil v příkazovém řádku ani v historii shellu. Obvyklá cesta k přidání webu je stránka Weby v administraci.

### Aktualizace

Stáhněte novou verzi (`git pull`), spusťte `migrate` jako výše a pak `docker compose up -d --build app`.

## Jazyky a překlady')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a) AND locale = 'cs'
  AND LOCATE('## Jazyky a překlady', bodytext) > 0 AND LOCATE('## Instalace a nastavení', bodytext) = 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, '## Samostatná aplikace, připojené weby', 'Tato stránka popisuje, co centrální administrace umí a jak se web připojí, a pak jak ji nainstalovat a provozovat. Části v pořadí:

- Samostatná aplikace, připojené weby; co může redaktor spravovat; uživatelé a nastavení webu; co administrace nenahrazuje
- Připojení webu krok za krokem
- Instalace a nastavení: požadavky, nastavení (proměnné prostředí), spuštění pomocí Docker Compose, reverzní proxy s HTTPS, první správce
- Účty a přístup: přihlášení, role, uživatelé a pozvánky, pozvánka emailem
- Provoz administrace: hlavní klíč a zálohy, příkazový řádek, aktualizace
- Jazyky a překlady

## Samostatná aplikace, připojené weby')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a) AND locale = 'cs'
  AND LOCATE('## Samostatná aplikace, připojené weby', bodytext) > 0 AND LOCATE('Části v pořadí:', bodytext) = 0;

UPDATE cms_articles
SET bodytext = REPLACE(bodytext, 'Its source is private and it is not a public Composer package or public container image. The public documentation describes its architecture and supported workflow; access to the tool is managed separately.', 'Its source is public on [GitHub](https://github.com/rrsoftcz/wbengine-admin) under the MIT license. It is not a Composer package, and no ready-made container image is published: the image is built from the source with Docker Compose. Installation, every setting and operation are described in the sections Installing and configuring, Accounts and access and Operating the administration below.')
WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND LOCATE('Its source is private and it is not a public Composer package or public container image. The public documentation describes its architecture and supported workflow; access to the tool is managed separately.', bodytext) > 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, 'Její zdrojový kód je soukromý a nejde o veřejný Composer balíček ani veřejný kontejner. Veřejná dokumentace popisuje architekturu a podporovaný postup; přístup k nástroji se řeší samostatně.', 'Její zdrojový kód je veřejný na [GitHubu](https://github.com/rrsoftcz/wbengine-admin) pod licencí MIT. Nejde o balíček Composeru a nepublikuje se hotový kontejnerový obraz: obraz se sestaví ze zdrojového kódu pomocí Docker Compose. Instalaci, všechna nastavení a provoz popisují části Instalace a nastavení, Účty a přístup a Provoz administrace níže.')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a) AND locale = 'cs'
  AND LOCATE('Její zdrojový kód je soukromý a nejde o veřejný Composer balíček ani veřejný kontejner. Veřejná dokumentace popisuje architekturu a podporovaný postup; přístup k nástroji se řeší samostatně.', bodytext) > 0;

UPDATE cms_articles
SET bodytext = REPLACE(bodytext, 'The operator creates accounts with `npm run admin -- invite EMAIL global` on the Admin server, and the person activates the account at `/accept`.', 'The first global admin is created on the Admin server with `npm run admin -- invite EMAIL global`; later a global admin invites people on the Users page, optionally by email (see Users and invitations below), and the person activates the account at `/accept`.')
WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND LOCATE('The operator creates accounts with `npm run admin -- invite EMAIL global` on the Admin server, and the person activates the account at `/accept`.', bodytext) > 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, 'Účty zakládá provozovatel na serveru Adminu příkazem `npm run admin -- invite EMAIL global`, osoba účet aktivuje na `/accept`.', 'První globální správce se vytvoří na serveru Adminu příkazem `npm run admin -- invite EMAIL global`; další lidi pak zve globální správce na stránce Uživatelé, volitelně emailem (viz Uživatelé a pozvánky níže), a osoba účet aktivuje na `/accept`.')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/administration/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a) AND locale = 'cs'
  AND LOCATE('Účty zakládá provozovatel na serveru Adminu příkazem `npm run admin -- invite EMAIL global`, osoba účet aktivuje na `/accept`.', bodytext) > 0;

UPDATE cms_articles
SET bodytext = REPLACE(bodytext, 'It needs an account with the role `admin`.', 'It needs an account with the role `admin`. Installing and running the administration itself is described on the same page, in the section Installing and configuring.')
WHERE id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a)
  AND LOCATE('It needs an account with the role `admin`.', bodytext) > 0 AND LOCATE('Installing and running the administration itself', bodytext) = 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, 'Vyžaduje účet s rolí `admin`.', 'Vyžaduje účet s rolí `admin`. Instalaci a provoz samotné administrace popisuje tatáž stránka, část Instalace a nastavení.')
WHERE article_id = (SELECT id FROM (SELECT id FROM cms_articles WHERE site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/' ORDER BY site_id LIMIT 1) ORDER BY id LIMIT 1) AS a) AND locale = 'cs'
  AND LOCATE('Vyžaduje účet s rolí `admin`.', bodytext) > 0 AND LOCATE('Instalaci a provoz samotné administrace', bodytext) = 0;
