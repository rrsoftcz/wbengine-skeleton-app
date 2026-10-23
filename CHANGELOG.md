# Changelog

## [Unreleased]

### Changed

- Docker setup: PHP 8.4 image, MySQL 8.4, lowercase `public/` and `schemas/`
  paths, an HTTP vhost with `AllowOverride All`, port 8080. TLS certificates are
  no longer part of the repository.
- `settings.json.default`: correct `SmartyRenderer` adapter name, `jwt` and
  `recaptcha` sections, `ipAdmins`, no minification by default.
- `cms_users.password` is `varchar(255)`. Existing databases: run
  `schemas/migrations/001-widen-user-password.sql`.
- The demo account is `admin@example.com` / `changeme` (change it).
- `public/.htaccess` no longer redirects `/api` to add a trailing slash.
- The blog box and its model use bound parameters.

### Added

- `bin/setup.sh`: creates `Settings.json` with random JWT keys, prepares the
  template cache and runs `composer install`.
- `Profile` box and template, `schemas/migrations/`.
- Rewritten README.

### Fixed

- The REST API box called methods that do not exist.
- `Blog::LocalStoryBox` resolved the wrong model class.

### Removed

- Private keys, certificates and a customer vhost from version control (rotate
  any key that was committed), the PHP 7.0 Dockerfile and its Apache snippet,
  `Exception.html`.

Requires WBengine 3.1 or newer (`composer.json` still points at `~3.0` until it
is released).
