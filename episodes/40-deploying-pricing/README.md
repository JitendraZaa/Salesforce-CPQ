# Episode 40: Deploying a pricing change

Status: files ready, not recorded yet; steps below may change when the episode is recorded.

## What this episode builds

A change to the pricing procedure is retrieved from the working org, shown as a diff, validated, deployed with its dependencies to a second org (`velora_qa`), and checked by pricing 100 Volt Vans there: 44,640 each.

## Before you start

Starting point: the source on `main` as episode 39 left it (tag `ep39-end`); the developer episodes continue the source, they do not check out older tags. `demo_cpq` already holds the pricing procedure, tiers and prices. You need a second org with Revenue Management, signed in once (a scratch org made from `config/revenue-cloud-scratch-def.json` with `sf org create scratch --definition-file config/revenue-cloud-scratch-def.json --alias velora_qa --target-dev-hub <your dev hub> --duration-days 7` is already signed in, and then this step is not needed):

```sh
sf org login web --alias velora_qa --instance-url <its My Domain URL>
```

- `sf org login web` opens a browser to sign in.
- `--alias velora_qa` is the short name the other commands use.
- `--instance-url` is the second org's My Domain address. No password or token is stored in the repository.

## Planned steps

1. In `demo_cpq` open the pricing procedure, create a new version with a unique rank, Simulate and Activate. The existing active versions are not edited.
2. Find the procedure's API name:

```sh
sf data query --target-org demo_cpq --query "SELECT DeveloperName, MasterLabel FROM ExpressionSetDefinition"
```

3. Retrieve it with the manifest:

```sh
sf project retrieve start --manifest manifest/ep40-pricing.xml --target-org demo_cpq
```

- `retrieve start` copies metadata from the org into `force-app`.
- `--manifest` names the package file that lists what to fetch (`manifest/ep40-pricing.xml` lists one `ExpressionSetDefinition`).
- `--target-org` is the org to read from. Then `git diff` shows the new version.

4. Deploy the base metadata the second org lacks (`Account.Has_Depot__c`, the `Velora_Fields` permission set) with the manifest `manifest/ep40-base.xml`:

```sh
sf project deploy start --manifest manifest/ep40-base.xml --target-org velora_qa
```

   On a fresh org this deploys two components. On an org that already carries them the result reads unchanged.
5. Validate without saving:

```sh
sf project deploy start --manifest manifest/ep40-pricing.xml --target-org velora_qa --dry-run
```

- `deploy start` sends metadata to an org.
- `--dry-run` checks the deploy and runs tests but saves nothing.
- If the check asks for dependencies, deploy `manifest/ep40-deps.xml` (context definitions and decision tables) first.

6. Run the same command without `--dry-run` to deploy.
7. Load the data, which metadata does not carry:

```sh
sh scripts/seed-second-org.sh velora_qa
```

   The script loads the Volt Van, the other products, Velora Connect and the volume tiers into the second org and assigns `Velora_Fields`. Then rebuild the product index and run Sync Pricing Data in `velora_qa`.
8. Price 100 vans in the second org:

```sh
sh scripts/api/price-100-vans.sh velora_qa
```

   The script looks up the context definition, mapping, price book and Volt Van by name, sends the Pricing API request of episode 15 and prints ListPrice, NetUnitPrice and NetTotalPrice.

## Files in this repo used by this episode

- `manifest/ep40-pricing.xml`: the pricing procedure to retrieve and deploy. It names the member `Velora_Pricing`, the expression set in `force-app/main/default/expressionSetDefinition/`; confirm the name with the query in step 2.
- `manifest/ep40-deps.xml`: context definitions and decision tables, deployed first when the validation asks.
- `scripts/seed-second-org.sh`: loads episodes 3 to 13 data into a second org.
- `scripts/api/price-100-vans.sh`, `scripts/ep15-pricing-body.json`: the price check.
- `manifest/ep40-base.xml`: the base metadata (`Account.Has_Depot__c` and the `Velora_Fields` permission set) deployed before the procedure.

## What you should see (planned)

A diff showing only the new version, a validation that succeeds, and in `velora_qa` a Volt Van net unit price of 44,640 for 100 vans (48,000 less the 7 percent volume tier).

## Try it yourself

Change the top tier from 7 to 8 percent in the first org and note that the diff shows nothing: tiers are data, not metadata. Then load the data plan into the second org.

All names and numbers are invented examples. Prices are in US dollars.
