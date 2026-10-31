#!/bin/sh
# Starts the renewal of Swift Couriers' Connect and Connect Plus assets from code:
#   POST /services/data/v68.0/connect/revenue-management/assets/actions/renew   (Asset Renewal, API 62.0 and later)
# It reads the asset ids and the contract id by query, builds scripts/api/renew-swift.json (generated, not committed),
# checks that no renewal quote exists yet on the contract's opportunity, sends the request with the CLI's login (no
# token appears here) and saves the answer to scripts/api/renew-swift.response.json (generated, not committed).
# The calling user needs the InitiateRenewal API permission set (RevLifecycleManagementInitiateRenewalApi).
# The dates are examples; in a demo org set them relative to today. Pass START and END to change them:
#   START=2030-02-01T00:00:00 END=2031-01-31T23:59:59 sh scripts/api/renew-swift.sh [org alias]
# The valid values of outputRecordType are not listed on the API page; Quote is used.
# Usage: sh scripts/api/renew-swift.sh [org alias]   (default org when none is given)
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/../.."
if [ -n "$1" ]; then TARGET_ORG="$1"; fi
. scripts/lib/common.sh

BODY=scripts/api/renew-swift.json
RESPONSE=scripts/api/renew-swift.response.json

# shellcheck disable=SC2086
sf data query --json $ORG_FLAG --query "SELECT Id FROM Asset WHERE Account.Name = 'Swift Couriers' AND Product2.ProductCode IN ('VC-SUB','VC-PLUS') AND Status = 'Active'" > "$BODY.assets"
CONTRACT=$(need_id "SELECT Id FROM Contract WHERE Account.Name = 'Swift Couriers' LIMIT 1" "a contract for Swift Couriers")

python3 - "$BODY" "$CONTRACT" "${START:-2030-02-01T00:00:00}" "${END:-2031-01-31T23:59:59}" <<'PY'
import json, sys
out, contract, start, end = sys.argv[1:5]
ids = [r["Id"] for r in json.load(open(out + ".assets"))["result"]["records"]]
if not ids:
    sys.exit("No active Connect assets for Swift Couriers.")
json.dump({"assetIds": ids, "contractId": contract, "outputRecordType": "Quote",
           "renewalStartDate": start, "renewalEndDate": end}, open(out, "w"), indent=2)
PY
rm -f "$BODY.assets"

OPEN=$(first_id "SELECT Id FROM Quote WHERE Opportunity.Account.Name = 'Swift Couriers' AND Name LIKE '%Renewal%' LIMIT 1")
if [ -n "$OPEN" ]; then
  echo "A renewal quote already exists ($OPEN). Not sending a second request." >&2
  exit 2
fi

# shellcheck disable=SC2086
sf api request rest "/services/data/v68.0/connect/revenue-management/assets/actions/renew" --method POST --body "$BODY" $ORG_FLAG > "$RESPONSE"
cat "$RESPONSE"
