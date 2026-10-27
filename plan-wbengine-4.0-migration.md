# Migrace vzorové aplikace na WBengine 4.0

Stav k 2026-10-27. Skeleton WBengine 4 je nasazen na `www.wbengine.org`. Uživatel potvrdil opravu obsahu, přepínání jazyků a angličtinu jako výchozí jazyk. Framework `v4.0.2` je uzamčen v Composer locku; aktuální commity skeletonu na `main`: `d2898d5` (jazykový přepínač a migrace průvodce) a `45dc494` (angličtina jako výchozí jazyk). Migrace obsahu `010` a nastavení `i18n.default=en`, `i18n.detect=[url]` byly nasazeny na live podle potvrzení uživatele. Historické poznámky níže o nenasazené databázi popisují tehdejší stav a tento kontrolní bod je nahrazuje.

Migrační projekt je dokončen. Další doporučený krok je pilot vzdálené administrace proti izolovanému testovacímu webu. Deset historických HTML položek ponechaných pro ruční posouzení se převede jen po redakčním rozhodnutí.

## Kontrolní bod Google Analytics a souhlasu s cookies

2026-10-27: Připravuje se GA4 `G-PRGMM4N3S6` a vlastní dvojjazyčná lišta souhlasu v skeleton layoutu. Základní Consent Mode začíná stavem denied; skript `gtag.js` se načte až po povolení analytiky. Odmítnutí ji nechá vypnutou, patička umožňuje volbu později znovu otevřít a odvolání souhlasu vypne měření, odstraní dostupné GA cookies a obnoví stránku. Volba se ukládá pouze do localStorage, bez serverového záznamu. Před nasazením zbývá ověřit skutečné chování na live při přijetí, odmítnutí a odvolání a doplnit úplné informace o správci a zpracování do zásad soukromí.

- [x] Oddělený worktree a Compose projekt, bez pevných jmen kontejnerů a veřejných portů.
- [x] App Application/Site zachovávají lazy strom frameworku a připravují layout až po page-cache gate.
- [x] POST logout s auth.logout CSRF, žádný GET odhlašovací odkaz, diagnostické údaje pouze při dostupnosti.
- [x] Composer cíl ^4.0 a oddělený dev smoke manifest. Ignorovaný místní composer.lock byl aktualizován na v4.0.0 a produkční composer install proběhl; vendor obsahuje WBengine v4.0.0 bez Smarty/Texy. Soubor composer.lock zůstává ignorovaný podle existující konvence projektu.
- [x] Reálná HTTP sada 20 kontrol lokálně zelená. RED nejprve chybějící cache HIT kvůli předčasnému user/session; potom chybějící POST logout. Login navíc odhalil Url null deprecation bez Apache aliasu, opraveno ve frameworku samostatnou regresí a commitem.
- [x] CI workflow používá framework tag v4.0.0 a spouští izolovanou přípravu i HTTP kontroly. Přidána také kontrola produkčního Composer manifestu/locku, aby smoke profil nemohl skrýt jejich nesoulad.
- [x] Commit/push35d2d54, draft PR#1 a jeho skutečná CI prošla.
- [x] TPL-03: čerstvé vendor bez Smarty, kontrola dependency profilu a vyčištěné cache, znovu20HTTP kontrol green. Framework checkpoint80208da/08dc79e.
- [x] MD-03/04: skutečných9článků+9překladů ověřeno naTEMPkopiích:18HTMLplánů,8safeapply/rollback,10manualreview bezaplikace. Původnířádky/hashe/schéma bezezměny; stávajícíHTML zůstává legacy_html.
- [x] Finální release gate a opakovaný smoke prošly v CI pro vydaný framework tag v4.0.0. PR migrace je sloučeno; produkční nasazení ani převod provozních dat se neprovádí.

Postup opakování je v README. Tests setup/seed se odmítnou spustit bez markeru izolovaného smoke prostředí. K odstranění použít pouze Compose projekt, který byl právě vytvořen, ne obecné zastavování cizích kontejnerů.

Rollback aplikačních změn: obnovit odpovídající public bootstrap, App služby, layout a Composer verzi, vyčistit kompilované/page/fragment/externí HTML cache. Samotné přepnutí adaptéru nestačí pro native-only set/t syntax. SQL obsahové migrace mají vlastní plán a originály; tento checkpoint je nespouští.

Kontrolní bod TPL-03: dependency-profile a reset-smoke-cache odmítají běh mimo označené izolované prostředí. CI provádí obě kontroly před HTTP sadou. Následuje MD-04 čerstvá instalace bez Texy a izolovaný obsahový pilot.


