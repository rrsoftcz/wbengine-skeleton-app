#!/bin/sh
set -eu

cd "$(dirname "$0")/.."
umask 077

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
        -e MYSQL_USER -e MYSQL_PASSWORD \
        -v "$PWD:/app" -w /app php:8.4-cli php -r '
        $settings = json_decode(file_get_contents("src/Config/settings.json.default"), true, 512, JSON_THROW_ON_ERROR);
        $settings["i18n"]["baseUrl"] = "https://www.wbengine.org";
        $settings["dbAdapterDefinition"]["username"] = getenv("MYSQL_USER");
        $settings["dbAdapterDefinition"]["password"] = getenv("MYSQL_PASSWORD");
        $settings["debug"] = false;
        $settings["analytics"]["enabled"] = false;
        $settings["jwt"]["accessKey"] = bin2hex(random_bytes(32));
        $settings["jwt"]["refreshKey"] = bin2hex(random_bytes(32));
        file_put_contents("src/Config/Settings.json", json_encode($settings, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR) . "\n", LOCK_EX);
    '
    chmod 600 src/Config/Settings.json
    echo "Created production Settings.json with fresh JWT keys."
else
    echo "Using existing Settings.json."
fi

docker compose -f docker-compose.production.yml up -d --build --wait

# Prepare framework API and analytics tables from the exact installed release.
for migration in 002-api-v2-integrations.sql 005-api-content.sql 006-analytics.sql; do
    docker compose -f docker-compose.production.yml exec -T web \
        cat "vendor/wbengine/wbengine/migrations/4.0.0/$migration" \
        | docker compose -f docker-compose.production.yml exec -T db \
            sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot wbengine_skeleton_app'
done

# Disable the publicly documented demo password before opening the public site.
DEMO_HASH=$(docker compose -f docker-compose.production.yml exec -T web php -r 'echo password_hash(bin2hex(random_bytes(48)), PASSWORD_DEFAULT);')
docker compose -f docker-compose.production.yml exec -T db \
    mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" wbengine_skeleton_app \
    -e "UPDATE cms_users SET password = '$DEMO_HASH' WHERE user_id = 1"

echo "Application containers are running at http://127.0.0.1:8080."
