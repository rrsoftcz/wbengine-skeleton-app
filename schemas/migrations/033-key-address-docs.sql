-- Documentation of the optional address restriction of an integration key. Each UPDATE only adds the text while it is missing, so the migration is safe to rerun.
SET NAMES utf8mb4;

UPDATE cms_articles SET bodytext = REPLACE(bodytext, 'A site that does not have the integrations page yet gets it with one command', 'A key can also be bound to the addresses it may be called from. The key form has an optional field for IP addresses or ranges, and after the first use the card of the key shows the address it was used from, with a form to restrict the key to it. A call from another address is refused. Behind a reverse proxy the site must have `http.trustedProxies` set so that it sees the real address of the caller.

A site that does not have the integrations page yet gets it with one command') WHERE LOCATE('A site that does not have the integrations page yet gets it with one command', bodytext) > 0 AND LOCATE('A key can also be bound to the addresses', bodytext) = 0;

UPDATE cms_article_translations SET bodytext = REPLACE(bodytext, 'Web, který stránku integrací ještě nemá, ji získá', 'Klíč lze také vázat na adresy, ze kterých smí být volán. Formulář klíče má volitelné pole pro IP adresy nebo rozsahy a po prvním použití karta klíče ukáže adresu, ze které byl použit, s formulářem pro omezení klíče na ni. Volání z jiné adresy je odmítnuto. Za reverzní proxy musí mít web nastavené `http.trustedProxies`, aby viděl skutečnou adresu volajícího.

Web, který stránku integrací ještě nemá, ji získá') WHERE LOCATE('Web, který stránku integrací ještě nemá, ji získá', bodytext) > 0 AND LOCATE('Klíč lze také vázat na adresy, ze kterýc', bodytext) = 0;

