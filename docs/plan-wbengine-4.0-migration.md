# Migration of the sample application to WBengine 4.0

Status as of 2026-10-27. The WBengine 4 skeleton is deployed on `www.wbengine.org`. The user confirmed the content fix, language switching and English as the default language. Framework `v4.0.2` is locked in the Composer lock; current skeleton commits on `main`: `d2898d5` (language switcher and guide migration) and `45dc494` (English as the default language). Content migration `010` and the settings `i18n.default=en`, `i18n.detect=[url]` were deployed to live according to the user's confirmation. The historical notes below about the undeployed database describe the state at that time and this checkpoint supersedes them.

## DOC-01: public system overview and central administration

2026-10-27: Completed and deployed to live. The Architecture page describes Application → Site → Section → Box → Model/Renderer/Template, the request flow, the split between database and PHP, and the extension procedure. The REST API page distinguishes the existing CMS API `/api/` from the optional server integration API `/api/v2`. The English and Czech pages of the central SvelteKit administration describe its multi-site flow over HTTPS/API v2, roles, proposals, previews, publishing and conflict resolution; they explicitly state the separate distribution and the private source/release. Documentation navigation and the home page are linked together. Migration 011 was applied to live and the user confirmed that the pages work. Production content is not changed automatically during the build.

Acceptance: met according to the user's confirmation after deployment. The documentation does not present the private administration as part of the PHP package; further editorial extensions can be made continuously based on feedback.

The migration project is complete. The two-site pilot of the remote administration is verified in isolated CI and the administration remains a separate SvelteKit project. The next step is to prepare its independent release after the visibility decision and publication approval. Ten historical HTML items left for manual review will be converted only after an editorial decision.

## Google Analytics and cookie consent checkpoint

2026-10-27: The GA4 `G-PRGMM4N3S6` consent flow was verified on the live site: on allow, `gtag.js` loaded and sent a measurement request; after refusal, neither the Google tag nor a measurement request loaded after a reload; allowing again loaded the tag; the following withdrawal of consent led to a reload without the Google tag and measurement. The user's original choice was restored to allowed after the test. The banner is bilingual and stores the choice only in localStorage. Technical verification on live is done. Before the cookie information is marked complete, a privacy policy still needs to be added and published with the verified identity of the controller, purposes, legal basis, retention period, recipients and any international transfers; these legal and operational details cannot be derived from the code.

- [x] Separate worktree and Compose project, no fixed container names and public ports.
- [x] The App Application/Site keep the framework's lazy tree and prepare the layout only after the page-cache gate.
- [x] POST logout with auth.logout CSRF, no GET logout link, diagnostic data only when available.
- [x] Composer target ^4.0 and a separate dev smoke manifest. The ignored local composer.lock was updated to v4.0.0 and the production composer install ran; vendor contains WBengine v4.0.0 without Smarty/Texy. The composer.lock file remains ignored according to the project's existing convention.
- [x] A real HTTP suite of 20 checks green locally. RED first the missing cache HIT because of a premature user/session; then the missing POST logout. The login also revealed a Url null deprecation without an Apache alias, fixed in the framework with a separate regression and commit.
- [x] The CI workflow uses framework tag v4.0.0 and runs isolated preparation and HTTP checks. A check of the production Composer manifest/lock was also added, so that the smoke profile cannot hide a mismatch between them.
- [x] Commit/push 35d2d54, draft PR #1 and its real CI passed.
- [x] TPL-03: fresh vendor without Smarty, dependency profile check and cleaned caches, again 20 HTTP checks green. Framework checkpoint 80208da/08dc79e.
- [x] MD-03/04: real 9 articles + 9 translations verified on TEMP copies: 18 HTML plans, 8 safe apply/rollback, 10 manual review without apply. Original rows/hashes/schema unchanged; existing HTML remains legacy_html.
- [x] The final release gate and repeated smoke passed in CI for the released framework tag v4.0.0. The migration PR is merged; production deployment and conversion of operational data are not performed.

The repeat procedure is in the README. Tests setup/seed refuse to run without the marker of the isolated smoke environment. For removal, use only the Compose project that was just created, not a general stopping of other people's containers.

