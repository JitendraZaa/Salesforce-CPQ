# Episode 12: Pricing procedures

## What this episode builds

Velora's own active pricing procedure, Velora Pricing, cloned from the default one and set as the default. Its price waterfall is on, so the pilot quote's Volt Van price can be opened as a step-by-step breakdown.

## Before you start

Starting point: tag `ep11-end`. The configurator flow is cloned, the pilot quote for Swift Couriers carries the Volt Van Fleet Package, Salesforce Pricing is on and synced, and the default pricing procedure exists. Your user needs the Salesforce Pricing Design Time User and Run Time User permission sets.

To bring a fresh org to this starting point, run `sh scripts/reset-to.sh ep11-end --org <your org alias>`. The script loads the data and lists the steps that must be done by hand. A git tag restores files only, never the org, so do not rely on `git checkout` to rebuild the org.

## Click path

1. Open the App Launcher, search Pricing Procedures and open the org's default procedure. Look at its Details tab and its versions. Why: this is the recipe Velora starts from.
2. On the default version click Simulate. Choose the simplified input mode and the Sales Transaction context definition, tick Auto-fill line items, paste the pilot quote's ID from the browser address and click Simulate. The Volt Van shows 48,000. Why: this proves the procedure and the pricing sync work before anything depends on them.
3. Clone the default procedure. Name it Velora Pricing and press Tab so the API name fills in. Usage type Pricing; choose the context definition for sales transactions. Save.
4. On Velora Pricing open its version in the Pricing Procedure Builder. Find the Pricing Setting and the List Price elements; List Price reads the Price Book Entries decision table.
5. On List Price tick Include in Output and set the rank to 1. Save. Why: when more than one version matches, the highest rank is used.
6. Click Simulate again, then Activate. Why: only an active version runs on a quote.
7. In Setup open Salesforce Pricing Setup, turn on Price Waterfall for API responses, and make Velora Pricing the default procedure.
8. Open the pilot quote, go to the Lines tab, and click the Volt Van's net unit price. The calculation opens as a waterfall: list 48,000, net 48,000.
9. In Lightning App Builder open the Quote Record Page and read which line component the Lines tab uses (the Sales Transaction Line Editor, STLE, or the older Transaction Line Editor, TLE).
10. On the quote line read Unit Price, Net Unit Price, Subtotal, Total Price and Net Total Price. If a price shows 0 or looks old, run Sync Pricing Data.

## Files in this repo used by this episode

- `force-app/main/default/expressionSetDefinition/Velora_Pricing.expressionSetDefinition-meta.xml`: the Velora Pricing procedure as the org stores it (a pricing procedure is an expression set definition). Deploy once with `sf project deploy start --source-dir force-app/main/default/expressionSetDefinition --target-org <alias>`. A second deploy of the same file fails while the version is active; deactivate it first.
- `force-app/main/default/settings/IndustriesPricing.settings-meta.xml`: the Salesforce Pricing switches (for example the waterfall setting). `sh scripts/setup-org.sh <alias>` deploys it with the other settings first. Flags of that deploy: `--source-dir` the folder to send, `--target-org` the org, `--ignore-conflicts` send even if the org's copy changed.
- `force-app/main/default/contextDefinitions/`: `RevSalesTransactionContext`, the data shape the procedure reads from a quote. It is deployed with the rest of `force-app`.
- Retrieve after any change: `sf project retrieve start --metadata ExpressionSetDefinition:Velora_Pricing --target-org <alias>` (`--metadata` is type and name; `--target-org` the org to read).

## What you should see

Velora Pricing is Active and is the default. The pilot quote's Volt Van line opens a price waterfall with list price 48,000 and net price 48,000, with every step named.

## Records and values

All names and numbers are invented examples. Prices are in US dollars.

- Procedure: Velora Pricing, elements Pricing Setting and List Price (rank 1, in output).
- Volt Van VV-100 list price 48,000, one-time.
- Pilot: 1 Volt Van plus Velora Connect, 29 per vehicle per month for 12 months.
