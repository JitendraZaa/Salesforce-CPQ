#!/bin/sh
# Brings an org to the start of episode 42: the Connect product with its prices in the standard price book (episodes
# 3 to 7), Swift Couriers, and an open opportunity for Swift on the standard price book. Episodes 14 to 23 (promotions,
# approvals, documents, contracts, billing setup, quote to order) are built on screen and are not repeated here.
# Usage: sh scripts/seed-ep23.sh   (default org, or TARGET_ORG=<alias>)
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/.."
. scripts/lib/common.sh
sh scripts/load-ep03.sh
sh scripts/load-ep05.sh
sh scripts/load-ep07.sh
BOOK=$(need_id "SELECT Id FROM Pricebook2 WHERE IsStandard = true" "standard price book")
ACCOUNT=$(ensure "SELECT Id FROM Account WHERE Name = 'Swift Couriers'" Account "Name='Swift Couriers' Has_Depot__c=true")
CLOSE=$(date -u -v+30d +%Y-%m-%d 2>/dev/null || date -u -d "+30 days" +%Y-%m-%d)
ensure "SELECT Id FROM Opportunity WHERE Name = 'Swift Couriers - Connect' AND AccountId = '$ACCOUNT'" Opportunity \
  "Name='Swift Couriers - Connect' AccountId=$ACCOUNT StageName=Prospecting CloseDate=$CLOSE Pricebook2Id=$BOOK" >/dev/null
echo "Opportunity ready. Rebuild the index and run Sync Pricing Data in the org if you have not."
