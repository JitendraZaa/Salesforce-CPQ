# Episode 24: Assets and activation

All names, people, companies and numbers in this project are invented examples.

## What this episode builds

The fleet order (00000126 in the example) is activated. The org's asset flow turns it into 16 assets, Swift's Assets tab (the Managed Asset Viewer) lists what Swift now owns with state periods, and 16 billing schedules are created, all ReadyForInvoicing. Assets are linked to contract 00000104 through Asset Contract Relationships.

## Before you start

- Starting point: the org as episode 23 left it (git tag `ep23-end`): the fleet order in Draft. A git tag restores files only, not the org.
- To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep23-end <org alias>`. It loads the data and lists the clicks that a script cannot do.
- Words used here are explained in `GLOSSARY.md` in this folder.

## Click path

1. Open Volt Van, Velora Connect, Depot Charger 150 kW and Charger Installation and check **Is Assetizable** is ticked, so an activated order creates assets.
2. Setup, Flows: find **Custom Assetize Order Flow**, a record-triggered flow on Order that runs when Status becomes Activated. It looks up the order's application usage assignment (`RevenueLifecycleManagement`) and then runs the action **Create or Update Asset from Order**. Check it is Active. (If you do not have it, deploy the repo's copy, see the files below.) Keep only this one asset flow active, so the order is assetized once.
3. Open the fleet order, **Edit**. Fill the billing and shipping address, set **Bill To Contact** to Marcus Hale and **Legal Entity** to Velora Motors Inc. Why: the billing schedules copy these. Save.
4. Edit **Status**, choose **Activated**, Save.
5. Open Accounts, Swift Couriers, the **Assets** tab (Managed Asset Viewer). Click an asset name for the side panel. Use the row action **View** for the state period and the asset actions (the initial sale). Open the asset **Dashboard** to see quantity and MRR over time.
6. Open the order's related lists **Billing Schedule Groups** and **Billing Schedules**. Connect is monthly in advance, bill day 1, with the amounts rising in Years 2 and 3 because of the uplift; vans and chargers are one time (1 Feb 2027, 1 Feb 2028, 1 Feb 2029). Every schedule is ReadyForInvoicing.
7. Open contract 00000104, Related tab: Asset Contract Relationships lists the assets created at activation.

## Files in this repo used by this episode

- `force-app/main/default/flows/Custom_Assetize_Order_Flow.flow-meta.xml`: the record-triggered flow described above. Deploy: `sf project deploy start --source-dir force-app/main/default/flows --target-org <org alias>`
  - `sf project deploy start`: send local metadata to the org.
  - `--source-dir`: only that folder.
  - `--target-org`: which org.
- `force-app/main/default/flows/Order_To_Billing_Schedule.flow-meta.xml`: makes the billing schedules at activation (set up in episode 22).
- `queries/ep24-billing-schedules.soql`: billing type, term unit, bill day, next billing date, total amount and status of the schedules of an order (written for order 00000126; change the number to yours). Command: `sf data query --query "$(cat queries/ep24-billing-schedules.soql)" --target-org <org alias>`
  - `sf data query`: run a read-only SOQL query.
  - `--query "$(cat ...)"`: the query text read from the file.
  - `--target-org`: which org to ask.
- `force-app/main/default/permissionsets/Velora_Fields.permissionset-meta.xml`: field and record type access. Assign: `sf org assign permset --name Velora_Fields --target-org <org alias>`
  - `--name`: the permission set to assign to you.
- No Asset or Contract layout file is in the repo: the Asset Contract Relationships list is on the contract's Related tab by default.

## What you should see

The order status shows Activated. Swift's Assets tab lists 16 assets (Volt Vans, Connect, Depot Chargers, Installations), each with its state period. 16 billing schedules exist, all ReadyForInvoicing, and the query returns Connect monthly from its start date. The contract shows its Asset Contract Relationships.

## Records and values

- Order 00000126 fields: Bill To Contact Marcus Hale, Legal Entity Velora Motors Inc., example addresses in Oakland, CA.
- Order lines: two Volt Van Fleet Package lines per year (40 Standard Panel and 60 Refrigerated Long Range in Year 1, then 100 vans in each of Years 2 and 3), Connect for 100, 200 and 300 vehicles over the three years at 29, 29.87 and 30.77, 2 Depot Chargers, 2 Installations.
- One-time items bill on delivery; Connect bills monthly in advance from the ramp dates. The vans start on the order's start date in the org; the story's 1 Feb 2027 is the narration date.

## Try it yourself

Run the billing schedule query for your order and count the schedules per billing type. Then open one Connect asset and read how its quantity changes between the yearly state periods.
