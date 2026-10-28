<?php

namespace App\Box\Central;

/**
 * Integration keys for the central WBengine Admin (site "/integrations/", login required).
 * The framework box checks the ADMIN role in the database and handles every request; it needs
 * WBengine 4.0.3 or newer and migrations/4.0.3/001 of the framework (last_used_at).
 */
class Integrations extends \Wbengine\Box\Integrations
{
}
