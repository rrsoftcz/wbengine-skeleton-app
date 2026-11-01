-- Documentation pages /docs/mcp/ (the MCP server) and /docs/mcp-clients/ (connecting a client on Linux, macOS and Windows),
-- English and Czech. Idempotent: every row is created only when it is missing, so edits made later in the Admin survive a rerun.
SET NAMES utf8mb4;

SET @mcp_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/mcp/' ORDER BY site_id LIMIT 1);
INSERT INTO cms_sites (parent_id, left_id, right_id, strict, visible, link, title, html_title, html_description, html_keywords, acl)
SELECT 1, 0, 0, 1, 1, '/docs/mcp/', 'MCP server', 'MCP server for editors', 'What the WBengine MCP server lets an AI assistant do for an editor, what it never does, which key to issue, and what to do when it does not work.', 'mcp,ai,editor,claude', 0
WHERE @mcp_site_id IS NULL;
SET @mcp_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/mcp/' ORDER BY site_id LIMIT 1);

INSERT INTO cms_site_translations (site_id, locale, title, html_title, html_description, html_keywords)
SELECT @mcp_site_id, 'cs', 'MCP server', 'MCP server pro redaktory', 'Co může MCP server WBengine dělat pro redaktora přes AI asistenta, co nedělá nikdy, jaký klíč vydat a co dělat, když nefunguje.', 'mcp,ai,redaktor,claude'
WHERE NOT EXISTS (SELECT 1 FROM cms_site_translations WHERE site_id = @mcp_site_id AND locale = 'cs');

INSERT INTO cms_articles (site_id, grouped, futured, c_enabled, views, title, introtext, bodytext, content_format, published, author, source)
SELECT @mcp_site_id, 0, 0, 0, 0, 'MCP server', 'The MCP server lets an AI assistant manage the content of one site for an editor who is not technical, within the permissions of its key.', '## What it does

The MCP server lets an AI assistant such as Claude manage the content of one WBengine site for an editor who is not technical. It works through the same API and the same kind of key as the central Admin, so it can do only what its key allows. It never opens the database and never reads the settings of the site.

An editor talks to the assistant in plain words, and the assistant does the technical steps:

- Writes an article as a draft, translates it, and shows a preview before anything is public.
- Creates what a new article needs: the page, a clean address, the browser title and description for search engines, the box that shows the article and, on request, a menu entry.
- Checks the article before it is published and says what is missing: no text, no box on the page, a missing translation, a title or description that is too long.
- Publishes, hides and shows an article, only when the editor asked for it.
- With the permission for structure: changes pages, the menu and boxes, and uploads images.
- Reads the statistics, writes a report from them and explains the change log.

## What it never does

- It never deletes anything. No tool deletes an article, a page, a box, a menu entry or an image.
- It publishes, hides or shows an article only when asked. The client asks you to confirm each such step, and the key can be limited so that publishing is not possible at all.
- It treats text from the website as data. A sentence in an article that tells the assistant to do something is not followed.
- It cannot do more than the key allows. A key without the Structure group cannot touch pages, menu or boxes, and a key restricted to certain addresses works only from them.

## Which key to issue

Issue a separate key for the assistant on the Integrations page of the site (see [Central administration](/docs/administration/)). Never reuse the key that the central Admin uses. The form offers presets:

| Preset | For | What the key may do |
|---|---|---|
| Editor with structure and statistics | an editor who is not technical | write, publish and hide articles; pages, menu, boxes and images; read statistics and the change log. No users, no settings. |
| Agent for content | an assistant that only handles articles | write, publish and hide articles and pages; images; read the change log. No structure. |
| Agent, drafts only | an assistant that may only prepare | write drafts and images. It cannot publish or hide anything. |
| Read only | monitoring | read content, structure and images and the change log. |
| Full management | the central Admin | everything the Admin needs. Not for an assistant. |

The key is shown once, together with the configuration to copy into the client. Restrict it to the addresses it is used from if you can, and revoke it when it is no longer used. The statistics tools need the Analytics choice on the key and analytics switched on for the site.

