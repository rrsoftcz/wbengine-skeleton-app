<?php

namespace App\Box\Api;

use Wbengine\Api;
use Wbengine\Box\WbengineBoxAbstract;

/**
 * REST API box (section "api", site "/api/").
 *
 * The framework registers and dispatches the API modules (auth, users, sections).
 * Every route except /api/auth/login requires a valid JWT bearer token.
 */
class Restapi extends WbengineBoxAbstract
{
    /**
     * @throws \Wbengine\Api\Exception\ApiException
     */
    public function Restapi()
    {
        $api = new Api();
        $api->Initialize();
        $api->end();
    }
}
