# wbengine-skeleton-app

A minimal application built on the [WBengine](https://packagist.org/packages/wbengine/wbengine) PHP framework. Use it as a starting point for a website or a backend: it shows a static page, a database driven blog article, a login, a user profile and the REST API.

## Requirements

* PHP 8.3 or newer (8.4 recommended) with the `mysqli` extension
* MySQL 8 or MariaDB 10.6+
* Apache with `mod_rewrite` and `AllowOverride All` for `public/` (or an equivalent Nginx rewrite to `public/index.php`)
* Composer
* Docker (optional, the quickest way to try it)

## Quick start with Docker

```bash
git clone <this repository> wbengine-skeleton-app
cd wbengine-skeleton-app

docker compose up -d --build          # web on http://localhost:8080, MySQL seeded from schemas/
docker compose exec web sh bin/setup.sh
```

`bin/setup.sh` creates `src/Config/Settings.json` from `settings.json.default` with new random JWT keys, makes `src/View/Compiled` writable and runs `composer install`.

Open http://localhost:8080 and sign in with the demo account:

| E-mail | Password |
|--------|----------|
| `admin@example.com` | `changeme` |

Change this password before the application is reachable by anyone else.

## Manual installation

1. `composer install`
2. `sh bin/setup.sh` (or copy `src/Config/settings.json.default` to `src/Config/Settings.json` and replace both `CHANGE_ME` JWT keys with random strings of at least 32 characters, for example `openssl rand -hex 32`)
3. Create a database and import `schemas/wbengine_skeletone_app_mysql_template.sql`
4. Edit `dbAdapterDefinition` in `src/Config/Settings.json`
5. Point the web server document root at `public/`

Upgrading an existing database: run the scripts in `schemas/migrations/` once. Passwords are stored with `password_hash()`; old MD5 hashes keep working and are upgraded on each user's next login once the column is widened.

## How it works

The page you see is assembled from database rows:

```
Site (cms_sites, matched by URL)
  Sections (cms_sections: header, central, api)
    Boxes (cms_boxes: module + method)
      static box  : renders a template only
      dynamic box : loads data through a Model, then renders a template
```

A `cms_boxes` row selects a PHP class and method: module `blog`, method `story`, section `central` runs `App\Box\Central\Blog::Story()`. The method returns HTML, which is placed into the layout (`src/View/site.tpl`) as `{$central}`, `{$header}` and so on. The `sites` column holds the site ids where the box is shown, `shared = 1` shows it on every site.

```
public/index.php          entry point (about ten lines)
public/.htaccess          routes everything to index.php
src/Config/               Settings.json (not committed), settings.json.default
src/Box/<Section>/        box classes, e.g. Central/Blog.php, Central/Profile.php
src/Box/Api/Restapi.php   REST API box
src/View/                 Smarty templates: site.tpl layout, <Section>/<Method>.tpl per box
src/View/Compiled/        template cache, must be writable
schemas/                  database schema and demo data, migrations/
bin/setup.sh              first-time setup
```

Examples to read first: `StaticBoxes::About` (static box), `Blog::LocalStoryBox` with `Article/Model.php` (dynamic box with a model), `Profile` (box that uses the logged in user).

## Templates

The skeleton uses WBengine's native template engine with automatic escaping: `{$value}` is HTML-escaped, so a menu name or an e-mail address containing markup is shown as text, not run. Print trusted HTML (the sections built by the boxes, formatted article text) with `|raw`:

```smarty
<title>{$meta.title}</title>          {* escaped *}
{$central|raw}                        {* HTML built by the boxes *}
{$LocalStoryBox->bodytext|raw}        {* article HTML written by administrators *}
```

The syntax is a subset of Smarty (`{if}`, `{foreach}`, `{include}`, modifiers, `{cache}` for fragment caching), see the framework README. Templates written with explicit `|raw` and `|escape` also work with Smarty: set `"adapterName": "SmartyRenderer"` in `Settings.json` to switch back.

## Adding a page

1. Insert a row into `cms_sites` (the URL) and optionally `cms_menu` (the navigation entry).
2. Create `src/Box/Central/Hello.php`:

   ```php
   namespace App\Box\Central;

   use Wbengine\Box\WbengineBoxAbstract;

   class Hello extends WbengineBoxAbstract
   {
       public function Hello()
       {
           return $this->getRenderer()->render($this->getBoxTemplatePath());
       }
   }
   ```
3. Create `src/View/Central/Hello.tpl`.
4. Insert a `cms_boxes` row: module `hello`, method `hello`, section 1 (central), `sites` `["<your site_id>"]`.

Always pass values to SQL as bound parameters: `Db::fetchAssoc('SELECT * FROM cms_articles WHERE id = ?', [$id])`.

## REST API

Served under `/api/`. Obtain a token, then send it as a bearer token:

```bash
curl -X POST -H 'Content-Type: application/json' \
     -d '{"username":"admin@example.com","password":"changeme"}' \
     http://localhost:8080/api/auth/login

curl -H "Authorization: Bearer <token>" http://localhost:8080/api/sections
```

Every route except `/api/auth/login` needs a valid token. Currently available: `auth` (login, logout, identify, revalidate), `users` (list, get, create, patch, delete), `sections` (CRUD).

## Security notes

* The JWT keys and reCAPTCHA secret live in `Settings.json` (or the environment variables `WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`). Never commit them. `Settings.json` is ignored by git.
* Keep `"debug": false` in production: debug mode prints SQL and error details.
* Any valid token can currently use every API route. Add a role check before exposing the API to more than administrators.
* Do not commit TLS certificates or private keys; terminate TLS in front of the application.

## License

MIT
