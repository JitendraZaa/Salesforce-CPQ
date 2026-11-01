# Episode 29: Payments

## What this episode builds

Swift Couriers pays 2,552 against the 2,900 Connect invoice. You record the payment in the Billing app, apply it to the two Connect invoice lines with the Apply Payment action from VS Code, and read the invoice: balance 348, Partially Settled. Swift keeps back 348 for 12 refrigerated vans that have not been delivered; the next episode deals with that amount.

## Before you start

Starting point: the end of episode 28 plus the Connect invoice of episode 26. Invoice DOC-000000002 for Swift Couriers (posted 1 Feb 2027, due 3 Mar 2027) has two lines, 1,160 for the Standard Panel vans' Connect plans and 1,740 for the refrigerated vans' plans, 2,900 in all, balance 2,900, Settlement Status Not Settled.

To bring a fresh org as far as it can go by loading data, run `sh scripts/reset-to.sh ep28-end <your org alias>`. The script loads the data and lists the steps that must be done by hand; the quotes, order and invoice come from episodes 18 to 26. A git tag restores files only, never the org. (This repository has no `ep29-end` tag yet.)

You need the permission set Payment Operations User (Setup, Users, Permission Sets, Payment Operations User, Manage Assignments, Add Assignments) and a working Billing licence.

## Click path

1. Open the Billing app, Invoices, and open DOC-000000002. Note Total 2,900, Balance 2,900, Net Payments Applied 0 and Settlement Status Not Settled. Why: this is the before picture you compare with at the end.
2. Open the App Launcher, search for Payments and open the Payments list, then click New.
3. Fill in the payment: Account Swift Couriers, Amount 2552.00, Status Processed, Type Sale, Processing Mode External (the money was received outside Salesforce, by bank transfer), Comments "Partial payment; 348 withheld for 12 refrigerated vans not yet delivered". Save. The payment is created as P-000000001 with Total Unapplied 2,552.
4. Setup, Permission Sets, Payment Operations User, Manage Assignments, Add Assignments: tick your user and Assign. Why: the Apply Payment action is available only to users with it.
5. In VS Code, open `scripts/api/ep29-apply-payment.json` and `scripts/api/apply-payment.sh` and read them (see the next section). Replace the two ids in the body with your own, using the queries below.
6. In the terminal run `sh scripts/api/apply-payment.sh`. The answer lists `isSuccess` true for both inputs, each with a `paymentLineInvoiceId` and the applied date.
7. Back in the org, reopen the invoice and the payment and compare with the "What you should see" section.

## Files in this repo used by this episode

- `scripts/api/ep29-apply-payment.json`: the request body. `inputs` is a list, one entry per application. Each entry has `paymentId` (the payment to take money from), `appliedToId` (the Id of an invoice LINE, not the invoice), `amount` and `comments`. This file applies 1,160 to the Standard Panel Connect line and 1,392 to the refrigerated Connect line (48 of the 60 vans, 48 x 29). The ids in it belong to the example org; replace them with yours.
- `scripts/api/apply-payment.sh`: sends the body. It runs `sf api request rest "/services/data/v66.0/actions/standard/applyPayment" --method POST --body "$(cat "$BODY")" --target-org "$ORG"`. Parts: `sf api request rest` sends a REST call with the CLI's own login, so no token is typed; the path is the Invocable Actions endpoint for the standard action `applyPayment` in API version 66.0; `--method POST` runs the action; `--body` is the JSON read from the body file; `--target-org` is the org alias. Usage: `sh scripts/api/apply-payment.sh [body file] [org alias]`; with no arguments it uses the body above and the alias `demo_cpq`.
- To find the ids for the body:
  - `sf data query --query "SELECT Id, PaymentNumber, Amount FROM Payment WHERE Account.Name = 'Swift Couriers'" --target-org <alias>`: `--query` is the SOQL; the result gives the payment Id.
  - `sf data query --query "SELECT Id, Description, TotalAmount FROM InvoiceLine WHERE Invoice.DocumentNumber = 'DOC-000000002'" --target-org <alias>`: the two invoice line Ids (match them by amount, 1,160 and 1,740).
- Check afterwards: `sf data query --query "SELECT DocumentNumber, TotalAmount, NetPaymentsApplied, Balance, Status FROM Invoice WHERE DocumentNumber = 'DOC-000000002'" --target-org <alias>`.

## What you should see

Payment P-000000001: Total Applied 2,552, Total Unapplied 0, with two Payment Line Invoice records of type Applied. Invoice DOC-000000002: Net Payments Applied 2,552, Balance 348, Settlement Status Partially Settled.

## Records and values

All names and numbers are invented examples. Amounts are in US dollars.

- Payment: Swift Couriers, 2,552, Processed, Sale, External.
- Applied: 1,160 to the Standard Panel Connect line (40 vans x 29, in full); 1,392 to the refrigerated Connect line (48 of 60 vans x 29).
- Invoice: 2,900 less 2,552 = 348 left.

## Try it yourself

Record a second payment of 100 dollars for Swift Couriers and do not apply it. Open the payment and read Total Unapplied (100). Do this on a copy of the org or delete the payment afterwards, so the invoice numbers in the next episodes stay the same.
