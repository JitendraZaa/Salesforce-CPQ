# Episode 34: Amendments and proration

## What this episode builds

Two changes to Swift Couriers' running Connect subscription. First an amendment: 50 more vehicles from 15 March 2028, priced for the part month. Then an upgrade: 20 vehicles move from Velora Connect to a new, higher plan, Velora Connect Plus, from 1 July 2028, done as a Swap. Both go quote, accepted, order, activated, and the assets follow.

## Before you start

Starting point: the end of episode 33. Swift Couriers has the fleet contract 00000104 (start 10/31/2026, 40 months), the activated fleet order 00000126 and its assets. The Year 2 Velora Connect asset runs 1 Feb 2028 to 31 Jan 2029 with 100 vehicles at 29.87 (29 plus the 3 percent yearly uplift of episode 19). Velora Connect Plus does not exist yet.

To bring a fresh org as far as it can go by loading data, run `sh scripts/reset-to.sh ep28-end <your org alias>`; the quotes, contract, order and assets of episodes 18 to 26 are built on screen. A git tag restores files only, never the org. (This repository has no `ep33-end` tag yet.)

## Click path

Part 1: amend the quantity

1. Open the account Swift Couriers, Assets, Managed Assets. Scroll to the Year 2 Velora Connect asset (100 from 2/1/2028) and tick its checkbox. The buttons Amend, Renew and Cancel become active.
2. Click Amend. In Set Amendment Date choose Mar 15, 2028 and click Submit.
3. Amendment Quote 00000039 opens. On the Velora Connect line the change quantity is 0 and the price is 29.87 (the 3 percent uplift is kept). Set the change quantity to 50.
4. Reprice. The line reads 15,754.02: 50 vehicles x 29.87 x (17/31 of March plus 10 months). Why 17/31: 15 March to 31 March is 17 days of a 31-day month, then the 10 months to the end of the Year 2 term on 31 January 2029.
5. Set the quote Status to Accepted. Click Create Order, choose Create Single Order, and fill in the order: Contract 00000104, Bill To Marcus Hale, Legal Entity Velora Motors Inc., and the billing and shipping addresses. Save. Order 00000127 is created.
6. Open the order and click Activate (status Activated).
7. Open the Year 2 Connect asset and its Dashboard: quantity 100 until 3/14/2028 and 150 from 3/15/2028; the monthly recurring revenue graph rises with it.

Part 2: create Velora Connect Plus

8. In VS Code open `scripts/ep34-connect-plus.sh`, read it (see below), then run `sh scripts/ep34-connect-plus.sh demo_cpq` in the terminal.
9. In Setup, Index and Search Configuration, run a partial index rebuild, and wait for it to finish (Product Catalog Management). Why: Browse Catalogs finds only indexed products.
10. In Salesforce Pricing Setup choose Sync Pricing Data, Sync, Confirm. Why: the new price entry must reach the pricing data before a quote can price it.

Part 3: upgrade by Swap

11. Swift Couriers, Assets, Managed Assets: tick the Year 2 Velora Connect asset (150 in service). Open the menu next to Cancel and choose Swap.
12. In Swap Selections, Set Start Date: type Jul 1, 2028. In the Selected Asset(s) table set Swap Quantity to 20 (click the pencil, type 20, Enter). Click Next.
13. Choose Velora Catalog, click Next. Under Browse Products open the category Services, find Velora Connect Plus, set quantity 20 and click Add (Added Products shows 1). Click Next.
14. The swap quote opens with two lines from 07/01/2028: Velora Connect Plus +20 and Velora Connect -20. On the Connect Plus line set End Date to 01/31/2029 and Unit Price Uplift to 3. On the Connect line (the credit of the 20 swapped out) set Unit Price Uplift to 0. Why 0: the credit takes the asset's Year 2 price, which already includes the 3 percent.
15. Save, then Reprice All. Connect Plus reads 40.17 (39 plus 3 percent), 20 vehicles for the rest of the term = 5,623.80; the Connect credit is -4,181.80; Grand Total 1,442.00.
16. Set the quote Status to Accepted. Click Create Order, choose Create Single Order, fill in Contract 00000104, Bill To Marcus Hale, Legal Entity Velora Motors Inc. and the addresses, Save. The order (Draft, 1,442.00) holds Connect Plus +20 at 5,623.80 and Connect -20 at -4,181.80.
17. Click Activate. The assets now show Connect Plus 20 from 7/1/2028 and Connect reduced by 20.

