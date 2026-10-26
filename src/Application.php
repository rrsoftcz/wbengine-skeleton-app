<?php
namespace App;

/** Application-specific lazy Site service, configured before request execution. */
class Application extends \Wbengine\Application\Application
{
    private ?Site $applicationSite = null;

    public function getSite()
    {
        return $this->applicationSite ??= new Site($this);
    }
}
