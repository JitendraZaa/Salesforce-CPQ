#!/bin/sh
# Episode 7: Velora Connect (VC-SUB) gets two selling model options, Term Based - Monthly (default) and
# Evergreen - Monthly, and a 29 per month price book entry for each in the standard price book.
# The selling models already exist in the org; this script only looks them up. Safe to run twice.
# Usage: sh scripts/load-ep07.sh   (default org, or TARGET_ORG=<alias>)
# @author Jitendra Zaa
set -e
. "$(dirname "$0")/lib/common.sh"

CONNECT=$(need_id "SELECT Id FROM Product2 WHERE ProductCode = 'VC-SUB'" "Velora Connect (run scripts/load-ep05.sh)")
BOOK=$(need_id "SELECT Id FROM Pricebook2 WHERE IsStandard = true" "standard price book")
TERM=$(need_id "SELECT Id FROM ProductSellingModel WHERE Name = 'Term Based - Monthly' AND Status = 'Active'" "selling model Term Based - Monthly")
EVERGREEN=$(need_id "SELECT Id FROM ProductSellingModel WHERE Name = 'Evergreen - Monthly' AND Status = 'Active'" "selling model Evergreen - Monthly")
POLICY=$(first_id "SELECT Id FROM ProrationPolicy WHERE Name = 'Default Proration Policy'")

option() { # selling model id, default flag
  values="Product2Id=$CONNECT ProductSellingModelId=$1 IsDefault=$2"
  if [ -n "$POLICY" ]; then values="$values ProrationPolicyId=$POLICY"; fi
  ensure "SELECT Id FROM ProductSellingModelOption WHERE Product2Id = '$CONNECT' AND ProductSellingModelId = '$1'" \
    ProductSellingModelOption "$values" >/dev/null
}
entry() { # selling model id
  ensure "SELECT Id FROM PricebookEntry WHERE Product2Id = '$CONNECT' AND Pricebook2Id = '$BOOK' AND ProductSellingModelId = '$1'" \
    PricebookEntry "Pricebook2Id=$BOOK Product2Id=$CONNECT ProductSellingModelId=$1 UnitPrice=29 IsActive=true" >/dev/null
}
option "$TERM" true
option "$EVERGREEN" false
entry "$TERM"
entry "$EVERGREEN"

echo "Velora Connect has its two options and two prices."
echo "Next, in the org: Salesforce Pricing Setup > Sync Pricing Data (every price change ends with a sync)."
