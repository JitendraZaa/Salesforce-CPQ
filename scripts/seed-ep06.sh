#!/bin/sh
# Brings an org to the start of episode 7: episode 5 plus the attributes of episode 6.
# The attribute picklists, attributes, classification and the Based On value are created on screen in episode 6;
# this script does the data part (episode 5) and lists the rest. Rebuild the index (partial) and sync pricing data after.
# Usage: sh scripts/seed-ep06.sh   (default org, or TARGET_ORG=<alias>)
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/.."
sh scripts/seed-ep05.sh
echo "Episode 6 by hand: attribute picklists (Battery, Body, Trim, Colour), attribute definitions, the classification and the Based On value."
