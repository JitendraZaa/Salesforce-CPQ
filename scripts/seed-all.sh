#!/bin/sh
# Loads all Velora reference data into an org, in dependency order: the catalog, products, price book entries,
# selling model options, attributes and classification, bundle structure, configuration, qualification rules,
# price adjustments, usage (units, resources, rate card), billing policy and treatment, legal entity, fulfillment
# design and the example accounts and contacts. The files are in data/seed/ (manifest.json gives the order); the
# loader is scripts/seed.py. Records already in the org (same name and same lookups) are skipped, so it can be run
# again. Metadata must be deployed first: sh scripts/setup-org.sh <alias> does both.
# Usage: sh scripts/seed-all.sh <org alias> [--dry-run]
# Afterwards, in the org, the steps that cannot be scripted: docs/REBUILD.md, section "Clicks after the data".
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/.."
if [ -z "$1" ]; then echo "Usage: sh scripts/seed-all.sh <org alias> [--dry-run]" >&2; exit 1; fi
ALIAS="$1"; shift
python3 scripts/seed.py load "$ALIAS" "$@"
echo
echo "Data loaded. Now do the clicks listed in docs/REBUILD.md (activations, Rebuild Index, Sync Pricing Data)."
