-- The Changelog menu entry stands right after Blog instead of at the end (migration 038 added it last).
-- Idempotent: it moves only while the entry is further away than the position after Blog, and entries in between
-- shift down by one, so the order of the other entries is kept.
SET NAMES utf8mb4;
START TRANSACTION;

SET @blog_site_id = (SELECT site_id FROM cms_sites WHERE link = '/blog/' ORDER BY site_id LIMIT 1);
SET @changelog_site_id = (SELECT site_id FROM cms_sites WHERE link = '/changelog/' ORDER BY site_id LIMIT 1);
SET @blog_menu_id = (SELECT menu_id FROM cms_menu WHERE site_id = @blog_site_id AND type = 1 AND parent = 0 ORDER BY menu_id LIMIT 1);
SET @changelog_menu_id = (SELECT menu_id FROM cms_menu WHERE site_id = @changelog_site_id AND type = 1 AND parent = 0 ORDER BY menu_id LIMIT 1);
SET @blog_order = (SELECT `order` FROM cms_menu WHERE menu_id = @blog_menu_id);
SET @changelog_order = (SELECT `order` FROM cms_menu WHERE menu_id = @changelog_menu_id);

UPDATE cms_menu SET `order` = `order` + 1
WHERE @blog_order IS NOT NULL AND @changelog_order IS NOT NULL AND @changelog_order > @blog_order + 1
  AND type = 1 AND parent = 0 AND `order` > @blog_order AND `order` < @changelog_order AND menu_id <> @changelog_menu_id;

UPDATE cms_menu SET `order` = @blog_order + 1
WHERE @blog_order IS NOT NULL AND @changelog_order IS NOT NULL AND @changelog_order > @blog_order + 1 AND menu_id = @changelog_menu_id;

COMMIT;
