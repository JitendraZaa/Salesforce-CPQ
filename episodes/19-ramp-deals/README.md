# Episode 19: Ramp deals

## What this episode builds

Swift's three-year plan with a different quantity each year. Quote V2 is grouped as Year 1, ramped as a group, and cloned into Years 2 and 3. Velora Connect grows from 100 to 200 to 300 vehicles with a 3 percent yearly uplift, and the deal metrics (annual charges, TCV, ACV, CMRR) are read from a query.

## Before you start

Starting point: tag `ep18-end`. V2 (quote 00000037) is the primary quote, approved and printed. Clone Quotes and Orders is on. You need Customize Application. Ramp deals are on the Growth, Advanced and Billing licences.

To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep18-end --org <your org alias>`. The script loads the data and lists the steps that must be done by hand. A git tag restores files only, never the org, so do not rely on `git checkout` to rebuild the org.

## Click path

1. In Setup, Revenue Settings, turn on Ramp Deals for Groups in Quotes and Orders (Groups and Clone Quotes and Orders must already be on). Leave Multiple Ramp Schedules Per Transaction off. Turn on Advanced Detail Line Pricing and set the default Ramp Uplift Type to compound.
2. Check Velora Pricing and the configurator flow include the latest ramp elements. If the procedure was cloned before the ramp update, clone the latest default again and re-add Velora's own steps.
3. In Lightning App Builder open the Quote Record Page, select the Sales Transaction Line Editor and show Start Date, End Date, Segment Type, Is Ramped and the group name; add Unit Price Uplift. The older Transaction Line Editor does not support group ramps.
4. On V2 switch the quote page to the Sales Transaction Line Editor. Add a group named Year 1 and move all of V2's lines into it. Click the group name, enter the Year 1 start and end dates, turn on Is Ramped, choose segment type Custom, and save.
5. Clone the segment to make Year 2 and build Year 3 (if Clone Segment gives an empty segment, build it by hand). In Years 2 and 3 keep one Standard Panel package line of 100 vans with the 12 percent discount, and remove the one-time items of Year 1.
6. Because Connect sits inside the package, show the earlier vans' plans continuing as a separate Velora Connect line: 100 in Year 2 and 200 in Year 3.
7. Set Unit Price Uplift 3 percent, compound, on Connect. Reprice All, click the net unit price and read the waterfall.
8. Run the metrics query (see files) to read the three Connect rows and work out the annual charges, TCV and ACV.

## Files in this repo used by this episode

- `force-app/main/default/flexipages/Quote_Record_Page.flexipage-meta.xml`: the Quote record page with the line editor. Redeploy it with `sf project deploy start --source-dir force-app/main/default/flexipages --target-org <alias>`.
- `force-app/main/default/classes/DealMetrics.cls` and `DealMetricsTest.cls`: Apex that works out the deal metrics (MRR, ARR, TCV, ACV) from quote lines, with its test. Run the test with `sf apex run test --target-org <alias> --class-names DealMetricsTest --result-format human --wait 10` (`--class-names` the test class, `--result-format human` readable output, `--wait 10` wait up to ten minutes).
- Settings files in `force-app/main/default/settings/` (Revenue Management) carry the ramp switches where the org accepts them; otherwise turn them on by hand as in step 1.
- Query used in the episode: `sf data query --query "SELECT SegmentName, StartDate, EndDate, Quantity, NetUnitPrice FROM QuoteLineItem WHERE QuoteId = '<V2 id>' AND Product2.ProductCode = 'VC-SUB' ORDER BY StartDate" --target-org <alias>`. `--query` is the SOQL, `<V2 id>` is V2's record id read from the quote's address. No `scripts/ep19-deal-metrics.sh` exists in the repository.

## What you should see

V2 has three groups, Year 1 to Year 3, in one ramp schedule. Velora Connect reads 100, 200, 300 vehicles at 29, 29.87 and 30.77. The metrics add up to the figures below.

## Records and values

All names and numbers are invented examples. Prices are in US dollars.

- Ramp: Year 1 from 1 Feb 2027 (100 vans), Year 2 from 1 Feb 2028 (100 vans), Year 3 from 1 Feb 2029 (100 vans); segment type Custom (Year 2 holds 29 Feb 2028). The ramp is a group ramp (decisions 66 and 67): a line ramp on Connect inside the package is refused because a bundled line is not valid for a ramp.
- Year 1 = V2 lines. Year 2 and Year 3: package of 100 Standard Panel vans at 39,283.20 (44,640 in the 100-and-more tier less 12 percent) plus a separate Connect line.
- Connect uplift 3 percent a year compound: 29, 29.87, 30.77 (30.7661 at full precision). The uplift applies to Connect only. The example org has no uplift element in its pricing procedure, so these Connect figures are Velora's rule shown as the value to expect.
- Annual Connect charges: 34,800; 71,688; 110,757.96. TCV 217,245.96; ACV 72,415.32 (TCV divided by 3). CMRR for month 13: 5,974 (200 x 29.87).
- Whole-year V2 charges: one-time 12,937,376; with Connect 13,146,176.
