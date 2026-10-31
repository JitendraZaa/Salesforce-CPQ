# Episode 25: Fulfillment orchestration

All names, people, companies and numbers in this project are invented examples.

## What this episode builds

A fresh fleet order, made from the accepted V2 and activated, is submitted on camera to Dynamic Revenue Orchestrator (DRO). The plan has one step per order line: chargers installed, the Standard Panel line built and delivered, the Refrigerated line built and delivered (with 12 of its 60 vans arriving later), and Connect activated after delivery. Every step ends Completed. This order is the canonical downstream order: episodes 26 to 36 select its records by id, never by customer alone.

## Before you start

- Starting point: the org as episode 24 left it (git tag `ep24-end`). A git tag restores files only, not the org.
- To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep24-end <org alias>`. It loads the data and lists the clicks that a script cannot do.
- Words used here are explained in `GLOSSARY.md` in this folder.

## Click path

1. Check access: DRO is turned on, the working user is a Fulfillment Designer or DRO Admin User, a fulfillment user exists, and the DRO context definitions are on. DRO needs the Advanced licence; name that on screen.
2. Create three **technical** products (record type Technical): `Volt Van Build`, `Charger Install Job` and `Connect Activation`. A technical product is a work item, not something sold, so it is never priced.
3. In the App Launcher open **Dynamic Revenue Orchestrator**, Products, Volt Van, **Decomposition** tab, **Add Decomposition Rule**: a unique name, a priority, destination product `Volt Van Build`. Repeat for Depot Charger 150 kW and Charger Installation (to `Charger Install Job`) and Velora Connect (to `Connect Activation`).
4. Open **Fulfillment Workspaces**, click **New**, name `Swift Fleet Fulfillment`. In it create one step definition group `Fleet delivery` and add the steps: `Build Vans` (manual task, line item scope), `Deliver Vans` (manual task, line item), `Install Chargers` (manual task, plan scope) and `Activate Connect` (an auto task that runs a flow).
5. Build the flow `Activate Connect Step` in Setup, Flows, an autolaunched flow that updates the Connect assets of the order line it runs for, and choose it on the Activate Connect step.
6. Set the dependencies: Build Vans before Deliver Vans (line item); Deliver Vans before Activate Connect (line item). Install Chargers has no dependency.
7. On the group, Related, **Scenarios**, **New**: for each technical product pick the Add action. The scenario `New van build and delivery` is for Volt Van Build.
8. Create the new order: on the accepted V2 click Create Order, activate it, then open the order in the DRO app, where the embedded submit flow shows. Click Submit. Expect Submit Status SUCCESS and a fulfillment plan In Progress.
9. Open the orchestration plan: one Install Chargers step, a Build Vans and Deliver Vans pair for each van line (two lines in Year 1), and an Activate Connect step. Complete the steps in order: Install Chargers (story date 28 Jan 2027), both Build Vans, the Standard Panel delivery, the first 48 Refrigerated vans, and finally the last 12 on 1 Mar 2027. Every step ends Completed.
10. Check the Swift account's Assets tab for duplicates of the assets made in episode 24, and decide whether to turn off the custom asset flow before activation so DRO creates the assets.

## Files in this repo used by this episode

- `scripts/seed.py` (the data loader) and `data/seed/manifest.json` (load order). Command: `python3 scripts/seed.py load <org alias> --only FulfillmentWorkspace,FulfillmentStepDefinitionGroup,FulfillmentStepDefinition,FulfillmentStepDependencyDef,FulfillmentWorkspaceItem,ProductFulfillmentDecompRule,ProductFulfillmentScenario`
  - `load`: create the records in the target org.
  - `<org alias>`: the name you gave the org in the Salesforce CLI.
  - `--only FulfillmentWorkspace,FulfillmentStepDefinitionGroup,FulfillmentStepDefinition,FulfillmentStepDependencyDef,FulfillmentWorkspaceItem,ProductFulfillmentDecompRule,ProductFulfillmentScenario`: load just these objects. Existing records are skipped, so it is safe to repeat.
  - `--dry-run` (optional): print what would be created and create nothing.
  - What they hold: `data/seed/56-FulfillmentWorkspace.json` (Swift Fleet Fulfillment), `57-FulfillmentStepDefinitionGroup.json` (Fleet delivery), `58-FulfillmentStepDefinition.json` (Build Vans, Deliver Vans), `59-FulfillmentStepDependencyDef.json` (Build before delivery), `60-FulfillmentWorkspaceItem.json`, `63-ProductFulfillmentDecompRule.json` (Volt Van to Build), `64-ProductFulfillmentScenario.json` (New van build and delivery). `18-Product2.json` holds the technical product Volt Van Build.
- `force-app/main/default/flows/Submit_Sales_Transaction_Flow.flow-meta.xml`: the flow embedded on the order page that submits the order to DRO. Deploy: `sf project deploy start --source-dir force-app/main/default/flows --target-org <org alias>`.
  - `--source-dir`: deploy only that folder.
- `force-app/main/default/flows/Custom_Assetize_Order_Flow.flow-meta.xml`: the custom asset flow from episode 24 (decide whether it stays active).
- `force-app/main/default/decisionTables/FulfillmentFalloutRules.decisionTable-meta.xml` and `Fulfillment_Step_Jeopardy_Rule_Decision_Table.decisionTable-meta.xml`: the fallout and jeopardy rules. After activating the decomposition rule set, refresh them in Setup, Decision Tables.
- Not in the repo: the steps Install Chargers and Activate Connect, the Charger Install Job and Connect Activation products and rules, and the `Activate Connect Step` flow. Create them by hand as in the click path.

## What you should see

An orchestration plan on the new fleet order with the steps above, each Completed in the end. Submit Status SUCCESS on the order. Install Chargers done on the story date 28 Jan 2027; 88 vans delivered on the road by 1 Feb 2027 and the last 12 refrigerated vans on 1 Mar 2027. The order has four van lines only if the full ramp is on it (40, 60, 100, 100); the plan shows the lines the order actually holds.

## Records and values

Where this page and an older note differ, the latest recorded values (31 Oct 2026) and the Velora example values win.

- a fresh order goes through DRO from submission to Completed; the order of 23 and 24 is not reused.
- Steps: Build Vans then Deliver Vans (line item scope, one instance per van line, not per van), Install Chargers (plan scope, done 28 Jan 2027, before charging starts), Activate Connect after its van line's Deliver step.
- Year 1 lines: 40 Standard Panel, 60 Refrigerated Long Range, 100 Connect, 2 Depot Chargers, 2 Installations. Delivery: 88 vans on 1 Feb 2027, the last 12 on 1 Mar 2027.
- DRO design pieces in the data: workspace "Swift Fleet Fulfillment", group "Fleet delivery", scenario "New van build and delivery".
