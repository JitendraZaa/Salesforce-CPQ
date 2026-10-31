# Episode 15: Pricing from code

## What this episode builds

A price request sent from a terminal instead of a quote. The call asks Velora Pricing for 100 Standard Panel Volt Vans and gets back a net unit price of 44,640 each with its waterfall, the same final price as the quote line.

## Before you start

Starting point: tag `ep14-end`. Velora Pricing is active and the waterfall is on for API responses. You need the Salesforce CLI logged in to the org (an alias), and a user with the pricing and API permission sets.

To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep14-end --org <your org alias>`. The script loads the data and lists the steps that must be done by hand. A git tag restores files only, never the org, so do not rely on `git checkout` to rebuild the org.

## Click path

1. Open a terminal in the project folder.
2. Look up the Volt Van's product ID and its price book entry with a query (see the files section). Why: the request needs real record IDs.
3. Find the context definition `RevSalesTransactionContext` and its mapping `QuoteEntitiesMapping`. Why: the request tells the API which fields mean what; on a quote the node SalesTransaction maps to Quote and SalesTransactionItem maps to QuoteLineItem.
4. Read the request body file. It holds the context IDs, the pricing procedure name, and the data as one JSON string.
5. Run the price script. It looks up all IDs by name, fills them into a temporary copy of the body, sends a POST request, and prints list, net unit and net total prices plus the steps that changed the price.
6. Open the fleet quote's Lines tab and click the net unit price of a Standard Panel van at quantity 100. Compare final price with final price: 44,640 in both.
7. Optional: send a request with a wrong ID to see how errors come back in the response.

## Files in this repo used by this episode

- `scripts/ep15-pricing-body.json`: the request body. Top level: `contextDefinitionId`, `contextMappingId`, `pricingProcedureId` (`Velora_Pricing`) and `jsonDataString` (the quote and line data). The IDs are placeholders; the script fills them in.
- `scripts/ep15-price.sh`: the short entry point. Run `PRICING_ORG=<alias> sh scripts/ep15-price.sh`. `PRICING_ORG` is an environment variable naming the org; if it is unset the project's default org is used. It runs `scripts/api/price-100-vans.sh`.
- `scripts/api/price-100-vans.sh`: looks up the context definition, mapping, standard price book, Volt Van, One Time selling model and price book entry, builds the body, and sends it with `sf api request rest "/services/data/v68.0/connect/core-pricing/pricing" --method POST --body @<file>`. Flags: `--method POST` sends data (a read would be GET), `--body @file` reads the body from a file, `--target-org` (set by the optional alias argument) picks the org. Run `sh scripts/api/price-100-vans.sh [--save] [alias]`; `--save` also writes the filled request to `out/pricing-body.json` and the full response to `out/pricing-response.json`.
- Lookup commands: `sf data query --query "SELECT Id, Name, ProductCode FROM Product2 WHERE ProductCode = 'VV-100'" --target-org <alias>` (`--query` is the SOQL text) and the same for `PricebookEntry` with `Pricebook2.IsStandard = true`.

## What you should see

The terminal prints List Price 48,000, Net Unit Price 44,640 and Net Total Price 4,464,000, then lists the volume step (7 percent) as the step that changed the price. The quote line shows the same final net unit price.

## Records and values

All names and numbers are invented examples. Prices are in US dollars.

- Request: 100 Volt Vans (VV-100), One Time, standard price book, procedure Velora_Pricing.
- Result: list 48,000; 7 percent volume tier; net unit price 44,640; net total 4,464,000. No promotion applies to the base van.
- Other tiers can be tried by changing `Quantity` in a copy of the body (25 gives 46,080).
