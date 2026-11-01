# Episode 28: From usage to invoice

All names, people, companies and numbers in this project are invented examples.

## What this episode builds

Usage readings for a depot charging month are loaded from a file, summarised and rated at 0.21 per kWh. The episode runs on a September depot order: quote "Swift Depot Charging September" (00000035, lines 9/1 to 9/30/2026), order 00000123 activated, with one Depot Charging asset per depot. The file `data/ep28-usage/transaction-journal-september.csv` is imported, the usage flow is scheduled, and the usage summaries read 41,800 kWh (North Depot) and 27,350 kWh (Harbour Depot). A rating procedure named Negotiable Rating Procedure does the pricing. On a slide the 69,150 kWh become 14,521.50 on a usage invoice, and a commitment of 60,000 kWh a month at 0.18 changes the next month to 11,661.

## Before you start

- Starting point: the org as episode 27 left it (git tag `ep27-end`): Depot Charging is active at 0.21 per kWh in the rate card "Velora Charging Rate Card". A git tag restores files only, not the org.
- To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep27-end <org alias>`. It loads the data and lists the clicks that a script cannot do.
- You need Usage Management, Rate Management and the Billing licences.
- Words used here are explained in `GLOSSARY.md` in this folder.

## Click path

1. Rate card: App Launcher, Rate Cards, open Velora Charging Rate Card and set **Effective From** to 9/1/2026. Open its entry list: the entry for Depot Charging, Charging Energy, 0.21 USD must run 9/1/2026 to 9/30/2026 and be Active. (An Active entry is locked except for its status, so create a new entry with these dates and activate it.) Why: a reading is rated with the entry that is valid on its dates.
2. Order: Accounts, Swift Couriers, create the quote "Swift Depot Charging September" with two Depot Charging lines (North, Harbour) for 9/1 to 9/30/2026, Accept it, Create Order, fill the order fields as in episode 24 and set it **Activated**. Open the Assets tab: one Depot Charging asset per depot starting 9/1/2026.
3. Rating procedure: App Launcher, **Rating Procedures**. If the list is empty, click **New**: `Negotiable Rating Procedure`, Usage Type Rating, Context RateManagementContext. This exact name is the one the usage flows look for. Fill it by deploying the repo's version (see the files): the Base Rate step reads the Rate Card Entries decision table and returns the net unit rate, and Formula-Based Rating sets TotalAmount = NetUnitRate x OverageQuantity. Activate version 1.
4. Setup, Decision Tables, **Rate Card Entries**: click Refresh. Why: the procedure reads this table, not the entries.
5. In VS Code run `queries/ep28-depot-assets.soql` and copy the two asset Ids.
6. Open `data/ep28-usage/transaction-journal-september.csv`: one row per depot with AccountId (Swift), ReferenceRecordId (the depot's asset), UsageResourceId, QuantityUnitOfMeasureId (kWh), Quantity (41,800 and 27,350), ActivityDate, StartDate, EndDate, UsageType UsageManagement, Status Pending and a UniqueIdentifier. Replace the Ids with those of your org.
7. Import it in the terminal: `sf data import bulk --sobject TransactionJournal --file data/ep28-usage/transaction-journal-september.csv --wait 10 --target-org <org alias>`. In the app open Transaction Journals: two records.
8. Setup, Flows: the usage flows are Schedule Entitlement Refresh, then **Velora Orchestrate Usage** (a copy of Orchestrate Usage Management). Save each as your own copy, set the run context to System Context without Sharing, schedule the entitlement refresh first and Velora Orchestrate Usage after it (the schedule uses your user's time zone), set the rating delay to 0 for the demo, and activate. The usage period must have ended before the flow runs.
9. After the run, check in order: Usage Summaries (UAG records for North and Harbour, Consumption 41,800 and 27,350, status SummaryCreated), Usage Ratable Summaries (net unit rate 0.21), Usage Billing Period Items.
10. Invoice (slide in this episode): an invoice scheduler for the usage charge type, Swift, USD, posted, gives one usage line: Depot Charging 69,150 at 0.21 = 14,521.50, Is Usage Based Invoice Line ticked, no tax.

## Files in this repo used by this episode

- `data/ep28-usage/transaction-journal-september.csv`: the September readings. The ids in it belong to the original org: replace them with your own before importing. (`transaction-journal-first-month.csv` in the same folder is an earlier, first-month version kept for reference.)
- `queries/ep28-depot-assets.soql`: finds the Depot Charging assets that start on 1 Sep 2026 (the ids for ReferenceRecordId). Command: `sf data query --query "$(cat queries/ep28-depot-assets.soql)" --target-org <org alias>`
  - `sf data query`: run a read-only SOQL query.
  - `--query "$(cat ...)"`: the query text read from the file.
  - `--target-org <org alias>`: which org to ask.
- Import command: `sf data import bulk --sobject TransactionJournal --file data/ep28-usage/transaction-journal-september.csv --wait 10 --target-org <org alias>`
  - `sf data import bulk`: load a CSV with the Bulk API.
  - `--sobject TransactionJournal`: the object that stores usage readings.
  - `--file`: the CSV to load.
  - `--wait 10`: wait up to 10 minutes for the job.
  - `--target-org`: which org.
- `force-app/main/default/expressionSetDefinition/Negotiable_Rating_Procedure.expressionSetDefinition-meta.xml`: the rating procedure (Base Rate on the Rate Card Entries table, then Formula-Based Rating). Deploy: `sf project deploy start --metadata ExpressionSetDefinition:Negotiable_Rating_Procedure --target-org <org alias>`
  - `--metadata ExpressionSetDefinition:Negotiable_Rating_Procedure`: deploy just that one component by type and name.
- `force-app/main/default/flows/Velora_Orchestrate_Usage.flow-meta.xml`: the scheduled usage flow. Open it in Flow Builder to set your own schedule date and time. Deploy: `sf project deploy start --source-dir force-app/main/default/flows --target-org <org alias>`
- `data/seed/39-RateCard.json` and `40-RateCardEntry.json`: the rate card and its entry (loaded by `scripts/seed-all.sh`).
- Not in the repo: the Schedule Entitlement Refresh copy, a March file and the commitment records (the commitment is explained on a slide).

## What you should see

Two Transaction Journal records; usage summaries for the two depots of 41,800 and 27,350 kWh (69,150 together), status SummaryCreated; the rating procedure active; a ratable summary at 0.21 per kWh once the usage month has ended.

## Records and values

- September usage: North 41,800 + Harbour 27,350 = 69,150 kWh x 0.21 = 14,521.50 (8,778.00 + 5,743.50). In the story this is February 2027, invoiced 1 Mar 2027, due 31 Mar 2027.
- Story commitment from 1 Mar 2027: 60,000 kWh a month at 0.18, overage at 0.21, split by depot because each has its own asset and entitlement account: North 36,000 and Harbour 24,000 kWh. March usage 38,200 + 25,900: North 36,000 x 0.18 = 6,480 + 2,200 x 0.21 = 462 = 6,942; Harbour 24,000 x 0.18 = 4,320 + 1,900 x 0.21 = 399 = 4,719; total 11,661 on one invoice dated 1 Apr 2027. Usage invoices carry no tax.

## Try it yourself

Load one more reading for the same depot with a new UniqueIdentifier dated inside September after the flow has run, run the flow again, and read whether the usage summary changes.
