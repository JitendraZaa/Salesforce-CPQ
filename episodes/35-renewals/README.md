# Episode 35: Renewals

## What this episode builds

Swift Couriers' third-year Connect subscription (200 vehicles, ending 31 January 2030) is renewed for another 12 months with the Renew action: renewal quote, accepted, order, activated. The renewal keeps the Year 3 price.

## Before you start

Starting point: the end of episode 34. The Year 3 Velora Connect asset (200 vehicles, 2/1/2029 to 1/31/2030, price 30.77) exists on contract 00000104. The asset needs a renewal term of 12 Months (on the asset or the contract), otherwise Renew has nothing to go on. `data/ep35/contract-renewal-terms.json` records the contract values (RenewalTerm2 12, RenewalTermUnit Months).

To bring a fresh org as far as it can go by loading data, run `sh scripts/reset-to.sh ep28-end <your org alias>`; the earlier quotes, order and assets are built on screen. A git tag restores files only, never the org. (This repository has no `ep34-end` tag yet.)

You need the permission sets InitiateRenewal API and the Sales Rep persona permissions. `sh scripts/seed-ep35.sh` assigns the InitiateRenewal API set.

## Click path

1. Open Swift Couriers, Assets, Managed Assets and tick the Year 3 Velora Connect asset (200, ending 1/31/2030).
2. Click Renew. In Set Renewal Term choose Automatic Renewal (it renews from the end of the current term, for the renewal term on the asset or contract, 12 Months) and click Submit.
3. Renewal Quote 00000041 opens: Velora Connect 200, 2/1/2030 to 1/31/2031, at 30.77 (the Year 3 price is kept, with the 6.09 percent uplift carried), total 73,838.64.
4. Set the quote Status to Accepted. Click Create Order, choose Create Single Order, fill in Contract 00000104, Bill To Marcus Hale, Legal Entity Velora Motors Inc. and the addresses, Save. Order 00000129 is created.
5. Open the order and click Activate. The Connect asset shows a renewal period from 2/1/2030 to 1/31/2031.

## Files in this repo used by this episode

- `scripts/seed-ep35.sh`: prepares the org for the renewal. Run `sh scripts/seed-ep35.sh` (default org, or `TARGET_ORG=<alias>`). It runs `sf org assign permset --name RevLifecycleManagementInitiateRenewalApi` (`--name` is the permission set's API name; it is assigned to the logged-in user), counts Swift's Connect assets with `sf data query --query "SELECT COUNT(Id) ... FROM Asset ..." --json`, stops with a message if there are none, and then runs `sf data update record --sobject Contract --record-id <id> --values "RenewalTerm2=12 RenewalTermUnit=Months"` (`--sobject` the object, `--record-id` the contract found by query, `--values` the fields to change).
- `data/ep35/contract-renewal-terms.json`: the two renewal-term values the script writes.
- `scripts/api/renew-swift.sh` and `scripts/api/renew-swift.sample.json`: the same renewal from code, used in episode 43.

## What you should see

Renewal Quote 00000041 with Connect 200 for 2/1/2030 to 1/31/2031 at 30.77, 73,838.64 (200 x 30.7661 x 12); order 00000129 Activated.

## Records and values

All names and numbers are invented examples. Prices are in US dollars.

- Year 3 price 30.7661, shown as 30.77 (29 x 1.0609, the 6.09 percent running uplift).
- Renewal term 12 months, automatic renewal.

## Try it yourself

Tick the Automatic Renewal option on a Connect asset instead of renewing by hand, then open Setup, Flows and look at the template that renews expiring assets: the variable NumberOfDaysInTheFuture sets how many days before expiry it acts.
