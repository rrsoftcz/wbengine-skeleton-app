-- Add explicit article formats for WBengine 4.0.
-- Apply after 005-content-translations.sql. Back up the database first.
-- Do not also apply vendor/wbengine/wbengine/migrations/4.0.0/003-markdown-content.sql.
-- Existing content is left byte-for-byte unchanged and defaults to legacy_html.
ALTER TABLE `cms_articles`
  ADD COLUMN `content_format` enum('legacy_html','markdown') NOT NULL DEFAULT 'legacy_html';

ALTER TABLE `cms_article_translations`
  ADD COLUMN `content_format` enum('legacy_html','markdown') NOT NULL DEFAULT 'legacy_html';
