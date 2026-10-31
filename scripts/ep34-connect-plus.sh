#!/bin/sh
# Creates Velora Connect Plus (VC-PLUS), the telematics plan for refrigerated routes, set up like Velora Connect:
# same record type, billing policy and category, monthly term-based selling model, and a standard price of 39.
# Every value is looked up by name, so the script works in any org seeded from this repo.
# Usage: sh scripts/ep34-connect-plus.sh [org alias]
# @author Jitendra Zaa
ORG="${1:-demo_cpq}"
q() { sf data query -o "$ORG" -q "$1" --json | python3 -c "import json,sys; r=json.load(sys.stdin)['result']['records']; print(r[0]['$2'] if r else '')"; }

echo "1. Read Velora Connect, the product we copy the settings from"
RT=$(q "SELECT RecordTypeId FROM Product2 WHERE ProductCode='VC-SUB'" RecordTypeId)
BP=$(q "SELECT BillingPolicyId FROM Product2 WHERE ProductCode='VC-SUB'" BillingPolicyId)
PSM=$(q "SELECT Id FROM ProductSellingModel WHERE Name='Term Based - Monthly'" Id)
PB=$(q "SELECT Id FROM Pricebook2 WHERE IsStandard=true" Id)
CAT=$(q "SELECT Id FROM ProductCategory WHERE Name='Services'" Id)

echo "2. Create the product Velora Connect Plus"
sf data create record -o "$ORG" -s Product2 -v "Name='Velora Connect Plus' ProductCode=VC-PLUS IsActive=true IsAssetizable=true Family=Subscriptions RecordTypeId=$RT BillingPolicyId=$BP Description='Telematics for refrigerated routes: fridge temperature and door alerts on top of Velora Connect.'"
P=$(q "SELECT Id FROM Product2 WHERE ProductCode='VC-PLUS'" Id)

echo "3. Allow the monthly term-based selling model"
sf data create record -o "$ORG" -s ProductSellingModelOption -v "Product2Id=$P ProductSellingModelId=$PSM"

echo "4. Standard price: 39 per vehicle per month"
sf data create record -o "$ORG" -s PricebookEntry -v "Pricebook2Id=$PB Product2Id=$P ProductSellingModelId=$PSM UnitPrice=39 IsActive=true"

echo "5. Put it in the Services category so reps can find it"
sf data create record -o "$ORG" -s ProductCategoryProduct -v "ProductCategoryId=$CAT ProductId=$P"

echo "Done. Next, in Setup: rebuild the search index and run Sync Pricing Data."