## DX-03 a MD-04 kontrolní bod 2026-10-26

Čerstvá instalace bez Smarty/Texy má pouze JWT a WBengine.20HTTPgreen, obě skutečné Composer bin proxy fungují. CI nově kontroluje i tento profil. Example apiV2.enabled=true používá časné API předCMS; obsahové endpointy vyžadují explicitní SQL002/003/005, produkční migrace se tímto neprovádí.

Skutečná CMS matice dokončena:300requestů/0chyb,15kohort,konkurence4,PHP8.4.27/MySQL8.4.13,14stránek/9článků/20boxů/2uživatelé,OPcacheCLI0. Off veřejný request6SQL/1spojení,datováwarm1SQL/1spojení,pagewarm20/20HIT a0SQL/0spojení. Privátní profile a customAPI nikdysharedHIT. Přesné naměřené latence, metodika a omezení v benchmark-cms-result.json. Reálný adminformlogin+CSRF a DBsession ověřeny, konfigurace a hlavní server bezezměn.

Další krok společný HTTPSAPI/adminpilot v samostatném prostředí a finálníreleasegate.


## Poslední ověření původu a převodu obsahu

Zdrojové SQL obsahuje skutečné HTML fragmenty a escapované HTML ukázky. Zmínka Texy v próze neznamená Texy syntaxi, formát se neodhaduje. Nový tests/content-migration-smoke.php s markerem/DB/cache guardem kopíruje skutečné články i překlady do connection-local TEMP InnoDB a používá skutečný core Migrator/HtmlConverter a SQL004 ledger. Na původní tabulky ani schéma nezapisuje.

18plánů:8bezpečných (1,1:cs,5,5:cs,6,6:cs,9,9:cs) schváleno hashem pouze vTEMP, aplikováno a přesněrollbacknuto;10ručních (2,2:cs,3,3:cs,4,4:cs,7,7:cs,8,8:cs) ponecháno bezezměn. Důvody8unsupported element a2semantic mismatch. Dryrun nemění obsah ani ledger, sourceSHA256/plnéřádky/schémata shodné před/po.

Jde o validní původníHTML mimo konzervativní převodní subset, nikoli vadnádata. Jeho zachování jako legacy_html je vědomá bezpečná migrační volba. Pokud provozovatel zvolí převod i těchto záznamů, musí jednotlivé layoutové/HTML konstrukce ručně přepracovat a znovu zkontrolovat render; nic se automaticky nebo ztrátově nepřepíše. Nové standardní texty používajíMarkdown. CI spouští stejné ověření předHTTPsmoke.

Finální technickábrána jádra i centrály prošla na dvou nezávislých HTTPS webech včetně revokace/výpadků a skutečného dump/restore. Zbývá sloučení a zveřejnění nové verze, aktuální společný stav v plan-framework-improvements.md jádra.


## Publikace

2026-10-26: Jádro bylo sloučeno do master jako cf710e5adbc25809868a864e615f8b9fc62a7489 a tag v4.0.0 ukazuje na tento commit. Následně byly aktualizovány CI reference na tag a sloučeny vzorová aplikace i administrace. GitHub release v4.0.0 byl vytvořen. Produkční nasazení nebylo provedeno.


## Lokální adopce v4.0 a Composer kontrola

2026-10-26: Čistý místní checkout ../wbengine-skeleton-app byl fast-forward aktualizován na migrační commit 19fde667530a273e95ce05a118bd438c705520b5. Větev `main` nebyla přepisována; následující oprava probíhá v `codex/skeleton-app-v4-composer-lock`.

Běžná `composer validate` odhalila, že commit aplikace změnil constraint na `^4.0`, ale nepřepočítal `composer.lock`, který stále obsahoval framework v3.5.0. CI tuto zastaralou lokální lock kopii nemohla zachytit, protože `composer.lock` je v `.gitignore`; její smoke workflow navíc používalo pouze alternativní `composer.smoke.json` s path repository. Lokální lock byl aktualizován Composerem na vydaný tag v4.0.0, bez Smarty/Texy; `composer validate --no-check-publish --strict` a skutečný produkční `composer install --no-dev` prošly. Místní vendor byl aktualizován; databáze a produkční data nebyla změněna.

Přidána regresní kontrola běžného `composer.json` a locku do CI před instalací odděleného smoke profilu. Ověřeno a dokončeno: PR #2 sloučeno jako b1c303460565cfbaa6023de3530a3a396b4c278d; CI main run 40390173093 úspěšně prošlo. Produkční nasazení ani úprava databáze nebyly provedeny.
