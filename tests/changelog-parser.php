<?php

declare(strict_types=1);

// The changelog page reads CHANGELOG.md of the framework package. This checks the parser on a sample that has every
// shape the file uses, and on the changelog that is really installed.
require dirname(__DIR__) . '/vendor/autoload.php';

use App\Changelog\Parser;

$fail = static function (string $message): never { throw new RuntimeException($message); };
$expect = static function (bool $ok, string $message) use ($fail): void { if (!$ok) { $fail($message); } };

$sample = <<<'MD'
# Changelog

Intro text.

## [Unreleased]

### Added

- Not released yet.

## [6.7.0] - 2026-11-01

### Added

- First entry
  continued on a second line.
- Second entry with `code`.

### Fixed

- A fix.

## [5.0.0] - 2026-10-30

### Removed (breaking)

- Something old.

## [4.0.2] - 2026-10-27

### Fixed

- Older fix.

### Template engine

A paragraph that is not a bullet.

## [4.0.1] - 2026-10-26

### Tests found real bugs

- Another.

## [3.0.0] - 2025-08-27

Initial documented release, see the git history.
MD;
$releases = Parser::releases($sample);
$expect(count($releases) === 5, 'five releases, Unreleased left out: ' . count($releases));
$expect(array_column($releases, 'version') === ['6.7.0', '5.0.0', '4.0.2', '4.0.1', '3.0.0'], 'newest first, as written');
$expect($releases[4]['groups'] === [['name' => 'Notes', 'entries' => ['Initial documented release, see the git history.']]], 'a release that is a sentence gets a Notes group');
$expect($releases[0]['date'] === '2026-11-01', 'the date is read');
$expect($releases[0]['recent'] === true && $releases[1]['recent'] === true && $releases[2]['recent'] === false, 'recent from 5.0.0');
$expect(array_column($releases[0]['groups'], 'name') === ['Added', 'Fixed'], 'groups in order');
$expect($releases[0]['groups'][0]['entries'] === ["First entry\ncontinued on a second line.", 'Second entry with `code`.'], 'a bullet continues on indented lines');
$expect($releases[1]['groups'][0]['name'] === 'Removed (breaking)', 'a breaking group keeps its marker');
$expect($releases[2]['groups'][1]['entries'] === ['A paragraph that is not a bullet.'], 'a paragraph is an entry');
$expect(!str_contains(json_encode($releases), 'Not released yet'), 'Unreleased is not listed');
$expect(Parser::releases('') === [] && Parser::releases("## [x] - y\n- z") === [], 'nothing and nonsense give no releases');

$installed = dirname(__DIR__) . '/vendor/wbengine/wbengine/CHANGELOG.md';
$expect(is_file($installed), 'the installed framework ships CHANGELOG.md');
$real = Parser::releases((string) file_get_contents($installed));
$expect(count($real) >= 30, 'the real changelog lists its releases: ' . count($real));
$expect(version_compare($real[0]['version'], $real[1]['version'], '>'), 'the real changelog is newest first');
foreach ($real as $release) {
    $expect($release['groups'] !== [], 'release ' . $release['version'] . ' has entries');
    foreach ($release['groups'] as $group) { $expect($group['entries'] !== [] && $group['name'] !== '', 'a group of ' . $release['version'] . ' is not empty'); }
}
echo 'changelog parser: ok (' . count($real) . " releases in the installed framework)\n";
