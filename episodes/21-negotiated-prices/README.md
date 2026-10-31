# Episode 21: Negotiated prices that last

All names, people, companies and numbers in this project are invented examples.

## What this episode builds

A price agreement on Swift's Draft contract: the Standard Panel Volt Van at a final net price of 39,283.20, with no further volume or manual adjustment, from 1 Feb 2027 to 31 Jan 2030. A 50-van comparison quote generated from the contract shows that price. Episode 34's amendment prices its 50 vans from this agreement.

## Before you start

- Starting point: the org as episode 20 left it (git tag `ep20-end`). A git tag restores files only, not the org.
- To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep20-end <org alias>`. It loads the data and lists the clicks that a script cannot do.
- Words used here are explained in `GLOSSARY.md` in this folder.

## Click path

1. In Setup, Object Manager, Contract, Lightning Record Pages, open the Contract Record Page, click Edit, add a tab labelled **Pricing Schedule**, drag the **Contract Pricing Schedule** component into it, and Save (and Activate the page if asked). The repo holds this page.
2. Open Swift's Draft contract (made in episode 20). Do the price work now: once a contract is activated its item prices cannot be edited or deleted, the status cannot go back to Draft, and only a new product can still be added.
3. First set the **Contract Term** to 40 months (this gives the end date 28 Feb 2030) before adding prices. you cannot extend the Start Date of a contract that already has contract item prices, so the contract keeps its start date of creation day.
4. Open the **Pricing Schedule** tab, search and add **Volt Van**. Only one price per product and selling model is allowed on a contract. Enter the contract price 39,283.20, the start date and the end date, and Save.
5. Open the row with **View**, and on the Contract Item Price subtab set the product selling model to **One Time** (open the One Time item first, because the lookup only shows recently used items). Save and close.
6. Keep the agreement to the Standard Panel van only. Add a Velora Connect price of 29 the same way if the episode shows it.
7. Give each one-time price an End Date inside the contract's range. Without one, activation fails with a message about a missing end date.
8. Click **Activate** on the contract. Then refresh the contract pricing decision table (Setup, Decision Tables) and run **Sync Pricing Data** in Salesforce Pricing Setup.
9. Open the Swift opportunity and click New Quote. Name it `Swift Couriers 50 Vans`, set the contract on the quote, delete the copied lines, and add 50 Volt Van (Standard, Panel). Save.
10. Click the **Net Unit Price** of the line to open the calculation details. You should see 39,283.20 and no volume tier or manual discount after the contract price. This quote is only a comparison: delete it at the end.

## Files in this repo used by this episode

- `force-app/main/default/flexipages/Contract_Record_Page.flexipage-meta.xml`: the Contract record page with the Pricing Schedule tab. Deploy: `sf project deploy start --source-dir force-app/main/default/flexipages --target-org <org alias>`.
  - `--source-dir force-app/main/default/flexipages`: deploy only the record pages in that folder.
- `force-app/main/default/expressionSetDefinition/` (the Velora Pricing procedure): reads the contract price. Not run directly; it prices the comparison quote.
- No script or data file exists for the contract item prices themselves: they are records tied to your own contract, so you enter them by hand as in the click path.

## What you should see

On the contract, the Pricing Schedule tab lists the Volt Van at 39,283.20, One Time, 1 Feb 2027 to 31 Jan 2030. The contract is Activated. The comparison quote shows net unit price 39,283.20 and a line total of 1,964,160 for 50 vans.

## Records and values

Where this page and an older note differ, the latest recorded values (31 Oct 2026) and the Velora example values win.

- Agreement: Standard Panel Volt Van, final net 39,283.20 (44,640 at the 100-and-more tier, less 12 percent), USD, 1 Feb 2027 to 31 Jan 2030 (story dates; in the org dates are set relative to the recording day).
- the contract (the example is contract 00000104) keeps start 10/31/2026 (creation day) and gets Contract Term 40 months, end 2/28/2030. Set the term first, then add prices. The negotiated Volt Van 39,283.20 (One Time) covers 2/1/2028 to 1/31/2030, the vans of Years 2 and 3.
- V1/V2 line prices differ (Standard Panel 40,550.40 in Year 1, Refrigerated Long Range 56,352), so only the Standard Panel van gets the agreed price; Connect 29 is added by hand.
- 50 vans: 50 x 39,283.20 = 1,964,160. Without the agreement and alone: 50 x 46,080 = 2,304,000. With 200 vans already in service, 250 reach the 100-and-more tier: 50 x 44,640 = 2,232,000; 72,000 apart. Cumulative quantity pricing is explained on a slide and is not built.
