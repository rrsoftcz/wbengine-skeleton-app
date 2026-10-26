<?php

namespace App\Box\Central;

use Wbengine\Box\WbengineBoxAbstract;

/**
 * The documentation pages. Each page is a row of cms_sites with an article in cms_articles
 * (the text, translated through cms_article_translations), so the pages are content, not code:
 * adding one needs no PHP, only rows and an entry in the list below for the sidebar.
 */
class Docs extends WbengineBoxAbstract
{
    /**
     * Url and catalog key of every documentation page, in reading order.
     */
    const PAGES = array(
        array('/docs/', 'doc.getting_started'),
        array('/docs/architecture/', 'doc.architecture'),
        array('/docs/boxes/', 'doc.boxes'),
        array('/docs/templates/', 'doc.templates'),
        array('/docs/languages/', 'doc.languages'),
        array('/docs/caching/', 'doc.caching'),
        array('/docs/security/', 'doc.security'),
        array('/docs/rest-api/', 'doc.rest_api'),
    );

    /**
     * An article with the sidebar and the previous and next page.
     * The template reads the data as {$Page.article->title}, {$Page.nav} and so on.
     *
     * @return string
     * @throws \Wbengine\Exception\RuntimeException
     */
    public function Page()
    {
        $article = $this->getModel('App\Box\Central\Article')->getArticleRow();
        $format = $article->content_format ?? 'legacy_html';
        if (!in_array($format, array('legacy_html', 'markdown'), true)) {
            throw new \UnexpectedValueException('Unknown article content format.');
        }
        if ($format === 'markdown') {
            $markdown = $this->getSite()->getParent()->getMarkdown();
            foreach (array('introtext', 'bodytext') as $field) {
                $article->$field = $markdown->render((string) ($article->$field ?? ''));
            }
        }

        $current = strtolower((string) $this->getSite()->getUrl());
        $nav = array();
        $index = -1;
        foreach (self::PAGES as $i => $page) {
            $active = strtolower($page[0]) === $current;
            if ($active) {
                $index = $i;
            }
            $nav[] = array('link' => $page[0], 'key' => $page[1], 'active' => $active, 'number' => $i + 1);
        }

        return $this->getRenderer()->render($this->getBoxTemplatePath(), array(
            'article' => $article,
            'nav' => $nav,
            'prev' => $index > 0 ? $nav[$index - 1] : null,
            'next' => ($index >= 0 && $index < count($nav) - 1) ? $nav[$index + 1] : null,
        ));
    }
}
