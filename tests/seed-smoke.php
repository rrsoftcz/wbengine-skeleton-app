<?php
if (getenv('WBENGINE_SMOKE') !== '1') { throw new RuntimeException('Run only in the isolated smoke Compose project'); }
$db = new mysqli('db', 'dev_user', 'dev_password', 'wbengine_skeleton_app');
$db->execute_query('UPDATE cms_users SET password = ? WHERE user_id = 1', [password_hash('Smoke-password-4.0', PASSWORD_DEFAULT)]);
