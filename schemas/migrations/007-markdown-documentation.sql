-- Expand the public Markdown guide on already installed skeleton sites.
-- Apply once after 006-markdown-content-format.sql, or after WBengine 4.0's
-- equivalent framework migration. The marker check makes the content append safe
-- to repeat. Only built-in documentation articles (ids 2 and 5) are changed.
UPDATE `cms_articles`
SET `bodytext` = REPLACE(
      `bodytext`,
      'Smarty and Texy are not runtime dependencies.',
      'The native template engine and Markdown parser are included in WBengine.'
    )
WHERE `id` = 2;

UPDATE `cms_article_translations`
SET `bodytext` = REPLACE(
      `bodytext`,
      'Smarty ani Texy nejsou běhové závislosti.',
      'Nativní template engine i parser Markdownu jsou součástí WBengine.'
    )
WHERE `article_id` = 2 AND `locale` = 'cs';

UPDATE `cms_articles`
SET `bodytext` = REPLACE(
      REPLACE(
        REPLACE(`bodytext`, 'Smarty compatibility, if needed during migration, is a separate optional package.', ''),
        'It has no Smarty runtime dependency. ', ''
      ),
      'Smarty and Texy are not runtime dependencies. ', 'The template engine and Markdown parser are included in WBengine. '
    ),
    `bodytext` = IF(
      `bodytext` LIKE '%## Supported Markdown syntax%',
      `bodytext`,
      CONCAT(`bodytext`, '\n\n## Supported Markdown syntax\n\nThe bundled parser supports CommonMark 0.31.2 and GitHub Flavored Markdown tables, strikethrough, and task lists. Common block forms include headings, paragraphs, thematic breaks, blockquotes, ordered and unordered lists, indented code, and fenced code blocks. Tables use the pipe and delimiter-row syntax.\n\nInline forms include emphasis, strong emphasis, inline code, links, images, escaped punctuation, automatic links and email addresses, and hard line breaks. GFM adds `~~strikethrough~~` and task list markers such as `- [x] done`. A language after a fenced code marker is retained as a `language-*` class.\n\n````markdown\n## Heading\n\nA paragraph with **strong**, *emphasis*, `code`, and [a link](https://example.com).\n\n- first item\n- second item\n\n| Name | Value |\n| --- | --- |\n| site | WBengine |\n\n- [x] reviewed\n\n```php\necho "Hello";\n```\n````\n\n## How rendering works\n\nThe parser turns source into a document tree. The HTML renderer then emits a limited set of elements and escapes text and attributes. Raw HTML in Markdown is displayed as text, and links are limited to safe URL schemes such as relative URLs, HTTP, HTTPS, and mailto. Markdown never executes PHP or template directives. The output of the built-in renderer is safe to print with `|raw`; do not use `|raw` for arbitrary input.\n\nFor a `.md` file, the native renderer selects Markdown by the file extension, whether the file is rendered directly or included from a `.tpl` file. For database articles, `content_format` is stored separately on each article and translation row. When it is `markdown`, the Article box parses the article text fields before the template prints the generated HTML. Rows marked `legacy_html` keep the existing HTML behavior. Review and convert legacy HTML before changing its format.')
    )
WHERE `id` = 5 AND `title` = 'Templates and Markdown' AND `content_format` = 'markdown';

UPDATE `cms_article_translations`
SET `bodytext` = REPLACE(
      REPLACE(
        REPLACE(`bodytext`, 'Případný Smarty compatibility balíček slouží jen jako oddělený migrační nástroj.', ''),
        'Smarty není běhovou závislostí. ', ''
      ),
      'Smarty ani Texy nejsou běhové závislosti. ', 'Template engine i parser Markdownu jsou součástí WBengine. '
    ),
    `bodytext` = IF(
      `bodytext` LIKE '%## Podporovaná syntaxe Markdownu%',
      `bodytext`,
      CONCAT(`bodytext`, '\n\n## Podporovaná syntaxe Markdownu\n\nVestavěný parser podporuje CommonMark 0.31.2 a z GitHub Flavored Markdown tabulky, přeškrtnutí a úkolové seznamy. Mezi blokové prvky patří nadpisy, odstavce, vodorovné oddělovače, citace, číslované i nečíslované seznamy, odsazené bloky kódu a bloky kódu ohraničené zpětnými apostrofy nebo vlnovkami. Tabulky používají svislé čáry a oddělovací řádek.\n\nV textu lze použít kurzívu, tučné písmo, řádkový kód, odkazy, obrázky, escapování interpunkce, automatické odkazy a e-mailové adresy i pevné zalomení řádku. Rozšíření GFM přidává `~~přeškrtnutí~~` a značky úkolů jako `- [x] hotovo`. Jazyk uvedený za úvodní značkou bloku kódu se zachová jako třída `language-*`.\n\n````markdown\n## Nadpis\n\nOdstavec s **tučným písmem**, *kurzívou*, `kódem` a [odkazem](https://example.com).\n\n- první položka\n- druhá položka\n\n| Název | Hodnota |\n| --- | --- |\n| web | WBengine |\n\n- [x] zkontrolováno\n\n```php\necho "Ahoj";\n```\n````\n\n## Jak probíhá vykreslení\n\nParser převede zdroj na strom dokumentu. HTML renderer z něj vytvoří omezenou sadu prvků a escapuje text i atributy. Syrové HTML v Markdownu se zobrazí jako text a odkazy povolují jen bezpečná schémata, například relativní adresy, HTTP, HTTPS a mailto. Markdown nespouští PHP ani direktivy šablon. Výstup vestavěného rendereru lze bezpečně vypsat pomocí `|raw`; tento filtr nepoužívejte pro libovolný vstup.\n\nU souboru `.md` nativní renderer zvolí Markdown podle přípony, ať se soubor vykreslí přímo, nebo vloží do `.tpl`. U databázových článků je `content_format` uložen samostatně u článku i jeho překladu. Pokud má hodnotu `markdown`, box Article nejprve zpracuje textová pole a šablona vypíše vytvořené HTML. Řádky označené `legacy_html` zachovávají dosavadní chování. Staré HTML nejprve zkontrolujte a převeďte, než jeho formát změníte.')
    )
WHERE `article_id` = 5 AND `locale` = 'cs' AND `content_format` = 'markdown';
