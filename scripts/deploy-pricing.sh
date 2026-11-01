#!/bin/sh
# Deploys the Velora Pricing procedure (all its versions) from this project to another org.
#
# Why a script and not a plain deploy:
# 1. The procedure stores the Ids of price adjustment schedules (volume, attribute, bundle discounts) as constants.
#    Record Ids differ in every org, so each Id is swapped for the Id of the schedule with the same name in the
#    target org. The project file itself is not changed: the swapped copy goes to a temporary folder.
# 2. A deploy cannot change a version that is active in the target org, so the target's active versions of
#    Velora Pricing are deactivated first. The deployed file activates the versions again.
#
# Usage: sh scripts/deploy-pricing.sh <target org alias> [--dry-run]
#   --dry-run checks the deploy without saving anything (the deactivation still runs; the real deploy reactivates).
# The source org (where the Ids in the file come from) is demo_cpq; set SOURCE_ORG to change it.
# --ignore-conflicts: a scratch org tracks its own changes; this project's file is the version to keep.
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/.."
TARGET="$1"; DRY="$2"
if [ -z "$TARGET" ]; then echo "Usage: sh scripts/deploy-pricing.sh <target org alias> [--dry-run]" >&2; exit 1; fi
SOURCE="${SOURCE_ORG:-demo_cpq}"
FILE=force-app/main/default/expressionSetDefinition/Velora_Pricing.expressionSetDefinition-meta.xml
WORK=$(mktemp -d)
mkdir -p "$WORK/force-app/main/default/expressionSetDefinition"
cp sfdx-project.json "$WORK/"
cp "$FILE" "$WORK/$FILE"

# Ids of price adjustment schedules in the file (they start with 84X), swapped by name.
for ID in $(grep -o '84X[A-Za-z0-9]\{15\}' "$FILE" | sort -u); do
  NAME=$(sf data query -o "$SOURCE" --json -q "SELECT Name FROM PriceAdjustmentSchedule WHERE Id = '$ID'" 2>/dev/null | python3 -c "
import json, sys
s = sys.stdin.read(); r = json.loads(s[s.index('{'):])['result']['records']
print(r[0]['Name'] if r else '')")
  NEW=$(sf data query -o "$TARGET" --json -q "SELECT Id FROM PriceAdjustmentSchedule WHERE Name = '$NAME' LIMIT 1" 2>/dev/null | python3 -c "
import json, sys
s = sys.stdin.read(); r = json.loads(s[s.index('{'):])['result']['records']
print(r[0]['Id'] if r else '')")
  if [ -n "$NEW" ]; then
    sed -i '' "s/$ID/$NEW/g" "$WORK/$FILE"
    echo "Schedule \"$NAME\": $ID -> $NEW"
  else
    echo "Schedule \"$NAME\" is not in $TARGET; its Id is left as it is."
  fi
done

# Deactivate the versions that are active in the target org.
sf data query -o "$TARGET" --json -q "SELECT Id, ApiName FROM ExpressionSetVersion WHERE ExpressionSet.ApiName = 'Velora_Pricing' AND IsActive = true" 2>/dev/null | python3 -c "
import json, sys
s = sys.stdin.read()
for r in json.loads(s[s.index('{'):])['result']['records']: print(r['Id'], r['ApiName'])" | while read VID VNAME; do
  sf data update record -o "$TARGET" --sobject ExpressionSetVersion --record-id "$VID" --values "IsActive=false" >/dev/null 2>&1
  echo "Deactivated $VNAME in $TARGET"
done

cd "$WORK"
sf project deploy start --source-dir force-app --target-org "$TARGET" --ignore-conflicts $DRY
cd - >/dev/null
rm -rf "$WORK"
