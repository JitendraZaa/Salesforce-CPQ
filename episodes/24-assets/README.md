# Episode 24: Assets and activation

All names, people, companies and numbers in this project are invented examples.

## What this episode builds

The fleet order is activated, and an asset flow turns it into assets. Swift's Assets tab (the Managed Asset Viewer) then lists what Swift owns, with state periods and asset actions. Billing schedules and billing schedule groups are created at activation, and assets are linked to the contract.

## Before you start

- Starting point: the org as episode 23 left it (git tag `ep23-end`). A git tag restores files only, not the org.
- To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep23-end <org alias>`. It loads the data and lists the clicks that a script cannot do.
- Words used here are explained in `GLOSSARY.md` in this folder.

## Click path

1. Open Volt Van, Velora Connect, Depot Charger 150 kW and Charger Installation and check **Is Assetizable** is ticked, so an activated order creates assets.
2. In Setup, Flows, check whether a standard Order to Asset flow is already active. If one is, do not build a second.
3. Otherwise use the repo's `Custom Assetize Order Flow`: a record-triggered flow on Order, run when Status becomes **Activated**. It looks up the order's application usage assignment (`RevenueLifecycleManagement`) and, when found, runs the action **Create or Update Asset from Order**. Activate it.
4. Make sure the order itself has the application usage assignment (it comes from the linked contract).
5. Open the fleet order, edit **Status**, choose **Activated** and Save. No error should appear.
6. Open Accounts, Swift Couriers, the **Assets** tab. Click an asset name for the side panel. Use the row action **View** to see the state period and the asset actions (the initial sale).
7. Open the order's **Billing Schedule Groups** and **Billing Schedules**. Connect should be monthly, in advance, bill day 1; vans and chargers one time.
8. Add the **Asset Contract Relationship** component to the Asset and Contract page layouts, then open the Connect asset and the contract to see the link.

## Files in this repo used by this episode

- `force-app/main/default/flows/Custom_Assetize_Order_Flow.flow-meta.xml`: the record-triggered flow described above. Deploy: `sf project deploy start --source-dir force-app/main/default/flows --target-org <org alias>`.
- `force-app/main/default/flows/Order_To_Billing_Schedule.flow-meta.xml`: makes the billing schedules at activation.
- `queries/ep24-billing-schedules.soql`: billing type, term unit, bill day, next billing date, total amount and status of the schedules of an order (written for order 00000121; change the number to yours). Command: `sf data query --query "$(cat queries/ep24-billing-schedules.soql)" --target-org <org alias>`
  - `sf data query`: run a read-only query.
  - `--query "$(cat ...)"`: query text from the file.
  - `--target-org`: which org.
- `force-app/main/default/permissionsets/Velora_Fields.permissionset-meta.xml`: field and record type access. Assign: `sf org assign permset --name Velora_Fields --target-org <org alias>`.
- The Asset and Contract layouts and the Assetize Order permission set are not in the repo: add them by hand.

## What you should see

The order status shows Activated. The Swift Couriers account lists assets for Volt Vans, Connect, Depot Chargers and Installations, each with one state period. Billing schedules exist, with Connect monthly from the start date. The Connect asset is linked to the contract. Billing treatments now show Velora Advance on every order line.

## Records and values

Where this page and an older note differ, the latest recorded values (31 Oct 2026) and the Velora example values win.

- Year 1 order lines: two Volt Van Fleet Package lines, 40 Standard Panel and 60 Refrigerated Long Range, 100 Connect, 2 Depot Chargers and 2 Installations. Wall Chargers are not on V2. Later ramp segments cover Years 2 and 3.
- Connect: 29 per vehicle per month, billed monthly in advance from 1 Feb 2027 (story date). One-time items invoiced on delivery.
- The order of episodes 23 and 24 is not the order DRO fulfils in episode 25: episode 25 uses a fresh order.
