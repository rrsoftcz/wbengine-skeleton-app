# Proposal: sample application content and guides for WBengine 4.0

Status: implemented, verified in an isolated copy
Date: 2026-10-26
Scope: `wbengine-skeleton-app`, released WBengine 4.0 line

## Goal

Update the sample application so that its home page, articles, database seed files and guides describe the actual state of WBengine 4.0. The new default content should use Markdown, explain native templates and installation without Smarty/Texy, and include clear CLI examples with syntax highlighting in the style of the home page.

## Scope

- Update the README in Czech or English, following the existing README language: installation, PHP and extensions, Composer dependencies, deployment, CLI, cache, migrations and troubleshooting of common problems.
- Adjust the localized home page texts, especially the version label and the claims about templates and article formatting.
- Manually rewrite all nine default articles and nine Czech translations in `schemas/wbengine_skeletone_app_mysql_template_content.sql`. Keep IDs, relations, navigation and factual data. The texts will be in Markdown, SQL values correctly escaped.
- Document the native template syntax, escaping, compilation and cache. State that source `.md` files can be rendered directly and also embedded in a native template using `{include 'content.md'}`. Markdown is not executed as PHP or as a template.
- Document Markdown in the database as an explicit record format, including preservation of older HTML records in the `legacy_html` format.
- Add light syntax highlighting for code blocks without a new runtime or NPM dependency. CLI blocks must be colored; other languages can be covered by the same mechanism based on the examples in the guides.
- Update the base schema files and prepare a follow-up migration SQL for `content_format` on articles and translations, if the schema check confirms that the framework migration is not part of the skeleton's regular procedure.
- Record in the skeleton's migration plan what is done, how the change was verified and how to proceed when updating an already deployed sample site.

## Decisions

### Content

The new default texts will be written manually in English and Czech in Markdown. Automatic conversion of the existing HTML will not be used. It is not possible to reliably determine whether the existing records are the original demo text or content edited by the operator. An upgrade of an existing database will therefore only add a format column with the default value `legacy_html`; it will not change the content or its format.

A fresh installation gets the updated seed. An already installed site gets instructions for safely updating the default content. Any optional SQL update of the demo articles must have a condition that verifies the original value or its checksum, and must not overwrite user edits. If such a condition cannot be created simply and verifiably, the content update remains manual.

### Schema

`cms_articles` and `cms_article_translations` each need their own `content_format`, because language variants may have different formats. A new database will have the columns in the main schema; an upgrade of an existing database gets a versioned migration in `schemas/migrations/`. The default value for existing rows is `legacy_html`. Markdown is set only on new seeded or explicitly edited records.

Before implementation, verify whether the framework migration `migrations/4.0.0/003-markdown-content.sql` already creates these fields and whether the skeleton runs it as part of the supported upgrade procedure. If so, do not create a duplicate incompatible ALTER; the skeleton migration must be idempotent or must clearly declare the assumed state of the core.

### Code highlighting

Use a small dependency-free JavaScript over `pre code.language-*`. Build tokens through DOM nodes and `textContent`, never insert source code as HTML. Languages will be on an allowlist; at minimum `bash`/`shell` for CLI, otherwise only languages actually used in the documentation. Unknown languages remain plain text. Colors follow the classes of the home page sample: purple for keywords, blue for commands/methods, gray for comments and green for strings. Preserve copying of the source text, accessibility and a fallback without JavaScript.

### Package independence

Normal runtime stays without Smarty, Texy and without a new JS library. The basic guide lists Composer and the actual requirements of the released framework version. Compatibility packages will be marked as optional migration tools, not as an application dependency.

## Implementation phases

1. **Facts and schema:** verify the Markdown API, `.md` rendering, current PHP/extension requirements and the order of core and skeleton migrations. Record exact examples according to the WBengine 4.0.0 tag.
2. **Data model:** modify the base SQL schema and add an upgrade path for `content_format`; default old data remains `legacy_html`. Prepare the Markdown seed for both locales.
3. **Content and guides:** rewrite the nine articles and translations, the README and the localized home page text. Verify every command against the real CLI and compare every claim with the released framework.
4. **Highlighting:** add a light safe lexer, CSS/Tailwind styles and script loading. Label examples in the articles with a language; the CLI must have uniform coloring.
5. **Verification and checkpoint:** perform a diff and SQL/Markdown validation, run the CSS/JS build and the existing isolated smoke scenarios. Verify the fresh seed and an upgrade of a database copy, preservation of the original legacy HTML, Markdown rendering, the page without JavaScript and input with HTML-like text against XSS. Update this plan with the results. Create a separate change overview before commit/push.

## Completion criteria