## A typical request

"Write a short article about our spring opening hours in English and Czech, show it to me and publish it when I say so."

The assistant proposes an address and the search fields, saves the draft with both languages, shows the preview, checks that the page is complete and waits. When you answer "publish", it publishes and gives you the address of the published page.

## The tools in plain words

| Area | What the assistant can do |
|---|---|
| Articles | list and read articles, save a draft with translations, preview it, publish, hide and show |
| New article page | propose an address, browser title and description, check that the article is ready to publish |
| Pages and menu | change the title, address and search fields of a page, list and change menu entries |
| Boxes | list the box types and boxes, add a box, change it, take it off a page and put it back |
| Images | upload a PNG, JPEG or WebP image (up to 512 KiB) and list the uploaded images |
| Statistics | page views, article views and box appearances for a period, a ready report with the change against the period before, and the split by language when the site records it |
| History | list the changes and analyze the change log: who changed what, what was changed again and again, what the site refused |
| Help | short texts about how the site works (addresses and search fields, boxes, menu, languages, images, statistics, troubleshooting) |

The assistant also has ready-made tasks: publish a new article, translate an article, a weekly report, find problems and a review of the search fields. The help texts are available to any client that reads resources.

## Statistics and the change log

The numbers come from the site and are never made up. The report says what they do not contain: there are no unique visitors, only the top ten of each list is returned, and a period that starts before counting began is marked, because earlier days show zero only because nothing was counted. See [Logging and audit](/docs/logging/) for the change log.

## Updating

A new version is a new file `wbengine-mcp.phar` from the WBengine release page. Replace the old file with it (copy it next to the old one under a temporary name and rename it, so the client never sees a half written file), then reconnect the client. See [Connect an MCP client](/docs/mcp-clients/).

## When something does not work

| What you see | Usually |
|---|---|
| the server does not start | the address or the key is missing in the configuration, or the path of the file is wrong; the message says which |
| "unauthorized" | the key is wrong, was revoked, or the address belongs to another site |
| "ip_not_allowed" | the key is restricted to other addresses than the one the assistant runs from |
| "forbidden" or a missing tool | the key lacks the permission group for it; issue a key with a preset that has it |
| statistics are refused | the key has no Analytics choice, or analytics is not switched on for the site |
| the published page is empty | the page has no box that shows articles; the check names it before publishing |', 'markdown', UNIX_TIMESTAMP(), 'RRSOFT', 'https://www.wbengine.org/'
WHERE NOT EXISTS (SELECT 1 FROM cms_articles WHERE site_id = @mcp_site_id);
SET @mcp_article_id = (SELECT id FROM cms_articles WHERE site_id = @mcp_site_id ORDER BY id LIMIT 1);

INSERT INTO cms_article_translations (article_id, locale, title, introtext, bodytext, content_format)
SELECT @mcp_article_id, 'cs', 'MCP server', 'MCP server umožňuje AI asistentovi spravovat obsah jednoho webu pro redaktora, který není technik, v rámci oprávnění jeho klíče.', '## Co umí

MCP server umožňuje AI asistentovi, například Claude, spravovat obsah jednoho webu na WBengine pro redaktora, který není technik. Pracuje přes stejné API a stejný druh klíče jako centrální administrace, takže smí jen to, co jeho klíč dovoluje. Nikdy neotvírá databázi a nečte nastavení webu.

Redaktor mluví s asistentem normálními slovy a technické kroky udělá asistent:

- Napíše článek jako koncept, přeloží ho a před zveřejněním ukáže náhled.
- Vytvoří, co nový článek potřebuje: stránku, čistou adresu, titulek prohlížeče a popis pro vyhledávače, box, který článek zobrazuje, a na požádání položku menu.
- Před zveřejněním článek zkontroluje a řekne, co chybí: text, box na stránce, překlad, příliš dlouhý titulek nebo popis.
- Zveřejní, skryje a znovu zobrazí článek, jen když o to redaktor požádá.
- S oprávněním pro strukturu: mění stránky, menu a boxy a nahrává obrázky.
- Čte statistiky, píše z nich report a vysvětluje záznam změn.

