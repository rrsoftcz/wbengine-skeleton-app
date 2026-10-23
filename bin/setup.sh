#!/bin/sh
# One-time setup of a fresh checkout: config with random JWT keys, writable
# template cache, PHP dependencies.
set -e
cd "$(dirname "$0")/.."

CFG=src/Config/Settings.json

if [ -f "$CFG" ]; then
    echo "$CFG already exists, leaving it untouched."
else
    cp src/Config/settings.json.default "$CFG"
    ACCESS=$(openssl rand -hex 32)
    REFRESH=$(openssl rand -hex 32)
    sed -e "s/\"accessKey\": \"CHANGE_ME\"/\"accessKey\": \"$ACCESS\"/" \
        -e "s/\"refreshKey\": \"CHANGE_ME\"/\"refreshKey\": \"$REFRESH\"/" \
        "$CFG" > "$CFG.tmp"
    mv "$CFG.tmp" "$CFG"
    echo "Created $CFG with new random JWT keys."
fi

mkdir -p src/View/Compiled
# Template cache only. The web server user must be able to write here (development setup).
chmod 777 src/View/Compiled 2>/dev/null || true

if command -v composer >/dev/null 2>&1; then
    composer install
else
    echo "composer not found: run 'composer install' inside the web container instead:"
    echo "  docker compose exec web composer install"
fi
