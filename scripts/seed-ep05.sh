#!/bin/sh
# Brings an org to the start of episode 6: episode 4 plus the five other products, the category tree and the
# assignments. Then rebuild the index (partial) and sync pricing data in the org.
# Usage: sh scripts/seed-ep05.sh   (default org, or TARGET_ORG=<alias>)
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/.."
sh scripts/seed-ep04.sh
sh scripts/load-ep05.sh
sh scripts/load-ep05-catalog.sh
