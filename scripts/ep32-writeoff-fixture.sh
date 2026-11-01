#!/bin/sh
# Leaves 0.50 open on a real invoice, so the Write Off Invoices flow of episode 32 has something to write off.
# The org holds two Connect invoices. DOC-000000001 (2,900.00, nothing paid) is unpaid; this script records a payment
# of 2,899.50 by Swift Couriers and prints the body for the Apply Payment action (scripts/api/apply-payment.sh), so the
# balance becomes 0.50. Run it AFTER episode 31 is recorded: 31 shows DOC-000000001 still open at 2,900.00.
#
#   sh scripts/ep32-writeoff-fixture.sh        records the payment and writes scripts/api/ep32-apply-payment.json
#   sh scripts/api/apply-payment.sh scripts/api/ep32-apply-payment.json      applies it (the step to show on screen)
#
# Usage: sh scripts/ep32-writeoff-fixture.sh   (default org, or TARGET_ORG=<alias>)
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/.."
. scripts/lib/common.sh

SWIFT=$(need_id "SELECT Id FROM Account WHERE Name = 'Swift Couriers' LIMIT 1" "Swift Couriers")
LINE=$(need_id "SELECT Id FROM InvoiceLine WHERE Invoice.DocumentNumber = 'DOC-000000001' LIMIT 1" "the line of invoice DOC-000000001")
OPEN=$(first_id "SELECT Id FROM Invoice WHERE DocumentNumber = 'DOC-000000001' AND Balance = 2900 LIMIT 1")
PAYMENT=$(first_id "SELECT Id FROM Payment WHERE Account.Name = 'Swift Couriers' AND Amount = 2899.50 LIMIT 1")
if [ -z "$PAYMENT" ]; then
  if [ -z "$OPEN" ]; then echo "DOC-000000001 no longer has a balance of 2,900.00; nothing to prepare." >&2; exit 1; fi
  TMP=$(mktemp -d)
  sed "s/__SWIFT_ACCOUNT_ID__/$SWIFT/" data/ep32-collections/Payment.json > "$TMP/Payment.json"
  # shellcheck disable=SC2086
  sf data import tree --files "$TMP/Payment.json" $ORG_FLAG
  rm -rf "$TMP"
  PAYMENT=$(need_id "SELECT Id FROM Payment WHERE Account.Name = 'Swift Couriers' AND Amount = 2899.50 LIMIT 1" "the payment just created")
fi
cat > scripts/api/ep32-apply-payment.json <<EOF
{
  "inputs": [
    {
      "paymentId": "$PAYMENT",
      "appliedToId": "$LINE",
      "amount": 2899.50,
      "comments": "Swift pays 2,899.50 of the 2,900.00 Connect invoice; 0.50 is left"
    }
  ]
}
EOF
echo "Payment $PAYMENT recorded; body written to scripts/api/ep32-apply-payment.json."
echo "Apply it: sh scripts/api/apply-payment.sh scripts/api/ep32-apply-payment.json"
