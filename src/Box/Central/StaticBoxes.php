<?php
namespace App\Box\Central;

use Wbengine\Box\WbengineBoxAbstract;
class StaticBoxes extends WbengineBoxAbstract
{
    /**
     * Return static HTML About box (from Central section)
     * @return string
     * @throws \Wbengine\Exception\RuntimeException
     */
    public function About()
    {
        return $this->getRenderer()->render($this->getBoxTemplatePath());
    }

    /**
     * The feature overview of the home page.
     * @return string
     * @throws \Wbengine\Exception\RuntimeException
     */
    public function Features()
    {
        return $this->getRenderer()->render($this->getBoxTemplatePath());
    }
}
