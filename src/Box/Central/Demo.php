<?php

namespace App\Box\Central;

use Wbengine\Cache;
use Wbengine\Config;
use Wbengine\Db;
use Wbengine\I18n;
use Wbengine\Box\WbengineBoxAbstract;

/**
 * Live demonstrations placed under the documentation articles. They are ordinary dynamic
 * boxes: the page of an article shows how the feature works, and the box right below it
 * shows the feature working on this very request. Each one is a cms_boxes row of the page.
 */
class Demo extends WbengineBoxAbstract
{
    /**
     * The boxes that built this page, read from the same table the framework reads.
     */
    public function Structure()
    {
        $site = $this->getSite();
        // "sites" is a JSON array of site ids written as text, for example ["12"].
        $boxes = Db::fetchAllAssoc(
            'SELECT b.name, b.module, b.method, b.shared, b.`order`, s.`key` AS section
               FROM cms_boxes b
               JOIN cms_sections s ON s.section_id = b.section_id
              WHERE s.active = 1 AND (b.shared = 1 OR JSON_CONTAINS(b.sites, ?))
              ORDER BY s.section_id, b.`order`',
            array(json_encode((string) $site->getSiteId()))
        );

        return $this->getRenderer()->render($this->getBoxTemplatePath(), array(
            'siteId' => (int) $site->getSiteId(),
            'url' => (string) $site->getUrl(),
            'boxes' => $boxes,
        ));
    }

    /**
     * Template syntax next to its result, rendered by the template engine right here.
     */
    public function Templates()
    {
        return $this->getRenderer()->render($this->getBoxTemplatePath(), array(
            // Hostile on purpose: the engine escapes it, so it is shown, not run.
            'hostile' => '<script>alert("x")</script> Tom & "Jerry"',
            'html' => '<strong>trusted</strong> markup',
            'name' => null,
            'items' => array('Site', 'Section', 'Box'),
            'price' => 1234.5,
            'time' => time(),
            'text' => 'WBengine compiles templates to plain PHP',
        ));
    }

    /**
     * What the language of this request is, and how it formats numbers, dates and plurals.
     */
    public function Languages()
    {
        $locales = array();
        foreach (I18n::locales() as $code) {
            $locales[] = array('code' => $code, 'url' => I18n::url('/docs/languages/', $code));
        }

        return $this->getRenderer()->render($this->getBoxTemplatePath(), array(
            'locale' => I18n::locale(),
            'language' => I18n::language(),
            'locales' => $locales,
            'counts' => array(0, 1, 2, 5, 22, 100),
            'price' => 1234567.891,
            'time' => time(),
            'cookie' => isset($_COOKIE['wb_locale']) ? (string) $_COOKIE['wb_locale'] : '',
            'accept' => isset($_SERVER['HTTP_ACCEPT_LANGUAGE']) ? (string) $_SERVER['HTTP_ACCEPT_LANGUAGE'] : '',
        ));
    }

    /**
     * When this page was built and how much it cost. With the page cache on, a reload shows
     * the same time: the page was not built again.
     */
    public function Caching()
    {
        $settings = Config::getCacheSettings();
        $pages = isset($settings['pages']) ? (array) $settings['pages'] : array();

        return $this->getRenderer()->render($this->getBoxTemplatePath(), array(
            'built' => date('H:i:s'),
            'ms' => round((microtime(true) - $_SERVER['REQUEST_TIME_FLOAT']) * 1000, 1),
            'queries' => Db::getQueriesCount(),
            'dataCache' => Cache::isEnabled(),
            'driver' => isset($settings['driver']) ? (string) $settings['driver'] : '',
            'pageCache' => !empty($pages['enabled']),
            'ttl' => isset($pages['ttl']) ? (int) $pages['ttl'] : 0,
        ));
    }

    /**
     * A small console that calls the REST API of this application from the browser.
     */
    public function Api()
    {
        return $this->getRenderer()->render($this->getBoxTemplatePath());
    }
}
