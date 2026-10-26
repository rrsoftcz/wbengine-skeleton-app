# Migrace vzorové aplikace na WBengine 4.0

Stav 2026-10-26. Pracovní větev codex/wbengine-4.0, výchozí čistý main d22281f. Framework se vyvíjí v samostatném repozitáři a [draft PR #2](https://github.com/rrsoftcz/wbengine/pull/2). Původní checkout ani jeho databáze nebyly změněny.

- [x] Oddělený worktree a Compose projekt, bez pevných jmen kontejnerů a veřejných portů.
- [x] App Application/Site zachovávají lazy strom frameworku a připravují layout až po page-cache gate.
- [x] POST logout s auth.logout CSRF, žádný GET odhlašovací odkaz, diagnostické údaje pouze při dostupnosti.
- [x] Composer cíl ^4.0 a oddělený dev smoke manifest, bez osobní konfigurace nebo tajemství v Gitu.
- [x] Reálná HTTP sada 20 kontrol lokálně zelená. RED nejprve chybějící cache HIT kvůli předčasnému user/session; potom chybějící POST logout. Login navíc odhalil Url null deprecation bez Apache aliasu, opraveno ve frameworku samostatnou regresí a commitem.
- [x] CI workflow spouští stejnou izolovanou přípravu a HTTP kontroly, navázaný na explicitní frameworkovou větev.
- [ ] Commit/push, draft PR a ověření skutečného CI tohoto checkpointu.
- [ ] TPL-03: zopakovat smoke po odstranění Smarty z jádra a čerstvé instalaci bez jeho balíčku.
- [ ] MD-03/04: prověřit zdrojové HTML článků a překladů, dry-run převodu, explicitní schválení bezpečných záznamů a ruční opravy ostatních; původní data automaticky nepřepisovat.
- [ ] Finální release gate, aktuální referenční framework verze a opakovaný smoke. Žádný merge, tag ani produkční nasazení zatím neproběhly.

Postup opakování je v README. Tests setup/seed se odmítnou spustit bez markeru izolovaného smoke prostředí. K odstranění použít pouze Compose projekt, který byl právě vytvořen, ne obecné zastavování cizích kontejnerů.

Rollback aplikačních změn: obnovit odpovídající public bootstrap, App služby, layout a Composer verzi, vyčistit kompilované/page/fragment/externí HTML cache. Samotné přepnutí adaptéru nestačí pro native-only set/t syntax. SQL obsahové migrace mají vlastní plán a originály; tento checkpoint je nespouští.
