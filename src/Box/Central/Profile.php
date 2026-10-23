<?php

namespace App\Box\Central;

use Wbengine\Box\WbengineBoxAbstract;

/**
 * Profile of the logged in user (site "/profile/", requires login via the site's acl).
 */
class Profile extends WbengineBoxAbstract
{
    /**
     * @return string
     * @throws \Wbengine\Exception\RuntimeException
     */
    public function Profile()
    {
        $user = $this->getSite()->getUser();
        $logged = $user->isLogged() === true;

        // The template reads this array as {$Profile.email} (named after the box method).
        return $this->getRenderer()->render($this->getBoxTemplatePath(), array(
            'logged' => $logged,
            'email' => $logged ? $user->getUserEmail() : '',
        ));
    }
}
