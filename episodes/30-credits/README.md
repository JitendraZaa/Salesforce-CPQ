# Episode 30: Disputes and credits

## What this episode builds

The 348 that Swift Couriers held back is cleared with a credit memo. You create and apply a credit memo of 348 from the refrigerated Connect line of invoice DOC-000000002, and the invoice goes from Partially Settled to Settled with a balance of 0.

## Before you start

Starting point: the end of episode 29. Invoice DOC-000000002 shows Net Payments Applied 2,552, Balance 348 and Partially Settled. The refrigerated Connect line carries the 348 balance.

To bring a fresh org as far as it can go by loading data, run `sh scripts/reset-to.sh ep28-end <your org alias>`, then follow episodes 29 and 30's earlier steps by hand. A git tag restores files only, never the org. (This repository has no `ep29-end` or `ep30-end` tag yet.)

You need the Billing Admin or the Credit Memo Operations User permission set, and the Billing licence.

## Click path

1. Open the Billing app, Invoices, DOC-000000002, and scroll to the Invoice Lines related list. Find the refrigerated Connect line: its Balance is 348. Why: a credit memo is applied to a line, so you start from the line that carries the amount.
2. Select that line and click Create and Apply Credit Memo.
3. In the dialog enter Credit Amount 348 and click Create and Apply.
4. Credit memo DOC-0000000001 is created in Pending status; about a minute later refresh the page and its status reads Posted and its balance 0.
5. Reopen invoice DOC-000000002 and read the totals.

## Files in this repo used by this episode

This episode uses the org's screens only; it adds no script. To read the result from the terminal:

- `sf data query --query "SELECT DocumentNumber, TotalAmount, NetPaymentsApplied, NetCreditsApplied, Balance, Status FROM Invoice WHERE DocumentNumber = 'DOC-000000002'" --target-org <alias>`: `--query` is the SOQL (the fields are the invoice totals); `--target-org` is the alias.
- `sf data query --query "SELECT DocumentNumber, TotalAmount, Balance, Status FROM CreditMemo" --target-org <alias>`: the same for credit memos.

## What you should see

Invoice DOC-000000002: Net Payments Applied 2,552, Net Credits Applied 348, Balance 0, Settled. Credit memo DOC-0000000001: Posted, balance 0.

## Records and values

All names and numbers are invented examples. Amounts are in US dollars.

- Credit: 12 refrigerated vans x 29 = 348, for vans not yet on the road in February.
- Invoice 2,900 = payments 2,552 + credit 348; balance 0.

## Try it yourself

Create a debit memo of 250 dollars for a site survey at Harbour Depot (App Launcher, Debit Memos, New; a debit memo is created in Draft and asks for a Reason Code value, which you add first under Object Manager, Debit Memo), add tax of 25, and read what the next invoice run does with it (275 on the next invoice). Do it on a copy of the org so the later episodes keep their numbers. The dispute record, which tracks a customer's objection before a credit memo, is explained on a slide in the video and is not built here.
