#!/bin/sh
# Loads the products Velora Motors sells besides the Volt Van, puts every product in its family, and gives the one-time ones their selling model and
# list price in the standard price book. Velora Connect gets its prices in episode 7.
# Usage: sh scripts/load-ep05.sh   (default org, or TARGET_ORG=<alias>); does nothing when the products already exist.
set -e
. "$(dirname "$0")/lib/common.sh"
if [ -n "$(first_id "SELECT Id FROM Product2 WHERE ProductCode = 'AR-200'")" ]; then
  echo "The episode 5 products already exist; nothing loaded."
  exit 0
fi
sf data import tree --files data/ep05/Product2.json $ORG_FLAG
# The Volt Van from episode 3 joins the Vehicles family and gets its full description.
sf data update record --sobject Product2 --where "ProductCode='VV-100'" --values "Family=Vehicles Description='Electric panel van for urban deliveries. Two batteries, panel or refrigerated body, up to 350 km of range.'" $ORG_FLAG
q() { sf data query --query "$1" --json $ORG_FLAG | python3 -c "import json,sys; print(json.load(sys.stdin)['result']['records'][0]['Id'])"; }
BOOK=$(q "SELECT Id FROM Pricebook2 WHERE IsStandard = true")
ONETIME=$(q "SELECT Id FROM ProductSellingModel WHERE SellingModelType = 'OneTime' AND Status = 'Active' LIMIT 1")
for pair in "AR-200 39000" "DC-150 32000" "SV-INST 6800" "WC-11 1100"; do
  set -- $pair
  PRODUCT=$(q "SELECT Id FROM Product2 WHERE ProductCode = '$1'")
  sf data create record --sobject ProductSellingModelOption --values "Product2Id=$PRODUCT ProductSellingModelId=$ONETIME IsDefault=true" $ORG_FLAG
  sf data create record --sobject PricebookEntry --values "Pricebook2Id=$BOOK Product2Id=$PRODUCT ProductSellingModelId=$ONETIME UnitPrice=$2 IsActive=true" $ORG_FLAG
done
sf data query --query "SELECT Product2.Name, Product2.ProductCode, UnitPrice, ProductSellingModel.Name FROM PricebookEntry WHERE Product2.ProductCode IN ('AR-200','DC-150','SV-INST','WC-11')" $ORG_FLAG
