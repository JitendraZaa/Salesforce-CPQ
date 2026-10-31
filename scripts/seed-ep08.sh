#!/bin/sh
# Brings an org to the start of episode 9: episode 7 plus the Volt Van Fleet Package (bundle, groups, components).
# The bundle is built on screen in episode 8; no data file is kept for it because its object names are not confirmed.
# Usage: sh scripts/seed-ep08.sh   (default org, or TARGET_ORG=<alias>)
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/.."
sh scripts/seed-ep07.sh
echo "Episode 8 by hand: the bundle product, its option and price entry, three groups and three components, then an index rebuild and a pricing sync."
