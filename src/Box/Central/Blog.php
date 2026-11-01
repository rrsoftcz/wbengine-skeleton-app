<?php
namespace App\Box\Central;

use App\Blog\Excerpt;
use Wbengine\Box\Article;
use Wbengine\Box\WbengineBoxAbstract;
use Wbengine\Content\ArticleVisibility;
use Wbengine\Db;
use Wbengine\I18n;
use Wbengine\I18n\ContentTranslations;

class Blog extends WbengineBoxAbstract
{
    /**
     * STORY BOX EXAMPLE
     * Return story content from table article
     * This is a Wbeingine story box implementation
     *
     * @return string
     * @throws \Wbengine\Box\Exception\BoxException
     * @throws \Wbengine\Exception\RuntimeException
     */
    public function Story()
    {
        $story = new Article($this);
        return $story->getArticleBox();
    }


    /**
     * STORY BOX EXAMPLE
     * Return story content from table article
     * This is a local application box implementation
     *
     * @return string
     * @throws \Wbengine\Box\Exception\BoxException
     * @throws \Wbengine\Exception\RuntimeException
     */
    public function LocalStoryBox()
    {
        $story = $this->getModel('App\Box\Central\Article')->getArticleRow();
        $format = $story->content_format ?? 'legacy_html';
        if (!in_array($format, array('legacy_html', 'markdown'), true)) {
            throw new \UnexpectedValueException('Unknown article content format.');
        }
        if ($format === 'markdown') {
            $markdown = $this->getSite()->getParent()->getMarkdown();
            foreach (array('introtext', 'bodytext') as $field) {
                $story->$field = $markdown->render((string) ($story->$field ?? ''));
            }
        }
        return $this->getRenderer()->render($this->getBoxTemplatePath(), $story);
    }
    /** How many posts are listed under Newest with an excerpt, under Most read, and at most in All posts. */
    private const NEWEST = 6;
    private const POPULAR = 3;
    private const ALL = 100;

    /**
     * The overview of the blog on /blog/: the newest posts with an excerpt, the most read ones and the list of all of
     * them. A post is an article on a page under /blog/ that a visitor can open (visible, public, not hidden).
     * One query, the translations are applied to the whole list at once.
     *
     * @return string
     */
    public function Overview()
    {
        $sql = sprintf('SELECT a.id, a.site_id, a.title, a.introtext, a.content_format, a.published, a.author, a.views, s.link
                        FROM %s a JOIN %s s ON s.site_id = a.site_id
                        WHERE s.link LIKE ? AND s.link <> ? AND s.visible = 1 AND COALESCE(s.acl, 0) = 0 AND a.published > 0%s
                        ORDER BY a.published DESC, a.id DESC LIMIT %d',
            S_TABLE_ARTICLES, S_TABLE_SITES, ArticleVisibility::isSupported() ? ' AND a.hidden = 0' : '', self::ALL);
        $rows = ContentTranslations::overlayRows('article', Db::fetchAllAssoc($sql, array('/blog/%', '/blog/')));
        $markdown = $this->getSite()->getParent()->getMarkdown();

        $posts = array();
        foreach ($rows as $row) {
            $intro = (string) ($row['introtext'] ?? '');
            $html = ($row['content_format'] ?? 'legacy_html') === 'markdown' ? $markdown->render($intro) : $intro;
            $posts[] = array(
                'id' => (int) $row['id'],
                'link' => (string) $row['link'],
                'title' => (string) $row['title'],
                'excerpt' => Excerpt::plain($html),
                'date' => I18n::date((int) $row['published'], 'long'),
                'author' => (string) ($row['author'] ?? ''),
                'views' => (int) $row['views'],
            );
        }
        $popular = array_values(array_filter($posts, static fn(array $p): bool => $p['views'] > 0));
        usort($popular, static fn(array $a, array $b): int => [$b['views'], $b['id']] <=> [$a['views'], $a['id']]);

        return $this->getRenderer()->render($this->getBoxTemplatePath(), array(
            'newest' => array_slice($posts, 0, self::NEWEST),
            'popular' => array_slice($popular, 0, self::POPULAR),
            'all' => $posts,
            'count' => count($posts),
        ));
    }
}
