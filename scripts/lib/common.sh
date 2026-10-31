# Shared helpers for the Velora Motors scripts. Source this file; do not run it.
# Every script uses the project's default org, or the org named in TARGET_ORG (an alias or username):
#   TARGET_ORG=velora_qa sh scripts/seed-second-org.sh
# @author Jitendra Zaa

ORG_FLAG=""
if [ -n "${TARGET_ORG:-}" ]; then ORG_FLAG="--target-org $TARGET_ORG"; fi

# Prints the Id of the first record a query returns, or nothing when there is none.
first_id() {
  # shellcheck disable=SC2086
  sf data query --query "$1" --json $ORG_FLAG | python3 -c "
import json, sys
records = json.load(sys.stdin)['result']['records']
print(records[0]['Id'] if records else '')"
}

# Prints the Id of the first record, and stops the script with a message when there is none.
need_id() {
  id=$(first_id "$1")
  if [ -z "$id" ]; then echo "Not found in the org: $2" >&2; exit 1; fi
  echo "$id"
}

# Creates a record unless the query already finds one; prints the Id either way.
# Usage: ensure "<query returning Id>" <sobject> "<field=value ...>"
ensure() {
  id=$(first_id "$1")
  if [ -n "$id" ]; then echo "$id"; return; fi
  # shellcheck disable=SC2086
  sf data create record --sobject "$2" --values "$3" --json $ORG_FLAG | python3 -c "
import json, sys
print(json.load(sys.stdin)['result']['id'])"
}

# Wraps a SOQL text value (single quotes doubled).
sq() { printf "%s" "$1" | sed "s/'/\\\\'/g"; }
