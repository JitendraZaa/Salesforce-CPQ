# Episode 10: Qualification rules

## What this episode builds

Some products are for some customers only. You make the Depot Charger and the Charger Installation visible only for
accounts with Has Depot ticked. Swift Couriers (depots) sees them in the catalog; Crumb & Co Bakery (no depot) does not.
Doing this touches a custom field, two disqualification records, a context definition, two decision tables and a
qualification procedure.

## Before you start

- Starting point: end of episode 9 (tag `ep09-end`): configuration rules work; Has Depot exists on Account but is ticked nowhere.
- Fresh org: `sh scripts/reset-to.sh ep09-end`. Tag at the end: `ep10-end`.

## Click path

1. Deploy the Has Depot field on Product Disqualification and its permission (command below). Why: the qualification
   rule compares the account's Has Depot with this field.
2. Open Swift Couriers and tick Has Depot. Create the account Crumb & Co Bakery with Has Depot clear, and a quote
   `Crumb & Co Bakery Quote` on it.
3. App Launcher, Product Disqualifications, New: product Depot Charger 150 kW, effective from today, effective to a later
   date, Has Depot unchecked. Repeat for Charger Installation. Meaning: the product is disqualified when the account's Has Depot is unchecked.
4. Setup, Context Definitions, Custom Definitions, BrowseProductsCtxDefinition, Edit. On the Account node add the
   attribute HasDepot (Input, Boolean), do the same on the Product node, and tag it HasDepot on the Account node. Save.
5. Map Data: map HasDepot from the input Account node to the Has Depot field of Account. Save.
6. Product Catalog Management, Qualification Rules, Product Disqualification: Deactivate, add the condition on
   `Has_Depot__c` with Equals, finish, Activate.
7. Qualification Rules Procedures, Product Qualification, newest active version: Deactivate, open Evaluate
   Disqualification, map the Has Depot input, Save and Activate. (The procedure is built on screen; it cannot be deployed.)
8. Setup, Product Discovery Settings: set the context definition to BrowseProductsCtxDefinition and the qualification procedure to ProductQualification.
9. Salesforce Pricing Setup, Sync Pricing Data, Sync, Confirm. If the rule seems not to work, sync again.
10. Test: Swift Couriers quote, Browse Catalogs, Charging, Depot shows the Depot Charger and Installation. The Crumb & Co Bakery quote does not.

## Files in this repo used by this episode

| File | What it contains |
|---|---|
| `force-app/main/default/objects/ProductDisqualification/fields/Has_Depot__c.field-meta.xml` | The Has Depot checkbox on Product Disqualification. |
| `force-app/main/default/permissionsets/Velora_Fields.permissionset-meta.xml` | Field access to it. |
| `force-app/main/default/contextDefinitions/BrowseProductsCtxDefinition.contextDefinition-meta.xml` | The context definition the qualification procedure reads. |
| `force-app/main/default/decisionTables/Product_Qualification.decisionTable-meta.xml`, `Product_Disqualification.decisionTable-meta.xml` | The two decision tables behind the rule. |
| `data/seed/30-ProductDisqualification.json` | The disqualification records for the Depot Charger and Charger Installation. |
| `data/seed/02-Account.json` | The example accounts with their Has Depot values. |

```sh
sf project deploy start --source-dir force-app --target-org my_alias
sh scripts/seed-all.sh my_alias
```

- `--source-dir force-app`: send everything in the folder. `--target-org`: which org.
- `seed-all.sh <alias>`: loads the accounts and disqualification records; add `--dry-run` to preview.
- The Product Qualification procedure (an expression set) cannot be deployed: build it on screen. After changing a decision table, use Setup, Decision Tables, the table, Refresh.

## What you should see

Depot Charger and Charger Installation appear in the catalog on the Swift Couriers quote and are hidden on the Crumb & Co Bakery quote. The org has no Person Accounts, so the bakery stands in for any account without a depot.

## Records and values

Swift Couriers: Has Depot yes. Crumb & Co Bakery: Has Depot no, a dealer's customer with three Volt Vans.
Qualification: Depot Charger and Charger Installation only for accounts with Has Depot = yes.
