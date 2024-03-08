<?php
namespace App\Box\Header;

use Wbengine\Box\WbengineBoxAbstract;
class Jumbotron extends WbengineBoxAbstract
{
    /**
     * Return HTML Jumbotron box (from header section)
     * @return string
     * @throws \Wbengine\Exception\RuntimeException
     */
    public function Jumbotron()
    {
        return $this->getRenderer()->render($this->getBoxTemplatePath());
    }
}