- Nowhere in the default texts or documentation are there outdated claims that the runtime requires Smarty or Texy.
- The README describes a reproducible installation for the released WBengine 4.0 and the actual dependencies.
- The documentation shows `.md` as a direct source and as an include, and Markdown as an explicit database format.
- The nine English articles and their Czech variants contain current content that matches in language.
- The fresh schema and the upgrade schema work; existing HTML content remains untouched and marked as `legacy_html`.
- Console examples are colored according to the home page palette and rendering of the source text cannot inject HTML.
- The project passes its CI and isolated smoke checks.

## Risks and mitigations

- **Unintended content overwrite:** the seed SQL is usually not run again when updating an existing database; any data migration will be opt-in and conditional on the original content.
- **Duplicate SQL migrations in core and skeleton:** before modifying the schema, verify the official order and idempotence of both paths.
- **XSS in code or Markdown:** the highlighter uses DOM text nodes; verify the Markdown renderer and its sanitization on the released version.
- **Outdated CLI examples:** run the commands in an isolated application with the 4.0.0 tag, do not rely only on the old articles.
- **Tailwind removes dynamic classes:** list the color classes statically in sources scanned by Tailwind or in its safelist.

## Out of scope

- Production deployment of the framework or changes to third-party sites.
- Automatic conversion of users' databases from HTML to Markdown.
- Development of the administration or new content APIs.
- Adding a parser library or a syntax-highlighter package.

## Work status

- [x] Scope and direction of the solution approved by the user.
- [x] The proposal passed an independent technical review with no open decisions and was approved.
- [x] Schema, Markdown API, `.md` include, CLI and dependencies verified against the released WBengine 4.0.0.
- [x] The base schema and migration path 006 add `content_format`; old HTML content is not changed.
- [x] Nine English articles and nine Czech translations rewritten as Markdown. The fresh seed marks them `markdown`.
- [x] README, home page copy, SEO metadata and the live `.md` file sample updated. The built-in Docs and the local Blog box render database Markdown through the framework service.
- [x] Console `bash` blocks are highlighted by a small dependency-free JavaScript and the four colors come from the home page sample.
- [x] Fresh seed verified: 9/9 articles and 9/9 translations have `content_format=markdown`.
- [x] Upgrade SQL 006 verified on old HTML rows: the text stayed unchanged and both tables received `legacy_html`.
- [x] Tailwind build and `node --check` passed; the existing HTTP smoke has 20/20 checks successful. English and Czech pages and the direct `.md` include rendered.
- [x] Final diff review completed; a warning about a non-idempotent seed was fixed.

Note on deployed databases: migration 006 safely adds the format but does not overwrite the existing demo text. The new content reaches fresh seed environments; for an already used site, the articles must be updated editorially so that operator edits are not overwritten.

## Follow-up fixes before publishing on wbengine.org

- [x] Fix switching from Czech to the default English: the language switcher uses an explicit `/en/...`, which sets the locale cookie, and the framework then redirects to the canonical unprefixed URL.
- [x] Add HTTP regression checks for choosing English from a Czech page, the canonical redirect and the English content after the redirect.
- [x] Extend the CLI highlighter: color a command in the command position even when it was not in the previous fixed list, and the subcommands of common tools such as Docker, Git, npm and Composer.
- [x] Add to the README the production setting of `i18n.baseUrl` to `https://www.wbengine.org`, HTTPS, production JWT keys and removal of the demo access before publishing.
- [ ] Run the HTTP regression smoke on the local service after it is started again. During this review the Docker socket was not available and `localhost:8080` was not listening. PHP syntax of the test, template compilation, `node --check` and `git diff --check` passed.
- [ ] Before the live publication, verify the production configuration, schema and migrations on the hosting; this has not been done and neither DNS nor deployment changes with this step.

## Follow-up appearance changes and Markdown documentation

- [x] The CTA box "Run it in two minutes" uses a dark base and the same indigo/fuchsia glow background as the Hero box.
- [x] The documentation explains the supported block and inline elements, GFM extensions, safe HTML rendering and the format of database records.
- [x] Mentions of Smarty removed from the public README and the new seed content. Migration 007 updates two built-in documentation pages on already installed sites.
- [x] Verified template compilation, syntax of the PHP smoke file, JavaScript syntax, balance of quotes/brackets in the SQL, presence of the required classes in the already built CSS and a clean diff.
- [ ] Run the web smoke test again and apply migration 007 to the local database once Docker/DB is available. In this session neither the Docker socket nor the local database port was available.

The Tailwind build produced `public/Css/output.min.css`; the local `caniuse-lite` printed a warning about the age of the browser database. This warning did not block the build. After a subsequent 500 on `localhost:8080`, the log confirmed a missing `content_format`. Migration 006 was run on the skeleton's local Docker database; the nine English articles and nine Czech translations were updated only after matching the checksums of the original seed rows. Before the change, targeted dumps of the affected rows were taken and removed after verification. `/cs/docs/` and `/cs/docs/templates/` now return 200. `Settings.json` was not changed. The other smoke and migration verification ran in a separate Docker environment.
