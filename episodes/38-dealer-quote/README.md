# Episode 38: A dealer's quote

Status: planned, not recorded yet; steps below may change when the episode is recorded.

## What this episode builds

A dealer, Sam Okafor of Brightside Motors, signs in to the Velora Dealers site and quotes three refrigerated Long Range Volt Vans for a customer, Crumb & Co Bakery. The line carries a partner discount of 8 percent; a discount above 10 percent is refused; Sam downloads the quote as a PDF.

## Before you start

Starting point: tag `ep37-end`. The Velora Dealers site exists, Brightside Motors is a partner account and Sam is its partner user. The permission set `Velora_Dealer_Configurator` is in `force-app/main/default/permissionsets/`. The product index must be rebuilt and Sync Pricing Data run (Salesforce Pricing Setup), otherwise the site's catalog is empty and lines price at 0.

## Planned steps

1. In Setup > Sharing Settings check the external access level of the product catalog objects; where it is Private, add sharing rules so Sam can read them.
2. Give the partner permission set read access to the objects and fields the configurator needs.
3. Load Crumb & Co Bakery and its contact (the data plan `data/ep38-bakery/` is planned):

```sh
sf data import tree --plan data/ep38-bakery/plan.json --target-org demo_cpq
```

- `sf data import tree` creates records from a JSON plan.
- `--plan` names the plan file that lists the record files and their order.
- `--target-org demo_cpq` is the org alias.

4. Open Velora Dealers as Sam (from the contact, Log in to Experience as User). Check that Product List, Product Details and the catalog quick action are on the pages.
5. Choose the Volt Van > Configure > Body Refrigerated; the configuration rule from episode 9 selects Long Range.
6. Set quantity 3 and create the quote for Crumb & Co Bakery.
7. In the line editor enter a partner discount of 8 percent. The refrigerated Long Range van lists at 58,700, so the expected partner unit price is 54,004 and the line total 162,012.
8. A validation rule `Partner_Discount_Within_Limit` on the quote line (planned) refuses a partner discount above 10 percent with the message "The partner discount is above Velora's limit."
9. Generate the quote PDF from the quote and download it.
10. In the org check Created By and Last Modified By on the quote: Sam Okafor.

## Files in this repo used by this episode

- `force-app/main/default/permissionsets/Velora_Dealer_Configurator.permissionset-meta.xml`: the permission set for dealer users. Deploy with `sf project deploy start --source-dir force-app/main/default/permissionsets --target-org <alias>`.
- `data/ep37-dealers/Account.json`: the dealer account from episode 37.
- Planned and not in the repository yet: `data/ep38-bakery/`, the sharing rules, and the validation rule.

## What you should see (planned)

A quote for Crumb & Co Bakery with three refrigerated Long Range vans, partner discount 8 percent, Created By Sam Okafor, a refused 12 percent entry, and a downloaded PDF.

## Try it yourself

Change the quantity to 30 and record how the volume tier meets the partner discount in the line editor.

All names and numbers are invented examples. Prices are in US dollars.
