<?php
if (getenv('WBENGINE_SMOKE') !== '1') { throw new RuntimeException('Run only in the isolated smoke project'); }
require dirname(__DIR__) . '/vendor/autoload.php';
require_once dirname(__DIR__) . '/vendor/wbengine/wbengine/Application/Env/Const.php';
Wbengine\Config::load(new Wbengine\Application\Path\File(dirname(__DIR__) . '/src/Config/Settings.json'));
Wbengine\Cache::flush();
foreach (glob(dirname(__DIR__) . '/src/View/Compiled/*.php') as $file) { unlink($file); }
