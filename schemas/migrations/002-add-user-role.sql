-- The REST API authorizes by role (user, editor, admin), stored in cms_users.role.
-- Run once on an existing database. WBengine 3.1 or newer is required.
ALTER TABLE `cms_users` ADD COLUMN `role` varchar(20) NOT NULL DEFAULT 'user';

-- Nobody is an administrator after the migration, so the API would reject everybody.
-- Promote your administrator account(s). The demo account has user_id 1:
UPDATE `cms_users` SET `role` = 'admin' WHERE `user_id` = 1;
