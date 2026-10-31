#!/bin/sh
# Loads the data of episodes 3 to 13 into a second org (the test org of episodes 40 and 41) and assigns the project
# permission sets. Metadata is deployed separately; metadata does not carry records.
# Usage: sh scripts/seed-second-org.sh <org alias>
# Afterwards, in the target org: Rebuild Index (full), then Salesforce Pricing Setup > Sync Pricing Data.
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/.."
if [ -z "$1" ]; then echo "Usage: sh scripts/seed-second-org.sh <org alias>" >&2; exit 1; fi
export TARGET_ORG="$1"
sh scripts/load-ep03.sh
sh scripts/load-ep05.sh
sh scripts/load-ep05-catalog.sh
sh scripts/load-ep07.sh
sh scripts/load-ep13.sh
sf org assign permset --name Velora_Fields --target-org "$TARGET_ORG" || echo "Velora_Fields was already assigned, or is not deployed yet."
echo "Second org seeded. Rebuild the product index and run Sync Pricing Data before pricing anything."