## Co nikdy nedělá

- Nikdy nic nemaže. Žádný nástroj nesmaže článek, stránku, box, položku menu ani obrázek.
- Článek zveřejní, skryje nebo zobrazí jen na požádání. Klient vás při každém takovém kroku žádá o potvrzení a klíč lze omezit tak, aby zveřejňování nebylo možné vůbec.
- Text z webu považuje za data. Věta v článku, která asistentovi něco přikazuje, se neplní.
- Nesmí víc, než klíč dovoluje. Klíč bez skupiny Struktura se nedotkne stránek, menu ani boxů a klíč omezený na určité adresy funguje jen z nich.

## Jaký klíč vydat

Pro asistenta vydejte samostatný klíč na stránce Integrace webu (viz [Centrální administrace](/cs/docs/administration/)). Nikdy nepoužívejte klíč, který používá centrální administrace. Formulář nabízí předvolby:

| Předvolba | Pro koho | Co smí klíč |
|---|---|---|
| Redaktor se strukturou a statistikami | redaktor, který není technik | psát, zveřejňovat a skrývat články, stránky, menu, boxy a obrázky, číst statistiky a záznam změn. Bez uživatelů a bez nastavení. |
| Agent pro obsah | asistent, který se stará jen o články | psát, zveřejňovat a skrývat články a stránky, obrázky, číst záznam změn. Bez struktury. |
| Agent, jen koncepty | asistent, který smí jen připravovat | psát koncepty a obrázky. Nic nezveřejní ani neskryje. |
| Jen čtení | dohled | číst obsah, strukturu, obrázky a záznam změn. |
| Plná správa | centrální administrace | vše, co administrace potřebuje. Ne pro asistenta. |

Klíč se zobrazí jednou spolu s konfigurací ke zkopírování do klienta. Pokud to jde, omezte ho na adresy, ze kterých se používá, a odvolejte ho, jakmile ho už nepotřebujete. Nástroje pro statistiky potřebují u klíče volbu Analytika a zapnutou analytiku webu.

## Typická žádost

"Napiš krátký článek o našich jarních otevíracích hodinách anglicky a česky, ukaž mi ho a zveřejni, až řeknu."

Asistent navrhne adresu a pole pro vyhledávače, uloží koncept v obou jazycích, ukáže náhled, zkontroluje, že je stránka úplná, a čeká. Až odpovíte "zveřejni", zveřejní ho a dá vám adresu zveřejněné stránky.

## Nástroje jednoduše

| Oblast | Co asistent umí |
|---|---|
| Články | vypsat a přečíst články, uložit koncept s překlady, ukázat náhled, zveřejnit, skrýt a zobrazit |
| Stránka nového článku | navrhnout adresu, titulek prohlížeče a popis, zkontrolovat, že je článek připravený ke zveřejnění |
| Stránky a menu | změnit název, adresu a pole pro vyhledávače, vypsat a změnit položky menu |
| Boxy | vypsat typy boxů a boxy, přidat box, změnit ho, sundat ze stránky a vrátit |
| Obrázky | nahrát obrázek PNG, JPEG nebo WebP (do 512 KiB) a vypsat nahrané obrázky |
| Statistiky | zobrazení stránek, článků a boxů za období, hotový report se změnou proti předchozímu období a rozpis po jazycích, když ho web zaznamenává |
| Historie | vypsat změny a rozebrat záznam změn: kdo co změnil, co se měnilo opakovaně, co web odmítl |
| Nápověda | krátké texty o tom, jak web funguje (adresy a pole pro vyhledávače, boxy, menu, jazyky, obrázky, statistiky, řešení potíží) |

Asistent má také hotové úlohy: zveřejnit nový článek, přeložit článek, týdenní report, najít problémy a zkontrolovat pole pro vyhledávače. Texty nápovědy jsou dostupné každému klientovi, který čte zdroje.

