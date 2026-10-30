<?php
if (PHP_SAPI !== 'cli') { throw new RuntimeException('Run this check from the command line.'); }
$project = dirname(__DIR__);
$root = sys_get_temp_dir() . '/wbengine-installer-' . bin2hex(random_bytes(6));
mkdir($root . '/src/Config', 0775, true);
mkdir($root . '/bin', 0775, true);
copy($project . '/src/Config/settings.json.default', $root . '/src/Config/settings.json.default');
$assert = static function (bool $ok, string $message): void { if (!$ok) { throw new RuntimeException($message); } };
$run = static function (string $configRoot) use ($project): array {
    $process = proc_open([PHP_BINARY, $project . '/bin/wbe', 'install', '--root=' . $configRoot, '--skip-composer'], [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
    if (!is_resource($process)) { throw new RuntimeException('Could not start the installer.'); }
    fclose($pipes[0]);
    $stdout = stream_get_contents($pipes[1]); fclose($pipes[1]);
    $stderr = stream_get_contents($pipes[2]); fclose($pipes[2]);
    return [proc_close($process), $stdout, $stderr];
};
$remove = static function (string $path) use (&$remove): void {
    if (!file_exists($path) && !is_link($path)) { return; }
    if (is_dir($path) && !is_link($path)) {
        foreach (array_diff(scandir($path) ?: [], ['.', '..']) as $entry) { $remove($path . '/' . $entry); }
        rmdir($path);
        return;
    }
    chmod($path, 0644);
    unlink($path);
};
try {
    [$code, $stdout, $stderr] = $run($root);
    $assert($code === 0, 'Fresh install failed: ' . $stderr . $stdout);
    $assert(str_contains($stdout, 'Created src/Config/Settings.json'), 'Install did not create Settings.json.');
    $settingsPath = $root . '/src/Config/Settings.json';
    $settings = json_decode((string) file_get_contents($settingsPath));
    $assert(is_object($settings), 'Created settings are not a JSON object.');
    $assert(!isset($settings->jwt), 'Settings must not carry signing keys: the framework has no JWT login.');
    $assert(isset($settings->dbAdapterDefinition), 'Settings were not created from the default configuration.');
    $created = (string) file_get_contents($settingsPath);
    $assert(is_dir($root . '/src/View/Compiled') && is_writable($root . '/src/View/Compiled'), 'Compiled template directory is not writable.');
    [$code] = $run($root);
    $assert($code === 0, 'Repeated install must be safe.');
    $again = json_decode((string) file_get_contents($settingsPath));
    $assert((string) file_get_contents($settingsPath) === $created, 'Repeated install replaced the existing settings.');

    file_put_contents($settingsPath, '{broken json');
    [$code, $stdout, $stderr] = $run($root);
    $assert($code !== 0 && str_contains($stderr . $stdout, 'Invalid JSON'), 'Malformed settings must produce an actionable CLI error.');
    $assert(file_get_contents($settingsPath) === '{broken json', 'Installer must not overwrite malformed existing settings.');

    $dockerfile = file_get_contents($project . '/Dockerfile');
    $compose = file_get_contents($project . '/docker-compose.yml');
    $entrypoint = file_get_contents($project . '/bin/container-entrypoint.sh');
    $assert(str_contains($dockerfile, 'container-entrypoint.sh'), 'Docker image must run the installer entrypoint.');
    $assert(!str_contains($compose, 'entrypoint:'), 'Compose must preserve the image command that starts Apache.');
    $assert(str_contains($entrypoint, 'bin/wbe install'), 'Container startup must run wbe install.');
    echo "OK (Docker installer smoke)\n";
} finally {
    $remove($root);
}
