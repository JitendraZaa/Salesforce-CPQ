# Episode 19: Ramp deals

## What this episode builds

Swift's three-year plan with a different quantity each year. Quote V2 is grouped as Year 1, ramped as a group, and cloned into Years 2 and 3. Velora Connect grows from 100 to 200 to 300 vehicles and rises 3 percent a year (29, 29.87, 30.77). The deal metrics (annual charges, TCV, ACV, CMRR) are read from a query.

## Before you start

Starting point: tag `ep18-end`. V2 (quote 00000037) is the primary quote, approved and presented. Clone Quotes and Orders is on. You need Customize Application. Ramp deals are on the Growth, Advanced and Billing licences.

To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep18-end <your org alias>`. The script loads the data and lists the steps that must be done by hand. A git tag restores files only, never the org, so do not rely on `git checkout` to rebuild the org.

## Click path

1. In Setup, Revenue Settings, turn on Ramp Deals for Groups in Quotes and Orders (Enable Groups in Quotes and Orders and Clone Quotes and Orders must already be on). Leave Multiple Ramp Schedules Per Transaction off. The default Ramp Uplift Type stays Standard.
2. In Setup, Lightning App Builder, open the Quote Record Page, select the Lines tab and use the Sales Transaction Line Editor component (the older Transaction Line Editor does not support group ramps). In its settings show Start Date, End Date, Segment Type, Is Ramped and the group name, and add Unit Price Uplift. Save and activate. (The repo's `Quote_Record_Page` has these columns.)
3. Open V2, Lines tab. Add a group named Year 1 and move all of V2's lines into it.
4. Click the group name. In the side panel enter Start Date 2/1/2027, End Date 1/31/2028, turn on Is Ramped, Segment Type Custom, Sort Order 1, and Save. Year 1 is now the first segment.
5. Open the group menu, choose Clone Segment, and clone All Line Items. The new segment takes the next year's dates. Rename it Year 2 and set the dates 2/1/2028 to 1/31/2029. Build Year 3 the same way (2/1/2029 to 1/31/2030). Open Edit Ramp Schedule to check the three segment names, dates and durations.
6. In Years 2 and 3 keep one Volt Van Fleet Package line of 100 Standard Panel vans (the 12 percent discount) and remove the one-time items of Year 1 (depot chargers and installations).
7. Because Connect sits inside the package, add the earlier vans' plans as a separate Velora Connect line: 100 in Year 2 and 200 in Year 3.
8. Set the uplift. First, Setup, Pricing Procedures, Velora Pricing, Deactivate. In VS Code open `force-app/main/default/expressionSetDefinition/Velora_Pricing.expressionSetDefinition-meta.xml`: a list group UpliftContainer keeps lines whose uplift is not empty and not zero, and the Formula Based Pricing step Uplift calculates `NetUnitPrice * (1 + ItemUnitPriceUplift__std)`. Deploy it (command below). The deployed version is active again.
9. In the line editor, type Unit Price Uplift 3 on the Year 2 Connect lines and 6.09 on the Year 3 Connect lines. Why 6.09 and not 3: each line holds the running total since Year 1, 1.03 x 1.03 = 1.0609.
10. Click Reprice All. Click the Year 3 Connect net unit price: the waterfall shows list 29, Uplift 6.09 percent +1.77, net 30.77 (30.7661 at full precision).
11. Run the metrics query (below) to read the Connect rows and work out the annual charges, TCV and ACV.

## Files in this repo used by this episode

- `force-app/main/default/flexipages/Quote_Record_Page.flexipage-meta.xml`: the Quote record page with the line editor. Redeploy with `sf project deploy start --source-dir force-app/main/default/flexipages --target-org <alias>`.
- `force-app/main/default/expressionSetDefinition/Velora_Pricing.expressionSetDefinition-meta.xml`: Velora Pricing with the Uplift step.
- Deploy the pricing procedure with: `sf project deploy start --source-dir force-app/main/default/expressionSetDefinition/Velora_Pricing.expressionSetDefinition-meta.xml --target-org <alias>`. In parts: `sf project deploy start` sends source files to the org; `--source-dir` names the file or folder to send; `--target-org` is the org alias. Deactivate the procedure version in Setup first.
- `force-app/main/default/classes/DealMetrics.cls` and `DealMetricsTest.cls`: Apex that works out the deal metrics (MRR, ARR, TCV, ACV) from quote lines, with its test. Run the test with `sf apex run test --target-org <alias> --class-names DealMetricsTest --result-format human --wait 10` (`--class-names` the test class, `--result-format human` readable output, `--wait 10` wait up to ten minutes).
- Settings in `force-app/main/default/settings/` carry the ramp switches where the org accepts them; otherwise turn them on as in step 1.
- Metrics query: `sf data query --query "SELECT SegmentName, StartDate, EndDate, Quantity, NetUnitPrice FROM QuoteLineItem WHERE QuoteId = '<V2 id>' AND Product2.ProductCode = 'VC-SUB' ORDER BY StartDate" --target-org <alias>`. In parts: `--query` is the SOQL; `<V2 id>` is V2's record id (the 15 or 18 characters in the quote's address); `Product2.ProductCode = 'VC-SUB'` keeps only Velora Connect lines; `ORDER BY StartDate` lists the years in order; `--target-org` is the org alias.

## What you should see

V2 has three groups, Year 1 to Year 3, in one ramp schedule. Velora Connect reads 100, 200, 300 vehicles at 29, 29.87 and 30.77. V2 totals 13,154,621.96. The metrics add up to the figures below.

## Records and values

All names and numbers are invented examples. Prices are in US dollars.

- Ramp: Year 1 from 1 Feb 2027 (100 vans), Year 2 from 1 Feb 2028 (100 vans), Year 3 from 1 Feb 2029 (100 vans), ending 31 Jan 2030; segment type Custom. It is a group ramp: Connect inside the package is not ramped on its own, so earlier vans' plans continue as a separate Connect line.
- Year 1 = V2's lines. Years 2 and 3: a package of 100 Standard Panel vans at 39,283.20 (44,640 in the 100-and-more tier less 12 percent) plus a separate Connect line.
- Connect uplift 3 percent a year compound: 29, 29.87, 30.77 (30.7661 at full precision). Unit Price Uplift typed: 0, 3, 6.09.
- Annual Connect charges: 34,800; 71,688; 110,757.96. TCV 217,245.96; ACV 72,415.32 (TCV divided by 3). CMRR for month 13: 5,974 (200 x 29.87).
- V2 total 13,154,621.96 (one-time 12,937,376 plus Connect 217,245.96).

## Try it yourself

Set the Ramp Uplift Type to Standard in Edit Ramp Schedule, rebuild the Year 3 uplift, run the query again, and compare Year 3 with the compound figure. The step reads the value typed on the line, so the compounding comes from the running totals you type. Then set it back.
