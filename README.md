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

## Nginx

`etc/nginx/wbengine.conf` is the equivalent of `public/.htaccess` for Nginx with PHP-FPM: pages get a trailing slash (a 301 redirect), the API is exempt (a redirect would turn a POST into a GET), every request that is not a file goes to `index.php`, and `src/`, `vendor/`, `schemas/`, `bin/` and `etc/` are never served. It was tested with Nginx 1.30, PHP 8.4 FPM and MariaDB 11.4. Adjust `fastcgi_pass` and `root` to your setup.

## HTTPS development with mkcert (optional)

The quick start above uses plain HTTP on port 8080. To develop against `https://wbengine.local` with a locally trusted certificate:

1. Install mkcert: `brew install mkcert` (macOS) or `sudo apt install mkcert` (Ubuntu or Debian).
2. Install its local certificate authority, once per machine: `mkcert -install`.
3. Add the hostname: `echo "127.0.0.1 wbengine.local" | sudo tee -a /etc/hosts`.
4. Generate the certificates in `etc/cert`:

   ```bash
   cd etc/cert
   mkcert -cert-file fullchain.cer -key-file wbengine.local.key wbengine.local localhost 127.0.0.1 ::1
   ```

5. Start Docker with the HTTPS override and open https://wbengine.local:

   ```bash
   docker compose -f docker-compose.yml -f docker-compose.https.yml up -d
   ```

The override (`docker-compose.https.yml`) publishes port 443, mounts `etc/cert` read only and enables the vhost `etc/apache2/sites-available/wbengine-https.conf`. If you prefer your own setup, a git-ignored `docker-compose.override.yml` and `etc/apache2/sites-available/wbengine.local.conf` are loaded the usual way and stay out of the repository.

| | Development | Production |
|---|---|---|
| Hostname | `wbengine.local` | `wbengine.rrsoft.cz` |
| Certificates | mkcert (local, valid about 27 months) | Let's Encrypt (certbot, renewed automatically) |
| Apache config | `wbengine-https.conf` | `wbengine-production.conf` |

**Certificates are never committed.** Production certificates are managed by certbot and renewed automatically, development ones are generated locally by mkcert, and a private key does not belong in version control. See `etc/cert/README.md` for details.

**Troubleshooting**

* SSL certificate error: run `mkcert -install` again, regenerate the certificates (step 4) and restart with `docker compose ... down` and `up -d`.
* `wbengine.local` does not resolve: check `cat /etc/hosts | grep wbengine`.
* Port 443 is already in use: find the process with `lsof -i :443`.

## Manual installation

1. `composer install`
2. `sh bin/setup.sh` (or copy `src/Config/settings.json.default` to `src/Config/Settings.json` and replace both `CHANGE_ME` JWT keys with random strings of at least 32 characters, for example `openssl rand -hex 32`)
3. Create a database and import `schemas/wbengine_skeletone_app_mysql_template.sql`
4. Edit `dbAdapterDefinition` in `src/Config/Settings.json`
5. Point the web server document root at `public/`

Upgrading an existing database: run the scripts in `schemas/migrations/` once. The translation tables of 005 are optional: without them the site stays in the default language. Passwords are stored with `password_hash()`; old MD5 hashes keep working and are upgraded on each user's next login once the column is widened.

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

## Languages

The skeleton is available in English and Czech. `/` is English, `/cs/` is Czech, `/en/...` redirects to the unprefixed URL, and the browser's `Accept-Language` and a cookie that remembers your last choice are used for the unprefixed URLs. The texts live in `src/Locale/en.php` and `src/Locale/cs.php`, the templates use `{t 'key'}`, menu links use `|lurl`, and the layout has a language switcher and `hreflang` links. Add a language by listing it in the `i18n.locales` setting and adding `src/Locale/<code>.php`. The content from the database is translated too: site titles and meta tags, menu names and the article live in `cms_site_translations`, `cms_menu_translations` and `cms_article_translations` (demo Czech rows are in the schema), the original tables hold the default language, and a field without a translation falls back to it. `Article/Model.php` shows the one line a box with its own query needs (`ContentTranslations::overlayRow('article', $row)`); the site and the menu are translated by the framework. Editors manage the translations with `GET`, `PUT` and `DELETE /api/translations/{site|menu|article}/{id}[/{locale}]`. An existing database needs `schemas/migrations/005-content-translations.sql`. See the framework README (Internationalisation).

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

Every route except `/api/auth/login` needs a valid token. Currently available: `auth` (login, logout, identify, revalidate), `users` (list, get, create, patch, delete), `sections` (CRUD), `translations` (content translations, editor role), `cache/flush`.

## Security notes

* The JWT keys and reCAPTCHA secret live in `Settings.json` (or the environment variables `WBENGINE_JWT_KEY`, `WBENGINE_JWT_REFRESH_KEY`, `WBENGINE_RECAPTCHA_SECRET`). Never commit them. `Settings.json` is ignored by git.
* Keep `"debug": false` in production: debug mode prints SQL and error details.
* Any valid token can currently use every API route. Add a role check before exposing the API to more than administrators.
* Do not commit TLS certificates or private keys; terminate TLS in front of the application.

## TailwindCSS

The stylesheet is built from `src/input.css` with Tailwind (`tailwind.config.js`):

```bash
npm install
npx tailwindcss -i ./src/input.css -o ./public/Css/output.min.css --watch --minify
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for the code of conduct and the process for submitting pull requests.

## Improving this sample

The WBengine library and this sample application are open source and a volunteer effort. RRsoft does not have people fully dedicated to maintaining them. If you want something improved or a new feature, please submit a pull request. The library lives at https://github.com/rrsoftcz/wbengine.

## License

See [LICENSE.md](LICENSE.md). `composer.json` declares the MIT license.
