-- Server side refresh tokens for the REST API (WBengine 3.1 or newer).
-- Tokens are stored as SHA-256 hashes, rotated on every use and revocable.
-- Without this table logging in still works, but refreshing is unavailable.
CREATE TABLE IF NOT EXISTS `cms_refresh_tokens` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `family_id` char(32) NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expires_at` int(10) unsigned NOT NULL,
  `created_at` int(10) unsigned NOT NULL,
  `used_at` int(10) unsigned DEFAULT NULL,
  `revoked_at` int(10) unsigned DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token_hash` (`token_hash`),
  KEY `family_id` (`family_id`),
  KEY `user_id` (`user_id`),
  KEY `expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
