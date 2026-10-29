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
        $this->setVariable('gaId', self::analyticsMeasurementId());
        if ($user && $user->getUserIsLogged()) {
            $this->setVariable('logoutToken', $app->getCsrf()->token('auth.logout'));
        }
        return $this;
    }

    /**
     * The Google Analytics measurement id from "googleAnalytics.measurementId" in Settings.json.
     * An empty, missing or malformed value returns '' and the layout then renders no consent banner
     * and no analytics script.
     */
    public static function analyticsMeasurementId(): string
    {
        $settings = \Wbengine\Config::$config;
        $id = is_object($settings) ? ($settings->googleAnalytics->measurementId ?? '') : '';
        return (is_string($id) && preg_match('/^G-[A-Z0-9]{4,20}$/', $id)) ? $id : '';
    }
}
