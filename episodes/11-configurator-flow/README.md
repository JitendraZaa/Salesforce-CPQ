# Episode 11: The configurator flow

## What this episode builds

Velora's own copy of the Product Configurator flow. The Volt Van Fleet Package opens in this cloned flow, with the Body attribute listed before Battery and the attributes shown in two columns. The flow is then retrieved into the repository as `Velora_Product_Configurator`.

## Before you start

Starting point: the org as episode 10 left it (tag `ep10-end`). The package, its rules and the qualification rule work, and the configurator still shows Salesforce's default layout with Battery before Body. Three things must already be true: Configure Products at Runtime is on in Revenue Settings, your user holds the Product Configurator permission, and the Volt Van Fleet Package allows Configure During Sale.

To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep10-end <your org alias>`. The script loads the data and lists the steps that must be done by hand. A git tag restores files only, never the org, so do not rely on `git checkout` to rebuild the org.

## Click path

1. In Product Catalog Management open the Electric Vehicle classification, open its Attributes tab and set Sequence 1 on Body and 2 on Battery. Why: the sequence number decides the order on the configurator screen.
2. In Setup, search Flows, open Flows, and open Default Product Configurator Flow.
3. Click Save As New Flow. Name it Velora Product Configurator; the API name fills in as `Velora_Product_Configurator`. Why: the default flow is Salesforce's and should not be edited.
4. Edit the screen element, select the Product Configurator Product Attributes component, and set Attribute Categorization, Attribute Display and the Columns Attribute Display Style to two columns.
5. Save the flow and click Activate.
6. Open the App Launcher, search Product Configuration Flows and click New. Enter the flow's API name as the Flow Identifier, set the status to Active, and save.
7. On the new record open Related, then Product Configuration Flow Assignment, click New, choose Volt Van Fleet Package and save. Why: a product uses a flow only after it is assigned, and a product can have only one.
8. Open a quote, configure the Volt Van Fleet Package and check that Body is listed first, then Battery.
9. In a terminal retrieve the flow into the repository (command below) and open the file to confirm it holds the screen and its settings.

## Files in this repo used by this episode

- `force-app/main/default/flows/Velora_Product_Configurator.flow-meta.xml`: the cloned flow as retrieved; it holds the screen with the Product Attributes component and its two-column setting. Deploy it to another org with:
  `sf project deploy start --source-dir force-app/main/default/flows --target-org <alias>`
  - `--source-dir` the folder to send; `--target-org` the org alias to receive it. After the deploy, activate the flow in Setup.
- `queries/ep11-sequence.soql`: lists the attributes assigned to the Electric Vehicle classification with their Sequence, so you can check Body is 1 and Battery is 2. Run:
  `sf data query --file queries/ep11-sequence.soql --target-org <alias>`
  - `--file` reads the query from the file; `--target-org` names the org to ask.
- `data/seed/27-ProductConfigurationFlow.json` and `data/seed/28-ProductConfigFlowAssignment.json`: the Product Configuration Flow record and its assignment to the Volt Van Fleet Package. `sh scripts/seed-all.sh <alias>` loads them (the loader `scripts/seed.py` skips records already there).
- Retrieve command used in the episode: `sf project retrieve start --metadata Flow:Velora_Product_Configurator --target-org <alias>`; `--metadata` names the type and the item to bring back, `--target-org` the org to read from.

## What you should see

The Volt Van Fleet Package opens in Velora's own flow. Body is listed first, then Battery, in two columns. The repository now holds the flow file.

## Records and values

All names and numbers are invented examples. Prices are in US dollars.

- Attribute Sequence: Body 1, Battery 2.
- Flow label Velora Product Configurator, API name `Velora_Product_Configurator`, status Active.
- Assignment: one flow, on the Volt Van Fleet Package.
- Bundle: Volt Van Fleet Package is the Volt Van (required), Velora Connect (required, one per van) and Wall Charger 11 kW (optional).
