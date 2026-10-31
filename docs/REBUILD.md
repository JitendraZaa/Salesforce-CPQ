# Rebuild the whole Velora Motors project in a new org

Everything the series builds is either **metadata** (in `force-app/`), **data** (in `data/seed/`, loaded by
`scripts/seed.py`), or a **click** that Salesforce does not let a script do (listed at the end of this page). Nothing the
episodes need lives only in the demo org. If your trial org expires, start here.

Every company, person, product, price and number is an invented example.

## 0. What you need

- The Salesforce CLI (`sf`), Python 3, and a Dev Hub if you want a scratch org.
- An org with the Revenue Cloud (Agentforce Revenue Management) licences. A scratch org gets them from
  `config/revenue-cloud-scratch-def.json` (features `CoreCpq`, `SalesforcePricing`, `ProductCatalogManagementAddOn`,
  `DecisionTable`, `BusinessRulesEngine`, `BillingAdvanced`, `InvoiceManagement`, `UsageManagement`, `RateManagement`,
  `RevSubscriptionManagement`). A Revenue Lifecycle Management demo Developer Edition works too.

## 1. Create the org

```sh
sf org create scratch --definition-file config/revenue-cloud-scratch-def.json --alias velora_qa \
  --target-dev-hub <your dev hub alias> --duration-days 7 --set-default
```

A scratch org is not a Revenue Cloud org until its settings are on, which is step 2. The settings are not in the
definition file on purpose: one bad flag in the definition would fail the creation (about four minutes lost); the same
flag in step 2 only fails one deploy.

## 2. One command for steps 2 to 5

```sh
sh scripts/setup-org.sh velora_qa
```

It runs, in this order:

1. `force-app/main/default/settings/`: the 14 trimmed `*.settings-meta.xml` files (Industries, IndustriesPricing,
   IndustriesContext, IndustriesUsage, IndustriesRating, IndustriesConstraints, Quote, Order, Billing,
   RevenueManagement, ProductCatalogManagement, ProductConfigurator, DynamicFulfillmentOrchestrator,
   LargeQuotesandOrdersForRlm). They hold only the flags that were `true` in the source org, because several flags that
   are `false` are rejected by a new org (for example `enableOptionalPricebook`).
2. `force-app/`: all the metadata, in one deploy (several minutes: the context definition is about 2 MB). The project's
   `sourceApiVersion` is 68.0; a lower value rejects the pricing procedure (`dataType`) and several settings.
3. `sf org assign permset` for `Velora_Fields` and `Velora_Quote_Action`.
4. `scripts/seed-all.sh`: the data.

Run the pieces by hand when something fails: `sf project deploy start --source-dir force-app/main/default/settings`,
then `--source-dir force-app`, then `sh scripts/seed-all.sh velora_qa` (add `--dry-run` to see what it would create).

## 3. What is in the metadata

