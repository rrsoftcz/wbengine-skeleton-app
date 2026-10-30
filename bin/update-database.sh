#!/bin/sh
# Applies the database updates that ship with the installed framework (API, analytics and change log tables).
# Every file is safe to run again. Keep the list in step with bin/setup-production.sh.
#
#   sh bin/update-database.sh [mysql options] DATABASE   apply through the mysql client
#   sh bin/update-database.sh --print                    print the SQL, to pipe into another mysql client
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
DIR="$ROOT/vendor/wbengine/wbengine/migrations"
FILES="4.0.0/002-api-v2-integrations.sql 4.0.0/005-api-content.sql 4.0.0/006-analytics.sql 4.0.0/007-api-integration-last-used.sql 4.8.0/008-change-log-source.sql 4.10.0/009-remote-users.sql 5.0.0/010-drop-refresh-tokens.sql 6.1.0/011-integration-ip-restriction.sql"

if [ ! -d "$DIR" ]; then
    echo "Error: $DIR is missing. Run composer install first." >&2
    exit 1
fi
if [ $# -eq 0 ]; then
    echo "Usage: sh bin/update-database.sh [mysql options] DATABASE | --print" >&2
    exit 2
fi
for f in $FILES; do
    # A framework version that does not ship a file does not need it.
    [ -f "$DIR/$f" ] || continue
    if [ "$1" = "--print" ]; then
        cat "$DIR/$f"
    else
        mysql "$@" < "$DIR/$f"
    fi
done
