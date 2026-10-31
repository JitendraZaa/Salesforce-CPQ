# Episode 28: From usage to invoice

All names, people, companies and numbers in this project are invented examples.

## What this episode builds

Usage readings for a depot charging month are loaded from a file, summarised, rated at 0.21 per kWh and invoiced. The episode was restarted this episode on a September depot order: quote "Swift Depot Charging September" (00000035), lines 9/1 to 9/30/2026, order 00000123 activated, and the file `data/ep28-usage/transaction-journal-september.csv` imported on camera. Then, in the story, a commitment of 60,000 kWh a month at 0.18, split by depot, changes the next month's invoice.

## Before you start

- Starting point: the org as episode 27 left it (git tag `ep27-end`). A git tag restores files only, not the org.
- To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep27-end <org alias>`. It loads the data and lists the clicks that a script cannot do.
- Words used here are explained in `GLOSSARY.md` in this folder.

## Click path

1. Reach the starting point: `sh scripts/reset-to.sh ep27-end` (see Before you start).
2. Check that Swift has two Depot Charging assets (North, Harbour) with usage entitlement accounts and Usage billing schedules (Billing Method Usage, ReadyForInvoicing).
3. Open the September file in VS Code: one row per depot with account, the depot's asset, usage resource, unit (kWh), quantity, start and end dates and a unique identifier. North 41,800 kWh and Harbour 27,350 kWh, 69,150 together.
4. Replace the account, asset, usage resource and unit ids in the file with the ids of your own org (see the files below), then import it with the terminal command.
5. In Setup, Flows, check the usage flows: Schedule Entitlement Refresh runs first, then Velora Orchestrate Usage (Orchestrate Usage Management). Set the context to System Context without Sharing and schedule them. Flow schedules use the user's time zone, not the browser's.
6. Set the rating delay to 0 for the recording (the default is 3 days). The usage summary only completes after the usage period ends, so the flows run after the period end.
7. Check in order: Usage Summaries (consumption 69,150 kWh), Usage Ratable Summaries (net unit rate 0.21, total 14,521.50), Usage Billing Period Items (used quantity, overage quantity and amount).
8. Create the invoice scheduler `Swift Charging September` for the usage charge type, Swift, USD, post. Check the invoice line: Is Usage Based Invoice Line, quantity 69,150, unit price 0.21, charge amount 14,521.50.
9. In the story, add the commitment from 1 Mar 2027: North Depot 36,000 kWh a month at 0.18 and Harbour Depot 24,000 at 0.18, overage 0.21 each. Load the next month and rate it: 11,661 on one invoice.

## Files in this repo used by this episode

- `data/ep28-usage/transaction-journal-september.csv`: the usage readings for the September order. Columns: AccountId, ReferenceRecordId (the depot's asset), UsageResourceId, QuantityUnitOfMeasureId, Quantity, ActivityDate, StartDate, EndDate, UsageType (UsageManagement), Status (Pending), UniqueIdentifier. The ids in it belong to the original org: replace them with your own before importing.
- `data/ep28-usage/transaction-journal-first-month.csv`: an earlier version of the readings for a first month (kept for reference; the September file replaces it).
- `queries/ep28-depot-assets.soql`: finds the Depot Charging assets that start on 1 Sep 2026 (the ids to put in ReferenceRecordId). Command: `sf data query --query "$(cat queries/ep28-depot-assets.soql)" --target-org <org alias>`
  - `sf data query`: run a read-only query.
  - `--query "$(cat ...)"`: the text of the query from the file.
  - `--target-org <org alias>`: which org to ask.
- Import command: `sf data import bulk --sobject TransactionJournal --file data/ep28-usage/transaction-journal-september.csv --wait 10 --target-org <org alias>`
  - `sf data import bulk`: load a CSV with the Bulk API.
  - `--sobject TransactionJournal`: the object that stores usage readings.
  - `--file`: the CSV to load.
  - `--wait 10`: wait up to 10 minutes for the job to finish.
  - `--target-org`: which org.
- `force-app/main/default/flows/Velora_Orchestrate_Usage.flow-meta.xml`: the schedule-triggered flow that runs the usage steps. Deploy: `sf project deploy start --source-dir force-app/main/default/flows --target-org <org alias>`. To test it use Debug in Flow Builder, not Run.
- Not in the repo: the Schedule Entitlement Refresh copy, a March file, the commitment records. Do them by hand or as slides.

## What you should see

Two Transaction Journal records loaded; usage summaries of 41,800 and 27,350 kWh (69,150); a usage ratable summary at 0.21 per kWh totalling 14,521.50; and a posted usage invoice for 14,521.50 with the usage-based line flag set. Results in the org: UAG-143 and UAG-144, URS-008 and URS-009 (41,800 and 27,350) with status SummaryCreated.

## Records and values

Where this page and an older note differ, the latest recorded values (31 Oct 2026) and the Velora example values win.

- September usage 41,800 (North) + 27,350 (Harbour) = 69,150 kWh x 0.21 = 14,521.50 (8,778.00 + 5,743.50). The flow was moved off camera to 10:32 Pacific time and ran.
- Story: this is "February 2027"; invoice 1 Mar 2027, due 31 Mar 2027. March: North 38,200 + Harbour 25,900 = 64,100 kWh.
- Commitment from 1 Mar 2027 only: 60,000 kWh a month at 0.18, overage at 0.21, split by depot because each depot has its own charging asset and entitlement account: North 36,000 kWh, Harbour 24,000 kWh (no pooling is claimed). North 36,000 x 0.18 = 6,480 + 2,200 x 0.21 = 462 = 6,942; Harbour 24,000 x 0.18 = 4,320 + 1,900 x 0.21 = 399 = 4,719. Total 10,800 + 861 = 11,661 on one invoice dated 1 Apr 2027.
- Usage invoices carry no tax in the example.
