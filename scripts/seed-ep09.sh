#!/bin/sh
# Brings an org to the start of episode 10: episode 8 plus the configuration rule and the Business Rules Engine setting.
# Usage: sh scripts/seed-ep09.sh   (default org, or TARGET_ORG=<alias>)
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/.."
sh scripts/seed-ep08.sh
echo "Episode 9 by hand: turn on Configuration Rules with Business Rules Engine in Revenue Settings, create the rule (Refrigerated body requires Long Range battery), set the pilot quote Transaction Type."
