# Episode 22: Billing setup

All names, people, companies and numbers in this project are invented examples.

## What this episode builds

The billing rules, set before any order exists: the active billing policy Velora Advance with one treatment and one treatment item, the legal entity Velora Motors Inc., the default 30-day payment term, and Swift Couriers' default billing profile (a Billing Account) with bill day 1. Every product points at Velora Advance. Usage charging later uses the org's own "Billing Policy - Arrears" (episode 27).

## Before you start

- Starting point: the org as episode 21 left it (git tag `ep21-end`). A git tag restores files only, not the org.
- To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep21-end <org alias>`. It loads the data and lists the clicks that a script cannot do.
- You need the Billing and Billing Advanced licences.
- Words used here are explained in `GLOSSARY.md` in this folder.

## Click path

1. Setup, Users, Permission Sets: assign **Billing Admin** and **Billing Operations User** to the admin user doing the setup. (Without one of these the billing pages do not open.)
2. App Launcher, **Billing Policies**, **New**: name `Velora Advance`, status Draft, billing treatment selection **Default**. Save. A policy can only be created in Draft.
3. App Launcher, **Legal Entities**, **New**: `Velora Motors Inc.` with company name and an address (example: Oakland, CA). Or open the org's default legal entity and rename it.
4. App Launcher, **Billing Treatments**, **New**: `Velora Advance Treatment`, the policy, the legal entity, status Draft, Exclude From Billing No. Save. Open the policy and set this treatment as its default.
5. App Launcher, **Billing Treatment Items**, **New**: `Velora Advance Item`, the treatment, processing order 1, Billing Type **Advance**, controller Billing Schedule Group, and the other required values the form asks for (copy the org's sample item). Activate in this order: the item, then the treatment, then the policy.
6. App Launcher, **Payment Terms**: the org's **Default Payment Term** is active, the default, with one Period-Based item of 30 days. Keep it; the series calls it "the default 30-day term". If the list is empty, create a list view (All Payment Terms) first.
7. App Launcher, **Billing Accounts**, **New**: name `Swift Couriers Billing`, tick Default Billing Profile, account Swift Couriers, an example address, Bill Day of Month 1, Bill To Contact Marcus Hale. Save. Each billing account is a billing profile. Look at **Created By** on the saved record.
8. Open each product (Volt Van, Aria, Velora Connect, Depot Charger 150 kW, Charger Installation, Wall Charger 11 kW), Edit, set **Billing Policy** to Velora Advance, Save. Do this now: the policy is copied to order items when an order is created.
9. Setup, Flows: confirm that **Order To Billing Schedule** is active and is the only active flow that makes billing schedules.

## Files in this repo used by this episode

- `scripts/seed.py` (the data loader) and `data/seed/manifest.json` (the list of data files in load order). Command to load only this episode's data:
  `python3 scripts/seed.py load <org alias> --only BillingPolicy,LegalEntity,BillingTreatment,BillingTreatmentItem,ProrationPolicy`
  - `load`: create the records in the target org (the other mode, `export`, only reads an org).
  - `<org alias>`: the name you gave the org in the Salesforce CLI.
  - `--only ...`: load just these objects, comma separated. Records already there are skipped, so it is safe to repeat.
  - Add `--dry-run` to print what would be created and create nothing.
  - What they hold: `data/seed/17-BillingPolicy.json`, `42-LegalEntity.json` (Velora Motors Inc.), `43-BillingTreatment.json`, `44-BillingTreatmentItem.json`, `21-ProrationPolicy.json`.
- `force-app/main/default/settings/Billing.settings-meta.xml`: the Billing switches. Deploy: `sf project deploy start --source-dir force-app/main/default/settings --target-org <org alias>`
  - `--source-dir`: deploy only the files in that folder.
- `force-app/main/default/flows/Order_To_Billing_Schedule.flow-meta.xml`: the flow that makes billing schedules when an order is activated. Deploy: `sf project deploy start --source-dir force-app/main/default/flows --target-org <org alias>`
- `force-app/main/default/layouts/BillingAccount-Billing Account Layout.layout-meta.xml`: the Billing Account page layout.
- The payment term and Swift's billing account are not in the data files: use the org's default term and enter the billing account by hand (steps 6 and 7).

## What you should see

An active policy Velora Advance with an active treatment and item. The legal entity Velora Motors Inc. The default 30-day payment term. A default Billing Account for Swift Couriers with bill day 1 and Bill To Marcus Hale. Each product shows Velora Advance as its billing policy. No order exists yet, so no billing schedule yet.

## Records and values

- Bill day 1; payment term 30 days; legal entity Velora Motors Inc.; prices exclude tax. Vans and chargers are invoiced once on delivery; Connect monthly in advance; charging monthly in arrears.
- Bill-to contact: Marcus Hale at Swift Couriers (example address, invented).
- Velora Connect Plus does not exist yet: it is created in episode 34 with Velora Advance.
- For an order the bill day comes from the period boundary on the order line; with a 1 Feb start both Anniversary and Align to Calendar give day 1.

## Try it yourself

Create a second billing account for Swift Couriers with bill day 15 and leave Default Billing Profile unticked. Check that the account can have only one default profile.
