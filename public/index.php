<?php
namespace App;

use Wbengine\Application\Application;

define('APP_DIR', dirname(__DIR__));

require(dirname(__DIR__) . '/vendor/autoload.php');

try {
    $App = new Application(APP_DIR . '/src', __NAMESPACE__);
    $user = $App->getClassUser();
    $App->getSite()->setVariable('user', $App->getClassUser());

} catch (\Wbengine\Application\ApplicationException $e) {
    die($e->Show());
}

$App->run();