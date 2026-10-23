-- Passwords are stored with password_hash() (60+ characters).
-- Existing installations must widen the column; legacy MD5 hashes keep working
-- and are upgraded automatically on the next successful login of each user.
ALTER TABLE `cms_users` MODIFY `password` varchar(255) NOT NULL DEFAULT '0';
