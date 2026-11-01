<?php

namespace App\Box\Central;

use App\Changelog\Parser;
use Wbengine\Box\WbengineBoxAbstract;
use Wbengine\I18n;

/**
 * The page /changelog/: the releases of the framework that renders this site, read from the CHANGELOG.md that
 * ships inside the framework package (no network). The entries are Markdown and go through the same safe
 * renderer as the articles.
 */
class Changelog extends WbengineBoxAbstract
{
    /** The groups of the changelog and the catalog key of their name. */
    private const GROUPS = ['Added' => 'added', 'Changed' => 'changed', 'Deprecated' => 'deprecated', 'Removed' => 'removed', 'Fixed' => 'fixed', 'Security' => 'security', 'Documentation' => 'documentation', 'Upgrade notes' => 'upgrade', 'Notes' => 'notes'];

    public function Releases()
    {
        $releases = Parser::releases($this->source());
        $markdown = $this->getSite()->getParent()->getMarkdown();
        $view = ['recent' => [], 'older' => []];
        foreach ($releases as $release) {
            $groups = [];
            foreach ($release['groups'] as $group) {
                $breaking = str_ends_with($group['name'], ' (breaking)');
                $base = $breaking ? substr($group['name'], 0, -strlen(' (breaking)')) : $group['name'];
                $label = isset(self::GROUPS[$base]) ? I18n::t('changelog.group.' . self::GROUPS[$base]) : $base;
                $groups[] = [
                    'label' => $label . ($breaking ? ' (' . I18n::t('changelog.breaking') . ')' : ''),
                    'entries' => array_map(static fn(string $text): string => $markdown->render($text), $group['entries']),
                ];
            }
            $view[$release['recent'] ? 'recent' : 'older'][] = ['version' => $release['version'], 'date' => $release['date'], 'groups' => $groups];
        }
        $view['available'] = [] !== $releases;
        // The layout variable is not visible inside a box template, so the box passes the version itself.
        $view['version'] = \Wbengine\Version::current();
        return $this->getRenderer()->render($this->getBoxTemplatePath(), $view);
    }

    /** The changelog of the installed framework, empty when the package does not ship it. */
    private function source(): string
    {
        $path = class_exists(\Composer\InstalledVersions::class) ? \Composer\InstalledVersions::getInstallPath('wbengine/wbengine') : null;
        $file = null === $path ? '' : rtrim($path, '/') . '/CHANGELOG.md';
        return '' !== $file && is_file($file) ? (string) file_get_contents($file) : '';
    }
}
