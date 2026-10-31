#!/bin/sh
# Brings an org to the start of episode 13: episode 11 plus the Velora Pricing procedure.
# Usage: sh scripts/seed-ep12.sh   (default org, or TARGET_ORG=<alias>)
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/.."
sh scripts/seed-ep11.sh
echo "Episode 12 by hand: clone the default pricing procedure as Velora Pricing, simulate it, activate it."
