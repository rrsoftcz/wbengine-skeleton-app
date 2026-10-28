-- Adds the "Integrations" page (/integrations/) for the central WBengine Admin key screen.
-- Requires WBengine 4.0.3 or newer, API v2 enabled and the framework migrations
-- 4.0.0/002-api-v2-integrations.sql and 4.0.3/001-api-integration-last-used.sql.
-- The page requires login (acl = 1); the framework box additionally requires the ADMIN role.
-- Safe to run more than once. Back up before applying.
SET NAMES utf8mb4;
START TRANSACTION;

INSERT INTO cms_sites (parent_id, left_id, right_id, strict, visible, link, title, html_title, html_description, html_keywords, acl)
SELECT 1, 1, 1, 1, 0, '/integrations/', 'Integrations', 'Integrations', 'Integration keys for the central WBengine Admin', 'integrations,api', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM cms_sites WHERE link = '/integrations/');

INSERT INTO cms_boxes (name, module, method, section_id, static, shared, device_min, device_strict, acl, `order`, sites)
SELECT 'Integrations', 'integrations', 'integrations', 1, 1, 0, 1, 0, 1, 1, JSON_ARRAY(CAST(site_id AS CHAR))
FROM cms_sites
WHERE link = '/integrations/'
  AND NOT EXISTS (SELECT 1 FROM cms_boxes WHERE module = 'integrations' AND method = 'integrations');

COMMIT;
