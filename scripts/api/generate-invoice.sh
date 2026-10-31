#!/bin/sh
# Creates and posts an invoice from billing schedules with the Billing Connect API.
# The body names the billing schedules, the invoice date and the target date.
# Usage: sh scripts/api/generate-invoice.sh [body file] [org alias]
# @author Jitendra Zaa
BODY="${1:-scripts/api/ep26-generate-invoice.json}"
ORG="${2:-demo_cpq}"
sf api request rest "/services/data/v65.0/commerce/invoicing/invoices/collection/actions/generate" \
  --method POST --body "$(cat "$BODY")" --target-org "$ORG"
