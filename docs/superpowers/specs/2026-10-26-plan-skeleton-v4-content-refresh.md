# Návrh: obsah a návody vzorové aplikace pro WBengine 4.0

Stav: implementováno, ověřeno v izolované kopii
Datum: 2026-10-26
Rozsah: `wbengine-skeleton-app`, vydaná řada WBengine 4.0

## Cíl

Aktualizovat vzorovou aplikaci tak, aby její úvodní stránka, články, databázové seed soubory a návody popisovaly skutečný stav WBengine 4.0. Nový výchozí obsah má používat Markdown, vysvětlit nativní šablony a instalaci bez Smarty/Texy a obsahovat srozumitelné příklady CLI se syntaxí obarvenou ve stylu úvodní stránky.

## Rozsah

- Aktualizovat README v češtině nebo angličtině podle stávajícího jazyka README: instalace, PHP a rozšíření, Composer závislosti, nasazení, CLI, cache, migrace a řešení běžných problémů.
- Upravit lokalizované texty úvodní stránky, zejména označení verze a tvrzení o šablonách a formátování článků.
- Ručně přepracovat všech devět výchozích článků a devět českých překladů v `schemas/wbengine_skeletone_app_mysql_template_content.sql`. Zachovat ID, vazby, navigaci a významové údaje. Texty budou v Markdownu, SQL hodnoty správně escapované.
- Dokumentovat nativní syntaxi šablon, escapování, kompilaci a cache. Uvést, že zdrojové `.md` soubory lze přímo vykreslit i vložit do nativní šablony pomocí `{include 'content.md'}`. Markdown se nevykonává jako PHP ani jako šablona.
- Dokumentovat Markdown v databázi jako explicitní formát záznamu, včetně zachování starších HTML záznamů ve formátu `legacy_html`.
- Přidat drobné zvýraznění syntaxe pro kódové bloky bez nové runtime nebo NPM závislosti. CLI bloky musí být obarvené; další jazyky lze pokrýt stejným mechanismem podle příkladů v návodech.
- Aktualizovat soubory základního schématu a připravit navazující migrační SQL pro `content_format` u článků i překladů, pokud ověření schématu potvrdí, že frameworková migrace není součástí běžného postupu skeletonu.
- Zapsat do migračního plánu skeletonu, co je dokončeno, jak se změna ověřila a jak postupovat při aktualizaci již nasazeného vzorového webu.

## Rozhodnutí

### Obsah

Nové výchozí texty se napíší ručně v angličtině a češtině v Markdownu. Automatický převod stávajícího HTML se nepoužije. Není možné spolehlivě určit, zda jsou existující záznamy původní demo text nebo obsah upravený provozovatelem. Upgrade existující databáze proto pouze přidá formátovací sloupec s výchozí hodnotou `legacy_html`; nebude měnit obsah ani jeho formát.

Čerstvá instalace dostane aktualizovaný seed. Již instalovaný web dostane návod na bezpečnou aktualizaci výchozího obsahu. Jakýkoliv volitelný SQL update demo článků musí mít podmínku, která ověří původní hodnotu nebo její kontrolní součet, a nesmí přepsat uživatelské úpravy. Pokud takovou podmínku nelze jednoduše a ověřitelně vytvořit, zůstane aktualizace obsahu ruční.

### Schéma

`cms_articles` i `cms_article_translations` potřebují vlastní `content_format`, protože jazykové varianty mohou mít odlišný formát. Nová databáze bude mít sloupce v hlavním schématu; upgrade existující databáze dostane verzovanou migraci v `schemas/migrations/`. Výchozí hodnota pro stávající řádky je `legacy_html`. Markdown se nastaví pouze na nové seedované nebo výslovně upravené záznamy.

Před implementací ověřit, zda frameworková migrace `migrations/4.0.0/003-markdown-content.sql` již tato pole vytváří a zda je skeleton spouští jako součást podporovaného upgrade postupu. Pokud ano, nevytvářet duplicitní nekompatibilní ALTER; skeleton migrace musí být idempotentní nebo musí jasně deklarovat předpokládaný stav jádra.

### Obarvení kódu

