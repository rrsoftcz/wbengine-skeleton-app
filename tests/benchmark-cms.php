<?php
/** Actual CMS fixture matrix. Run only in the isolated skeleton smoke Compose project. */
if (getenv('WBENGINE_SMOKE') !== '1') { throw new RuntimeException('Run in the isolated smoke Compose project only.'); }
require dirname(__DIR__) . '/vendor/autoload.php';
$directory = sys_get_temp_dir() . '/wb-cms-benchmark-' . bin2hex(random_bytes(8)); mkdir($directory, 0700);
putenv('WB_BENCHMARK_DIR=' . $directory); putenv('PHP_CLI_SERVER_WORKERS=4');
$server = null; $pipes = []; $exitCode = 0; $base = 'http://127.0.0.1:8081';
function benchmarkHttp(string $url, string $cookie = '', array $form = []): array
{
    $headers = ['User-Agent: WBengine-CMS-benchmark'];
    if ($cookie !== '') { $headers[] = 'Cookie: ' . $cookie; }
    if ($form) { $headers[] = 'Content-Type: application/x-www-form-urlencoded'; }
    $start = hrtime(true);
    $body = @file_get_contents($url, false, stream_context_create(['http'=>[
        'method'=>$form ? 'POST':'GET', 'header'=>implode("\r\n", $headers), 'content'=>$form ? http_build_query($form):'',
        'ignore_errors'=>true, 'follow_location'=>0, 'timeout'=>20]]));
    $elapsed = (hrtime(true) - $start) / 1e6; $raw = $http_response_header ?? [];
    preg_match('/\s(\d{3})\s/', $raw[0] ?? '', $status); $values = []; $cookies = [];
    foreach ($raw as $line) {
        if (preg_match('/^([^:]+):\s*(.*)$/', $line, $m)) { $values[strtolower($m[1])] = $m[2]; }
        if (preg_match('/^Set-Cookie:\s*([^=]+)=([^;]*)/i', $line, $m)) { $cookies[$m[1]] = $m[2]; }
    }
    $sample = ['ms'=>$elapsed, 'status'=>(int) ($status[1] ?? 0)];
    foreach (['queries','connections','memory'] as $name) { if (isset($values['x-wb-benchmark-' . $name])) { $sample[$name] = (int) $values['x-wb-benchmark-' . $name]; } }
    $sample['page_cache'] = $values['x-wbengine-cache'] ?? 'none';
    return ['sample'=>$sample, 'body'=>$body, 'cookies'=>$cookies, 'headers'=>$values];
}
function benchmarkCookie(array $cookies): string { return implode('; ', array_map(static fn ($k,$v)=>$k . '=' . $v, array_keys($cookies), $cookies)); }
function benchmarkBatch(string $url, string $cookie, string $directory, string $label): array
{
    $children = []; $start = hrtime(true);
    for ($worker = 0; $worker < 4; $worker++) {
        $pid = pcntl_fork();
        if ($pid === -1) { throw new RuntimeException('Cannot fork benchmark client.'); }
        if ($pid === 0) {
            $samples = [];
            for ($request = 0; $request < 5; $request++) { $samples[] = benchmarkHttp($url, $cookie)['sample']; }
            file_put_contents($directory . '/' . $label . '-' . $worker . '.json', json_encode($samples, JSON_THROW_ON_ERROR));
            exit(0);
        }
        $children[$worker] = $pid;
    }
    $samples = [];
    foreach ($children as $worker=>$pid) {
        pcntl_waitpid($pid, $status);
        if (pcntl_wexitstatus($status) !== 0) { throw new RuntimeException('Benchmark client failed.'); }
        $file = $directory . '/' . $label . '-' . $worker . '.json';
        $samples = array_merge($samples, json_decode(file_get_contents($file), true, 512, JSON_THROW_ON_ERROR)); unlink($file);
    }
    $report = \Wbengine\Console\RequestMatrix::summarize($samples, (hrtime(true) - $start) / 1e9);
    $report['page_cache_responses'] = array_count_values(array_column($samples, 'page_cache'));
    $report['http_statuses'] = array_count_values(array_column($samples, 'status'));
    $report['concurrency'] = 4;
    return $report;
}
try {
    // DB version/fixture size are recorded outside measured HTTP requests.
    $db = new mysqli('db','dev_user','dev_password','wbengine_skeleton_app');
    $data = [];
    foreach (['cms_sites','cms_articles','cms_boxes','cms_users'] as $table) { $data[$table] = (int) $db->query('SELECT COUNT(*) FROM ' . $table)->fetch_row()[0]; }
    $version = $db->server_info; $db->close(); unset($db);
    $server = proc_open([PHP_BINARY,'-S','127.0.0.1:8081','-t','public','tests/benchmark-router.php'],
        [0=>['pipe','r'],1=>['file',$directory . '/server.log','a'],2=>['file',$directory . '/server.log','a']], $pipes, dirname(__DIR__));
    if (!is_resource($server)) { throw new RuntimeException('Cannot start isolated benchmark server.'); }
    for ($attempt = 0; $attempt < 100; $attempt++) {
        $socket = @fsockopen('127.0.0.1',8081,$errno,$error,.05);
        if ($socket) { fclose($socket); break; }
        usleep(50000);
    }
    $first = benchmarkHttp($base . '/off/');
    if (($first['headers']['x-wb-benchmark-run'] ?? '') !== hash('sha256', $directory) || $first['sample']['status'] !== 200) { throw new RuntimeException('CMS home failed.'); }
    $result = ['recorded_at'=>gmdate(DATE_ATOM), 'environment'=>['php'=>$first['headers']['x-wb-benchmark-php'] ?? PHP_VERSION,
        'server'=>'PHP built-in HTTP server, PHP_CLI_SERVER_WORKERS=4; loopback in isolated smoke Compose container',
        'database'=>$version, 'opcache_cli'=>$first['headers']['x-wb-benchmark-opcache'] ?? 'unknown', 'data'=>$data,
        'template'=>'App native site.tpl and real CMS home/profile; file data/page cache',
        'sessions'=>'WBengine DB-backed sessions; real CSRF-protected admin form login'],
        'measurement'=>['latency'=>'per-request new TCP connection including body transfer; nearest-rank p50/p95', 'throughput'=>'measured batch wall time includes client fork and sample collection overhead', 'limits'=>'20 samples per case on a small isolated localhost fixture; no production latency, memory or capacity guarantee', 'requests_per_case'=>20,'concurrency'=>4,'warmup'=>'clear only the runner mode cache root, then one unmeasured request per cohort',
        'sql'=>'Db::getQueriesCount at response header commit; includes framework SQL but excludes connection initialization statements',
        'connections'=>'mysqlnd connect_success delta from request start to header commit',
        'memory'=>'memory_get_peak_usage(true) at header commit, server request peak allocated bytes',
        'cache_modes'=>'Isolated mode directories; full-page warm cohort uses HIT only where server reports HIT; private/custom API responses bypass shared pages'], 'cases'=>[]];
    foreach (['off','data-warm','page-warm'] as $mode) {
        mkdir($directory . '/' . $mode);
        // Creating anonymous and logged sessions is unmeasured setup in this dedicated DB.
        $anonymous = benchmarkHttp($base . '/' . $mode . '/login/');
        $anonCookie = benchmarkCookie($anonymous['cookies']);
        if ($anonCookie === '') { throw new RuntimeException('Anonymous session was not established.'); }
        $login = benchmarkHttp($base . '/' . $mode . '/login/');
        if (!preg_match('/name="token" value="([^"]+)"/', $login['body'], $token)) { throw new RuntimeException('CSRF login form missing.'); }
        $cookie = benchmarkCookie($login['cookies']);
        $logged = benchmarkHttp($base . '/' . $mode . '/login/', $cookie, ['userName'=>'admin@example.com','userPassword'=>'Smoke-password-4.0','token'=>html_entity_decode($token[1],ENT_QUOTES,'UTF-8'),'cResponse'=>'']);
        if ($logged['sample']['status'] !== 302) { throw new RuntimeException('Real admin login failed.'); }
        $loggedCookie = benchmarkCookie($logged['cookies'] + $login['cookies']);
        $profile = benchmarkHttp($base . '/' . $mode . '/profile/', $loggedCookie);
        if ($profile['sample']['status'] !== 200 || !str_contains($profile['body'], 'admin@example.com')) { throw new RuntimeException('Real authenticated profile failed.'); }
        $cases = ['anonymous'=>['/',''], 'anonymous-session'=>['/',$anonCookie], 'logged'=>['/profile/',$loggedCookie], 'custom-api'=>['/benchmark-api/',''], 'same-session'=>['/profile/',$loggedCookie]];
        foreach ($cases as $identity=>[$path,$cookie]) {
            // Clear only this runner's configured cache root before every cohort.
            foreach (glob($directory . '/' . $mode . '/*') ?: [] as $cacheFile) {
                if (is_file($cacheFile)) { unlink($cacheFile); }
            }
            benchmarkHttp($base . '/' . $mode . $path, $cookie);
            $result['cases'][$mode][$identity] = benchmarkBatch($base . '/' . $mode . $path, $cookie, $directory, $mode . '-' . $identity);
        }
    }
    echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR) . "\n";
    foreach ($result['cases'] as $cases) { foreach ($cases as $case) { if ($case['errors']) { $exitCode = 1; } } }
} finally {
    if (is_resource($server)) {
        $pid = proc_get_status($server)['pid'];
        $children = @file_get_contents('/proc/' . $pid . '/task/' . $pid . '/children');
        foreach (preg_split('/\s+/', trim((string) $children), -1, PREG_SPLIT_NO_EMPTY) as $child) { posix_kill((int) $child, SIGTERM); }
        proc_terminate($server); foreach ($pipes as $pipe) { if (is_resource($pipe)) { fclose($pipe); } } proc_close($server);
    }
    $files = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($directory, FilesystemIterator::SKIP_DOTS), RecursiveIteratorIterator::CHILD_FIRST);
    foreach ($files as $file) { $file->isDir() ? rmdir($file->getPathname()) : unlink($file->getPathname()); } rmdir($directory);
}
exit($exitCode);
