#!/bin/sh
# Applies a payment to an invoice with the standard Apply Payment invocable action.
# The body file names the payment, the invoice (appliedToId) and the amount.
# Usage: sh scripts/api/apply-payment.sh [body file] [org alias]
# @author Jitendra Zaa
BODY="${1:-scripts/api/ep29-apply-payment.json}"
ORG="${2:-demo_cpq}"
sf api request rest "/services/data/v66.0/actions/standard/applyPayment" \
  --method POST --body "$(cat "$BODY")" --target-org "$ORG"