## Statistiky a záznam změn

Čísla pocházejí z webu a nikdy se nevymýšlejí. Report říká, co v nich není: nejsou tu jedineční návštěvníci, vrací se jen deset nejlepších položek každého seznamu a období, které začíná před počátkem počítání, je označené, protože dřívější dny ukazují nulu jen proto, že se nepočítalo. Záznam změn viz [Logování a audit](/cs/docs/logging/).

## Aktualizace

Nová verze je nový soubor `wbengine-mcp.phar` ze stránky vydání WBengine. Nahraďte jím starý soubor (zkopírujte ho vedle starého pod dočasným názvem a přejmenujte, aby klient nikdy neviděl napůl zapsaný soubor) a klienta znovu připojte. Viz [Připojení MCP klienta](/cs/docs/mcp-clients/).

## Když něco nefunguje

| Co vidíte | Obvykle |
|---|---|
| server se nespustí | v konfiguraci chybí adresa nebo klíč, nebo je špatná cesta k souboru; zpráva řekne, co |
| "unauthorized" | klíč je špatný, byl odvolán, nebo adresa patří jinému webu |
| "ip_not_allowed" | klíč je omezený na jiné adresy, než ze které asistent běží |
| "forbidden" nebo chybějící nástroj | klíč nemá skupinu oprávnění, kterou nástroj potřebuje; vydejte klíč s předvolbou, která ji má |
| statistiky jsou odmítnuty | klíč nemá volbu Analytika, nebo web nemá analytiku zapnutou |
| zveřejněná stránka je prázdná | stránka nemá box, který zobrazuje články; kontrola to před zveřejněním pojmenuje |', 'markdown'
WHERE @mcp_article_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cms_article_translations WHERE article_id = @mcp_article_id AND locale = 'cs');

INSERT INTO cms_boxes (name, module, method, section_id, static, shared, device_min, device_strict, acl, `order`, sites)
SELECT 'Docs: MCP server', 'docs', 'page', 1, 1, 0, 1, 0, 0, 0, JSON_ARRAY(CAST(@mcp_site_id AS CHAR))
WHERE NOT EXISTS (SELECT 1 FROM cms_boxes WHERE name = 'Docs: MCP server');

SET @mcp_clients_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/mcp-clients/' ORDER BY site_id LIMIT 1);
INSERT INTO cms_sites (parent_id, left_id, right_id, strict, visible, link, title, html_title, html_description, html_keywords, acl)
SELECT 1, 0, 0, 1, 1, '/docs/mcp-clients/', 'Connect an MCP client', 'Connect an MCP client', 'Connect an AI client to the WBengine MCP server on Linux, macOS and Windows with WSL2: requirements, checking the download, configuration and troubleshooting.', 'mcp,claude,windows,wsl2,macos,linux', 0
WHERE @mcp_clients_site_id IS NULL;
SET @mcp_clients_site_id = (SELECT site_id FROM cms_sites WHERE link = '/docs/mcp-clients/' ORDER BY site_id LIMIT 1);

INSERT INTO cms_site_translations (site_id, locale, title, html_title, html_description, html_keywords)
SELECT @mcp_clients_site_id, 'cs', 'Připojení MCP klienta', 'Připojení MCP klienta', 'Připojení AI klienta k MCP serveru WBengine na Linuxu, macOS a Windows s WSL2: požadavky, kontrola souboru, konfigurace a řešení potíží.', 'mcp,claude,windows,wsl2,macos,linux'
WHERE NOT EXISTS (SELECT 1 FROM cms_site_translations WHERE site_id = @mcp_clients_site_id AND locale = 'cs');

INSERT INTO cms_articles (site_id, grouped, futured, c_enabled, views, title, introtext, bodytext, content_format, published, author, source)
SELECT @mcp_clients_site_id, 0, 0, 0, 0, 'Connect an MCP client', 'How to run the MCP server on Linux, macOS and Windows and connect an AI client to it.', '## What you need

