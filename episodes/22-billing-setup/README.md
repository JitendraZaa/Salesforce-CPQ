# Episode 22: Billing setup

All names, people, companies and numbers in this project are invented examples.

## What this episode builds

The billing rules are set before any order exists. Velora Advance and Velora Arrears are active billing policies with a treatment and treatment item each; Velora Motors Inc. is the legal entity; Net 30 is the payment term; and Swift Couriers has a default billing profile (a Billing Account) with bill day 1. The products point at Velora Advance.

## Before you start

- Starting point: the org as episode 21 left it (git tag `ep21-end`). A git tag restores files only, not the org.
- To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep21-end <org alias>`. It loads the data and lists the clicks that a script cannot do.
- Words used here are explained in `GLOSSARY.md` in this folder.

## Click path

1. In Setup, Permission Sets, give **Billing Admin** and **Billing Operations User** to Elena Ortiz and to the admin doing the setup.
2. In the App Launcher open **Billing Policies** and click **New**. Name it `Velora Advance`, status Draft, billing treatment selection Default. Save. A policy can only be created in Draft.
3. Create the legal entity `Velora Motors Inc.` (or open the default one and rename it) with its company name and address.
4. Open **Billing Treatments**, click **New**: `Velora Advance Treatment`, the policy, the legal entity, status Draft, Exclude From Billing No. Then edit the policy and set this treatment as its default.
5. Open **Billing Treatment Items**, click **New**: `Velora Advance Item`, the treatment, processing order 1, Billing Type **Advance**, controller Billing Schedule Group. Activate in this order: the item, then the treatment, then the policy.
6. Repeat for `Velora Arrears` with Billing Type **Arrears**. It is used by the usage product in episode 27.
7. Open **Payment Terms**, open the default term, and make it 30 days, period based. Name it `Net 30`.
8. Open **Billing Accounts** and click **New**: name `Swift Couriers Billing`, tick Default Billing Profile, choose the Swift Couriers account, an example address, bill day of month 1, bill-to contact Marcus Hale. Save. Each billing account is a billing profile.
9. Open each product (Volt Van, Aria, Velora Connect, Depot Charger 150 kW, Charger Installation, Wall Charger 11 kW) and set **Billing Policy** to Velora Advance. Do this now: policies copy to the order items when the order is created.
10. In Setup, Flows, confirm that the standard **Order To Billing Schedule** flow is active and is the only active flow that makes billing schedules.

## Files in this repo used by this episode

- `scripts/seed.py` (the data loader) and `data/seed/manifest.json` (the list of data files in load order). Command to load only this episode's data:
  `python3 scripts/seed.py load <org alias> --only BillingPolicy,LegalEntity,BillingTreatment,BillingTreatmentItem,ProrationPolicy`
  - `load`: create the records in the target org (the other mode, `export`, only reads an org).
  - `<org alias>`: the name you gave the org when you logged in with the Salesforce CLI.
  - `--only BillingPolicy,LegalEntity,BillingTreatment,BillingTreatmentItem,ProrationPolicy`: load just these objects, comma separated. Records already in the org are skipped, so running it twice is safe.
  - Add `--dry-run` to print what would be created and create nothing.
  - What they hold: `data/seed/17-BillingPolicy.json` (Velora Advance and the policy for arrears), `42-LegalEntity.json` (Velora Motors Inc.), `43-BillingTreatment.json`, `44-BillingTreatmentItem.json`, `21-ProrationPolicy.json`.
- `force-app/main/default/settings/Billing.settings-meta.xml`: the Billing switches. Deploy: `sf project deploy start --source-dir force-app/main/default/settings --target-org <org alias>`.
- `force-app/main/default/flows/Order_To_Billing_Schedule.flow-meta.xml`: the flow that makes billing schedules when an order is activated. Deploy: `sf project deploy start --source-dir force-app/main/default/flows --target-org <org alias>`.
- `force-app/main/default/layouts/BillingAccount-Billing Account Layout.layout-meta.xml`: the Billing Account page layout.
- Payment term and Swift's billing account are not in the data files: enter them by hand (steps 7 and 8).

## What you should see

Two active policies, each with an active treatment and item. A legal entity Velora Motors Inc. A payment term Net 30. A default Billing Account for Swift Couriers with bill day 1. Each product shows Velora Advance as its billing policy. No order exists yet, so no billing schedule yet.

## Records and values

Where this page and an older note differ, the latest recorded values (31 Oct 2026) and the Velora example values win.

- Bill day 1; payment term Net 30; legal entity Velora Motors Inc.; prices exclude tax. Vans and chargers are invoiced once on delivery; Connect monthly in advance; charging monthly in arrears.
- Billing person: Elena Ortiz. Bill-to contact: Marcus Hale at Swift Couriers (example address, invented).
- Velora Connect Plus does not exist yet: it is created in episode 34 with Velora Advance. Depot Charging gets Velora Arrears in episode 27.
- For an order the bill day comes from the period boundary on the order line; with a 1 Feb start both Anniversary and Align to Calendar give day 1.
