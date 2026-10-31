#!/bin/sh
# Restores the ep34-end state after episode 43: deletes the renewal quote(s) the renewal call created, then re-runs
# the checks of scripts/seed-ep35.sh. Deletion is of test records in your own demo org only.
# Usage: sh scripts/reset-ep34.sh [org alias]   (default org when none is given)
# It deletes quotes whose name contains "Renewal" on Swift Couriers' opportunities, after listing them and asking.
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/.."
if [ -n "$1" ]; then TARGET_ORG="$1"; export TARGET_ORG; fi
. scripts/lib/common.sh

# shellcheck disable=SC2086
sf data query --query "SELECT Id, Name FROM Quote WHERE Opportunity.Account.Name = 'Swift Couriers' AND Name LIKE '%Renewal%'" $ORG_FLAG
printf "Delete the quotes listed above? (yes/no) "
read -r answer
if [ "$answer" = "yes" ]; then
  # shellcheck disable=SC2086
  sf data query --query "SELECT Id FROM Quote WHERE Opportunity.Account.Name = 'Swift Couriers' AND Name LIKE '%Renewal%'" --json $ORG_FLAG \
    | python3 -c "import json,sys; [print(r['Id']) for r in json.load(sys.stdin)['result']['records']]" \
    | while read -r id; do sf data delete record --sobject Quote --record-id "$id" $ORG_FLAG; done
fi
rm -f scripts/api/renew-swift.json scripts/api/renew-swift.response.json
sh scripts/seed-ep35.sh
