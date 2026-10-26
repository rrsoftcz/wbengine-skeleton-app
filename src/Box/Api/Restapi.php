<?php

namespace App\Box\Api;

use Wbengine\Api;
use Wbengine\Box\WbengineBoxAbstract;

/**
 * REST API box (section "api", site "/api/").
 *
 * The framework registers and dispatches the API modules (auth, users, sections).
 * V1 protected resources require JWT. V2 exposes minimal discovery and uses
 * scoped integration keys for remote administration.
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
