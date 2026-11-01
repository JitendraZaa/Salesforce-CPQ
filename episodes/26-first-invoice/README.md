# Episode 26: The first invoice

All names, people, companies and numbers in this project are invented examples.

## What this episode builds

Swift's first invoice, made from the two Year 1 Connect billing schedules of the fleet order (00000126 in the example) with the Billing API and posted: 2,900 for 100 Connect plans at 29 for one month, dated 1 Feb 2027 and due 30 days later. The episode also shows the invoice scheduler screens (the admin way, which runs as scheduled background work) and, on slides, the invoice PDF and a tax policy with an example 10 percent rate.

## Before you start

- Starting point: the org as episode 25 left it (git tag `ep25-end`): the fleet order is activated and fulfilled, with billing schedules ReadyForInvoicing. A git tag restores files only, not the org.
- To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep25-end <org alias>`. It loads the data and lists the clicks that a script cannot do.
- Your user holds Billing Admin or Billing Operations User; the org has the Billing licences. Visual Studio Code with the Salesforce extensions and the Salesforce CLI are needed for the terminal part.
- Words used here are explained in `GLOSSARY.md` in this folder.

## Click path

1. App Launcher, **Billing Schedule Groups**: open the groups of the fleet order (find the order by its number, not by customer, because more than one order can belong to Swift). Look at the Connect schedules: Billing Type Advance, term unit Month, Status ReadyForInvoicing. The two Year 1 Connect schedules hold 40 x 29 = 1,160 and 60 x 29 = 1,740.
2. App Launcher, **Billing Batch Schedulers**: open the layout to see what a scheduler asks for: name, run time, filter by account and charge type, currency, and whether invoices are posted or left draft. It runs in the background on its schedule; in this episode the invoice is made with the API instead.
3. In VS Code open the folder of this project. Run `queries/ep26-connect-schedules.soql` (see the files) and copy the Ids of the two Year 1 Connect schedules (next billing date 2027-02-01).
4. Open `scripts/api/ep26-generate-invoice.json` and replace the two ids in `billingScheduleIds` with yours. Leave `action` as `Posted`, and `invoiceDate` and `targetDate` as `2027-02-01` (or a date on or after the schedules' next billing date in your org).
5. Open `scripts/api/generate-invoice.sh`, read it, then run it from the terminal: `sh scripts/api/generate-invoice.sh scripts/api/ep26-generate-invoice.json <org alias>`. The response shows `"success": true` and a request identifier.
6. Wait a few minutes. In the app open **Invoices**, then the new invoice (DOC-000000002 in the example). Check Status Posted, Invoice Date 2/1/2027, Due Date 30 days later, Total Amount 2,900, Total Tax Amount 0, Bill To Marcus Hale. Open Invoice Lines (2): Velora Connect 1,740 and 1,160. Look at **Created By** on the invoice.

## Files in this repo used by this episode

- `queries/ep26-connect-schedules.soql`: the monthly Connect schedules of an order (number, term unit, next billing date, total, status). It is written for another order number: edit the number in the file to your fleet order's (00000126 in the example). Command: `sf data query --query "$(cat queries/ep26-connect-schedules.soql)" --target-org <org alias>`
  - `sf data query`: run a read-only SOQL query.
  - `--query "$(cat ...)"`: the query text read from the file.
  - `--target-org <org alias>`: which org to ask.
- `scripts/api/ep26-generate-invoice.json`: the request body. `billingScheduleIds` lists the schedules to bill, `action` is `Posted` (post the invoice instead of leaving a draft), `invoiceDate` is the date on the invoice and `targetDate` is the date the run bills up to. The ids in the file belong to the original org: replace them with the ids from the query.
- `scripts/api/generate-invoice.sh`: sends that body to the Billing API. Command: `sh scripts/api/generate-invoice.sh [body file] [org alias]`
  - first argument: the body file (default `scripts/api/ep26-generate-invoice.json`).
  - second argument: the org alias (default `demo_cpq`; use your own).
  - Inside, `sf api request rest "/services/data/v65.0/commerce/invoicing/invoices/collection/actions/generate" --method POST --body "$(cat file)" --target-org <alias>` sends an HTTP POST: the path is the "generate invoices from billing schedules" service, `--method POST` sends data, `--body` is the file's text, `--target-org` picks the org.
- `force-app/main/default/layouts/BillingBatchScheduler-Billing Batch Scheduler Layout.layout-meta.xml`: the scheduler page layout.
- Not in the repo: the invoice PDF template and the tax policy records (shown on slides).

## What you should see

One posted invoice for Swift Couriers: total 2,900, balance 2,900, invoice date 2/1/2027, due 30 days later, two lines (1,740 and 1,160), tax 0 on Connect, Bill To Marcus Hale, Created By your name. The Connect schedules show as billed for February.

## Records and values

- Invoice DOC-000000002 (in the example): 100 x 29 = 2,900, lines 1,160 (40 vans) and 1,740 (60 vans), due 3 Mar 2027 in the org (30 days). Bill day 1.
- Tax policy (slide): vehicles and chargers only; Connect and charging carry no tax. One Year 1 Standard van: 40,550.40 net, tax 4,055.04, total 44,605.44; a Years 2 and 3 van: 39,283.20, tax 3,928.32, total 43,211.52.
- The 100 Connect plans are billed although 12 refrigerated vans are not yet delivered; episode 30 corrects that with a 348 credit memo.

## Try it yourself

Change `targetDate` and `invoiceDate` in a copy of the body to 2027-03-01 and send it with the Year 1 March schedule ids from your query. Compare the second invoice with the first.