- A computer that runs the AI client, with PHP 8.3 or newer and the `phar` extension. Check with `php -v` and `php -m`. Composer is not needed.
- The file `wbengine-mcp.phar` and its checksum file `wbengine-mcp.phar.sha256` from the [WBengine releases](https://github.com/rrsoftcz/wbengine/releases/latest).
- A key for the assistant from the Integrations page of the site, with the preset that fits (see [MCP server](/docs/mcp/)). The page shows the configuration once, with the key already in it.

The server needs three settings, which the client passes as environment variables: `WBENGINE_MCP_URL` (the address of the site, with https), `WBENGINE_MCP_KEY` (the key) and `WBENGINE_MCP_MODE` (`full`, or `draft` to hide the publish tools on this computer).

## Download and check the file

Save the two files in one folder that you will not delete, for example `~/wbengine/` on Linux and macOS or `C:\\Users\\you\\wbengine\\` on Windows. Check the file against its checksum:

- Linux: `sha256sum -c wbengine-mcp.phar.sha256`
- macOS: `shasum -a 256 -c wbengine-mcp.phar.sha256`
- Windows (PowerShell): `Get-FileHash wbengine-mcp.phar -Algorithm SHA256`, and compare the value with the content of `wbengine-mcp.phar.sha256`

Do not use a file whose checksum differs.

## Add the server to the client

Claude Code. The Integrations page shows this command with your key. Replace the path with the full path of the file:

```sh
claude mcp add --env ''WBENGINE_MCP_URL=https://www.example.org'' --env ''WBENGINE_MCP_KEY=wbv2_...'' --env ''WBENGINE_MCP_MODE=full'' --transport stdio wbengine-www -- php /path/to/wbengine-mcp.phar
```

Claude Desktop and other clients that read an `mcpServers` section of a configuration file:

```json
{
  "mcpServers": {
    "wbengine-www": {
      "command": "php",
      "args": ["/path/to/wbengine-mcp.phar"],
      "env": {
        "WBENGINE_MCP_URL": "https://www.example.org",
        "WBENGINE_MCP_KEY": "wbv2_...",
        "WBENGINE_MCP_MODE": "full"
      }
    }
  }
}
```

If the client cannot find `php` (a program started from a menu or the dock often does not see the PATH of your shell), put the full path of the PHP program in `command`, for example `/opt/homebrew/bin/php` or `C:\\\\php\\\\php.exe`.

## Linux

Use the commands above with a path such as `/home/you/wbengine/wbengine-mcp.phar`. Install PHP with your package manager if `php -v` shows an older version than 8.3.

## macOS

Use a path such as `/Users/you/wbengine/wbengine-mcp.phar`. PHP is available from Homebrew (`brew install php`). Claude Desktop reads its configuration from `~/Library/Application Support/Claude/claude_desktop_config.json`; that location comes from the documentation of the client and was not tested here.

## Windows

The recommended way is WSL2. Install a Linux distribution in WSL2, run the AI client and the server inside it, and follow the Linux steps there. The server and the client then run in the same Linux environment, as on any Linux computer.

If you run the client natively on Windows, install PHP for Windows (the `phar` extension must be enabled in `php.ini`), and use a path with the drive letter. In a JSON file every backslash is written twice:

```json
"args": ["C:\\\\Users\\\\you\\\\wbengine\\\\wbengine-mcp.phar"]
```

In PowerShell the `claude mcp add` command works with the single quotes as shown. In `cmd.exe` use double quotes instead. Claude Desktop reads `%APPDATA%\\Claude\\claude_desktop_config.json`; that location comes from the documentation of the client and was not tested here.

## Check that it works

Restart the client or reconnect the server (in Claude Code, `/mcp reconnect` followed by the name of the server). Ask the assistant to call `site_info`. It lists the languages of the site and what the key may do. If a publish tool is missing, the key or the mode does not allow it.

## What was checked

On Linux, macOS and Windows the server was started the way a client starts it, answered its first requests, stayed running while the client was quiet for more than a minute, and stopped cleanly when the client closed it. A full session of Claude Code was run on macOS. Sessions of other clients, and of Claude Code on Linux and Windows, were not run.

## When it does not start

| Message or sign | Remedy |
|---|---|
| the client says the server failed or disconnected at once | run the same command in a terminal: `php /path/to/wbengine-mcp.phar`. A message names a missing setting, or the file is not found. |
| `php` is not found | use the full path of PHP in `command` |
| the path still reads `/path/to/wbengine-mcp.phar` | replace it with the real path of the file |
| a key that worked stops working | it was revoked, or the site restricts the key to other addresses |
| the server needs a newer PHP | install PHP 8.3 or newer and the `phar` extension |

To update the server, replace the file as described on the [MCP server](/docs/mcp/) page and reconnect the client.', 'markdown', UNIX_TIMESTAMP(), 'RRSOFT', 'https://www.wbengine.org/'
WHERE NOT EXISTS (SELECT 1 FROM cms_articles WHERE site_id = @mcp_clients_site_id);
SET @mcp_clients_article_id = (SELECT id FROM cms_articles WHERE site_id = @mcp_clients_site_id ORDER BY id LIMIT 1);

INSERT INTO cms_article_translations (article_id, locale, title, introtext, bodytext, content_format)
SELECT @mcp_clients_article_id, 'cs', 'Připojení MCP klienta', 'Jak spustit MCP server na Linuxu, macOS a Windows a připojit k němu AI klienta.', '## Co potřebujete

- Počítač, na kterém běží AI klient, s PHP 8.3 nebo novějším a rozšířením `phar`. Ověříte příkazy `php -v` a `php -m`. Composer není potřeba.
- Soubor `wbengine-mcp.phar` a jeho soubor s kontrolním součtem `wbengine-mcp.phar.sha256` z [vydání WBengine](https://github.com/rrsoftcz/wbengine/releases/latest).
- Klíč pro asistenta ze stránky Integrace webu s vhodnou předvolbou (viz [MCP server](/cs/docs/mcp/)). Stránka ukáže konfiguraci jednou a klíč už je v ní.

Server potřebuje tři nastavení, která klient předává jako proměnné prostředí: `WBENGINE_MCP_URL` (adresa webu s https), `WBENGINE_MCP_KEY` (klíč) a `WBENGINE_MCP_MODE` (`full`, nebo `draft`, který na tomto počítači skryje nástroje pro zveřejňování).

## Stažení a kontrola souboru

Uložte oba soubory do jedné složky, kterou nesmažete, například `~/wbengine/` na Linuxu a macOS nebo `C:\\Users\\vy\\wbengine\\` ve Windows. Soubor zkontrolujte proti kontrolnímu součtu:

- Linux: `sha256sum -c wbengine-mcp.phar.sha256`
- macOS: `shasum -a 256 -c wbengine-mcp.phar.sha256`
- Windows (PowerShell): `Get-FileHash wbengine-mcp.phar -Algorithm SHA256` a hodnotu porovnejte s obsahem souboru `wbengine-mcp.phar.sha256`

Soubor, jehož součet se liší, nepoužívejte.

## Přidání serveru do klienta

Claude Code. Stránka Integrace ukáže tento příkaz s vaším klíčem. Cestu nahraďte úplnou cestou k souboru:

```sh
claude mcp add --env ''WBENGINE_MCP_URL=https://www.example.org'' --env ''WBENGINE_MCP_KEY=wbv2_...'' --env ''WBENGINE_MCP_MODE=full'' --transport stdio wbengine-www -- php /path/to/wbengine-mcp.phar
```

Claude Desktop a další klienti, které čtou sekci `mcpServers` konfiguračního souboru:

```json
{
  "mcpServers": {
    "wbengine-www": {
      "command": "php",
      "args": ["/path/to/wbengine-mcp.phar"],
      "env": {
        "WBENGINE_MCP_URL": "https://www.example.org",
        "WBENGINE_MCP_KEY": "wbv2_...",
        "WBENGINE_MCP_MODE": "full"
      }
    }
  }
}
```

Pokud klient nenajde `php` (program spuštěný z nabídky nebo z docku často nevidí PATH vašeho shellu), uveďte do `command` úplnou cestu k programu PHP, například `/opt/homebrew/bin/php` nebo `C:\\\\php\\\\php.exe`.

## Linux

Použijte příkazy výše s cestou jako `/home/vy/wbengine/wbengine-mcp.phar`. Pokud `php -v` ukazuje starší verzi než 8.3, nainstalujte PHP správcem balíčků.

## macOS

Použijte cestu jako `/Users/vy/wbengine/wbengine-mcp.phar`. PHP je k dispozici z Homebrew (`brew install php`). Claude Desktop čte konfiguraci z `~/Library/Application Support/Claude/claude_desktop_config.json`; to umístění je z dokumentace klienta a nezkoušeli jsme ho.

## Windows

Doporučený postup je WSL2. Nainstalujte do WSL2 distribuci Linuxu, spusťte AI klienta i server uvnitř ní a postupujte podle kroků pro Linux. Server i klient pak běží ve stejném linuxovém prostředí jako na každém počítači s Linuxem.

Pokud klienta spouštíte přímo ve Windows, nainstalujte PHP pro Windows (v `php.ini` musí být zapnuté rozšíření `phar`) a použijte cestu s písmenem disku. V souboru JSON se každé zpětné lomítko píše dvakrát:

```json
"args": ["C:\\\\Users\\\\vy\\\\wbengine\\\\wbengine-mcp.phar"]
```

V PowerShellu příkaz `claude mcp add` funguje s jednoduchými uvozovkami, jak je uvedeno. V `cmd.exe` použijte místo nich dvojité. Claude Desktop čte `%APPDATA%\\Claude\\claude_desktop_config.json`; to umístění je z dokumentace klienta a nezkoušeli jsme ho.

## Ověření, že to funguje

Restartujte klienta nebo server znovu připojte (v Claude Code `/mcp reconnect` a název serveru). Požádejte asistenta, ať zavolá `site_info`. Vypíše jazyky webu a co smí klíč. Pokud chybí nástroj pro zveřejňování, klíč nebo režim ho nedovoluje.

## Co bylo ověřeno

Na Linuxu, macOS a ve Windows byl server spuštěn tak, jak ho spouští klient, odpověděl na první požadavky, zůstal běžet, když byl klient přes minutu zticha, a čistě skončil, když ho klient zavřel. Plná relace Claude Code proběhla na macOS. Relace jiných klientů a Claude Code na Linuxu a ve Windows neproběhly.

## Když se nespustí

| Zpráva nebo příznak | Náprava |
|---|---|
| klient hlásí, že server selhal nebo se hned odpojil | spusťte stejný příkaz v terminálu: `php /path/to/wbengine-mcp.phar`. Zpráva pojmenuje chybějící nastavení, nebo soubor nebyl nalezen. |
| `php` se nenajde | uveďte do `command` úplnou cestu k PHP |
| cesta stále zní `/path/to/wbengine-mcp.phar` | nahraďte ji skutečnou cestou k souboru |
| klíč, který fungoval, přestal | byl odvolán, nebo ho web omezuje na jiné adresy |
| server potřebuje novější PHP | nainstalujte PHP 8.3 nebo novější s rozšířením `phar` |

Server aktualizujete výměnou souboru podle stránky [MCP server](/cs/docs/mcp/) a opětovným připojením klienta.', 'markdown'
WHERE @mcp_clients_article_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cms_article_translations WHERE article_id = @mcp_clients_article_id AND locale = 'cs');

INSERT INTO cms_boxes (name, module, method, section_id, static, shared, device_min, device_strict, acl, `order`, sites)
SELECT 'Docs: MCP clients', 'docs', 'page', 1, 1, 0, 1, 0, 0, 0, JSON_ARRAY(CAST(@mcp_clients_site_id AS CHAR))
WHERE NOT EXISTS (SELECT 1 FROM cms_boxes WHERE name = 'Docs: MCP clients');
