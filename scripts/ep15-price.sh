#!/bin/sh
# Episode 15: sends the Pricing API request for 100 Volt Vans. The org comes from the PRICING_ORG environment
# variable (an alias), or the project's default org when it is not set.
#   PRICING_ORG=demo_cpq sh scripts/ep15-price.sh
# Change "Quantity" in a copy of scripts/ep15-pricing-body.json to try other tiers (25 gives 46,080).
# @author Jitendra Zaa
exec sh "$(dirname "$0")/api/price-100-vans.sh" "${PRICING_ORG:-}"
