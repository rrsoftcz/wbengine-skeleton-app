<?php

namespace App\Changelog;

/**
 * Reads the CHANGELOG.md of the framework: one section `## [x.y.z] - YYYY-MM-DD` per release, newest first,
 * groups as `### Added`, entries as bullets (a bullet may continue on indented lines). The framework checks that
 * shape in its own tests, because this page depends on it. Unreleased is left out, a heading that is not a
 * release ends the list of releases it was in.
 */
final class Parser
{
    /** The first major version whose releases are shown open: older ones are collapsed on the page. */
    public const RECENT_FROM = '5.0.0';

    /**
     * @return list<array{version: string, date: string, recent: bool, groups: list<array{name: string, entries: list<string>}>}>
     */
    public static function releases(string $markdown): array
    {
        $releases = [];
        $release = null;
        $group = null;
        $entry = null;
        $close = static function () use (&$entry, &$group): void {
            if (null !== $entry && null !== $group) { $group['entries'][] = trim(implode("\n", $entry)); }
            $entry = null;
        };
        $finish = static function () use (&$release, &$group, &$releases, &$close): void {
            $close();
            if (null !== $group && null !== $release && [] !== $group['entries']) { $release['groups'][] = $group; }
            $group = null;
            if (null !== $release) { $releases[] = $release; }
            $release = null;
        };
        foreach (preg_split('/\R/', $markdown) ?: [] as $line) {
            if (str_starts_with($line, '## ')) {
                $finish();
                if (preg_match('/^## \[(\d+\.\d+\.\d+)\] - (\d{4}-\d{2}-\d{2})\s*$/D', $line, $m)) {
                    $release = ['version' => $m[1], 'date' => $m[2], 'recent' => version_compare($m[1], self::RECENT_FROM, '>='), 'groups' => []];
                }
                continue;
            }
            if (null === $release) { continue; }
            if (str_starts_with($line, '### ')) {
                $close();
                if (null !== $group && [] !== $group['entries']) { $release['groups'][] = $group; }
                $group = ['name' => trim(substr($line, 4)), 'entries' => []];
                continue;
            }
            // A release that is only a sentence (the first documented one) gets one group, Notes.
            if (null === $group) {
                if ('' === trim($line)) { continue; }
                $group = ['name' => 'Notes', 'entries' => []];
            }
            if (str_starts_with($line, '- ')) { $close(); $entry = [substr($line, 2)]; }
            elseif ('' === trim($line)) { $close(); }
            elseif (null !== $entry && (str_starts_with($line, '  ') || str_starts_with($line, "\t"))) { $entry[] = preg_replace('/^(  |\t)/', '', $line); }
            else { $close(); $entry = [$line]; }
        }
        $finish();
        return $releases;
    }
}
