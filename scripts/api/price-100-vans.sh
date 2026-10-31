#!/bin/sh
# Prices 100 Volt Vans with the Pricing API (POST /connect/core-pricing/pricing) and prints the response.
# The ids differ in every org, so they are looked up by name here and filled into a temporary copy of
# scripts/ep15-pricing-body.json. Expected net unit price: 44,640 (48,000 less the 7 percent volume tier).
# Usage: sh scripts/api/price-100-vans.sh [org alias]   (default org when none is given)
# The body keys come from the org's quote mapping; if the call is rejected, see the notes in episode 15's README.
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/../.."
if [ -n "$1" ]; then TARGET_ORG="$1"; fi
. scripts/lib/common.sh

CONTEXT=$(need_id "SELECT Id FROM ContextDefinition WHERE DeveloperName = 'RevSalesTransactionContext'" "context definition RevSalesTransactionContext")
MAPPING=$(need_id "SELECT Id FROM ContextMapping WHERE Title = 'QuoteEntitiesMapping' AND ContextDefinitionVersion.ContextDefinitionId = '$CONTEXT'" "context mapping QuoteEntitiesMapping")
BOOK=$(need_id "SELECT Id FROM Pricebook2 WHERE IsStandard = true" "standard price book")
VAN=$(need_id "SELECT Id FROM Product2 WHERE ProductCode = 'VV-100'" "Volt Van")
ONETIME=$(need_id "SELECT Id FROM ProductSellingModel WHERE SellingModelType = 'OneTime' AND Status = 'Active' LIMIT 1" "a One Time selling model")
ENTRY=$(need_id "SELECT Id FROM PricebookEntry WHERE Product2Id = '$VAN' AND Pricebook2Id = '$BOOK' AND ProductSellingModelId = '$ONETIME'" "the Volt Van One Time price book entry")

BODY=$(mktemp)
trap 'rm -f "$BODY"' EXIT
python3 - "$BODY" "$CONTEXT" "$MAPPING" "$BOOK" "$VAN" "$ENTRY" "$ONETIME" <<'PY'
import json, sys
out, context, mapping, book, van, entry, model = sys.argv[1:8]
body = json.load(open("scripts/ep15-pricing-body.json"))
body["contextDefinitionId"] = context
body["contextMappingId"] = mapping
quote = body["jsonDataString"]["SalesTransaction"][0]
quote["Pricebook"] = book
line = quote["SalesTransactionItem"][0]
line["Product"], line["PricebookEntry"], line["ProductSellingModel"] = van, entry, model
json.dump(body, open(out, "w"))
PY

# shellcheck disable=SC2086
sf api request rest "/services/data/v68.0/connect/core-pricing/pricing" --method POST --body "$BODY" $ORG_FLAG
