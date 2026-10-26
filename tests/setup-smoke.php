<?php
if (getenv('WBENGINE_SMOKE') !== '1') { throw new RuntimeException('Run only in the isolated smoke Compose project'); }
$path = dirname(__DIR__);
$config = json_decode(file_get_contents($path . '/src/Config/settings.json.default'), true, 512, JSON_THROW_ON_ERROR);
$config['dbAdapterDefinition']['hostname'] = 'db';
$config['jwt']['accessKey'] = str_repeat('smoke-access-', 8);
$config['jwt']['refreshKey'] = str_repeat('smoke-refresh-', 8);
$config['cache']['dir'] = '/tmp/wbengine-skeleton-smoke-cache';
$config['debug'] = false;
file_put_contents($path . '/src/Config/Settings.json', json_encode($config, JSON_PRETTY_PRINT | JSON_THROW_ON_ERROR));
if (!is_dir($path . '/src/View/Compiled')) { mkdir($path . '/src/View/Compiled', 0775, true); }
