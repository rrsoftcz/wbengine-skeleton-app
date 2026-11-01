<?php
namespace App;

define('APP_DIR', dirname(__DIR__));

require(dirname(__DIR__) . '/vendor/autoload.php');

try {
    $App = new Application(APP_DIR . '/src', __NAMESPACE__);

} catch (\Wbengine\Application\ApplicationException $e) {
    die($e->Show());
}

// robots.txt and sitemap.xml, generated from the pages and the "seo" settings.
\Wbengine\Seo\Crawlers::register($App);

$App->run();