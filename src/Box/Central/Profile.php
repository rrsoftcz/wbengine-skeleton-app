<?php

namespace App\Box\Central;

use Wbengine\Api\Model\ApiUserModel;
use Wbengine\Box\WbengineBoxAbstract;
use Wbengine\User\Role;

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

        // The role is read from the database, so demoting an account hides the link at once.
        $admin = false;
        if ($logged) {
            $actor = (new ApiUserModel())->getAuthorization((int) $user->getUserId());
            $admin = $actor && Role::atLeast($actor['role'], Role::ADMIN);
        }

        // The template reads this array as {$Profile.email} (named after the box method).
        return $this->getRenderer()->render($this->getBoxTemplatePath(), array(
            'logged' => $logged,
            'email' => $logged ? $user->getUserEmail() : '',
            'admin' => $admin,
        ));
    }
}
