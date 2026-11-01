#!/bin/sh
# Small off-camera preparations for episode 32.
#
#   sh scripts/ep32-prepare.sh permsets
#       Assigns Billing Collections And Recovery Specialist (collection plans) and Credit Memo Operations User
#       (the write-off action) to the running user. Billing Operations User is already assigned.
#   sh scripts/ep32-prepare.sh email <address>
#       Puts an address Velora controls on Marcus Hale, Swift Couriers' contact, who has none; the reminder email
#       goes to it. Never use a customer's real address.
#
# Usage: sh scripts/ep32-prepare.sh permsets|email <address>   (default org, or TARGET_ORG=<alias>)
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/.."
. scripts/lib/common.sh

case "$1" in
  permsets)
    # shellcheck disable=SC2086
    sf org assign permset --name BillingCollectionsAndRecoverySpecialist --name RevenueLifecycleManagementBillingCreditMemoOperations $ORG_FLAG \
      || echo "A permission set may already be assigned, or the org lacks it."
    ;;
  email)
    if [ -z "$2" ]; then echo "Usage: sh scripts/ep32-prepare.sh email <an address Velora controls>" >&2; exit 1; fi
    CONTACT=$(need_id "SELECT Id FROM Contact WHERE Account.Name = 'Swift Couriers' AND LastName = 'Hale' LIMIT 1" "Marcus Hale at Swift Couriers")
    # shellcheck disable=SC2086
    sf data update record --sobject Contact --record-id "$CONTACT" --values "Email=$2" $ORG_FLAG
    ;;
  *)
    echo "Usage: sh scripts/ep32-prepare.sh permsets | email <address>" >&2; exit 1 ;;
esac
