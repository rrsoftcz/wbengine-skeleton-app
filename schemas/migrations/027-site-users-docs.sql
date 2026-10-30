-- Central administration page: site users and settings, and one wording fix. Each UPDATE runs only while the section is missing, so the migration is safe to rerun.
SET NAMES utf8mb4;

UPDATE cms_articles
SET bodytext = REPLACE(REPLACE(REPLACE(bodytext, '## What it does not replace', '## Site users and settings

For a site administrator, the central administration also covers the accounts that sign in on the site itself and two server-side actions, when the site allows it.

- **Site users:** list and search the accounts, create an account, change its role (user, editor or administrator), disable and enable it. A new account has no password: the administration shows a one-time link once, and the owner opens it on the login page of the site to choose a password. Passwords are never set, read or stored by the central administration, and the last active administrator of a site cannot be demoted or disabled.
- **Site settings:** the effective settings of the site, read only, with secret values shown only as set, and a button that flushes the site cache. The settings themselves are changed on the server.

Both pages need an integration key issued with the matching permissions; a key without them asks to be replaced.

## What it does not replace'), '## Co administrace nenahrazuje', '## Uživatelé a nastavení webu

Pro správce webu centrální administrace pokrývá také účty, které se přihlašují přímo na webu, a dvě akce na straně serveru, pokud je web povolí.

- **Uživatelé webu:** seznam a hledání účtů, založení účtu, změna role (uživatel, editor nebo administrátor), zakázání a povolení. Nový účet nemá heslo: administrace jednou zobrazí jednorázový odkaz a majitel ho otevře na přihlašovací stránce webu a zvolí si heslo. Hesla centrální administrace nikdy nenastavuje, nečte ani neukládá a posledního aktivního administrátora webu nelze degradovat ani zakázat.
- **Nastavení webu:** platné nastavení webu pouze ke čtení, s tajnými hodnotami zobrazenými jen jako nastavené, a tlačítko, které vyprázdní cache webu. Samotné nastavení se mění na serveru.

Obě stránky vyžadují integrační klíč vydaný s odpovídajícími oprávněními; klíč bez nich vyzve k výměně.

## Co administrace nenahrazuje'), 'Obrázky podporované touto verzí jsou veřejná', 'Podporované obrázky jsou veřejná')
WHERE LOCATE('## Site users and settings', bodytext) = 0 AND LOCATE('## Uživatelé a nastavení webu', bodytext) = 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(REPLACE(REPLACE(bodytext, '## What it does not replace', '## Site users and settings

For a site administrator, the central administration also covers the accounts that sign in on the site itself and two server-side actions, when the site allows it.

- **Site users:** list and search the accounts, create an account, change its role (user, editor or administrator), disable and enable it. A new account has no password: the administration shows a one-time link once, and the owner opens it on the login page of the site to choose a password. Passwords are never set, read or stored by the central administration, and the last active administrator of a site cannot be demoted or disabled.
- **Site settings:** the effective settings of the site, read only, with secret values shown only as set, and a button that flushes the site cache. The settings themselves are changed on the server.

Both pages need an integration key issued with the matching permissions; a key without them asks to be replaced.

## What it does not replace'), '## Co administrace nenahrazuje', '## Uživatelé a nastavení webu

Pro správce webu centrální administrace pokrývá také účty, které se přihlašují přímo na webu, a dvě akce na straně serveru, pokud je web povolí.

- **Uživatelé webu:** seznam a hledání účtů, založení účtu, změna role (uživatel, editor nebo administrátor), zakázání a povolení. Nový účet nemá heslo: administrace jednou zobrazí jednorázový odkaz a majitel ho otevře na přihlašovací stránce webu a zvolí si heslo. Hesla centrální administrace nikdy nenastavuje, nečte ani neukládá a posledního aktivního administrátora webu nelze degradovat ani zakázat.
- **Nastavení webu:** platné nastavení webu pouze ke čtení, s tajnými hodnotami zobrazenými jen jako nastavené, a tlačítko, které vyprázdní cache webu. Samotné nastavení se mění na serveru.

Obě stránky vyžadují integrační klíč vydaný s odpovídajícími oprávněními; klíč bez nich vyzve k výměně.

## Co administrace nenahrazuje'), 'Obrázky podporované touto verzí jsou veřejná', 'Podporované obrázky jsou veřejná')
WHERE LOCATE('## Site users and settings', bodytext) = 0 AND LOCATE('## Uživatelé a nastavení webu', bodytext) = 0;