## Files in this repo used by this episode

- `scripts/ep34-connect-plus.sh`: creates the Velora Connect Plus product (code VC-PLUS) by copying the settings of Velora Connect (code VC-SUB). Usage: `sh scripts/ep34-connect-plus.sh [org alias]`; the alias defaults to `demo_cpq`. Its steps:
  1. A helper `q` runs `sf data query -o "$ORG" -q "<SOQL>" --json` and a short Python line pulls one field out of the first record. Parts: `-o` is the target org, `-q` the query, `--json` prints machine-readable output. It reads from Velora Connect the record type and the billing policy, then looks up the selling model "Term Based - Monthly", the standard price book and the category Services.
  2. `sf data create record -o "$ORG" -s Product2 -v "Name='Velora Connect Plus' ProductCode=VC-PLUS IsActive=true IsAssetizable=true Family=Subscriptions RecordTypeId=... BillingPolicyId=... Description=..."` creates the product. Parts: `-s` is the object, `-v` the field values. IsAssetizable lets an order create an asset, which the Swap needs.
  3. `sf data create record -s ProductSellingModelOption -v "Product2Id=... ProductSellingModelId=..."` allows the monthly term-based model on the product.
  4. `sf data create record -s PricebookEntry -v "... UnitPrice=39 IsActive=true"` sets the standard price: 39 per vehicle per month.
  5. `sf data create record -s ProductCategoryProduct -v "ProductCategoryId=... ProductId=..."` puts the product in the Services category so reps can find it.
  It ends by reminding you of the index rebuild and Sync Pricing Data (steps 9 and 10).
- `scripts/reset-ep34.sh`: used by episode 43, not here. After the renewal call of episode 43 it lists and (after you answer yes) deletes the test renewal quotes on Swift Couriers, removes the generated request files, and runs `scripts/seed-ep35.sh` to check that the Connect assets are there. Usage: `sh scripts/reset-ep34.sh [org alias]`.
- Check the assets: `sf data query --query "SELECT Name, Quantity, Status FROM Asset WHERE Account.Name = 'Swift Couriers' AND Product2.ProductCode IN ('VC-SUB','VC-PLUS')" --target-org <alias>`.

## What you should see

Amendment Quote 00000039 gives 15,754.02 for the 50 added vehicles; order 00000127 is Activated; the Year 2 asset goes from 100 to 150 on 3/15/2028. Swap quote 00000042 reprices to Connect Plus 20 at 40.17 (5,623.80), Connect -20 (-4,181.80), Grand Total 1,442.00; order 00000130 is Draft until you activate it, then the assets show 20 Connect Plus.

## Records and values

All names and numbers are invented examples. Prices are in US dollars.

- Connect Year 2: 29.87 per vehicle per month (29 x 1.03).
- Amendment: +50 from 3/15/2028; 50 x 29.87 = 1,493.50 per month; 17/31 of March plus 10 months = 15,754.02.
- Connect Plus: 39 list, 40.17 with the 3 percent uplift (39 x 1.03 = 40.17).
- Swap: 20 vehicles, from 7/1/2028, Connect Plus end date 1/31/2029; net charge 1,442.00.

## Try it yourself

Amend the Connect asset again with a later date and a smaller quantity, then find Rollback in the Managed Assets menu and see what it restores (it reverses the most recent future-dated change). Do it on a copy of the org.
