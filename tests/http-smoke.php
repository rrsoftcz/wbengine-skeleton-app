<?php
if (getenv('WBENGINE_SMOKE') !== '1') { throw new RuntimeException('Run only in the isolated smoke Compose project'); }
final class SmokeClient
{
    public array $cookies = [];
    public function request(string $path, array $form = []): array
    {
        $headers = ['User-Agent: WBengine-smoke'];
        if ($this->cookies) { $headers[] = 'Cookie: ' . implode('; ', array_map(static fn ($k, $v) => $k . '=' . $v, array_keys($this->cookies), $this->cookies)); }
        if ($form) { $headers[] = 'Content-Type: application/x-www-form-urlencoded'; }
        $body = file_get_contents('http://127.0.0.1:8080' . $path, false, stream_context_create(['http' => [
            'method' => $form ? 'POST' : 'GET', 'header' => implode("\r\n", $headers),
            'content' => $form ? http_build_query($form) : '', 'ignore_errors' => true, 'follow_location' => 0,
        ]]));
        $responseHeaders = $http_response_header ?? [];
        foreach ($responseHeaders as $header) {
            if (preg_match('/^Set-Cookie: ([^=]+)=([^;]*)/i', $header, $m)) { $this->cookies[$m[1]] = $m[2]; }
        }
        preg_match('/\s(\d{3})\s/', $responseHeaders[0] ?? '', $status);
        return ['status' => (int) ($status[1] ?? 0), 'body' => $body, 'headers' => implode("\n", $responseHeaders)];
    }
}
$checks = 0;
$check = static function (bool $ok, string $message) use (&$checks): void { $checks++; if (!$ok) { throw new RuntimeException($message); } };
$public = new SmokeClient();
$home = $public->request('/');
$check($home['status'] === 200, 'Home returns 200: ' . $home['status']);
$check(str_contains($home['body'], '<html lang="en"'), 'English layout rendered');
$again = $public->request('/');
$check(str_contains($again['headers'], 'X-WBengine-Cache: HIT'), 'Anonymous home reaches page-cache HIT');
$check(!str_contains($home['body'], '?a=logout'), 'No GET logout link');
$cs = $public->request('/cs/');
$check($cs['status'] === 200 && str_contains($cs['body'], '<html lang="cs"'), 'Czech locale rendered');
$check(preg_match('/<a[^>]*href="([^"]+)"[^>]*hreflang="en"/', $cs['body'], $englishSwitch), 'English language switch is present');
$check($englishSwitch[1] === '/?_wb_locale=en', 'English switch explicitly selects the default locale');
$englishSelection = $public->request($englishSwitch[1]);
$check($englishSelection['status'] === 302 && preg_match('/^Location: \/$/mi', $englishSelection['headers']), 'English locale selection redirects to canonical home');
$englishAfterSwitch = $public->request('/');
$check($englishAfterSwitch['status'] === 200 && str_contains($englishAfterSwitch['body'], '<html lang="en"'), 'English switch updates locale cookie');
$missing = $public->request('/no-such-smoke-page/');
$check($missing['status'] === 404, 'Unknown page returns 404');
$blog = $public->request('/blog/');
$check($blog['status'] === 200 && !str_contains($blog['body'], '{$'), 'Article rendered through native template');
foreach (['/docs/settings/', '/docs/deployment/', '/docs/logging/', '/cs/docs/settings/', '/cs/docs/deployment/', '/cs/docs/logging/'] as $docPath) {
    $docPage = $public->request($docPath);
    $check($docPage['status'] === 200 && !str_contains($docPage['body'], '{$'), 'Documentation page ' . $docPath . ' renders (status ' . $docPage['status'] . ')');
}
$check(str_contains($public->request('/docs/settings/')['body'], 'googleAnalytics.measurementId'), 'Settings reference documents the Google Analytics key');
$check(!str_contains($home['body'], 'id="cookie-banner"') && !str_contains($home['body'], 'cookie-consent.js'), 'Without googleAnalytics.measurementId the layout has no consent banner or analytics script');
$capabilities = $public->request('/api/v2/capabilities');
$capabilityBody = json_decode($capabilities['body'], true, 512, JSON_THROW_ON_ERROR);
$check($capabilities['status'] === 200 && ($capabilityBody['data']['api_version'] ?? '') === '2.0', 'API v2 discovery bypasses layout rendering');
$boxTypes = array_column($capabilityBody['data']['box_types'] ?? [], 'type');
$check(in_array('story', $boxTypes, true), 'API v2 capabilities list the registered story box type');
$check(($capabilityBody['data']['capabilities']['boxes']['write'] ?? false) === true, 'API v2 capabilities allow writing boxes');
$legacy = $public->request('/api/sections/');
$check($legacy['status'] === 404, 'The former API routes are gone');
$integrations = $public->request('/integrations/');
$check($integrations['status'] === 302 && stripos($integrations['headers'], '/login/') !== false, 'Integrations page resolves and sends anonymous visitors to the login (status ' . $integrations['status'] . ')');
$login = new SmokeClient();
$form = $login->request('/login/');
$check($form['status'] === 200 && preg_match('/name="token" value="([^"]+)"/', $form['body'], $match), 'Login CSRF token present');
$token = html_entity_decode($match[1], ENT_QUOTES, 'UTF-8');
$result = $login->request('/login/', ['userName' => 'admin@example.com', 'userPassword' => 'Smoke-password-4.0', 'token' => $token, 'cResponse' => '']);
if ($result['status'] !== 302) {
    if (preg_match('/<div id="alert"[^>]*>(.*?)<\/div>/s', $result['body'], $alert)) { fwrite(STDERR, 'Login alert: ' . strip_tags($alert[1]) . "\n"); }
    else { fwrite(STDERR, 'Response prefix: ' . substr(strip_tags($result['body']), 0, 240) . "\n"); }
}
$check($result['status'] === 302, 'Login succeeds: ' . $result['status']);
$profile = $login->request('/profile/');
$check($profile['status'] === 200 && str_contains($profile['body'], 'admin@example.com'), 'Private profile rendered');
$check(preg_match('/<form[^>]*method="post"[^>]*action="\/login\/"[^>]*>.*?name="a" value="logout".*?name="token" value="([^"]+)"/s', $profile['body'], $logout), 'Layout has POST logout with purpose token');
$check(!str_contains($profile['headers'], 'X-WBengine-Cache: HIT'), 'Private profile is not a shared HIT');
$check(str_contains($profile['body'], 'href="/integrations/"') || str_contains($profile['body'], '/integrations/'), 'Administrator profile links to the integrations page');
$integrationsPage = $login->request('/integrations/');
$check($integrationsPage['status'] === 200 && str_contains($integrationsPage['body'], 'data-wb-integrations'), 'The framework Integrations box renders for an administrator without a class in the application: ' . $integrationsPage['status']);
$getLogout = $login->request('/login/?a=logout');
$check($getLogout['status'] === 405, 'GET logout rejected');
$check($login->request('/profile/')['status'] === 200, 'GET logout leaves identity intact');
$invalidLogout = $login->request('/login/', ['a' => 'logout', 'token' => 'invalid']);
$check($invalidLogout['status'] === 403, 'Invalid logout CSRF rejected');
$check($login->request('/profile/')['status'] === 200, 'Invalid POST leaves identity intact');
$done = $login->request('/login/', ['a' => 'logout', 'token' => html_entity_decode($logout[1], ENT_QUOTES, 'UTF-8')]);
$check($done['status'] < 400, 'POST logout accepted');
$after = $login->request('/profile/');
$check($after['status'] === 302, 'Logged-out profile redirects');
echo 'OK (' . $checks . " HTTP checks)\n";
