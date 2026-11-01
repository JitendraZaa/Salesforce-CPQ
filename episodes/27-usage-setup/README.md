# Episode 27: Usage setup

All names, people, companies and numbers in this project are invented examples.

## What this episode builds

The Depot Charging product is made ready for usage billing: a unit of measure (kWh), a usage resource (Charging Energy), a monthly sum aggregation policy, a rate card with a rate of 0.21 per kWh, and billing policy Velora Arrears. Swift's second order for it (North Depot and Harbour Depot lines) is activated, so Swift has one charging asset per depot, each with a usage entitlement account and a Usage billing schedule.

## Before you start

- Starting point: the org as episode 26 left it (git tag `ep26-end`). A git tag restores files only, not the org.
- To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep26-end <org alias>`. It loads the data and lists the clicks that a script cannot do.
- Words used here are explained in `GLOSSARY.md` in this folder.

## Click path

1. Check access: the permission sets Usage Management Design Time, Rate Management Design Time User and a product designer set; org-wide defaults for the usage objects are Public Read/Write.
2. Create a unit of measure class `Energy` and a unit `kWh` (code KWH). The repo data holds them.
3. Open the product **Depot Charging** (code US-KWH): usage model type Anchor, billing policy Velora Arrears, selling model Term Based - Monthly.
4. On the product choose **Configure Usage Properties**, Product Usage Resources, **Add**: the resource `Charging Energy`. The out-of-the-box aggregation and overage policies fill in. Choose the aggregation policy **Sum Monthly**, set effective dates, Save.
5. Skip the usage grant: Depot Charging includes no free units.
6. In Rate Management open the base rate card `Velora Charging Rate Card`, Rate Card Entries, **New**: usage resource, product Depot Charging, selling model, rate **0.21**, unit USD, status Active, date range.
7. Create the **Price Book Rate Card**: standard price book plus Velora Charging Rate Card. Do this before you click Activate on the rate card: Activate needs the price book rate card to exist.
8. On Configure Usage Properties click **Activate**. Run the product validator.
9. Product Catalog Management, Index and Search Configuration, **Rebuild Index**; Salesforce Pricing Setup, **Sync Pricing Data**. Assign Depot Charging to a category.
10. Make a new quote on a new opportunity for Swift Couriers with Depot Charging twice, named North Depot and Harbour Depot, so the lines stay separate. Create the order, then **Activate** it.
11. After activation check Swift's assets: two Depot Charging assets, one per depot, each with a Usage Entitlement Account and a billing schedule with Billing Method Usage, status ReadyForInvoicing.

## Files in this repo used by this episode

- `scripts/seed.py` (the data loader) and `data/seed/manifest.json` (load order). Command: `python3 scripts/seed.py load <org alias> --only UnitOfMeasureClass,UnitOfMeasure,UsageResource,ProductUsageResource,RateCard,RateCardEntry,PriceBookRateCard,UsageResourceBillingPolicy,RatingFrequencyPolicy,UsageOveragePolicy,ProductUsageResourcePolicy`
  - `load`: create the records in the target org.
  - `<org alias>`: the name you gave the org in the Salesforce CLI.
  - `--only UnitOfMeasureClass,UnitOfMeasure,UsageResource,ProductUsageResource,RateCard,RateCardEntry,PriceBookRateCard,UsageResourceBillingPolicy,RatingFrequencyPolicy,UsageOveragePolicy,ProductUsageResourcePolicy`: load just these objects. Existing records are skipped, so it is safe to repeat.
  - `--dry-run` (optional): print what would be created and create nothing.
  - What they hold: `data/seed/08-UnitOfMeasureClass.json`, `09-UnitOfMeasure.json`, `37-UsageResource.json` (Charging Energy), `38-ProductUsageResource.json`, `39-RateCard.json` (Velora Charging Rate Card), `40-RateCardEntry.json` (Depot Charging at 0.21 per kWh), `41-PriceBookRateCard.json`, `45-UsageResourceBillingPolicy.json`, `46-RatingFrequencyPolicy.json`, `47-UsageOveragePolicy.json`, `52-ProductUsageResourcePolicy.json`. The product Depot Charging is in `18-Product2.json`.
  - After the load, Activate the product usage resource and the rate card entry in the org: the loader creates them as Draft and prints each one.
- `queries/ep27-rate-card.soql`: reads the rate card entry back (product, usage resource, rate, unit, status). Command: `sf data query --query "$(cat queries/ep27-rate-card.soql)" --target-org <org alias>`
  - `sf data query`: run a read-only query.
  - `--query "$(cat ...)"`: the text of the query from the file.
  - `--target-org`: which org.
- Not in the repo: Swift's two-line charging quote and order are results of the episode and are made by hand.

## What you should see

The rate card entry for Depot Charging is Active at 0.21 per kWh. The product is Active with its usage resource. After the order is activated, Swift has two charging assets (North, Harbour), each with a usage entitlement account and a Usage billing schedule.

## Records and values

Where this page and an older note differ, the latest recorded values (31 Oct 2026) and the Velora example values win.

- Product Depot Charging, code US-KWH, usage, 0.21 per kWh, billing policy Velora Arrears (billed monthly in arrears). Charging starts after the chargers are installed on 28 Jan 2027 (story).
- One charging asset per depot, so episode 36 can cancel the Harbour Depot alone.
- The September restart changes dates for episode 28: the rate card effective date was moved to 9/1/2026 and a new entry RCE-00000010 (0.21, 9/1 to 9/30) was made and activated, because an active entry can only change its status. Your own org needs the entry to start no later than the usage month.
- Create the price book rate card before you activate the rate card.
