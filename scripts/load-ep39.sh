#!/bin/sh
# Loads the data episode 39 needs around Lena Fischer, the Aria owner.
#
#   sh scripts/load-ep39.sh aria [--activate]
#       After the account and contact exist (the episode builds them on screen), puts Lena's Aria on her account as a
#       draft order with one line, the Aria at 39,000 from the standard price book, and links it to the Revenue
#       Lifecycle Management application usage. With --activate it also sets the order to Activated, which runs the
#       org's asset flow and gives her the Aria as an asset (the vehicle Velora Connect is bought for).
#   sh scripts/load-ep39.sh people <email>
#       For a rehearsal only: creates the account and the contact from data/ep39-lena/Account-Contact.json, with an
#       email address you control. Do not run it before the take that builds them on screen.
#
# Safe to run twice: it checks before it creates.
# Usage: sh scripts/load-ep39.sh aria|people ... (default org, or TARGET_ORG=<alias>)
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/.."
. scripts/lib/common.sh
MODE="$1"

lena_account() { first_id "SELECT Id FROM Account WHERE Name = 'Lena Fischer' LIMIT 1"; }

case "$MODE" in
  people)
    EMAIL="$2"
    if [ -z "$EMAIL" ]; then echo "Usage: sh scripts/load-ep39.sh people <an email address you control>" >&2; exit 1; fi
    if [ -n "$(lena_account)" ]; then echo "Lena Fischer is already in the org."; exit 0; fi
    TMP=$(mktemp -d)
    sed "s/__LENA_EMAIL__/$EMAIL/" data/ep39-lena/Account-Contact.json > "$TMP/Account-Contact.json"
    # shellcheck disable=SC2086
    sf data import tree --files "$TMP/Account-Contact.json" $ORG_FLAG
    rm -rf "$TMP"
    ;;
  aria)
    ACCOUNT=$(need_id "SELECT Id FROM Account WHERE Name = 'Lena Fischer' LIMIT 1" "the Lena Fischer account (build it on screen first, or run: sh scripts/load-ep39.sh people <email>)")
    CONTACT=$(need_id "SELECT Id FROM Contact WHERE AccountId = '$ACCOUNT' AND LastName = 'Fischer' LIMIT 1" "the Lena Fischer contact")
    EXISTING=$(first_id "SELECT Id FROM Order WHERE AccountId = '$ACCOUNT' AND Name = 'Lena Fischer - Aria' LIMIT 1")
    if [ -z "$EXISTING" ]; then
      BOOK=$(need_id "SELECT Id FROM Pricebook2 WHERE IsStandard = true" "standard price book")
      LEGAL=$(need_id "SELECT Id FROM LegalEntity WHERE Name = 'Velora Motors Inc.'" "legal entity Velora Motors Inc.")
      ENTRY=$(need_id "SELECT Id FROM PricebookEntry WHERE Product2.ProductCode = 'AR-200' AND Pricebook2Id = '$BOOK' AND IsActive = true LIMIT 1" "the Aria in the standard price book")
      TODAY=$(date -u +%Y-%m-%d)
      TMP=$(mktemp -d)
      sed -e "s/__LENA_ACCOUNT_ID__/$ACCOUNT/" -e "s/__LENA_CONTACT_ID__/$CONTACT/" -e "s/__PRICEBOOK_ID__/$BOOK/" \
          -e "s/__LEGAL_ENTITY_ID__/$LEGAL/" -e "s/__ARIA_PBE_ID__/$ENTRY/" -e "s/__TODAY__/$TODAY/" \
          data/ep39-lena/Order.json > "$TMP/Order.json"
      # shellcheck disable=SC2086
      sf data import tree --files "$TMP/Order.json" $ORG_FLAG
      rm -rf "$TMP"
      EXISTING=$(need_id "SELECT Id FROM Order WHERE AccountId = '$ACCOUNT' AND Name = 'Lena Fischer - Aria' LIMIT 1" "the order just created")
    else
      echo "Lena's Aria order is already there ($EXISTING)."
    fi
    # The asset flow reads this record to know the order is a Revenue Lifecycle Management order.
    AUA=$(first_id "SELECT Id FROM AppUsageAssignment WHERE RecordId = '$EXISTING' LIMIT 1")
    if [ -z "$AUA" ]; then
      # shellcheck disable=SC2086
      sf data create record --sobject AppUsageAssignment --values "RecordId=$EXISTING AppUsageType=RevenueLifecycleManagement" $ORG_FLAG
    fi
    if [ "$2" = "--activate" ]; then
      # shellcheck disable=SC2086
      sf data update record --sobject Order --record-id "$EXISTING" --values "Status=Activated" $ORG_FLAG
      echo "Order activated. Check the asset: SELECT Id, Name, Status FROM Asset WHERE Account.Name = 'Lena Fischer'"
    else
      echo "Order $EXISTING is in Draft. Add --activate to turn it into an asset."
    fi
    ;;
  *)
    echo "Usage: sh scripts/load-ep39.sh aria [--activate] | people <email>" >&2; exit 1 ;;
esac