Použít malý JavaScript bez závislostí nad `pre code.language-*`. Tokeny sestavovat přes DOM uzly a `textContent`, nikdy nevkládat zdrojový kód jako HTML. Jazyky budou na allowlistu; minimálně `bash`/`shell` pro CLI, dále pouze jazyky reálně používané v dokumentaci. Neznámé jazyky zůstanou prostým textem. Barvy vycházejí ze tříd úvodní ukázky: fialová pro klíčová slova, modrá pro příkazy/metody, šedá pro komentáře a zelená pro řetězce. Zachovat kopírování zdrojového textu, přístupnost a fallback bez JavaScriptu.

### Nezávislost na balíčcích

Běžný běh zůstane bez Smarty, Texy a bez nové JS knihovny. Základní návod uvede Composer a skutečné požadavky vydané verze frameworku. Kompatibilitní balíčky budou označené jako volitelné nástroje migrace, nikoliv jako závislost aplikace.

## Implementační fáze

1. **Fakta a schéma:** ověřit API Markdownu, vykreslení `.md`, aktuální požadavky PHP/rozšíření a pořadí migrací jádra a skeletonu. Zapsat přesné příklady podle tagu WBengine 4.0.0.
2. **Datový model:** upravit základní SQL schéma a přidat upgrade cestu pro `content_format`; výchozí stará data zůstanou `legacy_html`. Připravit seed pro Markdown na obou localech.
3. **Obsah a návody:** přepsat devět článků a překladů, README a lokalizovaný text úvodní stránky. Každý příkaz ověřit proti skutečnému CLI a každé tvrzení porovnat s vydaným frameworkem.
4. **Zvýraznění:** doplnit lehký bezpečný lexer, CSS/Tailwind styly a načtení skriptu. Příklady v článcích označit jazykem; CLI musí mít jednotné zbarvení.
5. **Ověření a checkpoint:** provést diff a validaci SQL/Markdown, spustit build CSS/JS a existující izolované smoke scénáře. Ověřit čerstvý seed i upgrade kopie databáze, zachování původního legacy HTML, vykreslení Markdownu, stránku bez JavaScriptu a vstup s HTML-like textem proti XSS. Aktualizovat tento plán o výsledky. Před commit/push vytvořit samostatný přehled změn.

## Kritéria dokončení

- Nikde ve výchozích textech ani dokumentaci nejsou zastaralá tvrzení, že runtime vyžaduje Smarty nebo Texy.
- README popisuje reprodukovatelnou instalaci pro vydaný WBengine 4.0 a skutečné závislosti.
- Dokumentace ukazuje `.md` jako přímý zdroj i jako include a Markdown jako explicitní databázový formát.
- Devět anglických článků a jejich české varianty obsahují aktuální, jazykově odpovídající obsah.
- Čerstvé schéma a upgrade schéma fungují; existující HTML obsah zůstane nedotčený a označený jako `legacy_html`.
- Konzolové ukázky jsou barevné podle úvodní palety a vykreslení zdrojového textu nemůže vložit HTML.
- Projekt projde svými CI a izolovanými smoke kontrolami.

## Rizika a opatření

- **Nechtěné přepsání obsahu:** seed SQL se při aktualizaci existující databáze obvykle znovu nespouští; případná data migrace bude opt-in a podmíněná původním obsahem.
- **Duplicitní SQL migrace jádra a skeletonu:** před úpravou schématu ověřit oficiální pořadí a idempotenci obou cest.
- **XSS v kódu nebo Markdownu:** zvýrazňovač používá DOM textové uzly; Markdown renderer a jeho sanitizaci ověřit na vydané verzi.
- **Neaktuální ukázky CLI:** spouštět příkazy v izolované aplikaci s tagem 4.0.0, nevycházet pouze ze starých článků.
- **Tailwind odstraní dynamické třídy:** třídy barev uvést staticky ve zdrojích skenovaných Tailwindem nebo v jeho safelistu.

## Mimo rozsah

- Produkční nasazení frameworku nebo změny cizích webů.
- Automatická konverze databází uživatelů z HTML na Markdown.
- Vývoj administrace nebo nových obsahových API.
- Přidání parserové knihovny či syntax-highlighter balíčku.

## Stav práce

