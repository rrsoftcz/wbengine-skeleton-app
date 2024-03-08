<?php
/**
 * Created by PhpStorm.
 * User: roza
 * Date: 06/07/2018
 * Time: 12:01
 */

namespace App\Box\Central;

use Wbengine\Box\Auth;
use Wbengine\Box\WbengineBoxAbstract;


class Login extends WbengineBoxAbstract
{
    /**
     * @return string
     * @throws \Wbengine\Exception\RuntimeException
     */
    public function Login(){
        $loginBox = new Auth($this);
        return $loginBox->getLoginBox();
    }
}