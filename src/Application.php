<?php
namespace App;

use Wbengine\Api\V2\BoxRegistry;

/** Application-specific lazy Site service, configured before request execution. */
class Application extends \Wbengine\Application\Application
{
    private ?Site $applicationSite = null;

    public function __construct($appBaseDir, $nameSpace = null)
    {
        parent::__construct($appBaseDir, $nameSpace = null);
        // Before run(): API v2 requests are answered early, so the catalog must already be filled.
        self::registerBoxTypes(BoxRegistry::current());
    }

    /**
     * Box types that WBengine Admin may add to a page through API v2. Only the website
     * itself registers executable module and method pairs; HTTP input selects a type ID.
     * Add your own box here: register($type, $module, $method, $settings, $sections).
     */
    public static function registerBoxTypes(BoxRegistry $registry): void
    {
        // The registry throws on a duplicate, so register only what is missing.
        if (null === $registry->typeFor('blog', 'story')) {
            $registry->register('story', 'blog', 'story', [], ['central']);
        }
    }

    public function getSite()
    {
        return $this->applicationSite ??= new Site($this);
    }
}
