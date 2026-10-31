# Episode 3: The first product and its price

## What this episode builds

You create Velora Motors' first product, the Volt Van, as a Commercial product. You attach the existing One Time
selling model to it, give it a list price of 48,000 in the standard price book, and place it in a first catalog,
Velora Catalog, under the category Vehicles.

## Before you start

- Starting point: the end of episode 2 (tag `ep02-end`): project open, Has Depot field deployed, Revenue Settings checked,
  pricing synced. The org already holds nine active selling models, including One Time.
- A tag restores files only, not the org. To bring a fresh org here, run `sh scripts/reset-to.sh ep02-end`.
- Tag at the end: `ep03-end`.

## Click path

1. App Launcher, Product Catalog Management, Product Selling Models, list view All. Find One Time (type One Time).
   We reuse it. If your org has none, create one with Selling Model Type One Time and Status Active.
2. Products, New. Choose the record type Commercial (Technical is for fulfillment, used later). Name `Volt Van`,
   Product Code `VV-100`, Active ticked. Leave Configure During Sale as Allowed. Save. Why: a product needs a code
   so people and files can refer to it without ambiguity.
3. On the Volt Van open Related, Product Selling Model Options, New. Choose One Time and tick Default. Open the One
   Time record first if the lookup finds nothing: the lookup lists only recently viewed records. Why: the option says
   how the product may be sold.
4. App Launcher, Price Management, Price Books, Standard Price Book, Price Book Entries, New. Product Volt Van,
   Active, List Price 48000, selling model One Time. Why: the price and the selling model are tied together in the
   entry and cannot be changed afterwards.
5. App Launcher, Catalogs, New. Name `Velora Catalog`, Catalog Code `VELORA`, effective start date today. Why: a rep
   browses a catalog when adding products to a quote.
6. On the catalog create the category `Vehicles` (code `VEHICLES`, sort order 1).
7. Open the category, Products section, Assign Products, choose Volt Van, Next, save. If you see error -265738217, the
   Category page layout is missing from your profile.
8. Open the Volt Van record and look at Created By and Last Modified By.
9. Do not sync or rebuild the index yet. Episode 4 does both, after the price exists.

## Files in this repo used by this episode

| File | What it contains |
|---|---|
| `data/ep03/Product2.json` | The Volt Van product record (name, code VV-100, Commercial, Active). |
| `scripts/load-ep03.sh` | Creates the Volt Van (from the file above), its One Time option, the 48,000 price entry, Velora Catalog, the Vehicles category and the assignment. It checks first and creates only what is missing, so running it twice is safe. |

Command (a fresh org, instead of steps 2 to 7):

```sh
sh scripts/load-ep03.sh
TARGET_ORG=my_alias sh scripts/load-ep03.sh
```

- `sh scripts/load-ep03.sh`: runs the script with your project's default org.
- `TARGET_ORG=my_alias`: sets the org alias for this one run (the script passes it on as `--target-org`).
- Inside, `sf data import tree --files data/ep03/Product2.json` loads the product (`--files` names the file) and
  `sf data create record --sobject ... --values ...` creates each other record.

After the script, rebuild the product index and sync pricing data (episode 4 explains both).

## What you should see

- Volt Van (VV-100), Commercial, Active, with One Time as its default option.
- A standard price book entry of 48,000 for the Volt Van.
- Velora Catalog with the category Vehicles holding the Volt Van.

## Records and values

Volt Van, code VV-100, one-time, list price 48,000. Options later: Battery Standard 60 kWh or Long Range 90 kWh;
Body Panel or Refrigerated. Catalog Velora Catalog, code VELORA.
