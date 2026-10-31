# Episode 5: Catalogs and categories

## What this episode builds

You add the other five products Velora sells, build the category tree of Velora Catalog (Vehicles with Vans and Cars,
Charging with Depot and Home, Services), assign each product to its categories, and rebuild the index so the whole
tree shows when a rep browses the catalog from the pilot quote.

## Before you start

- Starting point: end of episode 4 (tag `ep04-end`): Volt Van with a 48,000 price, Velora Catalog with Vehicles, a built index, the pilot quote.
- Fresh org: `sh scripts/reset-to.sh ep04-end`. Tag at the end: `ep05-end`.

## Click path

1. Load the five products (command below): Aria, Depot Charger 150 kW, Charger Installation, Wall Charger 11 kW,
   Velora Connect. Why: a product must exist before it can be put in a category.
2. Product Catalog Management, Catalogs, Velora Catalog, Categories. Vehicles exists from episode 3.
3. Create Category Charging (sort order 2, code CHG) and Services (sort order 3, code SVC). Leave Show In Menu unticked.
4. On Vehicles use Add Subcategory: Vans (VANS, sort 1) and Cars (CARS, sort 2). On Charging add Depot (DEPOT) and Home (HOME).
5. Open Vans, Products section, Assign Products: Volt Van. Repeat: Aria to Cars; Depot Charger to Depot; Wall Charger
   to Home and to Cars; Charger Installation and Velora Connect to Services. A product can sit in more than one category.
6. Index and Search Configuration, Rebuild Index, Partial. Why: new products and assignments are not searchable until the index is rebuilt.
7. Salesforce Pricing Setup, Sync Pricing Data, Sync, Confirm. Why: new price book entries were added.
8. On the pilot quote choose Browse Catalogs, price book, Velora Catalog, Next. Vehicles, then Vans shows the Volt Van;
   Charging and Services show their products. Do not add anything.

## Files in this repo used by this episode

| File | What it contains |
|---|---|
| `data/ep05/Product2.json` | Five products with code, family and description: Aria AR-200, Depot Charger 150 kW DC-150, Charger Installation SV-INST, Wall Charger 11 kW WC-11, Velora Connect VC-SUB. |
| `scripts/load-ep05.sh` | Imports the file above, sets the Volt Van's family, gives Aria, Depot Charger, Installation and Wall Charger the One Time option and a standard price (39,000; 32,000; 6,800; 1,100), then lists the prices. Does nothing if the products exist. |
| `scripts/load-ep05-catalog.sh` | Creates the categories and the assignments listed in step 3 to 5. Safe to run twice; needs `load-ep03.sh` and `load-ep05.sh` first. |

```sh
sh scripts/load-ep05.sh
sh scripts/load-ep05-catalog.sh
TARGET_ORG=my_alias sh scripts/load-ep05.sh
```

- `TARGET_ORG=my_alias`: runs against that org alias instead of the default.
- Inside, `sf data import tree --files <file>` loads the records; `sf data create record --sobject <object> --values "<field=value ...>"` creates one record; `sf data query --query "<SOQL>"` lists results.
- The Family picklist must contain Vehicles, Charging and Services before the load.

Velora Connect gets its selling model and price only in episode 7. The index rebuild and the sync are done by hand.

## What you should see

Browse Catalogs shows Velora Catalog with Vehicles (Vans, Cars), Charging (Depot, Home) and Services, with the Volt Van under Vans.

## Records and values

Aria AR-200 39,000 (one-time). Depot Charger 150 kW DC-150 32,000. Charger Installation SV-INST 6,800 per charger.
Wall Charger 11 kW WC-11 1,100. Velora Connect VC-SUB 29 per vehicle per month, added in episode 7.
