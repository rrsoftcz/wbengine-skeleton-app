<?php

namespace App\Box\Central;

/**
 * Integration keys for the central WBengine Admin (site "/integrations/", login required).
 * The framework box checks the ADMIN role in the database and handles every request; it needs
 * the first WBengine release after 4.1.0 and migrations/4.0.0/007 of the framework (last_used_at).
 */
class Integrations extends \Wbengine\Box\Integrations
{
}
