#!/bin/sh
# Brings an org to the start of episode 43: Swift Couriers with active Connect and Connect Plus assets, and the
# permission set the renewal API needs. The assets come from episodes 19 to 36 (ramp deal, contract, order, assets,
# amendments, Year 3), which are built on screen; this script checks that they exist and assigns the permission set.
# Contract renewal terms: RenewalTerm2 = 12, RenewalTermUnit = Months (data/ep35/contract-renewal-terms.json).
# Usage: sh scripts/seed-ep35.sh   (default org, or TARGET_ORG=<alias>)
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/.."
. scripts/lib/common.sh

# shellcheck disable=SC2086
sf org assign permset --name RevLifecycleManagementInitiateRenewalApi $ORG_FLAG || echo "Permission set already assigned, or not available in this org."

COUNT=$(sf data query --query "SELECT COUNT(Id) c FROM Asset WHERE Account.Name = 'Swift Couriers' AND Product2.ProductCode IN ('VC-SUB','VC-PLUS')" --json $ORG_FLAG | python3 -c "import json,sys; print(json.load(sys.stdin)['result']['records'][0]['c'])")
if [ "$COUNT" = "0" ]; then
  echo "No Connect assets for Swift Couriers yet. Build the deal through episodes 19 to 36 first." >&2
  exit 1
fi

CONTRACT=$(need_id "SELECT Id FROM Contract WHERE Account.Name = 'Swift Couriers' LIMIT 1" "a contract for Swift Couriers")
# shellcheck disable=SC2086
sf data update record --sobject Contract --record-id "$CONTRACT" --values "RenewalTerm2=12 RenewalTermUnit=Months" $ORG_FLAG
