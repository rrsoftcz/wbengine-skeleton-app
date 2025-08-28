# wbengine-skeleton-application
This is a skeleton application using the WBengine Library layer and module systems. This skeleton application is meant to be used as a starting place for those looking to get their feet wet with WBengine.

## Installation from Github
There is several ways how to install wbengine-skeleton-application. You can just simply clone it from Github repository by command:

```
git clone git@bitbucket.org:rrsoft/wbengine-skeleton-app.git
```
then run commands:
```bash
cd wbengine-skeleton-application
php composer.phar install
```
If you don't have Composer already installed, then please install it by typing a command:
```
curl -s http://getcomposer.org/installer | php
```

## Installation by Composer

The most easist way how to install a wbengine-skeleton-application project is to use Composer:

```
php composer.phar create-project wbengine-skeleton-application/wbengine-skeleton-application --stability=dev --keep-vcs
```

This command will download wbengine-skeleton-application directly from the packagist repository and install all required dependencies at once.

#### Requirements

To run this application on your machine, you need at least:

* >= PHP v5.6.*
* >= WBengine v1.2.2
* Apache Web Server with `mod_rewrite enabled`, and `AllowOverride Options` (or `All`) in your `httpd.conf` or Nginx Web Server
* MySQL / MariaDB >= 5.* compatible

### Prepare MySQL database:
```
echo 'CREATE DATABASE wbengine' | mysql -u root -p
```
and import schema with startup tables configuration:
```
cat Schemas/wbengine-skeleton-application.sql | mysql -u root -p wbengine
```
Don´t forget to edit configuration file located at (App/Config/...) and update the database section access part.

Now just create Apache vhost pointed to Public directory:

```
 <VirtualHost *:80>
     ServerName wbengine.localhost
     DocumentRoot /path/to/wbengine/Public
     <Directory /path/to/wbengine/Public>
         DirectoryIndex index.php
         AllowOverride All
         Order allow,deny
         Allow from all
     </Directory>
 </VirtualHost>
```
 and set "Write" access rights to "App/Cache/Renderer" directory:

```
chmod 777 App/Cache/Renderer
```

## TailwindCSS implementation


```
npx tailwindcss -i ./src/input.css -o ./public/css/output.min.css --watch --minify
```

## Contributing

Please read [CONTRIBUTING.md](https://github.com/Bajtlamer/wbengine-skeleton-application/blob/master/CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Improving this Sample
WBengine as wbengine-skeleton-application is an open source project and a volunteer effort. RRsoft does not have human resources fully dedicated to the mainteniance of this software. If you want something to be improved or you want a new feature please submit a Pull Request.

The WBengine Library project you can found at https://github.com/Bajtlamer/wbengine

## License
WBengine is open-sourced software licensed under the New BSD License.
