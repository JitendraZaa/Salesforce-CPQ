#!/bin/sh
# Brings an org to the END state of an episode (which is the starting point of the next one).
#
# Usage: sh scripts/reset-to.sh ep<NN>-end [org alias] [--list-only]
#   ep<NN>-end   the episode to reach, from ep02-end to ep28-end (ep28-part1 is accepted for 28).
#   org alias    the Salesforce CLI alias of a NEW org that already ran "sh scripts/setup-org.sh <alias>".
#                With an alias, this script runs "sh scripts/seed-all.sh <alias>" (data only, safe to repeat:
#                records already there are skipped). Without an alias, it only prints the steps.
#   --list-only  print the manual steps without touching any org, even if an alias is given.
#
# What it does NOT do: a tag restores files, not the org, and this script never checks out source. Quotes, orders,
# contracts, assets, invoices and usage records are the RESULT of the episodes and are not in the data files, so the
# steps that make them, and every click Salesforce does not let a script do, are printed below for each episode up to
# the one you asked for. Dates in the data are not shifted; the story dates in docs are examples.
# @author Jitendra Zaa
set -e
cd "$(dirname "$0")/.."
TARGET="$1"; ALIAS=""; LIST=0
shift || true
for a in "$@"; do
  case "$a" in
    --list-only) LIST=1 ;;
    --*) echo "Unknown option $a" >&2; exit 1 ;;
    *) ALIAS="$a" ;;
  esac
done
N=$(printf '%s' "$TARGET" | sed -n 's/^ep\([0-9][0-9]\)-end$/\1/p;s/^ep\(28\)-part1$/\1/p')
if [ -z "$N" ] || [ "$N" -lt 2 ] || [ "$N" -gt 28 ]; then
  echo "Usage: sh scripts/reset-to.sh ep<02..28>-end [org alias] [--list-only]" >&2; exit 1
