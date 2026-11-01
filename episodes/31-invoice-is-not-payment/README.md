# Episode 31: Invoice is not payment

Status: planned, not recorded yet; steps below may change when the episode is recorded.

## What this episode builds

A single view of Swift Couriers' two February invoices that reconciles four numbers: invoiced (17,421.50), paid (2,552), credited (348) and still open (14,521.50). The charging invoice is 15 days past its due date on the story date, 15 April 2027. Most of the episode is explanation on slides (invoice versus payment, accounts receivable, invoice balance versus account balance, aging); the hands-on part is an invoice list view, the aging component on the Account page and one query.

## Before you start

Starting point: tag `ep30-end`. Swift has February's Connect invoice (2,900, settled by a payment of 2,552 and a credit memo of 348) and the charging invoice (14,521.50, unpaid). Your user needs the Billing Admin or Billing Operations User permission set.

`scripts/reset-to.sh` brings an org to a checkpoint as far as episode 28 today. A checkpoint for episode 30 with story dates moved to a recording day is planned and does not exist in the repository yet.

## Planned steps

1. In the Billing app open Invoices and create a list view for the account Swift Couriers. Add the columns Total Amount, Net Payments Applied, Net Credits Applied, Balance, Due Date, Days Invoice Overdue and Settlement Status. Filter to the two February invoices.
2. Check the sums: 2,900 + 14,521.50 = 17,421.50, and 17,421.50 - 2,552 - 348 = 14,521.50. The Connect invoice should read Settled with balance 0; the charging invoice should read Not Settled with balance 14,521.50.
3. In Setup open Lightning App Builder, edit the Account record page, add the Invoice Aging for Account component (it needs the Billing licence and the Billing Admin or Billing Operations User permission set), save and activate. Open Swift Couriers and read Total Invoices, Open Invoices, Overdue Invoices and the aging chart. The component groups by invoice date in 30-day buckets; Velora's own rule counts days past due. The episode names the difference.
4. Account balance: the Account object has no balance field. The gross amount a customer owes is the sum of its open invoice balances; unapplied customer cash lowers it. The episode reconciles February's two invoices only.
5. In the terminal read the same rows with a query (the file `scripts/ep31-reconcile.soql` is planned):

```sh
sf data query --target-org demo_cpq --query "SELECT InvoiceNumber, InvoiceDate, DueDate, TotalAmount, NetPaymentsApplied, NetCreditsApplied, Balance, DaysInvoiceOverdue, SettlementStatus FROM Invoice ORDER BY InvoiceDate"
```

- `sf data query` runs a SOQL query against an org.
- `--target-org demo_cpq` is the alias of the org to read.
- `--query "..."` is the SOQL; it lists each invoice with the amounts above.

## Files in this repo used by this episode

- No files in the repository are specific to this episode yet. Planned: `scripts/ep31-reconcile.soql`, the Account record page with the aging component, and a list view for Swift's invoices.

## What you should see (planned)

Connect invoice: 2,900 total, 2,552 paid, 348 credited, balance 0. Charging invoice: 14,521.50 total, nothing applied, balance 14,521.50, 15 days overdue on the story date. Together: invoiced 17,421.50, paid 2,552, credited 348, open 14,521.50.

## Try it yourself

Read the charging invoice again one month later on the story clock (15 May 2027) and write down which aging bucket it falls into under the component's invoice-date buckets and under days past due, and why they differ.

All names and numbers are invented examples. Prices are in US dollars.
