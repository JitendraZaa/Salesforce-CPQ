#!/bin/sh
# Brings an org to the start of episode 8: episode 6 plus the Connect options and the two 29 per month prices.
# Usage: sh scripts/seed-ep07.sh   (default org, or TARGET_ORG=<alias>)
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/.."
sh scripts/seed-ep06.sh
sh scripts/load-ep07.sh
