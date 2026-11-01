# Episode 33: Booked, billed, collected, earned

All names, people, companies and numbers in this project are invented examples. Prices are in US dollars.

## What this episode builds

Four numbers for the Swift Couriers Connect subscription, side by side: booked 217,245.96 (what the contract is worth), billed 2,552 (the invoice less its credit), collected 2,552 (the payment) and earned 2,552 (an example policy, shown on slides). You read booked, billed and collected in the Billing app and with three queries from VS Code.

## Before you start

- Starting point: the end of episode 32. The fleet order 00000126 holds the Connect lines (VC-SUB). Invoice DOC-000000002 is 2,900 with credit 348 and payment 2,552 applied. Credit memo DOC-0000000001 (348) and payment P-000000001 (2,552) exist.
- To bring a fresh org as far as it can go by loading data, run `sh scripts/reset-to.sh ep28-end <org alias>` and follow episodes 29 to 32 by hand. A git tag restores files only, never the org. (This repository has no `ep32-end` tag yet.)
- You need the Billing licence.

## Click path

1. Billing app, Invoices, open DOC-000000002. In Invoice Amount Information Total Amount is 2,900. In Invoice Settlement Information: Net Credits Applied 348, Net Payments Applied 2,552, Balance 0, Settlement Status Settled.
2. Navigation menu, Credit Memos, open DOC-0000000001: 348, Posted, with invoice DOC-000000002 as its reference. Why: billed is the invoice less this credit.
3. App Launcher, Payments, open P-000000001: 2,552, Processed, account Swift Couriers, balance 0 (all of it applied). This is the collected number.
4. App Launcher, General Ledger Accounts (All view) and Accounting Periods: both lists show 0 items. Why: Billing builds journal entries from accounts, a period and rules; the journal entry on the slide is an illustration of what they would produce.
5. In VS Code open `queries/ep33-booked.soql` and run `sf data query -o <org alias> --file queries/ep33-booked.soql`. The answer is 217,245.96, the booked number.
6. Open `queries/ep33-billed.soql` and run the same command with that file. The row reads DOC-000000002, 2,900, 348, 2,552, 0: billed is 2,900 less 348, 2,552.
7. Open `queries/ep33-collected.soql` and run the command again. The row reads P-000000001, 2,552, 2,552, Processed: collected.

## Background on slides (not steps)

- Bookings are accepted contractual commitments valued under a stated policy; billings are amounts invoiced in a period after credits; cash collections are money received; revenue is what is earned under accounting rules.
- The earned number is an example policy, not Salesforce output: Connect is earned per vehicle on the road per month, so 88 vehicles x 29 = 2,552 for February.
- Deferred revenue, unbilled revenue and backlog explain why the numbers differ in time.
- The table of four numbers (booked 217,245.96 for three years; billed, collected and earned 2,552 for February) is shown on a slide.
- General ledger, chart of accounts, journal entries (debits equal credits; cash up 2,552, receivables down 2,552) and accounting periods are explained as an illustration. Debit and credit memos are documents, not debits and credits.

## Files in this repo used by this episode

- `queries/ep33-booked.soql`: SUM of TotalPrice from OrderItem for order 00000126 and product code VC-SUB (change the order number to yours).
- `queries/ep33-billed.soql`: document number, total, credits applied, payments applied and balance of invoice DOC-000000002.
- `queries/ep33-collected.soql`: payment number, amount, net applied and status of Swift Couriers' payment.
- Command for each: `sf data query -o <org alias> --file <query file>`
  - `sf data query`: run a read-only SOQL query.
  - `-o`: the org alias.
  - `--file`: read the query from a file.

## What you should see

Booked 217,245.96. Billed row: DOC-000000002, 2,900, 348, 2,552, 0. Collected row: P-000000001, 2,552, 2,552, Processed. General ledger accounts and accounting periods: 0 items.

## Try it yourself

Pick one deal in your org, find its booked, billed and collected amounts, apply your own accounting policy to get the earned amount, and write one sentence on why each differs.
