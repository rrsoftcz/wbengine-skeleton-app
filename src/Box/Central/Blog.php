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
        $story = $this->getModel(__CLASS__)->getArticleRow();
        return $this->getRenderer()->render($this->getBoxTemplatePath(), $story);
    }
}