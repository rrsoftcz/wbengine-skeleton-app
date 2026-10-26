#!/bin/sh
# Backwards-compatible entry point for existing instructions.
set -eu
cd "$(dirname "$0")/.."
exec php bin/wbe install "$@"
