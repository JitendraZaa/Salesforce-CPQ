# Episode 32: Collections and write-offs

Status: planned, not recorded yet; steps below may change when the episode is recorded.

## What this episode builds

How an overdue invoice is chased and how a small leftover amount is written off. This episode is conditional. It is recorded only if the org's Billing Settings offers Automate Dunning Orchestration and, once that is on, Collection Plans and Collection Plan Items open from the App Launcher, and the shipped dunning orchestration can run on a collection plan. If it cannot, the series uses the one collections slide in episode 31 and this folder is not used.

## Before you start

Starting point: tag `ep31-end`. Swift's charging invoice (14,521.50) is overdue. Your user needs the Billing Operations User permission set, or the Billing Collections and Recovery Specialist permission set for collection plans, and the Credit Memo Operations User permission set for the write-off.

`scripts/reset-to.sh` covers checkpoints up to episode 28 today. A dated checkpoint for this episode is planned and not in the repository yet.

## Planned steps

1. In Setup open Billing Settings and turn on Automate Dunning Orchestration. Confirm that the Collections Dunning Orchestration Workspace and the email templates Early Reminder, Invoice Due Notice and Suspension Notice appear.
2. From the App Launcher open Collection Plans > New. Choose the account Swift Couriers, a contact with an email address you control, a collection plan reason, and usage type Billing. Add the charging invoice as a collection plan item.
3. Start the dunning orchestration from the plan, open the orchestration plan and confirm that a reminder is sent a set number of days after the due date.
4. Days sales outstanding (DSO) is explained on a slide only, as Velora's own rule with example numbers.
5. Write-off (try-it): in Object Manager add values such as BD (bad debt) to the Reason Code picklist on Credit Memo. Pay all but 0.50 of the charging invoice with a payment, as in episode 29. Build a screen flow that calls the Write Off Invoices action with the invoice id and a reason code, then run it for the 0.50 balance.
6. Read the result:

```sh
sf data query --target-org demo_cpq --query "SELECT InvoiceNumber, Balance, WriteOffStatus, WriteOffTotalChargeAmount FROM Invoice"
```

- `--target-org demo_cpq` is the org alias.
- `--query` reads the invoice balance and the write-off fields.

## Files in this repo used by this episode

- No files in the repository are specific to this episode yet. Planned: the write-off screen flow and `scripts/ep32-check-writeoff.soql`.

## What you should see (planned)

A collection plan for Swift with the charging invoice as an item, a reminder sent from the dunning orchestration, and after the write-off an invoice whose Write Off Status is set and whose balance is 0.

## Try it yourself

Add a payment promise to the collection plan item and read where it appears on the plan. Then write off the 0.50 leftover from the checkpoint.

All names and numbers are invented examples.
