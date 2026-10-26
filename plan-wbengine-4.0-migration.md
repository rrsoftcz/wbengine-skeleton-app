# Migrace vzorové aplikace na WBengine 4.0

Stav 2026-10-26. Pracovní větev codex/wbengine-4.0, výchozí čistý main d22281f. Framework se vyvíjí v samostatném repozitáři a [draft PR #2](https://github.com/rrsoftcz/wbengine/pull/2). Původní checkout ani jeho databáze nebyly změněny.

- [x] Oddělený worktree a Compose projekt, bez pevných jmen kontejnerů a veřejných portů.
- [x] App Application/Site zachovávají lazy strom frameworku a připravují layout až po page-cache gate.
- [x] POST logout s auth.logout CSRF, žádný GET odhlašovací odkaz, diagnostické údaje pouze při dostupnosti.
- [x] Composer cíl ^4.0 a oddělený dev smoke manifest, bez osobní konfigurace nebo tajemství v Gitu.
- [x] Reálná HTTP sada 20 kontrol lokálně zelená. RED nejprve chybějící cache HIT kvůli předčasnému user/session; potom chybějící POST logout. Login navíc odhalil Url null deprecation bez Apache aliasu, opraveno ve frameworku samostatnou regresí a commitem.
- [x] CI workflow spouští stejnou izolovanou přípravu a HTTP kontroly, navázaný na explicitní frameworkovou větev.
- [x] Commit/push35d2d54, draft PR#1 a jeho skutečná CI prošla.
- [x] TPL-03: čerstvé vendor bez Smarty, kontrola dependency profilu a vyčištěné cache, znovu20HTTP kontrol green. Framework checkpoint80208da/08dc79e.
- [x] MD-03/04: skutečných9článků+9překladů ověřeno naTEMPkopiích:18HTMLplánů,8safeapply/rollback,10manualreview bezaplikace. Původnířádky/hashe/schéma bezezměny; stávajícíHTML zůstává legacy_html.
- [ ] Finální release gate, aktuální referenční framework verze a opakovaný smoke. Žádný merge, tag ani produkční nasazení zatím neproběhly.

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
