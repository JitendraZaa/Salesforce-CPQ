# Episode 13: Volume pricing

## What this episode builds

Volume discounts for the Volt Van, and the option prices for the configured van. The Volt Van reprices as the quantity grows (48,000 at 24, 46,080 at 25, 44,640 at 100) and each price opens as a waterfall. The same 100 vans are priced two ways, Range and Slab. Then Swift's first fleet quote, V1, is built with each line priced at its own quantity.

## Before you start

Starting point: tag `ep12-end`. Velora Pricing is active and the default, with Pricing Setting and List Price, and the price waterfall is on. Your user needs the Salesforce Pricing Design Time permission set.

To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep12-end --org <your org alias>`. The script loads the data and lists the steps that must be done by hand. A git tag restores files only, never the org, so do not rely on `git checkout` to rebuild the org.

## Click path

1. Open the schedule Standard Volume Based Adjustment (App Launcher, Price Adjustment Schedules). Velora Pricing reads its volume tiers from this schedule.
2. Add the tiers for the Volt Van, one-time: lower bound 1 and upper bound 24 (list price); lower 25, upper 99, 4 percent; lower 100, no upper bound, 7 percent. Both bounds are inclusive in this org, so 24 to 25 and 99 to 100 must not overlap.
3. In Setup, Decision Tables, open Volume Discount Entries and click Refresh. Why: the procedure reads the table, not the tier records.
4. Open Velora Pricing in the builder and check the Volume Discount element is after List Price and reads the Volume Discount Entries table. Make a small change, save, then Simulate with quantity 100 and Activate.
5. In Salesforce Pricing Setup run Sync Pricing Data (Sync, then Confirm).
6. Option prices: open the Volt Van, Attributes, View All, Configure, and tick Is Price Impacting on Battery and on Body. Why: the adjustment wizard refuses until this is set.
7. On the schedule Standard Attribute Based Adjustment add an adjustment for each combination of both attributes. Use the type Override: Standard Panel with Long Range 90 kWh is 54,500, Refrigerated with Long Range is 58,700, both from the day you enter them. Refresh the Attribute Discount Entries decision table after each change, then Sync Pricing Data.
8. On the opportunity Swift Couriers - Fleet create the quote. It starts with the opportunity's products. Delete the plain Volt Van line.
9. Add two Volt Van Fleet Package lines: 40 vans (Panel, Standard battery, with Wall Charger) and 60 vans (Refrigerated, Long Range, with Wall Charger). Add the depot chargers and installations.
10. On a test quote set the van quantity to 24, 25, 99 and 100, click the net unit price each time and read the waterfall. Then price 100 vans with a copy of the schedule set to Slab and compare the totals (Range 4,464,000, Slab 4,652,640). Restore the Range schedule and delete the copy.

## Files in this repo used by this episode

- `data/ep13/priceadjustment.plan.json`, `PriceAdjustmentSchedule.json`, `PriceAdjustmentTier.json`: an early version of the tiers, a schedule named Volt Van Fleet Tiers and three tiers. Note: these files write the upper bounds as 25 and 100 (exclusive). The org compares bounds inclusively, so for the current series use the values in the steps above (1 to 24, 25 to 99, 100 and more); the tier data in `data/seed/` (`31-PriceAdjustmentSchedule.json`, `32-PriceAdjustmentTier.json`) is the loaded set.
- `scripts/load-ep13.sh`: loads the early schedule and tiers from `data/ep13`. It looks up the Volt Van and the One Time selling model by name, fills the placeholders into a temporary copy, so no org id is written to the repository, and does nothing if the schedule exists. Run `sh scripts/load-ep13.sh` (uses the default org, or set `TARGET_ORG=<alias>`). It then prints the two clicks it cannot do: refresh Volume Discount Entries and Sync Pricing Data.
- `data/seed/34-AttributeBasedAdjRule.json`, `35-AttributeAdjustmentCondition.json`, `36-AttributeBasedAdjustment.json`: the attribute-based adjustments (the option prices). `sh scripts/seed-all.sh <alias>` loads them. Flag: `--dry-run` prints what would be created without creating it.
- `scripts/seed-ep13.sh`: chains the earlier episodes' seed scripts and `load-ep13.sh`.

## What you should see

The Volt Van line reads 48,000 at 24, 46,080 at 25 and 99, and 44,640 at 100, each with its waterfall. 100 vans total 4,464,000 under Range and 4,652,640 under Slab. A Refrigerated Long Range van lists at 58,700. Quote V1 has the two package lines and each line is priced at its own quantity.

## Records and values

All names and numbers are invented examples. Prices are in US dollars.

- Tiers (inclusive): 1-24 list price; 25-99 4 percent; 100 and more 7 percent.
- Base van: 48,000 at 24; 46,080 at 25 and 99; 44,640 at 100.
- Option prices (type Override): Panel + Long Range 54,500; Refrigerated + Long Range 58,700. Standard battery with Panel is the plain 48,000.
- Tiers apply per line quantity, not across the quote. V1: 40 Standard Panel vans at 46,080; 60 Refrigerated Long Range vans at 58,700 less 4 percent = 56,352 each.
- Range for 100 base vans: 100 x 44,640 = 4,464,000. Slab: 24 x 48,000 + 75 x 46,080 + 1 x 44,640 = 4,652,640.
- Test basis: 100 Refrigerated Long Range vans = 58,700 less 7 percent = 54,591 each.
