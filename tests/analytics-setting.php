<?php

declare(strict_types=1);

use App\Site;
use Wbengine\Config;

// The layout renders the consent banner and the analytics script only for a valid measurement id.
require dirname(__DIR__) . '/vendor/autoload.php';

$cases = [
    'valid id' => [json_decode('{"googleAnalytics":{"measurementId":"G-ABC123DEF4"}}'), 'G-ABC123DEF4'],
    'empty id' => [json_decode('{"googleAnalytics":{"measurementId":""}}'), ''],
    'missing section' => [json_decode('{}'), ''],
    'malformed id' => [json_decode('{"googleAnalytics":{"measurementId":"UA-12345-1"}}'), ''],
    'script injection' => [json_decode('{"googleAnalytics":{"measurementId":"G-ABCD\"><script>"}}'), ''],
    'not a string' => [json_decode('{"googleAnalytics":{"measurementId":123}}'), ''],
];
foreach ($cases as $name => [$settings, $expected]) {
    Config::$config = $settings;
    if (Site::analyticsMeasurementId() !== $expected) {
        throw new RuntimeException('analyticsMeasurementId failed for: ' . $name);
    }
}
echo "analytics setting: ok\n";
