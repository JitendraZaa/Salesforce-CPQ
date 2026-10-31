# Episode 4: From enquiry to the first quote

## What this episode builds

A web enquiry from Swift Couriers becomes a lead, is converted to an account, a contact and an opportunity, and then a
pilot quote with one Volt Van line at 48,000. On the way you build the product index and run the pricing sync a second
time, because without them the catalog is empty and the price is 0.

## Before you start

- Starting point: end of episode 3 (tag `ep03-end`): Volt Van with One Time and a 48,000 entry, Velora Catalog with Vehicles.
- Fresh org: `sh scripts/reset-to.sh ep03-end`. Tag at the end: `ep04-end`.

## Click path

1. Load the lead (command below). It stands in for the web form: Marcus Hale, Head of Fleet, company Swift Couriers.
2. Open the Leads list, open Marcus Hale and choose Convert. Keep account Swift Couriers and contact Marcus Hale;
   rename the opportunity `Swift Couriers - Pilot`. Convert.
3. On the opportunity open the Quotes related list, New Quote. Name `Swift Couriers Pilot Quote`, expiration date
   11/30/2026. Save.
4. On the quote choose Browse Catalogs. You may see "No products to show". Why: the product index has not been built yet.
5. App Launcher, Product Catalog Management, Index and Search Configuration, Rebuild Index, Full Index Rebuild. It
   takes about ten minutes the first time. After any new product or category assignment, rebuild again (partial is enough).
6. Setup, Quick Find "Salesforce Pricing Setup", Sync Pricing Data, Sync, Confirm. Why: the sync in episode 2 ran before
   the price existed.
7. On the quote choose Browse Catalogs, choose the Standard Price Book, then Velora Catalog, Next. Open Vehicles, find
   the Volt Van, add it, then add the items to the quote.
8. Open the quote's Lines tab. You should see Volt Van, quantity 1, unit price 48,000, total 48,000. If the price is
   0, sync again and check the opportunity uses the standard price book.
9. Look at Created By on the quote and the opportunity.

## Files in this repo used by this episode

| File | What it contains |
|---|---|
| `data/ep04/Lead.json` | One Lead: Marcus Hale, Head of Fleet, company Swift Couriers, source Web, description "Electric vans for urban deliveries, pilot first." |

```sh
sf data import tree --files data/ep04/Lead.json
sf org open --path lightning/o/Lead/list
```

- `sf data import tree`: loads records from a JSON file. `--files` names the file.
- `sf org open --path lightning/o/Lead/list`: opens the Leads list in the browser. The address holds a one-time login link; do not show it.

The accounts and contacts of the whole series are also in `data/seed/02-Account.json` and `03-Contact.json` (loaded by `sh scripts/seed-all.sh <alias>`). The conversion, the quote, the index rebuild and the sync are done by hand.

## What you should see

- A converted lead, the account Swift Couriers, the contact Marcus Hale and the opportunity Swift Couriers - Pilot.
- The pilot quote with one Volt Van line at 48,000. Has Depot is not ticked in this episode; episode 10 ticks it.

## Records and values

Swift Couriers: business customer, urban parcel delivery, two depots (North Depot, Harbour Depot). Contact Marcus Hale,
Head of Fleet. Quote `Swift Couriers Pilot Quote`. Volt Van 48,000.
