#!/bin/sh
# Episode 13: the schedule Volt Van Fleet Tiers (Volume, Range) and its three tiers, upper bounds exclusive:
# [1,25) list price, [25,100) 4 percent, [100, open) 7 percent. The files in data/ep13 hold placeholders
# ({{EFFECTIVE_FROM}}, {{VOLT_VAN_ID}}, {{ONE_TIME_ID}}); this script fills them into a temporary copy, so no org id is
# ever written into the repository. Skips the load when the schedule already exists.
# Usage: sh scripts/load-ep13.sh   (default org, or TARGET_ORG=<alias>)
# @author Jitendra Zaa
set -e
. "$(dirname "$0")/lib/common.sh"

if [ -n "$(first_id "SELECT Id FROM PriceAdjustmentSchedule WHERE Name = 'Volt Van Fleet Tiers'")" ]; then
  echo "Volt Van Fleet Tiers already exists; nothing loaded."
else
  VAN=$(need_id "SELECT Id FROM Product2 WHERE ProductCode = 'VV-100'" "Volt Van (run scripts/load-ep03.sh)")
  ONETIME=$(need_id "SELECT Id FROM ProductSellingModel WHERE SellingModelType = 'OneTime' AND Status = 'Active' LIMIT 1" "a One Time selling model")
  NOW=$(date -u +%Y-%m-%dT%H:%M:%S.000+0000)
  WORK=$(mktemp -d)
  trap 'rm -rf "$WORK"' EXIT
  for f in priceadjustment.plan.json PriceAdjustmentSchedule.json PriceAdjustmentTier.json; do
    sed -e "s/{{EFFECTIVE_FROM}}/$NOW/g" -e "s/{{VOLT_VAN_ID}}/$VAN/g" -e "s/{{ONE_TIME_ID}}/$ONETIME/g" "data/ep13/$f" > "$WORK/$f"
  done
  # shellcheck disable=SC2086
  sf data import tree --plan "$WORK/priceadjustment.plan.json" $ORG_FLAG
fi

echo "Next, in the org (no command-line path is confirmed for these):"
echo "  1. Setup > Decision Tables > Volume Discount Entries > Refresh."
echo "  2. Salesforce Pricing Setup > Sync Pricing Data."
