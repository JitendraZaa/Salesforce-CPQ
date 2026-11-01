# Episode 43: A renewal from code

All names, people, companies and numbers in this project are invented examples. Prices are in US dollars.

## What this episode builds

One renew request sent from the terminal for Swift Couriers' Connect Plus asset (20 seats on contract 00000104, made by the swap of episode 34). You set the asset's renewal term, send the request with `scripts/api/renew-swift.sh`, read the response, find the renewal quote it made (Renewal Quote 00000043, 20 Connect Plus at 40.17, 1 Feb 2029 to 31 Jan 2030, total 9,640.80), and run the script again to see its guard stop a second request.

## Before you start

- Starting point: the source on `main` as episode 42 left it. The org is not reset for this episode: it runs forward from where episode 36 left it. The Connect renewals are episode 35's quote; this is the asset still waiting.
- The calling user needs the InitiateRenewal API permission set (`RevLifecycleManagementInitiateRenewalApi`).
- `scripts/reset-ep34.sh` deletes renewal quotes after listing them and asking; do not run it for this episode.

## Click path

1. In VS Code open `queries/ep43-assets.soql` and run `sf data query -o <org alias> --file queries/ep43-assets.soql`. Eight assets come back: seven Velora Connect (VC-SUB) and one Velora Connect Plus (VC-PLUS), the one you renew.
2. The renewal needs to know how long the new term lasts, and the asset has no renewal term yet. Set it: `sf data update record -o <org alias> --sobject Asset --record-id <the Connect Plus asset Id> --values "RenewalTerm=12 RenewalTermUnit=Months"`. The terminal says it updated the record.
3. Open `scripts/api/renew-swift.sh` and read it from the top. It picks contract 00000104 (which holds the asset since the swap) and looks up its Id by query, queries Swift's assets for the product, and builds the body with a short block of Python: `assetIds`, `contractId`, `outputRecordType` Quote (a quote, not an order), `renewalStartDate` and `renewalEndDate` (defaults 1 Feb 2029 and 31 Jan 2030, an example one-year term you can change).
4. Read the guard: before sending, the script looks for a quote whose name contains Renewal that already holds a line for the product, and stops if a response file is already saved. Why: the same renewal is never started twice from this script.
5. Read the call: `sf api request rest "/services/data/v68.0/connect/revenue-management/assets/actions/renew" --method POST --body ...` and the output saved to `scripts/api/renew-swift.response.json`. No token appears anywhere: the CLI uses the login of the org you already authorised.
6. Run it: `sh scripts/api/renew-swift.sh <org alias>`. It prints Renewing and the asset Id, then the response: an empty errors list, `renewalRecordId` (the Id of the record made), a request id, a status URL that is null and `success` true.
7. Open `queries/ep43-renewal-quote.soql`, put the `renewalRecordId` in its `QuoteId` filter, and run `sf data query --target-org <org alias> --file queries/ep43-renewal-quote.soql`. One line: Renewal Quote 00000043, Velora Connect Plus, quantity 20, net unit price 40.17, 1 Feb 2029 to 31 Jan 2030, total 9,640.80. The list price is 39 with the asset's 3 percent uplift kept, and 20 x 40.17 x 12 = 9,640.80. The quote is a record a person can still review: the code starts the renewal, it does not decide the price.
8. Run the same command again, `sh scripts/api/renew-swift.sh <org alias>`. It prints that a renewal quote already exists, with its Id, and that it is not sending a second request (exit status 2).

## Background on slides (not steps)

- An asset is what a customer owns after an order is activated. Revenue Management has asset lifecycle APIs (amend, cancel, renew, upgrade, downgrade, swap) that offer the same actions as the buttons on the Managed Assets list; this episode uses renew.
- A renew request is JSON with the asset Ids and the output record type; the start date is required when the renewal starts early or the asset has already expired; the end date and contract are optional. The caller needs the same permission as the button, so an interface is never a side door around the rules the screen enforces.
- Read a response before building on it; the same habits work for the other calls in the list.

## Files in this repo used by this episode

- `queries/ep43-assets.soql`: Id, product code, lifecycle start date, end date and current quantity of Swift's VC-SUB and VC-PLUS assets.
  - `sf data query`: run a read-only SOQL query; `-o` or `--target-org` is the org; `--file` reads the query from a file.
- `queries/ep43-renewal-quote.soql`: the renewal quote's number, name, product, quantity, net unit price, dates and total price (change the `QuoteId` to yours).
- `scripts/api/renew-swift.sh`: the script described above. Change the contract or products with `CONTRACT_NUMBER=... PRODUCT_CODES="'VC-SUB','VC-PLUS'"`, the dates with `START=... END=...`. Usage: `sh scripts/api/renew-swift.sh [org alias]`.
- `scripts/api/renew-swift.sample.json`: a sample of the body the script builds.
- `scripts/api/renew-swift.json` and `scripts/api/renew-swift.response.json`: generated by the script (the body and the saved response).
- `scripts/lib/common.sh`: the shared helpers the script sources.

## What you should see

A saved response with `success` true and a `renewalRecordId`, Renewal Quote 00000043 with 20 Velora Connect Plus at 40.17 (9,640.80), and the second run stopping at the guard.

## Try it yourself

Open the script, read the guard's query and say in your own words what it stops. Then run it against your org with your own contract and asset, and find the renewal quote it created.