| Folder | What it is | Episode |
|---|---|---|
| `settings/` | Revenue Cloud switches | 2 |
| `objects/*/fields/` | `Has_Depot__c` on Account and Product Disqualification, and the sample fields the qualification decision tables and layouts read (`Industry__c`, `MaxNumberOfEmployees__c`, `ProposedACV__c` ...), `Quote_Request__c` with its seven fields | 10, 42 |
| `productSpecificationTypes/` | Commercial and Technical | 3, 25 |
| `contextDefinitions/` | `RevSalesTransactionContext` (the pricing procedure needs it) and `BrowseProductsCtxDefinition` (the qualification procedure needs it) | 10, 12 |
| `decisionTables/` | Product Qualification, Product Disqualification, Fulfillment Falloutrules, Fulfillment Step Jeopardy | 10, 25 |
| `expressionSetDefinition/` | `Velora_Pricing` (episodes 12 to 21), `Product_Qualification` | 10, 12 |
| `flows/` | Product Configurator, Fleet Discount Approval, Update Quote Status, Submit Sales Transaction, Order To Billing Schedule, Custom Assetize Order, Create Connect Quote, Orchestrate Usage | 11, 16, 23 to 28, 42 |
| `groups/` | `Admin_Group` (the approval flow's approver group) | 16 |
| `flexipages/`, `layouts/`, `quickActions/` | Record pages and layouts changed in the episodes | 17 to 24, 42 |
| `classes/` | Apex of episodes 41 and 42 and their tests | 41, 42 |
| `permissionsets/` | `Velora_Fields`, `Velora_Quote_Action` | 2, 10, 42 |

The pricing procedure file stores the Ids of decision tables next to their API names. On deploy the new org maps them
to its own tables by API name, so the procedure moves between orgs as plain metadata.

Placeholders: `Velora_Fleet_Discount_Approval` names the approver as `$Record.Owner:User.Manager.Username` (the original
holds the owner's username). In a new org the quote owner needs a manager, or change the approver step in Flow
Builder. The approval flow assigns work to the public group `Admin_Group`, which is deployed from `groups/`.

## 4. What is in the data (`data/seed/`)

`data/seed/manifest.json` lists the files in load order; each file is one object. Records point at each other by name,
never by Id. `python3 scripts/seed.py load <alias>` resolves the names to the Ids of the target org, skips records that
are already there, and creates the rest 200 at a time. Records the source org held from its own template (the nine
selling models, the standard price book, unit classes) are included when a Velora record points at them, because a
scratch org starts with none of them. Records that must be created as Draft and then activated are handled (the loader
creates them as Draft and updates the status; anything that stays Draft is listed in the output).

To refresh the files from a live org (read-only on the source): `python3 scripts/seed.py export <alias>`.
It keeps what was created after the Velora work began (`--since`) plus everything those records point at.

Not in the data on purpose, because they are the *result* of the episodes and are produced by running them (or by the
reset scripts of episodes 3 to 13): quotes, orders, contracts, assets, billing schedules, invoices, usage summaries,
approval work items, fulfillment orders, generated quote PDFs. The inputs that produce them are:

- `data/ep28-usage/*.csv`: the usage readings (Transaction Journal).
- `scripts/ep15-pricing-body.json`, `scripts/api/`: the pricing, invoice and renewal calls.
- `scripts/anonymous/place-one-quote.apex`: places one quote from code.

## 5. Clicks after the data

These cannot be scripted (no metadata type, no API, or an asynchronous job that only the UI starts). Do them in this
order; the episode in brackets shows the screens.

1. **Rule library**: Product Catalog Management, Configuration Rules library, activate the latest version (episode 9).
   Revenue Settings: turn on "Set Up Configuration Rules with Business Rules Engine".
2. **Activate** what the loader left in Draft (it prints each one): attribute picklists and classification, unit of
   measure class, usage resource, product usage resource ("Configure Usage Properties" then Activate), rate card entry
   (episodes 6, 27).
3. **Rebuild Index**: Product Catalog Management, Index and Search Configuration, Rebuild Index, full. About ten
   minutes the first time. Without it Browse Catalogs says "No products to show" (episode 4).
4. **Sync Pricing Data**: Salesforce Pricing Setup, Sync Pricing Data. Without it every line prices at 0 (episode 4).
   Repeat after any price change.
5. **Refresh the decision tables** you changed: Setup, Decision Tables, Volume Discount Entries (and the attribute and
   qualification tables), Refresh (episodes 10, 13).
6. **Activate the pricing procedure**: Expression Set `Velora_Pricing` version 1 (the deploy activates it; a *second*
   deploy of the same file fails with "can't update the expression set version ... because it's active": deactivate
   first), then make it the default in Revenue Settings (episode 12).
7. **Qualification procedure**: build the Product Qualification expression set in Qualification Rules Procedures (it
   cannot be deployed, see section 7), evaluate, activate (episode 10). The two decision tables it reads are deployed.
8. **Configurator flow**: Setup, Flows, activate `Velora_Product_Configurator`; App Launcher, Product Configuration
   Flows, create the record with the flow API name, and assign it to Volt Van Fleet Package as the Primary
   Configurator Flow (episode 11; the flow-assignment record is in the data if it loaded).
9. **Approval flow**: open `Velora_Fleet_Discount_Approval` in Flow Builder, choose the approver, activate (episode 16).
10. **Document Builder template** "Velora Fleet Quote": built in Document Builder, there is no metadata type to retrieve
    it. Steps and components: the episode 17 runbook in the series notes. Set it as the default template for Quote.
11. **Billing**: billing policy and treatment are in the data; link each product to its policy, activate the
    treatment, make the legal entity active (episode 22). The Billing Batch Scheduler cannot be created through the
    API: Billing app, Billing Batch Schedulers, New (episode 26).
12. **Fulfillment (DRO)**: decomposition rules and scenarios are data; the workspace, step definitions, dependencies and
    the falloutrule decision tables are in the metadata and data. Activate the decomposition rule set and run
    "Refresh" on the fulfillment decision tables (episode 25).
13. **Usage**: Price Book Rate Cards link, then Activate the product usage resource (episode 27). Flows
    `Velora_Orchestrate_Usage` is a schedule-triggered flow: Debug, not Run, to test it (episode 28).
14. **Experience Cloud sites** (episodes 37 and 39): built in Experience Builder; their metadata (`experiences/`,
    `networks/`, `sites/`) is not in the repo yet.
15. Rename the running user to Jitendra Zaa (or your own name) in a scratch org, so Created By shows it.

## 6. Check it

```sh
sf apex run test --target-org velora_qa --class-names DealMetricsTest --class-names ConnectQuoteActionTest
sh scripts/api/price-100-vans.sh    # prices 100 Volt Vans through the pricing API (needs steps 3 to 6)
```

## 7. What was tested, and what is known to be missing

Tested on a scratch org built from `config/revenue-cloud-scratch-def.json` (31 Oct 2026): the 14 settings deploy, all
metadata in `force-app/` deploys (86 components), `scripts/seed.py load` creates the 55 data files and a second run
creates nothing and fails nothing. The exceptions, all expected:

- Two end-dated attribute adjustments (the earlier 6,500 and 10,700 overrides) are skipped in a new org: they end
  before the new org's own "Standard Attribute Based Adjustment" schedule starts. Add them by hand with an earlier
  schedule start date if a video needs them.
- `AttributePicklist.Code` and `Product2.IsSerialized` do not exist in a scratch org and are dropped (printed).
- The loader sets the step definitions' assignee to the user running the load.
- Not in the repo, because Salesforce offers no way to retrieve or create them from a script: the Product
  Qualification expression set (its retrieve deploys with "ProductId isn't a valid variable name": build it in
  Qualification Rules Procedures), configuration rule records (created through the rule library), the Document Builder
  template, clause set category, the Experience Cloud sites, quotes/orders/contracts/assets/invoices (results of the
  episodes), the demo org's own layouts that point at other sample content (Order, Product Attribute Definition,
  Contract Item Price), and the Velora Fleet Quote record page (needs the Document Builder page type).
- Redeploying `Velora_Pricing` into an org where it is already active fails; the first deploy works.
