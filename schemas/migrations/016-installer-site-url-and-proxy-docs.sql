-- Deployment guide: the installer takes the site address and trusts the Docker network gateway.
-- Content-only migration; the LOCATE checks make it safe to rerun. Back up before applying.
SET NAMES utf8mb4;

UPDATE cms_articles
SET bodytext = REPLACE(bodytext, './bin/setup-production.sh\n```\n\nThe installer generates private database and JWT secrets on the server,', './bin/setup-production.sh https://www.your-domain.tld\n```\n\nThe installer takes the public HTTPS address of the site as its argument, trusts the Docker network gateway as the proxy that forwards the HTTPS headers from host Nginx, generates private database and JWT secrets on the server,')
WHERE id = 2
  AND site_id = 10
  AND LOCATE('takes the public HTTPS address of the site', bodytext) = 0;

UPDATE cms_article_translations
SET bodytext = REPLACE(bodytext, './bin/setup-production.sh\n```\n\nInstalátor na serveru vytvoří soukromé databázové a JWT klíče,', './bin/setup-production.sh https://www.vase-domena.cz\n```\n\nInstalátor přijme veřejnou HTTPS adresu webu jako argument, nastaví bránu Docker sítě jako důvěryhodnou proxy pro HTTPS hlavičky předávané z Nginx na hostiteli, na serveru vytvoří soukromé databázové a JWT klíče,')
WHERE article_id = 2
  AND locale = 'cs'
  AND LOCATE('přijme veřejnou HTTPS adresu webu', bodytext) = 0;
