<?php
if (getenv('WBENGINE_SMOKE') !== '1') { throw new RuntimeException('Run only in the isolated smoke project'); }
require dirname(__DIR__) . '/vendor/autoload.php';
if (class_exists(\Smarty\Smarty::class) || class_exists(\Wbengine\Renderer\Adapter\SmartyRenderer::class)) {
    throw new RuntimeException('The native smoke profile must not install Smarty or its optional compatibility package');
}
if (in_array('--without-texy', $argv, true) && class_exists(\Texy\Texy::class)) {
    throw new RuntimeException('The dependency-free content profile must not install Texy');
}
echo "Native dependency profile OK\n";
