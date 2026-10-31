#!/bin/sh
# Brings an org to the end of episode 13 (tag ep13-end): everything up to the volume tiers. Run it on the demo org
# before episode 40. Steps done on screen are printed as reminders by the scripts it chains.
# Usage: sh scripts/seed-ep13.sh   (default org, or TARGET_ORG=<alias>)
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/.."
sh scripts/seed-ep12.sh
sh scripts/load-ep13.sh
