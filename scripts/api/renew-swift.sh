#!/bin/sh
# Starts the renewal of Swift Couriers' Connect Plus asset (contract 00000104) from code:
#   POST /services/data/v68.0/connect/revenue-management/assets/actions/renew   (Asset Renewal, API 62.0 and later)
# It reads the asset ids and the contract id by query, builds scripts/api/renew-swift.json (generated, not committed),
# checks that no renewal quote exists yet for those products, sends the request with the CLI's login (no
# token appears here) and saves the answer to scripts/api/renew-swift.response.json (generated, not committed).
# The calling user needs the InitiateRenewal API permission set (RevLifecycleManagementInitiateRenewalApi).
# The dates are examples; in a demo org set them relative to today. Pass START and END to change them:
#   START=2029-02-01T00:00:00 END=2030-01-31T23:59:59 sh scripts/api/renew-swift.sh [org alias]
# The valid values of outputRecordType are not listed on the API page; Quote is used.
# Usage: sh scripts/api/renew-swift.sh [org alias]   (default org when none is given)
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/../.."
if [ -n "$1" ]; then TARGET_ORG="$1"; fi
. scripts/lib/common.sh

BODY=scripts/api/renew-swift.json
RESPONSE=scripts/api/renew-swift.response.json

# The contract and the products whose assets wait for renewal. Swift has two contracts; the Connect Plus asset made by
# the Swap in episode 34 sits on contract 00000104 and has no renewal yet. Asset Status and Quantity are empty on these
# assets (the quantity lives in AssetStatePeriod), so the assets are picked by product and by their contract link.
# Override with CONTRACT_NUMBER=... and PRODUCT_CODES="'VC-SUB','VC-PLUS'" to renew others.
CONTRACT_NUMBER="${CONTRACT_NUMBER:-00000104}"
PRODUCT_CODES="${PRODUCT_CODES:-'VC-PLUS'}"
CONTRACT=$(need_id "SELECT Id FROM Contract WHERE Account.Name = 'Swift Couriers' AND ContractNumber = '$CONTRACT_NUMBER' LIMIT 1" "contract $CONTRACT_NUMBER for Swift Couriers")

# shellcheck disable=SC2086
sf data query --json $ORG_FLAG --query "SELECT Id, Product2.ProductCode FROM Asset WHERE Account.Name = 'Swift Couriers' AND Product2.ProductCode IN ($PRODUCT_CODES) AND Id IN (SELECT AssetId FROM AssetContractRelationship WHERE ContractId = '$CONTRACT') ORDER BY LifecycleStartDate" > "$BODY.assets"

python3 - "$BODY" "$CONTRACT" "${START:-2029-02-01T00:00:00}" "${END:-2030-01-31T23:59:59}" <<'PY'
import json, sys
out, contract, start, end = sys.argv[1:5]
records = json.load(open(out + ".assets"))["result"]["records"]
ids = [r["Id"] for r in records]
if not ids:
    sys.exit("No assets of those products on contract " + contract + " for Swift Couriers.")
json.dump({"assetIds": ids, "contractId": contract, "outputRecordType": "Quote",
           "renewalStartDate": start, "renewalEndDate": end}, open(out, "w"), indent=2)
print("Renewing " + ", ".join(ids))
PY
rm -f "$BODY.assets"

# Repeat-call guard. A renewal quote made from an asset has no opportunity (the Renewal Quote of the Year 3 asset
# has none), so the check does not go through the opportunity. It stops when a quote named Renewal already holds a
# line for one of the products being renewed, or when this script has already saved a response.
OPEN=$(first_id "SELECT Id FROM Quote WHERE Name LIKE '%Renewal%' AND Id IN (SELECT QuoteId FROM QuoteLineItem WHERE Product2.ProductCode IN ($PRODUCT_CODES)) LIMIT 1")
if [ -n "$OPEN" ]; then
  echo "A renewal quote already exists ($OPEN). Not sending a second request." >&2
  exit 2
fi
if [ -s "$RESPONSE" ]; then
  echo "A response is already saved in $RESPONSE. Not sending a second request." >&2
  exit 2
fi

# shellcheck disable=SC2086
sf api request rest "/services/data/v68.0/connect/revenue-management/assets/actions/renew" --method POST --body "$(cat "$BODY")" $ORG_FLAG > "$RESPONSE"
cat "$RESPONSE"
