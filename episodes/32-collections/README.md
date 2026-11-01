# Episode 32: Collections and write-offs

All names, people, companies and numbers in this project are invented examples.

## What this episode builds

You give yourself the permission sets for collections work, switch on Automate Dunning Orchestration, create a collection plan for Swift Couriers with the open invoice DOC-000000001 as a collection plan item, and prepare the reason code BD for credit memos. Then Swift pays 2,899.50 of the 2,900, you apply that payment from VS Code, and a flow writes off the last 0.50: the invoice ends with balance 0.00, Settled, and a credit memo for 0.50 records the write-off.

## Before you start

- Starting point: the end of episode 31. Invoice DOC-000000001 for Swift Couriers is 2,900, due 3 Mar 2027, with nothing paid. Contact Marcus Hale and the billing account Swift Couriers Billing exist. Marcus needs an email address for a collection plan; use one you control, never a customer's real address (`sh scripts/ep32-prepare.sh email <address>` sets it).
- To bring a fresh org as far as it can go by loading data, run `sh scripts/reset-to.sh ep28-end <org alias>` and follow episodes 29 to 31 by hand. A git tag restores files only, never the org. (This repository has no `ep31-end` tag yet.)
- You need the Billing licence. The permission sets are assigned in the first step.

## Click path

1. Setup, Users, open your user, Permission Set Assignments, Edit Assignments. Add Billing Collections And Recovery Specialist and Credit Memo Operations User, then Save. Why: collection plans need the first, and the write-off needs the second. (`sh scripts/ep32-prepare.sh permsets` assigns both from the terminal.)
2. Setup, Billing Settings: scroll to Automate Dunning Orchestration and turn it on. A few seconds later the Collection Plan object is ready to use.
3. App Launcher, Collection Plans, New. Fill in Contact Marcus Hale, Account Swift Couriers, Billing Account Swift Couriers Billing and Usage Type Billing. Save. The plan is created as CP-000000001.
4. On the plan, Related, Collection Plan Items, New. In Invoice type DOC and pick DOC-000000001. Save. The item CPI-000000001 shows an Invoice Balance of 2,900. Why: a plan on its own has nothing to chase; each item points to one invoice.
5. Setup, Object Manager, Credit Memo, Fields & Relationships, Reason Code, Values, New. Add the value BD (bad debt) and Save. Why: every cent removed needs a reason code on file, and the credit memo that records the write-off carries it.
6. Swift's payment of 2,899.50 is recorded as in episode 29 (`sh scripts/ep32-writeoff-fixture.sh` creates it and writes the apply-payment body for you).
7. In VS Code open `scripts/api/ep32-apply-payment.json` (paymentId, appliedToId which is the invoice LINE, amount 2899.50). Replace the ids with your own.
8. Run `sh scripts/api/apply-payment.sh scripts/api/ep32-apply-payment.json <org alias>`. The answer shows `applyPayment` and `isSuccess` true.
9. Open `queries/ep31-reconcile.soql` and run `sf data query -o <org alias> --file queries/ep31-reconcile.soql`. DOC-000000001 now shows 2,899.50 applied, balance 0.50, Partially Settled; DOC-000000002 is Settled.
10. Open `force-app/main/default/flows/Velora_Write_Off_Invoice.flow-meta.xml`. It calls the Write Off Invoices action. An assignment step first fills the action's input list (Apex-defined, so the flow supplies exactly the shape the action expects): the invoiceId, the reasonCode BD and a reason in words.
11. Deploy it: `sf project deploy start --metadata Flow:Velora_Write_Off_Invoice --target-org <org alias>`. The table says Created.
12. Open `scripts/api/ep32-write-off.json`. It holds the invoiceId, the record Id of DOC-000000001 (not its number). Replace it with yours.
13. Run `sf api request rest /services/data/v66.0/actions/custom/flow/Velora_Write_Off_Invoice --method POST --body @scripts/api/ep32-write-off.json --target-org <org alias>`. The answer shows `isSuccess` true and the flow status Finished.
14. The write-off is processed in the background and takes a while. When it is done, open DOC-000000001 and scroll to Invoice Settlement Information: Balance 0.00, Net Payments Applied 2,899.50, Net Credits Applied 0.50, Settled. Open the credit memo DOC-0000000003: Swift Couriers, 0.50, Posted, reference DOC-000000001.

## Background on slides (not steps)

- Collections is all the work of recovering overdue money; dunning is sending reminders on a schedule, each a little firmer. A collection plan stores the account, the total invoice balance and the timeline; its items point to invoices.
- The reminder sequence is described from Salesforce help: Billing runs dunning with Dynamic Revenue Orchestrator, and the shipped orchestration plan drives reminders and escalations from the plan's due dates and the customer's risk, with three email templates (Early Reminder, Invoice Due Notice, Suspension Notice). The dates, emails and escalation are shown on slides; the click path above ends at the plan and its item.
- A write-off removes an amount from receivables because it will not be collected; it is not a refund. After a write-off no further credit memo or payment can be applied to that invoice.

## Files in this repo used by this episode

- `scripts/ep32-prepare.sh`: `permsets` assigns the two permission sets; `email <address>` puts an address you control on Marcus Hale.
- `scripts/ep32-writeoff-fixture.sh`: records Swift's payment of 2,899.50 (from `data/ep32-collections/Payment.json`) and writes `scripts/api/ep32-apply-payment.json`.
- `scripts/api/ep32-apply-payment.json`: the apply-payment body. `inputs` holds `paymentId`, `appliedToId` (the Id of an invoice line), `amount` and `comments`. The ids belong to the example org.
- `scripts/api/apply-payment.sh`: sends the body to the standard `applyPayment` action. Usage: `sh scripts/api/apply-payment.sh [body file] [org alias]`.
- `queries/ep31-reconcile.soql`: both invoices with payments, credits, balance and status.
- `force-app/main/default/flows/Velora_Write_Off_Invoice.flow-meta.xml`: the flow that calls Write Off Invoices.
- `scripts/api/ep32-write-off.json`: the request body, `{"inputs": [{"invoiceId": "..."}]}`.
- Calls in parts: `sf project deploy start --metadata Flow:<name>` sends one flow; `sf api request rest <path>` sends a REST call with the CLI's own login; the path ends `actions/custom/flow/<flow name>`; `--method POST` runs it; `--body @file` reads the body from a file.

## What you should see

Collection plan CP-000000001 with item CPI-000000001 (balance 2,900). After the payment: DOC-000000001 paid 2,899.50, balance 0.50, Partially Settled. After the write-off: balance 0.00, Net Credits Applied 0.50, Settled, and credit memo DOC-0000000003 for 0.50 (Posted, reason code BD).

## Records and values

- Invoice DOC-000000001: 2,900.00; payment 2,899.50; written off 0.50.
- Reason code BD, reason "Remaining balance under one dollar".

## Try it yourself

Find an overdue invoice in your org, read its collection steps, and work out what a write-off would do to its balance before you run one.
