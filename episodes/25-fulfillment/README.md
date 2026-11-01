# Episode 25: Fulfillment orchestration

All names, people, companies and numbers in this project are invented examples.

## What this episode builds

The fleet order (00000126 in the example) is submitted to Dynamic Revenue Orchestrator (DRO). A fulfillment design with one technical product (Volt Van Build), one decomposition rule, one workspace with a group of two manual steps (Build Vans, then Deliver Vans) and one scenario produces a fulfillment plan with the steps of every van line. Both steps are completed and the plan ends Completed. Chargers and Connect follow the same pattern and are explained rather than built.

## Before you start

- Starting point: the org as episode 24 left it (git tag `ep24-end`): the fleet order is activated, with assets and billing schedules. A git tag restores files only, not the org.
- To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep24-end <org alias>`. It loads the data and lists the clicks that a script cannot do.
- You need the Revenue Cloud Advanced licence and the Fulfillment User permission set licence.
- Words used here are explained in `GLOSSARY.md` in this folder.

## Click path

1. Setup, Dynamic Revenue Orchestrator Settings: DRO is On, In-flight Amendments and Future Dated Steps on, and the Fulfillment User ("Other User") is set. Setup, Permission Sets: your user holds Fulfillment Designer or DRO Admin User.
2. App Launcher, Products (Product Catalog Management), **New Product**, record type **Technical**: `Volt Van Build`. A technical product is a work item, not something sold, so it has no price.
3. App Launcher, **Dynamic Revenue Orchestrator**, Products, Volt Van, **Decomposition** tab, **Add Decomposition Rule**: a unique name, a priority, destination product `Volt Van Build`. Save.
4. App Launcher, **Fulfillment Workspaces**, **New**: `Swift Fleet Fulfillment`. In it create one step definition group, `Fleet delivery`, and **Add Step** twice: `Build Vans` (manual task, scope Line Item) and `Deliver Vans` (manual task, scope Line Item). Line Item scope gives one step per order line, not per van.
5. Set the dependency: click the dependency icon on Build Vans, then on Deliver Vans, scope Line Item. Deliver starts when Build completes.
6. On the group, Related, **Scenarios**, **New**: `New van build and delivery`, product Volt Van Build, move the **Add** action to Chosen. Save.
7. Open order 00000126 in the DRO app. The page embeds the **Submit Sales Transaction Flow**. Click **Submit**. Expect "Submit Status: SUCCESS".
8. Open the Fulfillment Plan from the order. It shows each van line with Build Vans In Progress and Deliver Vans Pending. Use the plan canvas menu on each Build Vans step, **Mark Complete**; DRO starts each Deliver Vans step about two minutes later; complete those too. The plan ends Completed with every step green.

## Files in this repo used by this episode

- `scripts/seed.py` (the data loader) and `data/seed/manifest.json` (load order). Command: `python3 scripts/seed.py load <org alias> --only FulfillmentWorkspace,FulfillmentStepDefinitionGroup,FulfillmentStepDefinition,FulfillmentStepDependencyDef,FulfillmentWorkspaceItem,ProductFulfillmentDecompRule,ProductFulfillmentScenario`
  - `load`: create the records in the target org.
  - `<org alias>`: the name you gave the org in the Salesforce CLI.
  - `--only ...`: load just these objects. Records already there are skipped, so it is safe to repeat.
  - `--dry-run` (optional): print what would be created and create nothing.
  - What they hold: `data/seed/56-FulfillmentWorkspace.json` (Swift Fleet Fulfillment), `57-FulfillmentStepDefinitionGroup.json` (Fleet delivery), `58-FulfillmentStepDefinition.json` (Build Vans, Deliver Vans), `59-FulfillmentStepDependencyDef.json`, `60-FulfillmentWorkspaceItem.json`, `63-ProductFulfillmentDecompRule.json` (Volt Van to Volt Van Build), `64-ProductFulfillmentScenario.json`. `18-Product2.json` holds the technical product Volt Van Build.
- `force-app/main/default/flows/Submit_Sales_Transaction_Flow.flow-meta.xml`: the flow embedded on the order page in the DRO app. Deploy: `sf project deploy start --source-dir force-app/main/default/flows --target-org <org alias>`
  - `--source-dir`: only that folder.
- `force-app/main/default/decisionTables/FulfillmentFalloutRules.decisionTable-meta.xml` and `Fulfillment_Step_Jeopardy_Rule_Decision_Table.decisionTable-meta.xml`: the fallout and jeopardy rules. Refresh them in Setup, Decision Tables after loading.
- No file is in the repo for the charger and Connect decompositions: the same steps as 2 to 6 repeat for each product.

## What you should see

Submit Status SUCCESS on the order and a Fulfillment Plan (000000004 in the example) with one Build Vans and one Deliver Vans step per van line, four van lines for the three-year order. Build Vans completes first; Deliver Vans then starts and completes; the plan is Completed.

## Records and values

- Design pieces: workspace "Swift Fleet Fulfillment", group "Fleet delivery", scenario "New van build and delivery", technical product Volt Van Build.
- Van lines: 40 Standard Panel and 60 Refrigerated Long Range (Year 1), 100 vans (Year 2), 100 vans (Year 3).
- Story dates only: chargers installed 28 Jan 2027; 88 vans delivered by 1 Feb 2027; the last 12 refrigerated vans on 1 Mar 2027. In the org the steps carry the completion time of the day you click.

## Try it yourself

Add a second step group for Connect with one manual step `Activate Connect`, a Line Item dependency from Deliver Vans, and a scenario for a technical product `Connect Activation`. Submit a fresh order and read the plan.
