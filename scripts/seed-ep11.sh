#!/bin/sh
# Brings an org to the start of episode 12: episode 10 plus the cloned configurator flow and its assignment.
# Usage: sh scripts/seed-ep11.sh   (default org, or TARGET_ORG=<alias>)
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/.."
sh scripts/seed-ep10.sh
echo "Episode 11 by hand: clone the Product Configurator flow, activate it, create the Product Configuration Flow record and its assignment, set attribute Sequence values."
