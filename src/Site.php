<?php
namespace App;

/** Layout data is prepared after the framework's route/page-cache gate. */
class Site extends \Wbengine\Site
{
    public function initialize($app)
    {
        parent::initialize($app);
        if (!$this->isLoaded()) { return $this; }
        // Ordinary anonymous pages do not need a session or user lookup.
        $user = isset($_COOKIE[session_name()]) ? $app->getClassUser() : null;
        $this->setVariable('user', $user);
        if ($user && $user->getUserIsLogged()) {
            $this->setVariable('logoutToken', $app->getCsrf()->token('auth.logout'));
        }
        return $this;
    }
}
