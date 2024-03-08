<?php
/**
 * Created by PhpStorm.
 * User: roza
 * Date: 09.10.17
 * Time: 17:52
 */

namespace App\Box\Api;

use Wbengine\Box\WbengineBoxAbstract;
use Wbengine\Router;
use Wbengine\Application\Env\Http;

class Restapi extends WbengineBoxAbstract
{
    public function Restapi()
    {
        try {

            Router::get('/api/', function () {
                $this->Api()->toString('Blog Rest API v1.0');
            });

            Router::post('/api/sections/', function () {
                return $this->Api()->Section()->addNewSection(Http::Json(true));
            });

            Router::put('/api/sections/{id}/', function (Router\Route $route) {
                return $this->Api()->Section()->updateSection($route->getParams('id'), Http::Json(true));
            });

            Router::delete('/api/sections/{id}/', function (Router\Route $route) {
                return $this->Api()->Section()->deleteSection($route->getParams('id'));
            });

            Router::get('/api/sections/active', function () {
                return $this->Api()->Section()->getSections(true);
            });

            Router::get('/api/sections/', function () {
                return $this->Api()->Section()->getSections();
            });

            Router::get('/api/sections/{id}/', function (Router\Route $route) {
                return $this->Api()->Section()->getSectionById($route->getParams('id'));
            });

            header("HTTP/1.0 404 Not Found", null, 404);

            $this->Api()->getApiError('404 Not Found');

        } catch (\Exception $e) {
            $this->Api()->getApiError($e->getMessage());
        }
    }

}