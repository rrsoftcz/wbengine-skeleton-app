-- Repair for installations that applied the first version of migration 013: the framework resolves only
-- pages with visible = 1 (Site\SiteModel::loadSiteData), so /integrations/ answered 404 for everyone.
-- Safe to run more than once. Back up before applying.
UPDATE cms_sites SET visible = 1 WHERE link = '/integrations/' AND visible = 0;
