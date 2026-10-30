#!/bin/sh
set -eu

cd "$(dirname "$0")/.."
umask 077

# Public address of the site: ./bin/setup-production.sh https://www.example.org (or SITE_URL=...).
SITE_URL=${1:-${SITE_URL:-https://www.wbengine.org}}
case "$SITE_URL" in
    https://*) ;;
    *) echo "Error: the site address must start with https:// (got: $SITE_URL)." >&2; exit 1 ;;
esac
SITE_URL=${SITE_URL%/}
export SITE_URL

if [ ! -f .env ]; then
    MYSQL_ROOT_PASSWORD=$(openssl rand -hex 32)
    MYSQL_PASSWORD=$(openssl rand -hex 32)
    cat > .env <<EOF
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
MYSQL_USER=wbengine
MYSQL_PASSWORD=$MYSQL_PASSWORD
EOF
    chmod 600 .env
    echo "Created .env with random database passwords."
else
    echo "Using existing .env."
fi
set -a
. ./.env
set +a

if [ ! -f src/Config/Settings.json ]; then
    docker run --rm \
        -e MYSQL_USER -e MYSQL_PASSWORD -e SITE_URL \
        -v "$PWD:/app" -w /app php:8.4-cli php -r '
        $settings = json_decode(file_get_contents("src/Config/settings.json.default"), true, 512, JSON_THROW_ON_ERROR);
        $settings["i18n"]["baseUrl"] = getenv("SITE_URL");
        $settings["dbAdapterDefinition"]["username"] = getenv("MYSQL_USER");
        $settings["dbAdapterDefinition"]["password"] = getenv("MYSQL_PASSWORD");
        $settings["debug"] = false;
        $settings["analytics"]["enabled"] = false;
        file_put_contents("src/Config/Settings.json", json_encode($settings, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR) . "\n", LOCK_EX);
    '
    chgrp 33 src/Config/Settings.json
    chmod 640 src/Config/Settings.json
    echo "Created production Settings.json."
else
    echo "Using existing Settings.json."
fi

# Host Nginx terminates TLS and reaches the web container through the Compose network gateway.
# Trust exactly that address for X-Forwarded-For and X-Forwarded-Proto; otherwise the framework
# sees plain HTTP and, for example, refuses to show an integration key.
docker compose -f docker-compose.production.yml up --no-start --build
PROJECT=$(basename "$PWD" | tr 'A-Z' 'a-z' | tr -cd 'a-z0-9_-')
NETWORK=$(docker network ls -q --filter "label=com.docker.compose.project=$PROJECT" --filter "label=com.docker.compose.network=default")
GATEWAY=$(docker network inspect "$NETWORK" --format '{{(index .IPAM.Config 0).Gateway}}')
if [ -z "$GATEWAY" ]; then
    echo "Error: could not determine the Docker network gateway; set http.trustedProxies in src/Config/Settings.json manually." >&2
    exit 1
fi
export GATEWAY
docker run --rm -e GATEWAY -v "$PWD:/app" -w /app php:8.4-cli php -r '
    $file = "src/Config/Settings.json";
    $settings = json_decode(file_get_contents($file), true, 512, JSON_THROW_ON_ERROR);
    if (empty($settings["http"]["trustedProxies"])) {
        $settings["http"]["trustedProxies"] = [getenv("GATEWAY") . "/32"];
        $settings["http"]["forwardedHeaders"] = ["x-forwarded-for", "x-forwarded-proto"];
        file_put_contents($file, json_encode($settings, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR) . "\n", LOCK_EX);
        echo "Trusted proxy set to " . getenv("GATEWAY") . "/32.\n";
    }
'

docker compose -f docker-compose.production.yml up -d --build --wait

# Prepare framework API, analytics and change log tables from the exact installed release
for migration in 4.0.0/002-api-v2-integrations.sql 4.0.0/005-api-content.sql 4.0.0/006-analytics.sql 4.0.0/007-api-integration-last-used.sql 4.8.0/008-change-log-source.sql 4.10.0/009-remote-users.sql 5.0.0/010-drop-refresh-tokens.sql 6.1.0/011-integration-ip-restriction.sql; do
    docker compose -f docker-compose.production.yml exec -T web \
        cat "vendor/wbengine/wbengine/migrations/$migration" \
        | docker compose -f docker-compose.production.yml exec -T db \
            sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot wbengine_skeleton_app'
done

# Disable the publicly documented demo password before opening the public site.
DEMO_HASH=$(docker compose -f docker-compose.production.yml exec -T web php -r 'echo password_hash(bin2hex(random_bytes(48)), PASSWORD_DEFAULT);')
docker compose -f docker-compose.production.yml exec -T db \
    mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" wbengine_skeleton_app \
    -e "UPDATE cms_users SET password = '$DEMO_HASH' WHERE user_id = 1"

echo "Application containers are running at http://127.0.0.1:8080."
echo
echo "The demo password was disabled, so nobody can sign in yet. Create your administrator now:"
echo "  docker compose -f docker-compose.production.yml exec web php bin/wbe user:create --email=YOU@YOUR-DOMAIN --role=admin"
echo "Then sign in at /login/ and remove the demo account with: bin/wbe user:delete --example"
echo "Full guide: docs/deploy-vps-docker.md, section Users and the first login."