fi
N=$((10#$N))

if [ -n "$ALIAS" ] && [ "$LIST" = 0 ]; then
  echo "Loading the data into $ALIAS (scripts/seed-all.sh) ..."
  sh scripts/seed-all.sh "$ALIAS"
else
  echo "No data loaded (no org alias given, or --list-only). Run: sh scripts/seed-all.sh <alias>"
fi
echo
echo "Manual steps to reach the end of episode $N, in order:"

step() {
  # $1 episode number; the lines that follow on standard input are its steps
  if [ "$N" -ge "$1" ]; then
    echo
    echo "--- Episode $1 (see episodes/$2/README.md)"
    cat
  else
    cat >/dev/null
  fi
}

step 2 02-our-workspace <<'EOFSTEP'
Run: sh scripts/setup-org.sh <alias> (deploys settings, all metadata, assigns Velora_Fields and Velora_Quote_Action, loads data/seed).
Manual: in Revenue Settings check Enable Revenue Cloud Features, Configure Products at Runtime, Document Builder, Ramp Deals, Create Application Usage Type are on.
Manual: Salesforce Pricing Setup, Sync Pricing Data, Sync, Confirm.
Manual (scratch org): rename the running user to your own name so Created By shows it.
EOFSTEP

step 3 03-first-product <<'EOFSTEP'
Run: sh scripts/setup-org.sh <alias> (data/seed loads Volt Van VV-100, One Time option, 48,000 entry, Velora Catalog VELORA, Vehicles). Existing alternative: sh scripts/load-ep03.sh.
Manual: confirm an active One Time selling model exists (a new org has the nine standard ones).
Manual: nothing else; sync and index rebuild belong to episode 4.
EOFSTEP

step 4 04-first-quote <<'EOFSTEP'
Run: sh scripts/setup-org.sh <alias> (data/seed has the Swift Couriers account and Marcus Hale contact). Optional: sf data import tree --files data/ep04/Lead.json.
Manual: convert the lead (account Swift Couriers, opportunity Swift Couriers - Pilot).
Manual: create quote Swift Couriers Pilot Quote (expiry 11/30/2026) from the opportunity.
Manual: Product Catalog Management, Index and Search Configuration, Rebuild Index (full, about 10 minutes).
Manual: Salesforce Pricing Setup, Sync Pricing Data, Sync, Confirm.
Manual: Browse Catalogs, add Volt Van to the quote (line 48,000).
EOFSTEP

step 5 05-catalogs <<'EOFSTEP'
Run: sh scripts/setup-org.sh <alias> (data/seed loads all six products, categories, assignments, prices); or existing chain sh scripts/load-ep03.sh, load-ep05.sh, load-ep05-catalog.sh.
Manual: Index and Search Configuration, Rebuild Index (partial).
Manual: Salesforce Pricing Setup, Sync Pricing Data, Sync, Confirm.
Manual: pilot quote from episode 4 must exist (lead conversion, quote with Volt Van line).
EOFSTEP

step 6 06-attributes <<'EOFSTEP'
Run: sh scripts/setup-org.sh <alias> (data/seed loads picklists, values, attributes, Electric Vehicle classification, Based On).
Manual: activate anything the loader reports as Draft (attribute picklists, attributes, classification).
Manual: Index and Search Configuration, Rebuild Index (partial); Sync Pricing Data.
Manual: pilot quote: remove the old Volt Van line, add Volt Van through Browse Catalogs.
EOFSTEP

step 7 07-subscriptions <<'EOFSTEP'
Run: sh scripts/setup-org.sh <alias> (data/seed has Connect options and 29 entries); or sh scripts/load-ep07.sh.
Manual: Sync Pricing Data.
Manual: pilot quote: add Velora Connect (Term Based - Monthly) and set start date today, end date 12 months later.
Check: sf data query --file queries/ep07-quote-lines.soql.
EOFSTEP

step 8 08-bundles <<'EOFSTEP'
Run: sh scripts/setup-org.sh <alias> (data/seed loads package VVF-PKG, 3 groups, 3 components, option, 0 entry, Vans assignment).
Manual: assign permission set IndustriesARCPsl if the Structure tab is missing.
Manual: Index and Search Configuration, Rebuild Index (partial); Sync Pricing Data.
Manual: pilot quote: delete Volt Van and Connect lines, add Volt Van Fleet Package from Browse Catalogs, save configuration.
EOFSTEP

step 9 09-configuration-rules <<'EOFSTEP'
Run: sh scripts/setup-org.sh <alias> (settings, metadata, data).
Manual: Revenue Settings, turn on Configuration Rules with Business Rules Engine; activate latest version in the Configuration Rules library.
Manual: create rule 'Refrigerated Needs Long Range' (seq 10, Set Attribute Battery = Long Range 90 kWh) and 'Refrigerated Blocks Standard Battery' (seq 20, Disable Attribute Value Standard 60 kWh).
Manual: set the pilot quote Transaction Type to the Standard Configurator type; pilot ends on Standard and Panel.
EOFSTEP

step 10 10-qualification-rules <<'EOFSTEP'
Run: sh scripts/setup-org.sh <alias> (deploys Has Depot on Product Disqualification, context definitions, decision tables; data/seed loads accounts with Has Depot and 2 disqualification records).
Manual: Context Definitions, BrowseProductsCtxDefinition: add HasDepot, tag it, map to Account Has Depot.
Manual: Qualification Rules: Product Disqualification condition on Has_Depot__c, activate; build Product Qualification procedure in Qualification Rules Procedures (cannot be deployed), map input, activate.
Manual: Product Discovery Settings: context BrowseProductsCtxDefinition, procedure ProductQualification.
Manual: Sync Pricing Data; Refresh the Product Qualification and Product Disqualification decision tables.
EOFSTEP

step 11 11-configurator-flow <<'EOFSTEP'
Scripts: sh scripts/seed-all.sh <alias> (data); deploy force-app/main/default/flows (Velora_Product_Configurator).
Manual: set Sequence Body 1 and Battery 2 on the Electric Vehicle classification attributes.
Manual: activate flow Velora_Product_Configurator in Setup, Flows.
Manual: App Launcher, Product Configuration Flows: confirm the record (Active) exists and is assigned to Volt Van Fleet Package.
EOFSTEP

step 12 12-pricing-procedures <<'EOFSTEP'
Scripts: sh scripts/setup-org.sh <alias> deploys settings, the pricing procedure (Velora_Pricing) and context definitions, then loads data.
Manual: in Setup, Salesforce Pricing Setup: turn on Price Waterfall for API responses; Sync Pricing Data.
Manual: activate expression set Velora_Pricing version 1 (the deploy activates it) and make it the default in Revenue Settings.
EOFSTEP

step 13 13-volume-pricing <<'EOFSTEP'
Scripts: sh scripts/seed-all.sh <alias> (tiers and attribute adjustments are in data/seed); older: sh scripts/load-ep13.sh.
Manual: Volt Van, Attributes: tick Is Price Impacting on Battery and Body.
Manual: Setup, Decision Tables: Refresh Volume Discount Entries and Attribute Discount Entries.
Manual: Salesforce Pricing Setup: Sync Pricing Data.
Manual: create quote V1 (Swift Couriers - Fleet): Volt Van Fleet Package 40 Panel/Standard and 60 Refrigerated/Long Range with Wall Chargers, depot chargers 2, installations 2.
EOFSTEP

step 14 14-promotions <<'EOFSTEP'
Scripts: none for promotions (no promotion data in the repo); run the episode 13 reset first.
Manual (only if the org has the promotions licence): rule library, Promotion Execution element in Velora Pricing, turn promotions on, create Refrigerated Launch Offer, Sync Pricing Data.
Otherwise nothing to do: the promotion is a slide.
EOFSTEP

step 15 15-pricing-api <<'EOFSTEP'
Scripts: sh scripts/seed-all.sh <alias>; then the earlier manual steps (Sync Pricing Data, procedure active).
Nothing new is stored in the org by this episode: the call only reads prices.
Check: PRICING_ORG=<alias> sh scripts/ep15-price.sh prints net unit price 44,640.
EOFSTEP

step 16 16-approvals <<'EOFSTEP'
Scripts: sh scripts/setup-org.sh <alias> (deploys Velora_Fleet_Discount_Approval, Update_Quote_Status, Admin_Group, then data).
Manual: create users Priya Raman and Daniel Brooks; assign permission set licence and approval permission sets; give the quote owner a manager.
Manual: cost book Velora Costs (default) with Volt Van 34,000 and Velora Connect 9.
Manual: open Velora_Fleet_Discount_Approval in Flow Builder, choose the approver, activate.
Manual: rebuild quote V1 (see episode 13) and apply 12 percent to the 40 Standard Panel vans; move to Needs Review and approve twice.
EOFSTEP

step 17 17-quote-document <<'EOFSTEP'
Scripts: sh scripts/setup-org.sh <alias>.
Manual: Revenue Settings: Document Builder on; assign Document Builder User to the quote users.
Manual: Setup, Document Builder, New Template: label Velora Fleet Quote for Quote; add the Velora logo; Save, Activate, default.
Manual: rebuild quote V1 (episode 13 and 16) if the next episode needs it.
EOFSTEP

step 18 18-quote-versions <<'EOFSTEP'
Scripts: sh scripts/setup-org.sh <alias>.
Manual: Revenue Settings: Clone Quotes and Orders on. Quote page layout: add Deep Clone (and Start Sync) to the actions.
Manual: V1 (from episodes 13 and 16), then Deep Clone to V2; remove the Wall Chargers; Start Sync; approve; PDF; Expiration Date; Status Presented.
EOFSTEP

step 19 19-ramp-deals <<'EOFSTEP'
Scripts: sh scripts/setup-org.sh <alias>.
Manual: Revenue Settings: Ramp Deals for Groups on, Advanced Detail Line Pricing on, Ramp Uplift Type compound.
Manual: Quote record page: line editor columns (Start Date, End Date, Segment Type, Is Ramped, Unit Price Uplift).
Manual: V2: group Year 1, ramp it (Custom), build Years 2 and 3 with Connect lines of 100 and 200, uplift 3 percent, Reprice All.
EOFSTEP

step 20 20-contracts <<'EOFSTEP'
Clicks: add New Contract and the Quote Special Terms related list to the Quote layout (deploy the layout file); add New Contract to the Order layout by hand.
Check the clause library has the clause set and two clauses (data/seed 66-69 load them).
On V2 add the two special terms (8 years for the warranty), then New Contract with price choice None; leave Draft.
Scripts and data: scripts/seed-all.sh <alias> loads the clause data.
EOFSTEP

step 21 21-negotiated-prices <<'EOFSTEP'
Open the Draft contract from episode 20; set Contract Term 40 months first.
Pricing Schedule tab: Volt Van 39,283.20, One Time, with an end date inside the contract; Activate.
Refresh the contract pricing decision table, then Sync Pricing Data.
Deploy the Contract record page (force-app flexipages); run scripts/seed-all.sh <alias> for the base data.
EOFSTEP

step 22 22-billing-setup <<'EOFSTEP'
Permission sets Billing Admin and Billing Operations User for the working user.
Activate in order: treatment item, treatment, policy (Velora Advance, then Velora Arrears) after the data load.
Create Payment Term Net 30 and Swift Couriers Billing (default profile, bill day 1) by hand; set Billing Policy on each product.
Scripts and data: scripts/setup-org.sh <alias> deploys the Billing settings and flow and loads data/seed 17, 42-44.
EOFSTEP

step 23 23-quote-to-order <<'EOFSTEP'
Run the V2 approval by hand (status Needs Review, two approvals); Generate PDF; set Accepted.
Create Order from V2, set PO Number and Contract; leave it Draft.
Scripts and data: scripts/seed-all.sh <alias> for the base data; V2 and the order are results of the episodes and are not in the data files.
EOFSTEP

step 24 24-assets <<'EOFSTEP'
Order from episode 23 activated (Status Activated).
Flow Custom Assetize Order Flow and Order To Billing Schedule active; Assetizable ticked on the four products.
Add Asset Contract Relationship component to Asset and Contract layouts by hand.
Scripts and data: scripts/setup-org.sh <alias> deploys both flows.
EOFSTEP

step 25 25-fulfillment <<'EOFSTEP'
Create the technical products Charger Install Job and Connect Activation, the Install Chargers and Activate Connect steps, and the Activate Connect Step flow by hand.
Activate the decomposition rule set and refresh the two fulfillment decision tables.
Create the fresh order from V2, activate it, submit it, and complete the steps.
Scripts and data: scripts/seed-all.sh <alias> loads data/seed 56-64 (workspace, group, Build Vans, Deliver Vans, dependency, one rule, one scenario).
EOFSTEP

step 26 26-first-invoice <<'EOFSTEP'
Billing Batch Scheduler and invoice PDF are clicks; the invoice can also be posted with scripts/api/generate-invoice.sh (replace the schedule ids first).
Tax engine of type Revenue Standard Tax, policy assigned to Volt Van: by hand.
Scripts and data: scripts/seed-all.sh <alias>; queries/ep26-connect-schedules.soql to find the schedule ids.
EOFSTEP

step 27 27-usage-setup <<'EOFSTEP'
Activate the product usage resource and the rate card entry (the loader creates them Draft); create the price book rate card before activating.
Rebuild Index (full) and Sync Pricing Data.
Quote with Depot Charging twice (North Depot, Harbour Depot), create order, Activate.
Scripts and data: scripts/seed-all.sh <alias> loads the usage data (data/seed 08-09, 37-41, 45-47, 52).
EOFSTEP

step 28 28-usage-to-invoice <<'EOFSTEP'
Run the September order: quote Swift Depot Charging September, order activated, assets from 1 Sep.
Replace the ids in the CSV with your org's, import it with sf data import bulk.
Deploy the flow Velora_Orchestrate_Usage; schedule Entitlement Refresh first; set the rating delay to 0.
Create the usage invoice scheduler and post the invoice.
Scripts and data: queries/ep28-depot-assets.soql finds the asset ids; data/ep28-usage/transaction-journal-september.csv.
EOFSTEP
