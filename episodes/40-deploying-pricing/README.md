# Episode 40: Deploying a pricing change

All names, people, companies and numbers in this project are invented examples. Prices are in US dollars.

## What this episode builds

A new version of the Velora Pricing procedure is made in the working org (`demo_cpq`), retrieved as a file with a manifest, shown as a diff, validated with a dry run and deployed to a second org (`velora_qa`) with a script, and checked by pricing 100 Volt Vans there: list 48,000, net 44,640, volume discount 7 percent.

## Before you start

- Starting point: the source on `main` as episode 39 left it. `demo_cpq` holds the pricing procedure, tiers and prices.
- A second org with Revenue Management, signed in with the alias `velora_qa`. Its products, prices and volume tiers are loaded with `sh scripts/seed-second-org.sh velora_qa`, then rebuild the product index and run Sync Pricing Data in that org. The Velora_Fields permission set is assigned to its user.
- `sf org login web --alias velora_qa --instance-url <its My Domain URL>` signs in (browser sign-in; nothing secret is stored in the repository).

## Click path

1. In `demo_cpq`, Pricing Procedures, open Velora Pricing and its builder. Leave the first version alone. Why: the active version may be pricing quotes right now.
2. Save As, New Pricing Procedure Version. Name it Velora Pricing V2, version number 2, Save.
3. In the properties set Rank to 2, Save again, then Activate. The procedure page lists V1 (rank 1) and Velora Pricing V2 (rank 2), both active.
4. In VS Code open `manifest/ep40-pricing.xml`: `members` Velora_Pricing, `name` ExpressionSetDefinition, `version` 68.0.
5. Retrieve it: `sf project retrieve start --manifest manifest/ep40-pricing.xml --target-org demo_cpq`. The table shows one component, Velora_Pricing, in `force-app`.
6. See the change: `git diff --stat` shows the expression set file with 4,751 lines added and none removed. Open `force-app/main/default/expressionSetDefinition/Velora_Pricing.expressionSetDefinition-meta.xml` at line 4,483, where the V2 `versions` block begins (label Velora Pricing V2, rank 2).
7. Deploy the base metadata to `velora_qa`: `sf project deploy start --manifest manifest/ep40-base.xml --target-org velora_qa`. It names the Has Depot field on Account and the Velora Fields permission set; on an org that already holds them the result is 2 of 2 components, unchanged.
8. Open `scripts/deploy-pricing.sh` and read it (see the next section). Why a script and not a plain deploy: the procedure stores the Ids of the price adjustment schedules as fixed values, record Ids differ in every org, so the script swaps them by schedule name; it also switches off the target's active versions of Velora Pricing first (the deployed file switches them on again).
9. Validate with a dry run: `sh scripts/deploy-pricing.sh velora_qa --dry-run`. The script prints a line per step, then the org checks the file: Succeeded, one component, Velora_Pricing, "Dry-run complete".
10. Deploy for real: `sh scripts/deploy-pricing.sh velora_qa`. Succeeded, one component changed. After it velora_qa holds V1 and V2, both active.
11. Check the price: `sh scripts/api/price-100-vans.sh velora_qa`. It prints list price 48,000, net unit price 44,640, total 4,464,000 and the step that changed the price, the 7 percent volume discount. Same as the first org: the price is the proof.

## Background on slides (not steps)

- Metadata is setup stored as files you can deploy; data is records. The pricing procedure is metadata (an expression set definition, with versions); products, prices and volume tiers are data, so both must reach the second org.
- Dependencies of an expression set (context definitions, decision tables) must arrive first or together. CRUD and FLS are granted by permission sets: a field that exists is not a field a user can see.
- The seed of the second org (data and the permission set assignment) is a one-line statement in the episode.

## Files in this repo used by this episode

- `manifest/ep40-pricing.xml`: the pricing procedure to retrieve.
  - `sf project retrieve start`: copy metadata from an org into the project.
  - `--manifest`: the package file that lists what to fetch.
  - `--target-org`: the org to read from.
- `manifest/ep40-base.xml`: the base metadata (`Account.Has_Depot__c`, `Velora_Fields`) deployed first; `sf project deploy start --manifest ... --target-org velora_qa` sends it.
- `manifest/ep40-deps.xml`: the context definitions and decision tables a procedure can depend on.
- `scripts/deploy-pricing.sh`: swaps each price adjustment schedule Id (found by schedule name) for the target org's Id in a temporary copy, so the project file stays unchanged; switches off the target's active versions of Velora Pricing; then deploys `force-app` with `--ignore-conflicts` (the project's file is the version to keep). Usage: `sh scripts/deploy-pricing.sh <target org alias> [--dry-run]`.
- `scripts/api/price-100-vans.sh` and `scripts/ep15-pricing-body.json`: the Pricing API request of episode 15, with ids looked up by name in the target org. Usage: `sh scripts/api/price-100-vans.sh <org alias>`.
- `scripts/seed-second-org.sh`: loads the data of episodes 3 to 13 into the second org.
- `force-app/main/default/expressionSetDefinition/Velora_Pricing.expressionSetDefinition-meta.xml`: the retrieved procedure.

## What you should see

A diff showing only the new version, a dry run and a deploy that succeed, and in `velora_qa` a Volt Van net unit price of 44,640 for 100 vans (48,000 less the 7 percent volume tier).

## Try it yourself

Open the manifest and read what it lists, validate the deployment with a dry run, deploy it, and check the procedure in the target org.
