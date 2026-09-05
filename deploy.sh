#!/usr/bin/env bash
# Copy the WAR to Tomcat. Does NOT run SQL — the WAR migrator owns schema + seed.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

if [[ -x "$ROOT/mvnw" ]]; then
  MVN="$ROOT/mvnw"
else
  MVN="mvn"
fi
"$MVN" -B package

CATALINA_HOME="${CATALINA_HOME:-/usr/share/tomcat11}"
WEBAPPS="${WEBAPPS:-$CATALINA_HOME/webapps}"
NAME="${OPENMES_CONTEXT:-openmes}"

rm -rf "$WEBAPPS/$NAME" "$WEBAPPS/$NAME.war"
cp -f "$ROOT/target/openmes.war" "$WEBAPPS/$NAME.war"
echo "Deployed $WEBAPPS/$NAME.war — wait for GET /${NAME}/health → 200"
echo "Schema upgrades run inside the WAR on startup."
