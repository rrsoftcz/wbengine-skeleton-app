<?php

namespace App\Box\Central;

/**
 * Integration keys for the central WBengine Admin (site "/integrations/", login required).
 * The framework box checks the ADMIN role in the database and handles every request; it needs
 * the framework database updates (sh bin/update-database.sh). `vendor/bin/wbengine.php integrations:install`
 * creates this class, the page and the box record on a site that lacks them.
 */
class Integrations extends \Wbengine\Box\Integrations
{
}
