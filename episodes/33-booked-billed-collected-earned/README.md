# Episode 33: Booked, billed, collected, earned

Status: planned, not recorded yet; steps below may change when the episode is recorded.

## What this episode builds

One Connect-only table for the story date, 15 April 2027, with four numbers that answer four questions: booked (what the contract is worth), billed (what was invoiced), collected (what was paid) and recognised (what was earned under an example policy). The hands-on part reads each number from the org; the general ledger part is an illustration.

## Before you start

Starting point: tag `ep31-end` (or `ep32-end` if episode 32 was recorded). Swift's February invoices are reconciled and the Connect deal is the three-year ramp of 100, 200 and 300 vehicles.

`scripts/reset-to.sh` covers checkpoints up to episode 28 today; a checkpoint for this episode is planned and not in the repository yet.

## Planned steps

1. Booked: take the total contract value of the Connect ramp from episode 19's quote lines (annual charges 34,800 + 71,688 + 110,757.96 = 217,245.96 when the Year 3 price is kept at full precision).
2. Billed: open the February Connect invoice. Total Amount 2,900 less Net Credits Applied 348 gives 2,552.
3. Collected: open the payment for Swift. Net Applied is 2,552.
4. Recognised: under Velora's example policy, a Connect plan is earned per delivered vehicle per month, so 88 vehicles on the road in February at 29 gives 2,552. This is labelled an example policy, not Salesforce output.
5. Read the invoice and payment numbers:

```sh
sf data query --target-org demo_cpq --query "SELECT InvoiceNumber, TotalAmount, NetCreditsApplied, NetPaymentsApplied FROM Invoice"
sf data query --target-org demo_cpq --query "SELECT Amount, NetApplied FROM Payment"
```

- `--target-org demo_cpq` is the org alias.
- `--query` is the SOQL; the first reads invoice totals, credits and payments applied, the second reads each payment and how much of it is applied.

6. General ledger: open General Ledger Accounts and Accounting Periods in the Billing app to see where debits and credits are kept. A balanced journal entry is shown as an illustration.

## Files in this repo used by this episode

- No files in the repository are specific to this episode yet. Planned: `scripts/ep33-four-numbers.soql`.

## What you should see (planned)

Booked 217,245.96; billed for February 2,552; collected 2,552; recognised 2,552 under the example policy.

## Try it yourself

Add March's Connect invoice (issued 1 March for the month ahead) to the table and say whether it changes billings, deferred revenue or both on 15 March.

All names and numbers are invented examples. Prices are in US dollars.
