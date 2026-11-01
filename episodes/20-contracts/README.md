# Episode 20: Contracts and clauses

All names, people, companies and numbers in this project are invented examples.

## What this episode builds

Swift Couriers' contract, made from the second fleet quote (V2) with the New Contract button and left in Draft. The two contract terms, the battery warranty (8 years) and data ownership (telematics data belongs to the customer), sit on V2 as Quote Special Terms, taken from the clause library. The contract in the example is number 00000104. It stays Draft here, because an active contract refuses price edits: episode 21 adds the negotiated prices first.

## Before you start

- Starting point: the org as episode 19 left it (git tag `ep19-end`). V2 is the primary quote, ramped in three yearly groups. A git tag restores files only, not the org.
- To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep19-end <org alias>`. It loads the data and lists the clicks that a script cannot do.
- You need the Clause Management and Contract Lifecycle Management permission set licences, both assigned to your user.
- Words used here are explained in `GLOSSARY.md` in this folder.

## Click path

1. Setup, Company Information, Permission Set Licenses: check that Clause Management User and Contract LifeCycle Management User show as used.
2. Setup, Object Manager, Quote, Page Layouts, open Quote Layout, Mobile and Lightning Actions: drag **New Contract** into the Salesforce Mobile and Lightning Experience Actions section, and add the **Quote Special Terms** related list. Save. Do the same for the Order layout (Object Manager, Order, Page Layouts, Mobile and Lightning Actions, New Contract). The repo holds the Quote layout with both changes.
3. App Launcher, Document Clause Sets: open the clause set and its two clauses and check they are Active (Battery Warranty for Fleet Vans and Fleet Telematics Data Ownership, category "Warranty and Data"). The data files below create them. The battery warranty text carries a token for the number of years.
4. Open V2 (Accounts, Swift Couriers, Quotes, V2). On the Quote Special Terms related list click **Add Term**, search the clause library, select Battery Warranty for Fleet Vans, check Language, Category and Clause Type, then **Insert**. Enter 8 for the years token and **Apply**. Add Fleet Telematics Data Ownership the same way (no token). Each term asks for a reason: type one line. The related list now reads Quote Special Terms (2). A clause can be added to a quote only once.
5. On V2 click **New Contract**. The dialog asks how to create the contract prices: Net Unit Price, Discount or None. Choose **None**. Why: a contract holds one price per product, selling model and date range, and V2 has several Connect lines (one per ramp segment) and two Volt Van prices; episode 21 adds the contract prices by hand.
6. Wait about a minute and open the new contract from the Contracts related list of the account. It is in Draft, starts on the day you created it (Revenue Management does not create orders from future-dated contracts) and shows Contract Item Prices (0) and a Pricing Schedule tab.
7. Check the Application Usage Assignment related list shows `RevenueLifecycleManagement` (set by default for contracts made with New Contract). If it is empty, add it with **New**.
8. Leave the contract in **Draft**. Do not click Activated.
9. Look at **Created By** on the contract: it shows the person who built it.

## Files in this repo used by this episode

- `scripts/seed.py` (the data loader) and `data/seed/manifest.json` (the list of data files in load order). Command to load only this episode's data:
  `python3 scripts/seed.py load <org alias> --only ClauseCatgConfiguration,DocumentClauseSet,DocumentClause,DocumentClauseContentToken`
  - `load`: create the records in the target org (the other mode, `export`, only reads an org).
  - `<org alias>`: the name you gave the org when you logged in with the Salesforce CLI.
  - `--only ...`: load just these objects, comma separated. Records already in the org are skipped, so running it twice is safe.
  - Add `--dry-run` to print what would be created and create nothing.
  - What they hold: `data/seed/66-ClauseCatgConfiguration.json` (category "Warranty and Data"), `67-DocumentClauseSet.json` (the clause sets), `68-DocumentClause.json` (the clause text; the battery warranty has a years token), `69-DocumentClauseContentToken.json` (the token).
- `force-app/main/default/layouts/Quote-Quote Layout.layout-meta.xml`: the Quote layout with New Contract and the Quote Special Terms related list. Deploy: `sf project deploy start --source-dir force-app/main/default/layouts --target-org <org alias>`
  - `sf project deploy start`: send local metadata to the org.
  - `--source-dir force-app/main/default/layouts`: only the layouts in that folder.
  - `--target-org <org alias>`: which org to deploy to.
- Also in `force-app/main/default/layouts/`: `DocumentClause-Document Clause Layout`, `DocumentClauseSet-Document Clause Set Layout` and `QuoteClause-Quote Clause Layout`, the layouts of the clause objects.
- No Order layout file is in the repo: add New Contract to the Order layout by hand (step 2).

## What you should see

Two rows under Quote Special Terms on V2 (Battery Warranty with 8 years, Data Ownership). A Draft contract for Swift Couriers (00000104 in the example) with the application usage assignment RevenueLifecycleManagement and no contract item prices yet. The terms stay on V2, one click from the contract.

## Records and values

- Customer: Swift Couriers (contact Marcus Hale). Quote: V2, the full-fleet quote after the ramp.
- Contract status: Draft. Start date: the day you create it. Contract price choice: None.
- Clauses (invented wording): "Velora Motors warrants the battery of each Volt Van against defects for 8 years from delivery." and "Telematics data produced by the vehicles under this agreement belongs to the customer."
- Prices V2 carries and episode 21 negotiates: Standard Panel Volt Van 40,550.40 in Year 1 (46,080 less 12 percent) and 39,283.20 in Years 2 and 3 (44,640 less 12 percent); Refrigerated Long Range 56,352; Velora Connect 29.
- Contract Status values: Draft, In Approval Process, Rejected, Negotiating, Awaiting Signature, Signed, Signature Declined, Activated, Contract Expired, Contract Terminated, Canceled.

## Try it yourself

Add a third clause to V2 from the clause library, with a token of your own, and check that the same clause cannot be added twice. Then open the contract and find the application usage assignment.
