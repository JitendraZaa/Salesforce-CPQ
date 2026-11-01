#!/bin/sh
# Loads what episode 38 needs before the camera runs: Crumb & Co Bakery with its owner Dana Whitfield as a contact,
# and the standard price book on the bakery's open opportunity (the quote is made for that account).
# If the account is already in the org (the seed loads it), only the contact and the price book are added.
# If it is not, data/ep38-bakery/Account-Contact.json creates the account and the contact together.
# Safe to run twice: it checks before it creates.
# Usage: sh scripts/load-ep38.sh   (default org, or TARGET_ORG=<alias>)
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/.."
. scripts/lib/common.sh

ACCOUNT=$(first_id "SELECT Id FROM Account WHERE Name = 'Crumb & Co Bakery' LIMIT 1")
if [ -z "$ACCOUNT" ]; then
  # shellcheck disable=SC2086
  sf data import tree --files data/ep38-bakery/Account-Contact.json $ORG_FLAG
  echo "Created the account and the contact."
else
  CONTACT=$(first_id "SELECT Id FROM Contact WHERE AccountId = '$ACCOUNT' AND LastName = 'Whitfield' LIMIT 1")
  if [ -z "$CONTACT" ]; then
    TMP=$(mktemp -d)
    sed "s/__BAKERY_ACCOUNT_ID__/$ACCOUNT/" data/ep38-bakery/Contact.json > "$TMP/Contact.json"
    # shellcheck disable=SC2086
    sf data import tree --files "$TMP/Contact.json" $ORG_FLAG
    rm -rf "$TMP"
    echo "Created the contact on the existing account $ACCOUNT."
  else
    echo "The bakery contact is already there."
  fi
fi

# The bakery's opportunity carries no price book yet; quotes for it need the standard one.
BOOK=$(need_id "SELECT Id FROM Pricebook2 WHERE IsStandard = true" "standard price book")
OPP=$(first_id "SELECT Id FROM Opportunity WHERE Name = 'Crumb & Co Bakery - Delivery Vans' AND Pricebook2Id = null LIMIT 1")
if [ -n "$OPP" ]; then
  # shellcheck disable=SC2086
  sf data update record --sobject Opportunity --record-id "$OPP" --values "Pricebook2Id=$BOOK" $ORG_FLAG
  echo "Set the standard price book on the bakery opportunity."
fi
echo "Done. Sharing the account with Brightside's partner users is an on-camera step in the episode."
