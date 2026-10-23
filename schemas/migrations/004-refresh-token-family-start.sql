-- Absolute lifetime of a refresh token family (WBengine 3.1 or newer).
-- Existing tokens get 0, which is read as "started when the token was created".
ALTER TABLE `cms_refresh_tokens` ADD COLUMN `family_started_at` int(10) unsigned NOT NULL DEFAULT '0' AFTER `created_at`;
