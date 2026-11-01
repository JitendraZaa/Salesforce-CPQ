# Episode 31: Invoice is not payment

All names, people, companies and numbers in this project are invented examples.

## What this episode builds

You read Swift Couriers' two Connect invoices side by side in the Billing app, in a list view of your own, and check the same figures with a query from VS Code: 5,800 invoiced, 2,552 paid, 348 credited and 2,900 still open. Most of the episode explains the ideas on slides (invoice versus payment, accounts receivable, invoice balance versus account balance, aging); the hands-on part is the list view, two invoice records and one query.

## Before you start

- Starting point: the end of episode 30. Swift Couriers has two invoices dated 1 Feb 2027 and due 3 Mar 2027, 2,900 each. DOC-000000002 has the payment of 2,552 (episode 29) and the credit memo of 348 (episode 30) applied. DOC-000000001 has nothing applied.
- To bring a fresh org as far as it can go by loading data, run `sh scripts/reset-to.sh ep28-end <org alias>` and follow episodes 29 and 30 by hand. A git tag restores files only, never the org. (This repository has no `ep30-end` tag yet.)
- You need the Billing licence and the Billing Admin or Billing Operations User permission set.

## Click path

1. App Launcher, search for Billing and open the Billing app. It opens on the Billing Operations Console: 2 invoices, 5,800 in total, and 1 credit memo of 348. Why: this is the summary the rest of the episode explains.
2. From the navigation menu open Invoices. The list menu already holds views by days overdue (1 to 30 up to more than 90). Pick All Invoices.
3. From the list view controls choose New. Name it Swift Couriers Invoices, let all users see it, and add the filter Account Name equals Swift Couriers. Save. Why: standard list views keep their own columns, so a view of your own shows only Swift's invoices.
4. From the list view controls choose Select Fields to Display and move these columns across, in this order: Document Number, Account Name, Invoice Date, Due Date, Total Amount, Balance, Settlement Status. Why: Net Payments Applied and Net Credits Applied are not list columns; you read them on each invoice.
5. Read the list: both invoices are dated 1 Feb 2027, due 3 Mar 2027, 2,900 each. DOC-000000001 has balance 2,900 and Not Settled; DOC-000000002 has balance 0 and Settled.
6. Open DOC-000000002 and scroll to its settlement section: Net Payments Applied 2,552, Net Credits Applied 348, Balance 0, Settlement Status Settled.
7. Open DOC-000000001: payments applied 0, credits applied 0, balance 2,900. Nothing is paid or credited on it, so it is Swift's open invoice.
8. In VS Code open `queries/ep31-reconcile.soql` and read it (see the next section). Why: the same check runs again on any day.
9. In the terminal run `sf data query -o <org alias> --file queries/ep31-reconcile.soql`. Two records come back, the same as the screen.
10. Add them up: invoiced 5,800, paid 2,552, credited 348, open 2,900, all of it on DOC-000000001.

## Background on slides (not steps)

- Invoice versus payment: an invoice asks for money, a payment is money received, and five gaps sit between them (payment terms, a part payment, a dispute, a credit, a late payer).
- Accounts receivable (AR) is what customers owe for goods or services already invoiced. An invoice balance is the open amount on one invoice; adding the open balances of a customer's invoices gives the gross amount it owes, and unapplied cash lowers it. Swift has no unapplied cash.
- Aging is a story example: a charging invoice of 14,521.50 issued 1 March on Net 30, due 31 March, is 15 days past due on 15 April and sits in the 1 to 30 days bucket. It is not a record in the org.
- The Billing app's Invoice Aging for Account component comes with the Billing licence and counts from the invoice date in 30 day steps (an admin can change the step), so one invoice can sit in different buckets than a days-past-due count gives. Swift's account page already holds it; this episode does not configure it.

## Files in this repo used by this episode

- `queries/ep31-reconcile.soql`: selects DocumentNumber, InvoiceDate, DueDate, TotalAmount, NetPaymentsApplied, NetCreditsApplied, Balance and SettlementStatus from Invoice where the billing account is Swift Couriers, ordered by document number.
- Run it: `sf data query -o <org alias> --file queries/ep31-reconcile.soql`
  - `sf data query`: run a read-only SOQL query.
  - `-o`: the org alias (short for `--target-org`).
  - `--file`: read the query text from a file.

## What you should see

Two records. DOC-000000001: total 2,900, payments 0, credits 0, balance 2,900, Not Settled. DOC-000000002: total 2,900, payments 2,552, credits 348, balance 0, Settled. Created By on the invoices is you.

## Records and values

- Invoiced 5,800 (2 x 2,900); paid 2,552; credited 348; open 2,900.

## Try it yourself

After an invoice's due date has passed, open it and read Days Invoice Open and Days Invoice Overdue. Overdue money leads to collections, the next episode.
