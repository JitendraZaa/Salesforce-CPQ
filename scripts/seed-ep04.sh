#!/bin/sh
# Brings an org to the start of episode 5: the Volt Van with its One Time model and 48,000 price, and Velora Catalog
# with the category Vehicles. Episodes 2 to 4 were done by hand on screen, so this repeats them as data.
# Not scripted (done on screen in episode 4): converting the Swift Couriers lead (data/ep04/Lead.json), the pilot
# opportunity and the pilot quote with one Volt Van line, the product index build and the pricing sync.
# Usage: sh scripts/seed-ep04.sh   (default org, or TARGET_ORG=<alias>)
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/.."
sh scripts/load-ep03.sh
echo "Episode 4 by hand: load data/ep04/Lead.json, convert it, create the pilot opportunity and quote."
