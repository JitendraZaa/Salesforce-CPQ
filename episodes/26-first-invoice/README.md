# Episode 26: The first invoice, and tax

All names, people, companies and numbers in this project are invented examples.

## What this episode builds

Swift's first invoice is created from the Connect billing schedules of the canonical fleet order and posted: 2,900 for 100 Connect plans at 29 for one month, due 30 days later. The episode then shows the invoice PDF and a tax policy with an example 10 percent rate on a van invoice line.

## Before you start

- Starting point: the org as episode 25 left it (git tag `ep25-end`). A git tag restores files only, not the org.
- To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep25-end <org alias>`. It loads the data and lists the clicks that a script cannot do.
- Words used here are explained in `GLOSSARY.md` in this folder.

## Click path

1. Reach the starting point: `sh scripts/reset-to.sh ep25-end` (see Before you start).
2. Check access: the working user holds Billing Admin or Billing Operations User, DocGen User and OmniStudio User; the org has the Billing licences.
3. In Billing Schedule Groups open the Connect schedules of the fleet order from episode 25 (select by its id, not by customer). Status ReadyForInvoicing, Billing Type Advance, term unit Month. They hold 40 x 29 = 1,160 and 60 x 29 = 1,740, 2,900 together for February.
4. Open **Billing Batch Schedulers** and click **New Invoice Scheduler**: name `Swift Connect First Month`, filter to Swift Couriers, recurring charge types only, USD, post the invoices, and **Schedule**. In testing, in the demo org the scheduler did not always start; the working fallback is the Billing API call in the files below.
5. Open **Invoice Batch Runs** and the run record: started to Completed, one invoice generated, total 2,900.
6. Open the invoice from its related list. Check Status Posted, Invoice Date, Due Date (invoice date plus 30 days), Total Amount 2,900, Total Tax Amount 0, Balance 2,900. The lines show quantities 40 and 60, unit price 29, charge amounts 1,160 and 1,740.
7. Generate the invoice PDF: an Omniscript on the invoice page produces it from a template with server-side document generation.
8. Open the tax policy "Tax Policy for LE" and its treatment. Set the example rate 10 percent, create a tax engine of type Revenue Standard Tax, assign the policy to Volt Van and produce a one-van invoice line.

## Files in this repo used by this episode

- `queries/ep26-connect-schedules.soql`: the Connect billing schedules of an order (number, term unit, next billing date, total, status). Edit the order number in the file to your fleet order's number first. Command: `sf data query --query "$(cat queries/ep26-connect-schedules.soql)" --target-org <org alias>`
  - `sf data query`: run a read-only query.
  - `--query "$(cat ...)"`: the query text read from the file.
  - `--target-org`: which org to ask.
- `scripts/api/ep26-generate-invoice.json`: the request body for the invoice API. It lists `billingScheduleIds` (the schedules to bill), `action` (`Posted` to post the invoice, not leave it a draft), `invoiceDate` and `targetDate` (the date the run bills up to). The ids in the file belong to the original org: replace them with the ids from the query above.
- `scripts/api/generate-invoice.sh`: sends that body to the Billing API. Command: `sh scripts/api/generate-invoice.sh [body file] [org alias]`
  - first argument: the body file (default `scripts/api/ep26-generate-invoice.json`).
  - second argument: the org alias (default `demo_cpq`; use your own alias).
  - Inside, `sf api request rest ... --method POST --body ... --target-org ...` sends a POST request with the file's text as the body to `/services/data/v65.0/commerce/invoicing/invoices/collection/actions/generate`.
- `force-app/main/default/layouts/BillingBatchScheduler-Billing Batch Scheduler Layout.layout-meta.xml`: the scheduler page layout. The scheduler itself cannot be created by a script: create it with New Invoice Scheduler.
- Not in the repo: the Invoice record page, the invoice Omniscript, the tax policy data.

## What you should see

One posted invoice for Swift Couriers: total 2,900, balance 2,900, invoice date the start date of Connect, due 30 days later, Settlement Status Not Settled, tax 0 on Connect. Created By shows the person who ran the batch. The one-van tax example shows tax added at 10 percent.

## Records and values

Where this page and an older note differ, the latest recorded values (31 Oct 2026) and the Velora example values win.

- Connect invoice: 100 x 29 = 2,900 (lines 1,160 for 40 vans and 1,740 for 60 vans), due Net 30 (3 Mar 2027 in the story). Bill day 1.
- Tax policy applies to vehicles and chargers only; Connect and depot charging carry no tax in the example.
- One Year 1 Standard van: 40,550.40 net, tax 4,055.04, total 44,605.44. A Years 2 and 3 van: 39,283.20, tax 3,928.32, total 43,211.52. Charger Installation at Harbour Depot: 6,800 + 680 = 7,480. Do not invoice 100 vans for this check.
- The 100 Connect plans are billed although 12 vans are not yet delivered; episode 30 corrects that with the 348 credit memo.
