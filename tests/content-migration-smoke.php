<?php

declare(strict_types=1);

use Wbengine\Application\Path\File;
use Wbengine\Config;
use Wbengine\Content\Migration\HtmlConverter;
use Wbengine\Content\Migration\Migrator;
use Wbengine\Content\Migration\Model;
use Wbengine\Db;

// Exercise actual seed content on connection-local shadows, never on source tables.
if (getenv('WBENGINE_SMOKE') !== '1') {
    throw new RuntimeException('Run only in the isolated smoke Compose project');
}

require dirname(__DIR__) . '/vendor/autoload.php';
require_once dirname(__DIR__) . '/vendor/wbengine/wbengine/Application/Env/Const.php';

function checkContentMigration(bool $condition, string $message): void
{
    if (!$condition) {
        throw new RuntimeException($message);
    }
}

function sourceSnapshot(string $table, string $order): array
{
    return Db::fetchAllAssoc('SELECT * FROM ' . Db::identifier($table) . ' ORDER BY ' . $order);
}

function sourceSchema(string $table): string
{
    return Db::fetchAssoc('SHOW CREATE TABLE ' . Db::identifier($table))['Create Table'];
}

function issueCategory(string $issue): string
{
    $issue = preg_replace('/^(introtext|bodytext): /', '', $issue);
    foreach ([
        'Unsupported element', 'Unsupported attribute', 'HTML parser repair required',
        'Rendered Markdown does not preserve', 'Comments or processing instructions',
        'Document declarations', 'Only explicit legacy_html', 'Unsafe or unsupported URL',
    ] as $category) {
        if (str_starts_with($issue, $category)) {
            return $category;
        }
    }
    return 'Other manual repair';
}

