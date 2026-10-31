#!/bin/sh
# Brings an org to the start of episode 11: episode 9 plus the Has Depot values and the qualification rule.
# Account.Has_Depot__c is deployed with the project: sf project deploy start --source-dir force-app/main/default/objects/Account
# Usage: sh scripts/seed-ep10.sh   (default org, or TARGET_ORG=<alias>)
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/.."
sh scripts/seed-ep09.sh
echo "Episode 10 by hand: tick Has Depot on Swift Couriers, leave it clear on another account, create the two disqualification records, update the context definition and qualification procedure."
