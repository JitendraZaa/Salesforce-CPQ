# Episode 43: A renewal from code

Status: files ready, not recorded yet; steps below may change when the episode is recorded.

## What this episode builds

One renew request sent from the terminal for Swift Couriers' Connect Plus asset (`02ig7000002BZxNAAW`, 20 seats on contract 00000104, made by the swap of episode 34). The response is saved and read, and the renewal quote it made is found in the org. The Connect assets are already renewed or are renewed by episode 35's quote, so this is the asset still waiting.

## Before you start

Starting point: source on `main` as episode 42 left it (tag `ep42-end`). The org is not reset for this episode: it runs forward from where episode 36 left it, and the renewal quote of episode 35 (Renewal Quote 00000041, 200 Connect) already exists. The Connect Plus asset has no renewal. The calling user needs the InitiateRenewal API permission set (`RevLifecycleManagementInitiateRenewalApi`). `scripts/reset-ep34.sh` deletes renewal quotes after listing them and asking; do not run it for this episode.

## Planned steps

1. List the assets (the query is in `queries/ep43-assets.soql`):

```sh
sf data query --target-org demo_cpq --file queries/ep43-assets.soql
```

- `--target-org` is the org alias; `--file` reads the query from a file.
- Seven Connect assets and the Connect Plus asset come back. `Status` and `Quantity` are empty on these assets and `CurrentQuantity` reads 0, because the quantities live in the asset state periods: `SELECT AssetId, StartDate, EndDate, Quantity FROM AssetStatePeriod WHERE Asset.Account.Name = 'Swift Couriers'`.

2. Open `scripts/api/renew-swift.sh` and read it: it takes the contract 00000104, picks the Connect Plus assets linked to that contract (`CONTRACT_NUMBER` and `PRODUCT_CODES` change this), builds a JSON body (`assetIds`, `contractId`, `outputRecordType` Quote, `renewalStartDate`, `renewalEndDate`), refuses to run if a renewal quote for those products already exists or a response is already saved, and calls the Asset Renewal resource. The renewal quote of an asset has no opportunity, so the guard looks at the quote lines, not at an opportunity. The sample body is `scripts/api/renew-swift.sample.json`.
3. Send it:

```sh
sh scripts/api/renew-swift.sh demo_cpq
```

   Inside the script the call is:

```sh
sf api request rest "/services/data/v68.0/connect/revenue-management/assets/actions/renew" --method POST --body scripts/api/renew-swift.json --target-org demo_cpq
```

- `sf api request rest` sends a REST request with the CLI's sign-in, so no token appears in the file.
- The path is the Asset Renewal resource of the Connect REST API.
- `--method POST` sends data; `--body` names the request file; `--target-org` is the org alias.
- Change the dates with `START=... END=... sh scripts/api/renew-swift.sh demo_cpq`. The defaults are 2030-02-01 to 2031-01-31; the Connect Plus asset runs to 2029-01-31, so if the org rejects the dates, use the day after the asset's end.

4. Read the saved response (`scripts/api/renew-swift.response.json`, generated) and find the record id it returns.
5. Query the quote and its lines: `SELECT Id, Name, Status, OpportunityId FROM Quote WHERE Id = '<id>'` and `SELECT Quantity, UnitPrice, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = '<id>'`. Expect 20 Connect Plus. Open the quote in the org; Created By is the user who sent the call. A renewal quote made this way has no opportunity.
6. Run the script again: it prints that a renewal quote already exists (or that a response is saved) and exits with status 2 without sending a second request.

## Files in this repo used by this episode

- `scripts/api/renew-swift.sh`, `scripts/api/renew-swift.sample.json`, `scripts/lib/common.sh`
- `queries/ep43-assets.soql`

## What you should see (planned)

A saved response, a renewal quote for the Connect Plus asset with 20 seats, and the second run stopping at the guard. The price (41.38) and the dates are confirmed only when the call is made.

## Try it yourself

Send the same request with the record type Order if the org accepts it, and compare the result with the quote. Both change the org, so do it only in a copy.

All names and numbers are invented examples. Prices are in US dollars.
