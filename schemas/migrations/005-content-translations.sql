-- Translations of database content (WBengine 3.3 or newer): site titles and meta tags,
-- menu names and articles. The default language stays in the original tables; a row
-- here exists only for another language, and an empty field falls back to the default.
CREATE TABLE IF NOT EXISTS `cms_site_translations` (
  `site_id` int(10) unsigned NOT NULL,
  `locale` varchar(10) NOT NULL,
  `title` varchar(120) DEFAULT NULL,
  `html_title` varchar(120) DEFAULT NULL,
  `html_description` varchar(170) DEFAULT NULL,
  `html_keywords` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`site_id`,`locale`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;

CREATE TABLE IF NOT EXISTS `cms_menu_translations` (
  `menu_id` int(10) unsigned NOT NULL,
  `locale` varchar(10) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `description` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`menu_id`,`locale`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;

CREATE TABLE IF NOT EXISTS `cms_article_translations` (
  `article_id` int(10) unsigned NOT NULL,
  `locale` varchar(10) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `introtext` text,
  `bodytext` text,
  PRIMARY KEY (`article_id`,`locale`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_czech_ci;
