# Episode 20: Contracts and clauses

All names, people, companies and numbers in this project are invented examples.

## What this episode builds

Swift Couriers' contract is made from the second quote (V2) with the New Contract button and left in Draft. The two contract terms, the battery warranty (8 years) and data ownership (telematics data belongs to the customer), sit on V2 as quote special terms, taken from the clause library. The contract carries the Revenue Management application usage assignment. It stays Draft here because an active contract refuses price edits; episode 21 negotiates the prices first.

## Before you start

- Starting point: the org as episode 19 left it (git tag `ep19-end`). A git tag restores files only, not the org.
- To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep19-end <org alias>`. It loads the data and lists the clicks that a script cannot do.
- Words used here are explained in `GLOSSARY.md` in this folder.

## Click path

1. Open Setup, Company Information, Permission Set Licenses, and check that the Contracts and Clause Management licences are in use. Without them the clause and contract steps do not exist.
2. In Setup, Object Manager, Quote, Page Layouts, open the layout in use, choose Buttons, and drag **New Contract** into the Salesforce Mobile and Lightning Experience Actions section. Save. Do the same on Order. (The repo already holds the Quote layout with this change.)
3. On the same Quote layout add the **Quote Special Terms** related list, so terms show on the quote.
4. Check the clause library: the clause set and the two clauses (Battery Warranty for Fleet Vans, Data Ownership) must exist and be Active. The data files below create them; otherwise create them in the clause library by hand. The battery warranty text has a placeholder token for the number of years.
5. Open V2, go to **Quote Special Terms**, click **Add**, search the clause library, select Battery Warranty, check Language, Category and Clause Type, click **Insert**, enter 8 in the token panel, and click **Apply**. Add Data Ownership the same way (no token). Save. You now have two rows in the related list. The same clause cannot be added twice to one quote.
6. On V2 click **New Contract**. When asked how to create contract prices, choose **None**. (The other choice, Net Unit Price, fails on the ramped full-fleet V2 because a contract holds only one price per product, selling model and date range; ) The page does not move on; wait about a minute for the Draft contract to appear. Episode 21 adds the negotiated contract prices by hand.
7. The start date must be today: Revenue Management does not support creating orders from future-dated contracts.
8. Open the contract and check that its application usage assignment is `RevenueLifecycleManagement` (it is set by default for contracts made with New Contract). If it is empty, add it with **New**.
9. Leave the contract in **Draft**. Do not click Activated.
10. Look at **Created By** on the contract; it shows the person who built it.

## Files in this repo used by this episode

- `scripts/seed.py` (the data loader) and `data/seed/manifest.json` (the list of data files in load order). Command to load only this episode's data:
  `python3 scripts/seed.py load <org alias> --only ClauseCatgConfiguration,DocumentClauseSet,DocumentClause,DocumentClauseContentToken`
  - `load`: create the records in the target org (the other mode, `export`, only reads an org).
  - `<org alias>`: the name you gave the org when you logged in with the Salesforce CLI.
  - `--only ClauseCatgConfiguration,DocumentClauseSet,DocumentClause,DocumentClauseContentToken`: load just these objects, comma separated. Records already in the org are skipped, so running it twice is safe.
  - Add `--dry-run` to print what would be created and create nothing.
  - What they hold: `data/seed/66-ClauseCatgConfiguration.json` (the clause category "Warranty and Data"), `67-DocumentClauseSet.json` (the clause sets), `68-DocumentClause.json` (the clause text, for example the battery warranty with a years placeholder), `69-DocumentClauseContentToken.json` (the placeholder token).
- `force-app/main/default/layouts/Quote-Quote Layout.layout-meta.xml`: the Quote page layout, including the New Contract button and the Quote Special Terms related list. Deploy: `sf project deploy start --source-dir force-app/main/default/layouts --target-org <org alias>` (`--source-dir` deploys just that folder).
- Also in `force-app/main/default/layouts/`: `DocumentClause-Document Clause Layout`, `DocumentClauseSet-Document Clause Set Layout` and `QuoteClause-Quote Clause Layout`, the layouts of the clause objects.
- No Order layout file is in the repo: add the New Contract button to the Order layout by hand (step 2).

## What you should see

Two rows under Quote Special Terms on V2 (Battery Warranty with 8 years, Data Ownership). A Draft contract for Swift Couriers, with the application usage assignment RevenueLifecycleManagement. The contract's own Special Terms field is empty: the terms stay on V2, one click from the contract.

## Records and values

Where this page and an older note differ, the latest recorded values (31 Oct 2026) and the Velora example values win.

- Customer: Swift Couriers (contact Marcus Hale). Quote: V2, the full-fleet quote after the ramp.
- Contract status: Draft. Start date: the day of creation (it keeps the creation-day start date). The contract price choice is **None**.
- Clauses (invented wording): "Velora Motors warrants the battery of each Volt Van against defects for 8 years from delivery." and "Telematics data produced by the vehicles under this agreement belongs to the customer."
- Prices that V2 carries and that episode 21 negotiates: Standard Panel Volt Van 40,550.40 in Year 1 (46,080 less 12 percent), 39,283.20 in Years 2 and 3 (44,640 less 12 percent); Refrigerated Long Range 56,352; Velora Connect 29.
- Contract Status values in the org: Draft, In Approval Process, Rejected, Negotiating, Awaiting Signature, Signed, Signature Declined, Activated, Contract Expired, Contract Terminated, Canceled.
