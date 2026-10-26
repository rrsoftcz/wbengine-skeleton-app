<?php
namespace App\Box\Central;

use Wbengine\Box\Article;
use Wbengine\Box\WbengineBoxAbstract;

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
}
