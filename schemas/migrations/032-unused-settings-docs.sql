-- The settings the framework no longer reads are removed from the Settings reference. Each UPDATE only removes text that is still present, so the migration is safe to rerun.
SET NAMES utf8mb4;

UPDATE cms_articles SET bodytext = REPLACE(bodytext, '| `codePage` | string, `utf8` | Charset sent in the HTML header. Keep `utf8`. |
', '') WHERE LOCATE('| `codePage` | string, `utf8` | Charset sent in the HTML header. Keep `utf8`. |
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '| `minimizeHtml` | bool, `false` | Deprecated and ignored by the dispatcher. Kept in the default file for old templates. |
', '') WHERE LOCATE('| `minimizeHtml` | bool, `false` | Deprecated and ignored by the dispatcher. Kept in the default file for old templates. |
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '| `minimizeCss` | bool, `false` | Combines and minimizes the files listed in `cssFiles`. |
', '') WHERE LOCATE('| `minimizeCss` | bool, `false` | Combines and minimizes the files listed in `cssFiles`. |
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '| `minimizeJs` | bool, `false` | Same for scripts. Not in older files: add it explicitly, the framework reads the key directly. |
', '') WHERE LOCATE('| `minimizeJs` | bool, `false` | Same for scripts. Not in older files: add it explicitly, the framework reads the key directly. |
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '| `cssFiles` | array, `[]` | CSS files combined when `minimizeCss` is on. |
', '') WHERE LOCATE('| `cssFiles` | array, `[]` | CSS files combined when `minimizeCss` is on. |
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '| `cdnPath` | string, empty | Prefix for static asset URLs, for example `https://cdn.example.com`. |
', '') WHERE LOCATE('| `cdnPath` | string, empty | Prefix for static asset URLs, for example `https://cdn.example.com`. |
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '| `ipAdmins` | array, `[]` | List of administrator IP addresses. |
', '') WHERE LOCATE('| `ipAdmins` | array, `[]` | List of administrator IP addresses. |
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '  "codePage": "utf8",
', '') WHERE LOCATE('  "codePage": "utf8",
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '  "minimizeHtml": false,
', '') WHERE LOCATE('  "minimizeHtml": false,
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '  "minimizeCss": false,
', '') WHERE LOCATE('  "minimizeCss": false,
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '  "minimizeJs": false,
', '') WHERE LOCATE('  "minimizeJs": false,
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '  "cdnPath": "",
', '') WHERE LOCATE('  "cdnPath": "",
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '  "cssFiles": [],
', '') WHERE LOCATE('  "cssFiles": [],
', bodytext) > 0;
UPDATE cms_articles SET bodytext = REPLACE(bodytext, '  "ipAdmins": [],
', '') WHERE LOCATE('  "ipAdmins": [],
', bodytext) > 0;

UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '| `codePage` | řetězec, `utf8` | Znaková sada v hlavičce HTML. Ponechte `utf8`. |
', '') WHERE LOCATE('| `codePage` | řetězec, `utf8` | Znaková sada v hlavičce HTML. Ponechte `utf8`. |
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '| `minimizeHtml` | bool, `false` | Zastaralé, dispečer ho ignoruje. Zůstává ve výchozím souboru kvůli starým šablonám. |
', '') WHERE LOCATE('| `minimizeHtml` | bool, `false` | Zastaralé, dispečer ho ignoruje. Zůstává ve výchozím souboru kvůli starým šablonám. |
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '| `minimizeCss` | bool, `false` | Spojí a zmenší soubory z `cssFiles`. |
', '') WHERE LOCATE('| `minimizeCss` | bool, `false` | Spojí a zmenší soubory z `cssFiles`. |
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '| `minimizeJs` | bool, `false` | Totéž pro skripty. Ve starších souborech chybí: přidejte ho výslovně, framework klíč čte přímo. |
', '') WHERE LOCATE('| `minimizeJs` | bool, `false` | Totéž pro skripty. Ve starších souborech chybí: přidejte ho výslovně, framework klíč čte přímo. |
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '| `cssFiles` | pole, `[]` | Soubory CSS spojované při zapnutém `minimizeCss`. |
', '') WHERE LOCATE('| `cssFiles` | pole, `[]` | Soubory CSS spojované při zapnutém `minimizeCss`. |
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '| `cdnPath` | řetězec, prázdný | Předpona URL statických souborů, například `https://cdn.example.com`. |
', '') WHERE LOCATE('| `cdnPath` | řetězec, prázdný | Předpona URL statických souborů, například `https://cdn.example.com`. |
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '| `ipAdmins` | pole, `[]` | Seznam IP adres správců. |
', '') WHERE LOCATE('| `ipAdmins` | pole, `[]` | Seznam IP adres správců. |
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '  "codePage": "utf8",
', '') WHERE LOCATE('  "codePage": "utf8",
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '  "minimizeHtml": false,
', '') WHERE LOCATE('  "minimizeHtml": false,
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '  "minimizeCss": false,
', '') WHERE LOCATE('  "minimizeCss": false,
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '  "minimizeJs": false,
', '') WHERE LOCATE('  "minimizeJs": false,
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '  "cdnPath": "",
', '') WHERE LOCATE('  "cdnPath": "",
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '  "cssFiles": [],
', '') WHERE LOCATE('  "cssFiles": [],
', bodytext) > 0;
UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, '  "ipAdmins": [],
', '') WHERE LOCATE('  "ipAdmins": [],
', bodytext) > 0;

