<?php
/** Test-only instrumented entry point for the isolated smoke Compose project. */
if (getenv('WBENGINE_SMOKE') !== '1' || !is_dir((string) getenv('WB_BENCHMARK_DIR'))) { http_response_code(404); exit; }
require dirname(__DIR__) . '/vendor/autoload.php';
use Wbengine\Config;
use Wbengine\Db;
use Wbengine\Cache;

$uri = $_SERVER['REQUEST_URI'];
if (!preg_match('~^/(off|data-warm|page-warm)/(.*)$~D', $uri, $match)) { http_response_code(404); exit; }
$mode = $match[1]; $_SERVER['REQUEST_URI'] = '/' . $match[2];
$_REQUEST['link'] = trim((string) parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH), '/');
$connections = function_exists('mysqli_get_client_stats') ? (int) (mysqli_get_client_stats()['connect_success'] ?? 0) : null;
// An outer buffer delays header commit until output-buffer/shutdown processing, including HIT exits.
ob_start();
header_register_callback(static function () use ($connections): void {
    header('X-WB-Benchmark-Run: ' . hash('sha256', getenv('WB_BENCHMARK_DIR')));
    header('X-WB-Benchmark-Queries: ' . Db::getQueriesCount());
    if ($connections !== null) { header('X-WB-Benchmark-Connections: ' . ((int) (mysqli_get_client_stats()['connect_success'] ?? 0) - $connections)); }
    header('X-WB-Benchmark-Memory: ' . memory_get_peak_usage(true));
    header('X-WB-Benchmark-PHP: ' . PHP_VERSION);
    header('X-WB-Benchmark-OPcache: ' . (int) ini_get('opcache.enable_cli'));
});
$app = new \App\Application(dirname(__DIR__) . '/src', 'App');
Config::$config->cache = (object) ['enabled'=>$mode !== 'off', 'driver'=>'file', 'ttl'=>300,
    'dir'=>getenv('WB_BENCHMARK_DIR') . '/' . $mode, 'pages'=>(object) ['enabled'=>$mode === 'page-warm','ttl'=>300]];
Cache::setDriver(null);
$app->get('/benchmark-api/', static function ($route, $app) {
    header('Content-Type: application/json');
    echo json_encode(['ok'=>true,'custom'=>true,'locale'=>$app->getLocale()]);
    return true;
});
$app->run();
