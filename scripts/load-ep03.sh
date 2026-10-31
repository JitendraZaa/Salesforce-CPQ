#!/bin/sh
# Episode 3: the Volt Van, its One Time selling model and 48,000 price in the standard price book, and Velora Catalog
# (code VELORA) with the category Vehicles holding the van. Safe to run twice: it creates only what is missing.
# Usage: sh scripts/load-ep03.sh   (default org, or TARGET_ORG=<alias>)
# @author Jitendra Zaa
set -e
. "$(dirname "$0")/lib/common.sh"

if [ -z "$(first_id "SELECT Id FROM Product2 WHERE ProductCode = 'VV-100'")" ]; then
  # shellcheck disable=SC2086
  sf data import tree --files data/ep03/Product2.json $ORG_FLAG
fi
VAN=$(need_id "SELECT Id FROM Product2 WHERE ProductCode = 'VV-100'" "Volt Van")
BOOK=$(need_id "SELECT Id FROM Pricebook2 WHERE IsStandard = true" "standard price book")
ONETIME=$(need_id "SELECT Id FROM ProductSellingModel WHERE SellingModelType = 'OneTime' AND Status = 'Active' LIMIT 1" "an active One Time selling model")

ensure "SELECT Id FROM ProductSellingModelOption WHERE Product2Id = '$VAN' AND ProductSellingModelId = '$ONETIME'" \
  ProductSellingModelOption "Product2Id=$VAN ProductSellingModelId=$ONETIME IsDefault=true" >/dev/null
ensure "SELECT Id FROM PricebookEntry WHERE Product2Id = '$VAN' AND Pricebook2Id = '$BOOK' AND ProductSellingModelId = '$ONETIME'" \
  PricebookEntry "Pricebook2Id=$BOOK Product2Id=$VAN ProductSellingModelId=$ONETIME UnitPrice=48000 IsActive=true" >/dev/null

CATALOG=$(ensure "SELECT Id FROM ProductCatalog WHERE Code = 'VELORA'" ProductCatalog "Name='Velora Catalog' Code=VELORA")
VEHICLES=$(ensure "SELECT Id FROM ProductCategory WHERE Name = 'Vehicles' AND CatalogId = '$CATALOG'" ProductCategory "Name=Vehicles CatalogId=$CATALOG")
ensure "SELECT Id FROM ProductCategoryProduct WHERE ProductCategoryId = '$VEHICLES' AND ProductId = '$VAN'" \
  ProductCategoryProduct "ProductCategoryId=$VEHICLES ProductId=$VAN" >/dev/null

echo "Episode 3 data is in place."
echo "Next, in the org: Product Catalog Management > Index and Search Configuration > Rebuild Index (full), then"
echo "Salesforce Pricing Setup > Sync Pricing Data. Without them Browse Catalogs is empty and lines price at 0."