Rollback of application changes: restore the corresponding public bootstrap, App services, layout and Composer version, clear the compiled/page/fragment/external HTML caches. Switching the adapter alone is not enough for the native-only set/t syntax. The SQL content migrations have their own plan and originals; this checkpoint does not run them.

TPL-03 checkpoint: dependency-profile and reset-smoke-cache refuse to run outside the marked isolated environment. CI runs both checks before the HTTP suite. Next is MD-04 fresh installation without Texy and an isolated content pilot.


## DX-03 and MD-04 checkpoint 2026-10-26

A fresh installation without Smarty/Texy has only JWT and WBengine. 20 HTTP green, both real Composer bin proxies work. CI now also checks this profile. Example apiV2.enabled=true uses the early API before the CMS; content endpoints require explicit SQL 002/003/005, production migrations are not run by this.

Real CMS matrix completed: 300 requests/0 errors, 15 cohorts, concurrency 4, PHP 8.4.27/MySQL 8.4.13, 14 pages/9 articles/20 boxes/2 users, OPcache CLI 0. Off public request 6 SQL/1 connection, data warm 1 SQL/1 connection, page warm 20/20 HIT and 0 SQL/0 connections. Private profile and custom API never shared HIT. Exact measured latencies, methodology and limitations are in benchmark-cms-result.json. Real admin form login + CSRF and DB session verified, configuration and main server unchanged.

The next step is a joint HTTPS API/admin pilot in a separate environment and the final release gate.


## Last verification of content origin and conversion

The source SQL contains real HTML fragments and escaped HTML examples. A mention of Texy in the prose does not mean Texy syntax; the format is not guessed. The new tests/content-migration-smoke.php with a marker/DB/cache guard copies the real articles and translations into connection-local TEMP InnoDB and uses the real core Migrator/HtmlConverter and the SQL004 ledger. It writes to neither the original tables nor the schema.

18 plans: 8 safe (1, 1:cs, 5, 5:cs, 6, 6:cs, 9, 9:cs) approved by hash only in TEMP, applied and exactly rolled back; 10 manual (2, 2:cs, 3, 3:cs, 4, 4:cs, 7, 7:cs, 8, 8:cs) left unchanged. Reasons: 8 unsupported element and 2 semantic mismatch. Dry run changes neither content nor ledger, source SHA256/full rows/schemas identical before/after.

This is valid original HTML outside the conservative conversion subset, not bad data. Keeping it as legacy_html is a deliberate safe migration choice. If the operator chooses to convert these records too, they must manually rework the individual layout/HTML constructs and re-check the render; nothing is rewritten automatically or lossily. New standard texts use Markdown. CI runs the same verification before the HTTP smoke.

The final technical gate of the core and the central administration passed on two independent HTTPS sites including revocation/outages and a real dump/restore. What remains is merging and publishing the new version; the current joint status is in the core's plan-framework-improvements.md.


## Publication

2026-10-26: The core was merged into master as cf710e5adbc25809868a864e615f8b9fc62a7489 and tag v4.0.0 points to this commit. CI references to the tag were then updated and both the sample application and the administration were merged. GitHub release v4.0.0 was created. Production deployment was not performed.


## Local adoption of v4.0 and Composer check

2026-10-26: The clean local checkout ../wbengine-skeleton-app was fast-forward updated to migration commit 19fde667530a273e95ce05a118bd438c705520b5. The `main` branch was not overwritten; the following fix runs in `codex/skeleton-app-v4-composer-lock`.

A regular `composer validate` revealed that the application commit changed the constraint to `^4.0` but did not recompute `composer.lock`, which still contained framework v3.5.0. CI could not catch this stale local lock copy because `composer.lock` is in `.gitignore`; its smoke workflow moreover used only the alternative `composer.smoke.json` with a path repository. The local lock was updated by Composer to the released tag v4.0.0, without Smarty/Texy; `composer validate --no-check-publish --strict` and a real production `composer install --no-dev` passed. The local vendor was updated; the database and production data were not changed.

A regression check of the regular `composer.json` and the lock was added to CI before installing the separate smoke profile. Verified and completed: PR #2 merged as b1c303460565cfbaa6023de3530a3a396b4c278d; CI main run 40390173093 passed successfully. Production deployment and database modification were not performed.
