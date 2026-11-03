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
$check(preg_match('/<link rel="canonical" href="([^"]+)\/cs\/">/', $cs['body']) === 1, 'Czech home has a canonical link to its own /cs/ address');
$check(preg_match('/<link rel="canonical" href="https?:\/\/[^"\/]+\/">/', $home['body']) === 1, 'English home has a canonical link to its own address');
$check(substr_count($cs['body'], 'rel="canonical"') === 1 && substr_count($home['body'], 'rel="canonical"') === 1, 'Exactly one canonical link per page');
// The header shows what is installed: a release as vX.Y.Z, anything else (the smoke job installs the framework from a checkout) as dev.
$installed = is_file(__DIR__ . '/../vendor/composer/installed.php') ? require __DIR__ . '/../vendor/composer/installed.php' : [];
$pretty = (string) ($installed['versions']['wbengine/wbengine']['pretty_version'] ?? '');
$expectedVersion = preg_match('/^v?(\d+\.\d+\.\d+(?:-[0-9A-Za-z.]+)?)$/D', $pretty, $release) ? 'v' . $release[1] : 'dev';
$check(preg_match('/<a[^>]*href="\/changelog\/"[^>]*>(v\d+\.\d+\.\d+[^<]*|dev)<\/a>/', $home['body'], $shown) === 1, 'The header shows the framework version');
$check($shown[1] === $expectedVersion, 'The header shows the installed framework version: ' . $shown[1] . ' against ' . $expectedVersion . ' (' . $pretty . ')');
$check(preg_match('/<footer.*href="https:\/\/github\.com\/rrsoftcz\/wbengine-admin".*<\/footer>/s', $home['body']) === 1, 'The footer links to the GitHub project of the central administration');
$assetParts = array_map(static fn ($f) => (string) md5_file(__DIR__ . '/../public/' . $f), ['Css/output.min.css', 'menu.js', 'code-highlight.js', 'cookie-consent.js']);
$assetsVersion = substr(md5(implode('|', $assetParts)), 0, 10);
$check(str_contains($home['body'], 'href="/Css/output.min.css?v=' . $assetsVersion . '"') && str_contains($home['body'], 'src="/menu.js?v=' . $assetsVersion . '"'), 'The stylesheet and scripts carry a fingerprint of their content, so a browser never keeps an outdated copy: ?v=' . $assetsVersion);
$skeletonVersion = trim((string) file_get_contents(__DIR__ . '/../VERSION'));
$check(preg_match('/^\d+\.\d+\.\d+$/D', $skeletonVersion) === 1, 'VERSION holds a release number: ' . $skeletonVersion);
$check(preg_match('/<footer.*&copy; 2008.*<span id="skeleton-version">WBengine Skeleton App v' . preg_quote($skeletonVersion, '/') . '<\/span><\/span>\s*<\/div>\s*<\/div>\s*<\/footer>/s', $home['body']) === 1, 'The footer ends at the bottom right with the version of the skeleton application: v' . $skeletonVersion);
$check(preg_match('/data-nav="\/blog\/".*?data-nav="\/changelog\/".*?data-nav="\/about\/"/s', $home['body']) === 1, 'The changelog is in the menu right after the blog and before About');
$changelog = $public->request('/changelog/');
$check($changelog['status'] === 200 && str_contains($changelog['body'], '<h1'), 'The changelog page returns 200: ' . $changelog['status']);
$changelogFile = (string) @file_get_contents(__DIR__ . '/../vendor/wbengine/wbengine/CHANGELOG.md');
$check(preg_match('/^## \[(\d+\.\d+\.\d+)\] - /m', $changelogFile, $newest) === 1, 'The installed framework ships a changelog with releases');
$check(str_contains($changelog['body'], 'id="v' . $newest[1] . '"') && substr_count($changelog['body'], '<section class="card mt-6 sm:p-8" id="v') >= 5, 'The changelog page lists the newest release of the installed framework and several more');
$check(str_contains($changelog['body'], 'href="/changelog/"') && str_contains($home['body'], 'href="/changelog/"'), 'The menu and the header version link to the changelog');
$check(preg_match('/WBengine <strong>(v\d+\.\d+\.\d+[^<]*|dev)<\/strong>/', $changelog['body'], $runningVersion) === 1 && $runningVersion[1] === $expectedVersion, 'The changelog page names the running version, not an empty one: ' . ($runningVersion[1] ?? 'missing'));
$csChangelog = $public->request('/cs/changelog/');
$check($csChangelog['status'] === 200 && str_contains($csChangelog['body'], '<html lang="cs"') && str_contains($csChangelog['body'], 'Přehled změn') && str_contains($csChangelog['body'], 'Opraveno'), 'The Czech changelog page has Czech headings');
$blog = $public->request('/blog/');
$check($blog['status'] === 200 && str_contains($blog['body'], 'id="blog-newest"') && str_contains($blog['body'], 'id="blog-all"'), 'The blog overview lists the newest posts and all posts: ' . $blog['status']);
$check(str_contains($blog['body'], 'href="/blog/what-wbengine-gives-a-site/"') && str_contains($blog['body'], 'What WBengine gives a site'), 'The overview links the demo post with its title');
$check(str_contains($blog['body'], 'id="blog-popular"') && preg_match('/\d+ views/', $blog['body']) === 1, 'The most read block shows a post that has views');
$check(!str_contains($blog['body'], '<h1 class="mb-4 mt-0 text-3xl sm:text-4xl">Articles with the bundled box'), 'The overview does not show one article any more');
$post = $public->request('/blog/what-wbengine-gives-a-site/');
$check($post['status'] === 200 && str_contains($post['body'], 'Pages and boxes live in the database') && str_contains($post['body'], 'Languages are built in'), 'The demo post is on its own page with its new text: ' . $post['status']);
$csBlog = $public->request('/cs/blog/');
$check($csBlog['status'] === 200 && str_contains($csBlog['body'], 'Co WBengine webu dává') && str_contains($csBlog['body'], 'Nejnovější') && str_contains($csBlog['body'], 'href="/cs/blog/what-wbengine-gives-a-site/"'), 'The Czech overview has Czech texts and Czech links');
$csPost = $public->request('/cs/blog/what-wbengine-gives-a-site/');
$check($csPost['status'] === 200 && str_contains($csPost['body'], 'Jazyky jsou součástí'), 'The Czech demo post is translated');
foreach (['/docs/', '/docs/architecture/', '/docs/boxes/', '/docs/templates/', '/docs/languages/', '/docs/caching/', '/docs/performance/', '/docs/seo/', '/docs/security/', '/docs/rest-api/', '/docs/administration/', '/docs/mcp/', '/docs/mcp-clients/', '/docs/settings/', '/docs/deployment/', '/docs/logging/', '/docs/analytics/'] as $docPath) {
    $en = $public->request($docPath);
    $check($en['status'] === 200 && str_contains($en['body'], '<html lang="en"') && str_contains($en['body'], '<h1'), 'Documentation page ' . $docPath . ' in English: ' . $en['status']);
    $csDoc = $public->request('/cs' . $docPath);
    $check($csDoc['status'] === 200 && str_contains($csDoc['body'], '<html lang="cs"') && str_contains($csDoc['body'], '<h1'), 'Documentation page ' . $docPath . ' in Czech: ' . $csDoc['status']);
    $check(!preg_match('/doc\.[a-z_]+</', $en['body'] . $csDoc['body']), 'No untranslated catalog key in the sidebar of ' . $docPath);
}
foreach ([['/docs/administration/', 'MAIL_SMTP_HOST'], ['/docs/administration/', 'Invitation by email'], ['/cs/docs/administration/', 'MAIL_SMTP_PASSWORD'], ['/cs/docs/administration/', 'Pozvánka emailem']] as [$setupPath, $setupText]) {
    $setupPage = $public->request($setupPath);
    $check($setupPage['status'] === 200 && str_contains($setupPage['body'], $setupText), 'The page ' . $setupPath . ' mentions: ' . $setupText);
}
foreach ([['/docs/boxes/', 'Strict and dynamic pages'], ['/docs/caching/', 'The page cache in detail'], ['/docs/languages/', 'Addresses, links and statistics'], ['/docs/templates/', 'wbengine_version'], ['/docs/rest-api/', 'Hiding and showing an article'], ['/cs/docs/boxes/', 'Striktní a dynamické stránky'], ['/cs/docs/rest-api/', 'Omezení klíče na adresy']] as [$extendedPath, $extendedText]) {
    $extended = $public->request($extendedPath);
    $check($extended['status'] === 200 && substr_count($extended['body'], $extendedText) >= 1, 'The extended page ' . $extendedPath . ' has its new section: ' . $extendedText);
}
$boxesDoc = $public->request('/docs/boxes/');
$check(substr_count($boxesDoc['body'], 'Strict and dynamic pages') === 1, 'The new section appears once, not twice');
// The numbers on the home page and in the Performance page are the recorded benchmark, not numbers typed by hand.
$bench = json_decode((string) file_get_contents(__DIR__ . '/benchmark-cms-result.json'), true);
$coreNoCache = (float) $bench['cases']['off']['anonymous']['php_ms']['p50'];
$coreCached = (float) $bench['cases']['page-warm']['anonymous']['php_ms']['p50'];
$check(preg_match('/>' . round($coreNoCache) . ' ms<\/dd>/', $home['body']) === 1 && preg_match('/>' . round($coreCached) . ' ms<\/dd>/', $home['body']) === 1, 'The hero shows the recorded core times: ' . round($coreNoCache) . ' ms and ' . round($coreCached) . ' ms');
$check(!str_contains($home['body'], 'Runtime packages') && str_contains($home['body'], 'href="/docs/performance/"'), 'The hero links to the method and no longer shows the runtime packages');
$perfDoc = $public->request('/docs/performance/');
$check(str_contains($perfDoc['body'], sprintf('%.1f ms', $coreNoCache)) && str_contains($perfDoc['body'], sprintf('%.1f ms', $coreCached)) && str_contains($perfDoc['body'], 'What is measured'), 'The Performance page has the recorded numbers: ' . sprintf('%.1f ms', $coreNoCache) . ' and ' . sprintf('%.1f ms', $coreCached));
$csPerfDoc = $public->request('/cs/docs/performance/');
$check(str_contains($csPerfDoc['body'], 'Co se měří') && str_contains($csPerfDoc['body'], str_replace('.', ',', sprintf('%.1f ms', $coreNoCache))), 'The Czech Performance page has its text and the number with a decimal comma');
$architecture = $public->request('/docs/architecture/');
$check(str_contains($architecture['body'], 'src="/Assets/request-flow.en.svg"') && !str_contains($architecture['body'], 'language-text">public/index.php'), 'The architecture page shows the request diagram instead of the text block');
$csArchitecture = $public->request('/cs/docs/architecture/');
$check(str_contains($csArchitecture['body'], 'src="/Assets/request-flow.cs.svg"') && str_contains($csArchitecture['body'], '<ol>'), 'The Czech architecture page shows the Czech diagram and the steps');
foreach (['en', 'cs'] as $flowLang) {
    $svg = $public->request('/Assets/request-flow.' . $flowLang . '.svg');
    $check($svg['status'] === 200 && str_contains($svg['headers'], 'image/svg+xml') && str_starts_with(ltrim($svg['body']), '<svg') && str_contains($svg['body'], '<title') && !preg_match('/<script|onload=|javascript:/i', $svg['body']), 'The ' . $flowLang . ' diagram is served as an SVG image with a title and no script: ' . $svg['status']);
}
$seoDoc = $public->request('/docs/seo/');
$check(str_contains($seoDoc['body'], 'canonical') && str_contains($seoDoc['body'], '/sitemap.xml') && str_contains($seoDoc['body'], 'seo.allowIndexing'), 'The search engines page has its content');
$analyticsDoc = $public->request('/cs/docs/analytics/');
$check(str_contains($analyticsDoc['body'], 'Co se nepočítá') && str_contains($analyticsDoc['body'], 'analytics:prune'), 'The Czech statistics page has its content');
$mcpDoc = $public->request('/docs/mcp/');
$check(str_contains($mcpDoc['body'], 'What it never does') && str_contains($mcpDoc['body'], 'Editor with structure and statistics'), 'The MCP page has its content');
$mcpClients = $public->request('/cs/docs/mcp-clients/');
$check(str_contains($mcpClients['body'], 'WSL2') && str_contains($mcpClients['body'], 'Co bylo ověřeno'), 'The Czech client page names WSL2 and what was checked');
$robots = $public->request('/robots.txt');
$check($robots['status'] === 200 && str_contains($robots['headers'], 'Content-Type: text/plain'), 'robots.txt is plain text: ' . $robots['status']);
$check(str_contains($robots['body'], "Disallow: /login/\n") && str_contains($robots['body'], 'Sitemap: http://127.0.0.1:8080/sitemap.xml'), 'robots.txt lists the disallowed path and names the sitemap');
$sitemap = $public->request('/sitemap.xml');
$check($sitemap['status'] === 200 && str_contains($sitemap['headers'], 'Content-Type: application/xml'), 'sitemap.xml is XML: ' . $sitemap['status']);
$sitemapDoc = new DOMDocument();
$check($sitemapDoc->loadXML($sitemap['body']) && $sitemapDoc->getElementsByTagName('url')->length > 1, 'sitemap.xml is well-formed and lists pages');
$check(str_contains($sitemap['body'], '<loc>http://127.0.0.1:8080/</loc>'), 'sitemap.xml lists the home page with the address of the request');
$check(str_contains($sitemap['body'], 'hreflang="cs" href="http://127.0.0.1:8080/cs/'), 'sitemap.xml lists a translated page in Czech with alternates');
$check(!str_contains($sitemap['body'], '/login/'), 'sitemap.xml leaves out the excluded login page');
$check(!str_contains($sitemap['headers'], 'X-WBengine-Cache: HIT'), 'sitemap.xml is not served from the page cache');
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
$storyType = array_values(array_filter($capabilityBody['data']['box_types'] ?? [], static fn($t) => ($t['type'] ?? '') === 'story'))[0] ?? [];
$check(($storyType['renders'] ?? null) === 'article', 'The story box type is registered as a renderer of articles');
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