try {
    $configPath = dirname(__DIR__) . '/src/Config/Settings.json';
    $settings = json_decode(file_get_contents($configPath), true, 512, JSON_THROW_ON_ERROR);
    checkContentMigration(($settings['dbAdapterDefinition']['database'] ?? null) === 'wbengine_skeleton_app', 'Unexpected configured database');
    checkContentMigration(($settings['dbAdapterDefinition']['hostname'] ?? null) === 'db', 'Unexpected configured database host');
    checkContentMigration(($settings['cache']['dir'] ?? null) === '/tmp/wbengine-skeleton-smoke-cache', 'Unexpected smoke cache directory');
    Config::load(new File($configPath));
    checkContentMigration(Db::fetchAssoc('SELECT DATABASE() AS name')['name'] === 'wbengine_skeleton_app', 'Unexpected connected database');

    $originalTables = ['cms_articles' => '`id`', 'cms_article_translations' => '`article_id`, BINARY `locale`'];
    $originals = [];
    $schemas = [];
    foreach ($originalTables as $table => $order) {
        $originals[$table] = sourceSnapshot($table, $order);
        $schemas[$table] = sourceSchema($table);
    }
    checkContentMigration(count($originals['cms_articles']) === 9, 'Expected the nine actual skeleton source articles');
    $sourceHash = Model::hash($originals);

    $articles = 'smoke_content_articles';
    $translations = 'smoke_content_translations';
    $ledger = 'smoke_content_migrations';
    foreach ([$articles => 'cms_articles', $translations => 'cms_article_translations'] as $shadow => $source) {
        Db::query('CREATE TEMPORARY TABLE ' . Db::identifier($shadow) . ' LIKE ' . Db::identifier($source));
        Db::query('ALTER TABLE ' . Db::identifier($shadow) . ' ENGINE=InnoDB');
        Db::query('INSERT INTO ' . Db::identifier($shadow) . ' SELECT * FROM ' . Db::identifier($source));
        $columns = array_column(Db::fetchAllAssoc('SHOW COLUMNS FROM ' . Db::identifier($shadow)), 'Field');
        if (!in_array('content_format', $columns, true)) {
            Db::query('ALTER TABLE ' . Db::identifier($shadow) . " ADD content_format VARCHAR(16) NOT NULL DEFAULT 'legacy_html'");
        }
    }
    $ledgerSql = file_get_contents(dirname(__DIR__) . '/vendor/wbengine/wbengine/migrations/4.0.0/004-content-migration-ledger.sql');
    $ledgerSql = preg_replace('/CREATE TABLE cms_content_migrations\b/', 'CREATE TEMPORARY TABLE ' . Db::identifier($ledger), $ledgerSql, 1, $replacements);
    checkContentMigration($replacements === 1, 'Expected the core MD-03 ledger schema');
    Db::query($ledgerSql);

    $model = new Model($articles, $translations, $ledger);
    $migrator = new Migrator($model, new HtmlConverter());
    $shadowBefore = [sourceSnapshot($articles, '`id`'), sourceSnapshot($translations, '`article_id`, BINARY `locale`')];
    $plans = [];
    foreach ($originals['cms_articles'] as $article) {
        // The source SQL stores HTML fragments. A Texy mention inside prose/code is
        // not evidence of Texy source. Never infer a converter from content strings.
        array_push($plans, ...$migrator->planArticle((int) $article['id'], 'html'));
    }
    checkContentMigration(count($plans) === count($originals['cms_articles']) + count($originals['cms_article_translations']), 'Every actual article and translation must receive a plan');
    checkContentMigration($shadowBefore === [sourceSnapshot($articles, '`id`'), sourceSnapshot($translations, '`article_id`, BINARY `locale`')], 'Dry run changed shadow data');
    checkContentMigration((int) Db::fetchAssoc('SELECT COUNT(*) AS count FROM ' . Db::identifier($ledger))['count'] === 0, 'Dry run wrote a ledger entry');

    $safe = [];
    $manual = [];
    $categories = [];
    $manualIssueCount = 0;
    foreach ($plans as $plan) {
        $id = $plan['article_id'];
        $locale = $plan['locale'];
        $identity = (string) $id . ($locale === null ? '' : ':' . $locale);
        $before = $model->read($plan['entity'], $id, $locale);
        checkContentMigration($before === $plan['before'], 'Plan did not preserve original bytes, format and nulls');
        if ($plan['safe']) {
            $migrationId = $migrator->apply($plan, $plan['approval_hash']);
            checkContentMigration($model->read($plan['entity'], $id, $locale) === $plan['after'], 'Applied data differs from the approved plan');
            checkContentMigration($migrator->rollback($migrationId), 'Expected a successful rollback');
            checkContentMigration($model->read($plan['entity'], $id, $locale) === $before, 'Rollback did not restore exact original bytes, format and nulls');
            $backup = $model->backup($migrationId);
            checkContentMigration($backup !== null && $backup['rolled_back_at'] !== null, 'Rollback was not recorded');
            $safe[] = $identity;
        } else {
            $manual[] = $identity;
            $manualIssueCount += count($plan['issues']);
            foreach ($plan['issues'] as $issue) {
                $category = issueCategory($issue);
                $categories[$category] = ($categories[$category] ?? 0) + 1;
            }
            checkContentMigration($model->read($plan['entity'], $id, $locale) === $before, 'Manual-repair content changed');
            checkContentMigration($model->backup($plan['approval_hash']) === null, 'Manual-repair content received a ledger entry');
        }
    }
    checkContentMigration($shadowBefore === [sourceSnapshot($articles, '`id`'), sourceSnapshot($translations, '`article_id`, BINARY `locale`')], 'Final shadow data differs from its original copy');
    $after = [];
    foreach ($originalTables as $table => $order) {
        $after[$table] = sourceSnapshot($table, $order);
        checkContentMigration($schemas[$table] === sourceSchema($table), 'Original schema changed');
    }
    checkContentMigration($originals === $after && hash_equals($sourceHash, Model::hash($after)), 'Original source rows changed');
    ksort($categories);
    echo json_encode([
        'articles' => count($originals['cms_articles']),
        'translations' => count($originals['cms_article_translations']),
        'dry_run_plans' => count($plans),
        'safe_apply_rollback_count' => count($safe),
        'safe_ids' => $safe,
        'manual_count' => count($manual),
        'manual_ids' => $manual,
        'manual_issue_count' => $manualIssueCount,
        'manual_issue_categories' => $categories,
        'original_row_hash_checks' => 1,
        'original_schema_checks' => count($originalTables),
    ], JSON_PRETTY_PRINT | JSON_THROW_ON_ERROR) . "\n";
} catch (Throwable $error) {
    // Database/converter errors can embed content or credentials. Keep CI output safe.
    fwrite(STDERR, 'Content migration smoke failed (' . get_class($error) . ").\n");
    exit(1);
}
