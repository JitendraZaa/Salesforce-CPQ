# Episode 8: Bundles

## What this episode builds

You create the Volt Van Fleet Package, a configurable bundle. It has three groups: Vehicle (the Volt Van, required),
Services (Velora Connect, required and included by default, one per van) and Accessories (the Wall Charger, optional).
You put it in the Vans category, rebuild the index, sync pricing and add the package to the pilot quote.

## Before you start

- Starting point: end of episode 7 (tag `ep07-end`): Connect has its options and a 29 price; the pilot quote has a Volt Van line and a dated Connect line.
- Fresh org: `sh scripts/reset-to.sh ep07-end`. Tag at the end: `ep08-end`.

## Click path

1. Check access: Configure Products at Runtime is on (episode 2). Assign the ARC Access permission set to yourself if the
   Structure tab is missing: `sf org assign permset --name IndustriesARCPsl`.
2. Product Catalog Management, Products, New. Record type Commercial, name `Volt Van Fleet Package`, code `VVF-PKG`,
   Product Type Bundle, Configure During Sale Allowed, Active. Save. A Structure tab appears.
3. Related, Product Selling Model Options, New: One Time, Default. Then a standard price book entry for the package,
   One Time, list price 0. Why: a quote line needs an entry; the children carry the prices.
4. Structure tab: add three Product Groups under the root. Vehicle (min 1, max 1), Services (1, 1), Accessories (0, 1).
   Components go under groups, never directly under the root.
5. In Vehicle add Volt Van, quantity 1, tick Require this component, leave Allow quantity changes clear.
6. In Services add Velora Connect: Require this component and Include component by default; selling model Term Based -
   Monthly. Quantity Scale Method stays Proportional (Connect follows the package quantity; the other value, Constant,
   keeps the quantity fixed). The bundle price does not include the child.
7. In Accessories add Wall Charger 11 kW with both boxes cleared (an optional component, drawn as a dotted line).
8. Assign the package to the Vans category. Rebuild Index (partial). Sync Pricing Data.
9. On the pilot quote delete the Volt Van and Connect lines. Browse Catalogs, Vehicles, Vans, Volt Van Fleet Package.
   The configurator opens with the Volt Van (Battery, Body) and Connect included and the Wall Charger unticked. Save the
   configuration and set the Connect line's start and end dates if asked.

## Files in this repo used by this episode

| File | What it contains |
|---|---|
| `data/seed/18-Product2.json` | Includes the Volt Van Fleet Package product (code VVF-PKG). |
| `data/seed/24-ProductComponentGroup.json` | The three groups Vehicle, Services and Accessories with their minimum and maximum components. |
| `data/seed/25-ProductRelatedComponent.json` | The three components with required, default and price-inclusion flags. |
| `data/seed/22-ProductSellingModelOption.json`, `23-PricebookEntry.json`, `20-ProductCategoryProduct.json` | The package's option, its 0 entry and its place in Vans. |
| `scripts/seed-ep08.sh` | Runs the episode 7 chain and prints the by-hand list for this episode. |

```sh
sh scripts/seed-all.sh my_alias
sf org assign permset --name IndustriesARCPsl --target-org my_alias
```

- `seed-all.sh <alias>`: loads every data file (including the bundle) into the org; safe to run again.
- `sf org assign permset --name <set>`: gives the permission set to the logged-in user; `--target-org` chooses the org.
- After a load, rebuild the index and sync pricing data by hand.

## What you should see

On the pilot quote the package is the root line, with the Volt Van and Velora Connect as component lines under it. The
Wall Charger is left optional.

## Records and values

Volt Van Fleet Package (VVF-PKG) = Volt Van (required) + Velora Connect (required, one per van) + Wall Charger
(optional, 1,100). Package price 0; the components carry the prices. Fleet quotes later use this package for every van.
