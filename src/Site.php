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
        $this->setVariable('skeleton_version', self::skeletonVersion());
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

    /**
     * The release number of this skeleton application from the VERSION file in the project root (for example "1.1.0").
     * A missing or malformed file returns '' and the footer then shows no version.
     */
    public static function skeletonVersion(): string
    {
        static $version = null;
        if ($version === null) {
            $raw = is_file(dirname(__DIR__) . '/VERSION') ? trim((string) file_get_contents(dirname(__DIR__) . '/VERSION')) : '';
            $version = preg_match('/^\d+\.\d+\.\d+$/D', $raw) === 1 ? $raw : '';
        }
        return $version;
    }
}
