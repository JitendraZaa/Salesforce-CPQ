# Episode 21: Negotiated prices that last

All names, people, companies and numbers in this project are invented examples.

## What this episode builds

A price agreement on Swift's Draft contract (00000104 in the example): the Volt Van at a negotiated price of 39,283.20 (One Time) from 1 Feb 2028 to 31 Jan 2030, the vans of Years 2 and 3, and Velora Connect at 29 (Term Based - Monthly). A new quote for 50 more vans, with the contract set as its Pricing Contract, shows the contract price as the line's new list price.

## Before you start

- Starting point: the org as episode 20 left it (git tag `ep20-end`): Swift's Draft contract, no contract item prices. A git tag restores files only, not the org.
- To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep20-end <org alias>`. It loads the data and lists the clicks that a script cannot do.
- Words used here are explained in `GLOSSARY.md` in this folder.

## Click path

1. Setup, Object Manager, Contract, Lightning Record Pages, open the Contract Record Page, click Edit, add a tab labelled **Pricing Schedule**, drag the **Contract Pricing Schedule** component into it, Save and Activate for the org. The repo holds this page.
2. Open Swift's Draft contract. Do the price work now: once a contract is activated its item prices cannot be edited or deleted and the status cannot go back to Draft.
3. Set **Contract Term** to 40 months first (end date 28 Feb 2030). Why first: the start date of a contract with item prices cannot be moved, so the contract keeps the start date of the day it was created.
4. Open the **Pricing Schedule** tab and look at the adjustment types: Amount Discount, Percent Discount, Negotiated Price, Negotiated Price and Discount, Volume Pricing. Add **Volt Van** with the type **Negotiated Price**: 39,283.20, start 2/1/2028, end 1/31/2030. Save. Only one price per product, selling model and date range is allowed on a contract.
5. Open the new row with **View**. On the Contract Item Price record set the product selling model to **One Time** (open the One Time selling model once first, because the lookup lists recently used items). Save.
6. Add **Velora Connect** the same way: price 29, selling model **Term Based - Monthly**, same dates. The tab now lists two contract item prices.
7. In Setup, Decision Tables, open **Contract Pricing Entries** and look at its inputs (contract, item, product selling model, dates). Why: Velora Pricing reads this table to find a contract price. Click Refresh. Then run **Sync Pricing Data** in Salesforce Pricing Setup (Sync, Confirm).
8. Click **Activated** on the contract.
9. Put the Pricing Contract field on the Quote layout: deploy the repo's layout (see the files) so a quote shows **Pricing Contract**. (Two fields share the label "Contract ID" on a quote; the repo's layout adds the right one.)
10. On the Swift Couriers account, Quotes, **New**: name `Swift 50 More Vans`, Pricing Contract 00000104. Add 50 Volt Van (Standard Panel). The line's start date is 15 Mar 2028, inside the agreement; open the line's side panel to read or set it. Reprice.
11. Click the line's **Net Unit Price** to open the price waterfall. Read it row by row: price book 48,000, List Price 39,283.20 marked Sourced From Contract, Volume Discount 4 percent (-1,571.33), net 37,711.87. Total for 50 vans 1,885,593.60. This quote only compares prices: delete it when you are done.

## Files in this repo used by this episode

- `force-app/main/default/flexipages/Contract_Record_Page.flexipage-meta.xml`: the Contract record page with the Pricing Schedule tab. Deploy: `sf project deploy start --source-dir force-app/main/default/flexipages --target-org <org alias>`
  - `--source-dir force-app/main/default/flexipages`: only the record pages in that folder.
- `force-app/main/default/layouts/Quote-Quote Layout.layout-meta.xml`: the Quote layout with Pricing Contract. Deploy: `sf project deploy start --source-dir force-app/main/default/layouts --target-org <org alias>`
- `force-app/main/default/expressionSetDefinition/Velora_Pricing.expressionSetDefinition-meta.xml`: the Velora Pricing procedure. It is not run directly; it prices the comparison quote and reads the contract price.
- No data file or script exists for the contract item prices: they belong to your own contract, so you enter them by hand as in the click path.

## What you should see

The Pricing Schedule tab lists Volt Van at 39,283.20, One Time, 2/1/2028 to 1/31/2030, and Velora Connect at 29. The contract is Activated. The 50-van line shows a waterfall that starts from the contract price and then applies the 4 percent volume tier.

## Records and values

- Contract 00000104: start 10/31/2026 (creation day), Contract Term 40 months, end 2/28/2030.
- Negotiated Volt Van: 39,283.20 (44,640 at the 100-and-more tier less 12 percent), One Time, 2/1/2028 to 1/31/2030.
- Without the agreement 50 vans price at 46,080 each (the 25 to 99 tier): 2,304,000. With the agreement: 39,283.20 becomes the list price and the volume tier still runs: 37,711.87 net each, 1,885,593.60 for 50.
- Lesson: a contract price replaces the list price; later steps of the procedure still run. Cumulative quantity pricing (250 vans reaching the 7 percent tier) is explained on a slide and is not built.

## Try it yourself

Change the quote's line start date to a day after 1/31/2030 and reprice: the waterfall goes back to the price book price, because the agreement no longer covers the date. Delete the comparison quote afterwards.
