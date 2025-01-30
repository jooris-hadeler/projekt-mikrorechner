#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

java -jar "$SCRIPT_DIR/build/libs/projekt-mikrorechner-1.0-SNAPSHOT-all.jar" "$@"