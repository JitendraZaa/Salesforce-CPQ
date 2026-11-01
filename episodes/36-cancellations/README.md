# Episode 36: Cancellations

## What this episode builds

One depot's charging is cancelled from a date: Swift Couriers' Harbour Depot Charging asset ends on 14 November 2026. You cancel the asset, accept the cancellation quote, create and activate the cancellation order, and read the asset's new end date.

## Before you start

Starting point: the end of episode 35. Swift Couriers has a Harbour Depot Charging asset from the depot charging order of episodes 27 and 28. You need the InitiateCancellation API permission set and the Sales Rep persona permissions.

To bring a fresh org as far as it can go by loading data, run `sh scripts/reset-to.sh ep28-end <your org alias>`; the orders and assets are built on screen. A git tag restores files only, never the org. (This repository has no `ep35-end` tag yet.)

## Click path

1. Open Swift Couriers, Assets, Managed Assets and tick the Harbour Depot Charging asset.
2. Click Cancel. In Set Cancellation Date choose Nov 15, 2026 and click Submit.
3. Cancellation Quote 00000040 opens with the depot charging line at a negative quantity. Why: a cancellation is the opposite of the sale.
4. Set the quote Status to Accepted. Click Create Order, choose Create Single Order, fill in Contract 00000104, Bill To Marcus Hale, Legal Entity Velora Motors Inc. and the addresses, Save. Order 00000128 is created.
5. Click Activate.
6. Open the Harbour Depot Charging asset and its Dashboard: the service ends on 11/14/2026.

## Files in this repo used by this episode

This episode uses the org's screens only. To read the result from the terminal: `sf data query --query "SELECT Name, Status, Quantity FROM Asset WHERE Account.Name = 'Swift Couriers' AND Name LIKE '%Charging%'" --target-org <alias>` (`--query` is the SOQL, `--target-org` the alias).

## What you should see

Cancellation Quote 00000040, order 00000128 Activated, and the Harbour Depot Charging asset's state period ending 11/14/2026. The other depot's charging is unchanged.

## Records and values

All names and numbers are invented examples.

- Cancellation date Nov 15, 2026; the last day of service is Nov 14, 2026.
- Early-termination fee, churn and the point of no return are explained on slides.

## Try it yourself

Make a future-dated amendment on a Connect asset and look for Rollback in the Managed Assets menu; it reverses the most recent future-dated amendment or renewal. Do it on a copy of the org.
