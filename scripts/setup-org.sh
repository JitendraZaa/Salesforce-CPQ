#!/bin/sh
# Builds the Velora Motors project in an empty org: settings, then all metadata, then permission sets, then the data.
# For a scratch org, create it first:
#   sf org create scratch --definition-file config/revenue-cloud-scratch-def.json --alias velora_qa \
#     --target-dev-hub <dev hub alias> --duration-days 7 --set-default
# Usage: sh scripts/setup-org.sh <org alias>
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/.."
if [ -z "$1" ]; then echo "Usage: sh scripts/setup-org.sh <org alias>" >&2; exit 1; fi
ALIAS="$1"
echo "1/4 Settings (a bad flag here would fail the whole deploy, so they go first and alone)"
sf project deploy start --target-org "$ALIAS" --source-dir force-app/main/default/settings --ignore-conflicts
echo "2/4 All metadata (the context definition is about 2 MB and takes several minutes)"
sf project deploy start --target-org "$ALIAS" --source-dir force-app --ignore-conflicts
echo "3/4 Permission sets"
for p in Velora_Fields Velora_Quote_Action; do
  sf org assign permset --name "$p" --target-org "$ALIAS" || echo "$p was already assigned."
done
echo "4/4 Data"
sh scripts/seed-all.sh "$ALIAS"