- [x] Rozsah a směr řešení odsouhlasen uživatelem.
- [x] Návrh prošel nezávislou technickou kontrolou bez otevřených rozhodnutí a byl schválen.
- [x] Schéma, Markdown API, include `.md`, CLI a závislosti ověřeny proti vydanému WBengine 4.0.0.
- [x] Základní schéma a migrační cesta 006 přidávají `content_format`; starý HTML obsah se nemění.
- [x] Devět anglických článků a devět českých překladů přepsáno jako Markdown. Čerstvý seed je označuje `markdown`.
- [x] README, homepage copy, SEO metadata a živá ukázka `.md` souboru aktualizovány. Vlastní Docs a lokální Blog box vykreslují databázový Markdown přes frameworkovou službu.
- [x] Konzolové bloky `bash` zvýrazňuje malý JavaScript bez závislostí a čtyři barvy vycházejí z homepage ukázky.
- [x] Ověřen čerstvý seed: 9/9 článků a 9/9 překladů má `content_format=markdown`.
- [x] Upgrade SQL 006 ověřeno na starých HTML řádcích: text zůstal nezměněn a obě tabulky dostaly `legacy_html`.
- [x] Tailwind build a `node --check` prošly; stávající HTTP smoke má 20/20 kontrol úspěšných. Anglické a české stránky i přímý `.md` include se vykreslily.
- [x] Závěrečná revize diffu dokončena; opraveno upozornění na ne-idempotentní seed.

Poznámka k nasazeným databázím: migration 006 bezpečně přidá formát, ale nepřepíše stávající demo text. Nový obsah se dostane do čerstvého seed prostředí; u již používaného webu je třeba články aktualizovat redakčně, aby se nepřepsaly úpravy provozovatele.

## Navazující opravy před zveřejněním na wbengine.org

- [x] Opravit přepnutí z češtiny do výchozí angličtiny: jazykový přepínač používá explicitní `/en/...`, které nastaví locale cookie, a framework následně přesměruje na kanonickou neprefixovanou URL.
- [x] Přidat HTTP regresní kontroly pro volbu angličtiny z české stránky, canonical redirect a anglický obsah po přesměrování.
- [x] Rozšířit zvýrazňovač CLI: obarvit příkaz v příkazové pozici i tehdy, když nebyl v předchozím pevném seznamu, a pod-příkazy běžných nástrojů jako Docker, Git, npm a Composer.
- [x] Doplnit README o nastavení produkční `i18n.baseUrl` na `https://www.wbengine.org`, HTTPS, produkční JWT klíče a odstranění demo přístupu před zveřejněním.
- [ ] Spustit HTTP regresní smoke na lokální službě po jejím opětovném spuštění. Při této revizi Docker socket nebyl dostupný a `localhost:8080` neposlouchal. PHP syntaxe testu, kompilace šablony, `node --check` a `git diff --check` prošly.
- [ ] Před ostrým zveřejněním ověřit produkční konfiguraci, schéma a migrace na hostingu; toto není provedeno a DNS ani deployment se tímto krokem nemění.

## Navazující úprava vzhledu a Markdown dokumentace

- [x] CTA box „Run it in two minutes“ používá tmavý základ a stejné indigo/fuchsiové světelné pozadí jako Hero box.
- [x] Dokumentace vysvětluje podporované blokové a řádkové prvky, GFM rozšíření, bezpečné HTML vykreslení a formát databázových záznamů.
- [x] Z veřejného README a nového seed obsahu odstraněny zmínky o Smarty. Migrace 007 aktualizuje dvě vestavěné dokumentační stránky na již nainstalovaných webech.
- [x] Ověřena kompilace šablon, syntaxe PHP smoke souboru, JavaScript syntaxe, SQL vyvážení uvozovek/závorek, přítomnost potřebných tříd v již sestaveném CSS a čistota diffu.
- [ ] Znovu spustit webový smoke test a aplikovat migraci 007 na lokální databázi, až bude dostupný Docker/DB. V této relaci Docker socket ani lokální databázový port dostupné nebyly.

Tailwind build vytvořil `public/Css/output.min.css`; lokální `caniuse-lite` vypsal upozornění na stáří databáze prohlížečů. Toto upozornění neblokovalo build. Po následném 500 na `localhost:8080` log potvrdil chybějící `content_format`. Na lokální Docker databázi skeletonu byla provedena migrace 006; devět anglických článků a devět českých překladů se aktualizovalo jen po shodě s kontrolními součty původních seed řádků. Před změnou byly pořízeny cílené dumpy dotčených řádků a po ověření odstraněny. `/cs/docs/` a `/cs/docs/templates/` nyní vracejí 200. `Settings.json` nebyl změněn. Ostatní smoke a migrační ověření běžela v odděleném Docker prostředí.
