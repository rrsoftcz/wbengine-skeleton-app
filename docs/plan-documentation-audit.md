# Plan: audit of the skeleton documentation

Status: done 2026-11-01. The owner approved the table and the page list; the four new pages (MCP server,
Connect an MCP client, Search engines, Statistics) and the sections added to Boxes, Caching, Languages,
Templates and API are live in English and Czech (migrations 040 to 042). The table below is the state
before the work. Part of `plan-release-6-7-0.md` in the framework repository (part E).

## Method

The documentation of the skeleton is 12 pages under `/docs/`, stored in the database (`cms_articles`
in English, `cms_article_translations` in Czech). Each feature of the framework releases 4.0.0 to 6.7.0
was searched for by 2 to 4 key words in the English text of all documentation pages
(`/docs/*`, the home page and `/about/`). The count shows only that a feature is mentioned, not that it
is explained, so the verdict column is a reading of where it is mentioned and how long that page is.
The Czech pages exist for all 12 pages and are about as long as the English ones (checked by length),
so the gap is in the content, not in the translation.

## Result

Verdicts: **Missing** (no mention anywhere), **Thin** (one mention, in a table or in a page about
something else), **Partial** (mentioned in a page of the matching topic, quality to be read before the
page is extended).

| Feature | Since | Mentioned in | Verdict |
|---|---|---|---|
| MCP server: install and connect a client | 6.3 | nowhere | Missing |
| MCP on macOS, Linux, Windows and WSL2 | 6.7 | nowhere | Missing |
| MCP: article workflow, images and statistics tools | 6.4, 6.5 | nowhere | Missing |
| Version of the framework (layout variable, header) | 6.7 | nowhere | Missing |
| Box device limits (`device_min`, `device_strict`) | 4.1 | nowhere | Missing |
| Changelog of the framework | 6.7 | nowhere | Missing |
| MCP server: what it is and its tools | 6.3 | Central administration (3) | Thin |
| Permission groups and presets of a key | 5.1, 6.3 | Central administration (6) | Thin |
| Address (IP) restriction of a key | 6.1 | Settings reference (1) | Thin |
| Hide and show an article | 6.2 | Settings reference (1) | Thin |
| Views per language | 6.7 | Settings reference (1) | Thin |
| Sitemap, robots.txt, canonical, hreflang | 6.6 | Settings reference (10), Deployment (1) | Thin: a settings table only, no page that explains the set |
| Images: store and limits | 6.4 | Settings reference (5), Deployment (3) | Thin |
| Native analytics: counting, retention, report | 4.x | Deployment (3), Settings reference (2) | Thin: no page explains the numbers |
| Dynamic boxes and strict addresses | core | Boxes page does not name them | Thin: the Boxes page is 757 characters |
| API v2: endpoints, keys, scopes | 4.0 | API (7), Logging (5), Deployment (3) | Partial: the API page is 1,617 characters |
| Change log, audit and change feed | 4.x | Logging and audit (17) | Partial |
| Remote users API and user CLI | 4.10 | Home (2), Deployment (1), Logging (1) | Partial |
| Cache flush and config API | 4.10 | Deployment (11), Settings reference (6), Caching (5) | Partial |
| Translated content and `translation_locales` | 4.x | Central administration (1), Templates (1) | Partial |
| Markdown content (`content_format`) | 4.0 | Templates (16) | Partial: probably adequate |
| Page cache and its controls | 4.x | Settings reference (8), Caching (2) | Partial: the Caching page is 1,122 characters |
| Trusted proxies, CSRF, rate limiting | 4.x | Settings reference (12), Deployment (7) | Partial |
| CLI: doctor, config:check, migration:status | 4.x | Deployment (10) | Partial |
| Database updates (`update-database.sh`) | 4.x | Deployment (5), Logging (3) | Partial |
| Docker production deployment | skeleton | Home (16), Logging (7) | Partial |

## Proposed changes (to approve)

New pages, English and Czech each, written as guarded content migrations mirrored at the end of the
content dump and checked on a scratch database, one pull request each:

1. `/docs/mcp/` MCP server for editors: what it is, which key and preset to issue (Editor, Agent for
   content, Read only), what the tools do in plain words (articles and pages, menu and boxes, images,
   statistics and reports, the change log), the guide, prompts and resources, what it never does
   (nothing is deleted, publish only on request), updating the file, troubleshooting.
2. `/docs/mcp-clients/` Connect an MCP client: requirements, the file and its checksum, the
   configuration and the command, per platform: Linux, macOS, Windows with WSL2 as the recommended
   way, native Windows as the second option. Each platform has a "verified" line that says what was
   proven (the CI run on that platform) and what was not.
3. `/docs/seo/` Search engines: sitemap, robots.txt, canonical link and hreflang as one set, the `seo`
   settings, the rule for strict and dynamic pages, what is left out and why.
4. `/docs/analytics/` Statistics: how views are counted, what is not counted, retention, the split by
   language, the report, and how a site turns it on.

Extended pages:

5. API (`/docs/rest-api/`): hiding articles, the change feed, key presets and the address restriction,
   images and their limits, analytics with the split by language, the error codes.
6. Boxes: dynamic boxes and strict addresses (a box receives the rest of the address and answers the
   404 itself), device limits.
7. Caching, Languages and Templates: what changed since they were written (the cache key per device,
   translated content, the layout variables `wbengine_version`, `hreflangs`, `alternates`).
8. The `/docs/` index and the menu list the new pages.

Not proposed: rewriting pages marked Partial that are long and current (Logging, Deployment, Settings
reference). They get a reading pass and only the facts that changed.

## Order

The changelog page (part C) and the blog overview (part D) do not depend on this audit and go first.
Then pages 1 and 2 (the owner's explicit wish), then 3, 4, 5, 6, 7 and 8.

## Check at the end

Every page has both languages, no page links to a missing page, every claim about a platform has its
"verified" line, and a smoke test requests every documentation page in both languages.
