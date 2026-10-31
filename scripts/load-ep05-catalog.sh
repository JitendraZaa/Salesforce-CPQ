#!/bin/sh
# Episode 5: the category tree of Velora Catalog and which categories hold which product.
#   Vehicles: Vans (Volt Van), Cars (Aria, Wall Charger)
#   Charging: Depot (Depot Charger), Home (Wall Charger)
#   Services: Charger Installation, Velora Connect
# Run after scripts/load-ep03.sh and scripts/load-ep05.sh. Safe to run twice.
# Usage: sh scripts/load-ep05-catalog.sh   (default org, or TARGET_ORG=<alias>)
# @author Jitendra Zaa
set -e
. "$(dirname "$0")/lib/common.sh"

CATALOG=$(need_id "SELECT Id FROM ProductCatalog WHERE Code = 'VELORA'" "Velora Catalog (run scripts/load-ep03.sh)")

category() { # name, parent id or empty, sort order
  if [ -n "$2" ]; then
    ensure "SELECT Id FROM ProductCategory WHERE Name = '$1' AND CatalogId = '$CATALOG' AND ParentCategoryId = '$2'" \
      ProductCategory "Name=$1 CatalogId=$CATALOG ParentCategoryId=$2 SortOrder=$3"
  else
    ensure "SELECT Id FROM ProductCategory WHERE Name = '$1' AND CatalogId = '$CATALOG' AND ParentCategoryId = null" \
      ProductCategory "Name=$1 CatalogId=$CATALOG SortOrder=$3"
  fi
}
assign() { # category id, product code
  PRODUCT=$(need_id "SELECT Id FROM Product2 WHERE ProductCode = '$2'" "product $2")
  ensure "SELECT Id FROM ProductCategoryProduct WHERE ProductCategoryId = '$1' AND ProductId = '$PRODUCT'" \
    ProductCategoryProduct "ProductCategoryId=$1 ProductId=$PRODUCT" >/dev/null
}

VEHICLES=$(category Vehicles "" 1)
CHARGING=$(category Charging "" 2)
SERVICES=$(category Services "" 3)
VANS=$(category Vans "$VEHICLES" 1)
CARS=$(category Cars "$VEHICLES" 2)
DEPOT=$(category Depot "$CHARGING" 1)
HOME=$(category Home "$CHARGING" 2)

assign "$VANS" VV-100
assign "$CARS" AR-200
assign "$CARS" WC-11
assign "$DEPOT" DC-150
assign "$HOME" WC-11
assign "$SERVICES" SV-INST
assign "$SERVICES" VC-SUB

echo "Categories and assignments are in place."
echo "Next, in the org: Rebuild Index (partial), then Sync Pricing Data."
