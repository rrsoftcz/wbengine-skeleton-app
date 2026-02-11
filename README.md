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

* Docker & Docker Compose
* mkcert (for local development SSL)
* >= PHP v8.1 (provided by Docker)
* >= WBengine v1.2.2
* MySQL 8.4 (provided by Docker)

---

## Docker Development Setup (Step by Step)

This project runs in Docker with HTTPS enabled. Follow these steps to set up your local development environment.

### Step 1: Install mkcert

mkcert creates locally-trusted SSL certificates for development.

**macOS:**
```bash
brew install mkcert
```

**Ubuntu/Debian:**
```bash
sudo apt install mkcert
```

### Step 2: Install Local Certificate Authority

This installs a root CA into your system's trust store (one-time per machine):

```bash
mkcert -install
```

You may be prompted for your password.

### Step 3: Add Local Hostname

Add `wbengine.local` to your hosts file:

```bash
echo "127.0.0.1 wbengine.local" | sudo tee -a /etc/hosts
```

Verify:
```bash
cat /etc/hosts | grep wbengine
```

### Step 4: Generate SSL Certificates

Navigate to the cert directory and generate certificates:

```bash
cd etc/cert
mkcert -cert-file fullchain.cer -key-file wbengine.local.key wbengine.local localhost 127.0.0.1 ::1
```

This creates:
- `fullchain.cer` - Certificate file (valid ~27 months)
- `wbengine.local.key` - Private key

### Step 5: Start Docker

```bash
docker-compose up -d
```

Docker Compose automatically loads `docker-compose.override.yml` which mounts the development Apache configuration.

### Step 6: Access the Application

Open your browser:
```
https://wbengine.local
```

---

## How It Works

### Development vs Production

| | Development | Production |
|---|---|---|
| Hostname | `wbengine.local` | `wbengine.rrsoft.cz` |
| SSL Certificates | mkcert (local) | Let's Encrypt (certbot) |
| Apache Config | `wbengine.local.conf` | `wbengine.conf` |
| Certificate Renewal | Manual (~27 months) | Automatic (cron, every 3 months) |

### Project Structure

```
├── README.md
├── docker-compose.yml              # Main Docker config (tracked)
├── docker-compose.override.yml     # Dev overrides (gitignored)
├── Dockerfile
├── Public/                         # Web root
├── etc/
│   ├── apache2/sites-available/
│   │   ├── wbengine.conf           # Production Apache config (tracked)
│   │   └── wbengine.local.conf     # Dev Apache config (gitignored)
│   ├── cert/
│   │   ├── README.md               # Certificate setup guide
│   │   └── *.cer, *.key            # Certificates (gitignored)
│   └── mysql/
└── Schemas/
```

### Why Certificates Are Not in Git

- **Production:** Managed by certbot, auto-renewed every 3 months
- **Development:** Generated locally by mkcert, valid ~27 months
- **Security:** Private keys should never be in version control

See `etc/cert/README.md` for detailed certificate instructions.

---

## Database (Docker)

MySQL 8.4 runs in Docker:

- **Host:** `localhost`
- **Port:** `3306`
- **Database:** `wbengine_skeleton_app`
- **User:** `dev_user`
- **Password:** `dev_password`

---

## Troubleshooting

### SSL Certificate Error
1. Re-run: `mkcert -install`
2. Regenerate certs (Step 4)
3. Restart Docker: `docker-compose down && docker-compose up -d`

### Cannot Resolve wbengine.local
Check hosts file: `cat /etc/hosts | grep wbengine`

### Port 443 Already in Use
```bash
lsof -i :443
```

---

## Alternative: Manual Setup (without Docker)

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
