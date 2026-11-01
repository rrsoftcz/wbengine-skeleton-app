-- Adds the page /changelog/ (the changelog of the installed framework) with a menu entry, English and Czech.
-- The box reads CHANGELOG.md from the framework package, so the page needs WBengine 6.7 or newer, whose changelog
-- has one dated section per release. Safe to run more than once: each row is added only while it is missing.
SET NAMES utf8mb4;
START TRANSACTION;

INSERT INTO cms_sites (parent_id, left_id, right_id, strict, visible, link, title, html_title, html_description, html_keywords, acl)
SELECT 1, 1, 1, 1, 1, '/changelog/', 'Changelog', 'Changelog of WBengine', 'What changed in each release of the WBengine framework: new features, changes, fixes and upgrade notes, newest release first.', 'changelog,releases,wbengine', 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cms_sites WHERE link = '/changelog/');

SET @changelog_site_id = (SELECT site_id FROM cms_sites WHERE link = '/changelog/' ORDER BY site_id LIMIT 1);

INSERT INTO cms_site_translations (site_id, locale, title, html_title, html_description, html_keywords)
SELECT @changelog_site_id, 'cs', 'Přehled změn', 'Přehled změn WBengine', 'Co se změnilo v každém vydání frameworku WBengine: nové funkce, změny, opravy a poznámky k upgradu, od nejnovějšího vydání.', 'změny,vydání,wbengine'
FROM DUAL
WHERE @changelog_site_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cms_site_translations WHERE site_id = @changelog_site_id AND locale = 'cs');

INSERT INTO cms_boxes (name, module, method, section_id, static, shared, device_min, device_strict, acl, `order`, sites)
SELECT 'Changelog', 'changelog', 'releases', 1, 1, 0, 1, 0, 0, 0, JSON_ARRAY(CAST(@changelog_site_id AS CHAR))
FROM DUAL
WHERE @changelog_site_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cms_boxes WHERE name = 'Changelog');

SET @changelog_menu_order = (SELECT COALESCE(MAX(`order`), 0) + 1 FROM cms_menu WHERE parent = 0);
INSERT INTO cms_menu (site_id, type, name, description, visible, `order`, parent)
SELECT @changelog_site_id, 1, 'Changelog', 'Releases and changes', 1, @changelog_menu_order, 0
FROM DUAL
WHERE @changelog_site_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cms_menu WHERE site_id = @changelog_site_id AND type = 1);

INSERT INTO cms_menu_translations (menu_id, locale, name, description)
SELECT menu_id, 'cs', 'Změny', 'Vydání a změny'
FROM cms_menu
WHERE site_id = @changelog_site_id AND type = 1
  AND NOT EXISTS (SELECT 1 FROM cms_menu_translations t WHERE t.menu_id = cms_menu.menu_id AND t.locale = 'cs');

COMMIT;
