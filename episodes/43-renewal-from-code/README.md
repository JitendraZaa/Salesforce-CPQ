# Episode 43: A renewal from code

Status: planned, not recorded yet; steps below may change when the episode is recorded.

## What this episode builds

One renew request sent from the terminal for Swift Couriers' Connect and Connect Plus assets. The response is saved and read, and the renewal quote it made is found in the org: 1 February 2030 to 31 January 2031, with Connect at 30.77 and Connect Plus at 41.38, the same as the renewal quote built by hand in episode 35.

## Before you start

Starting point: source on `main` as episode 42 left it (tag `ep42-end`). The org data should be at the state just before the renewal of episode 35: no renewal quote exists for Swift. A checkpoint command for this (`scripts/reset-to.sh ep34-end`) is planned; `scripts/reset-ep34.sh` already deletes the renewal quote(s) after listing them and asking, then re-runs `scripts/seed-ep35.sh`. The calling user needs the InitiateRenewal API permission set (`RevLifecycleManagementInitiateRenewalApi`).

## Planned steps

1. List the assets:

```sh
sf data query --target-org demo_cpq --query "SELECT Id, Name, Quantity, Status, Product2.ProductCode FROM Asset WHERE Account.Name = 'Swift Couriers' AND Product2.ProductCode IN ('VC-SUB','VC-PLUS')"
```

- `--target-org` is the org alias; `--query` lists Swift's active Connect and Connect Plus assets.

2. Open `scripts/api/renew-swift.sh` and read it: it queries the asset ids and the contract id, builds a JSON body (`assetIds`, `contractId`, `outputRecordType` Quote, `renewalStartDate`, `renewalEndDate`), refuses to run if a renewal quote already exists, and calls the Asset Renewal resource. The sample body is `scripts/api/renew-swift.sample.json`.
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
- Change the dates with `START=... END=... sh scripts/api/renew-swift.sh demo_cpq`.

4. Read the saved response (`scripts/api/renew-swift.response.json`, generated) and find the record id it returns.
5. Open the renewal quote in the org and compare it with the one made by the Renew button in episode 35. Created By is the user who sent the call.
6. Run the script again: it prints that a renewal quote already exists and exits with status 2 without sending a second request.
7. Restore the org with `sh scripts/reset-ep34.sh demo_cpq`.

## Files in this repo used by this episode

- `scripts/api/renew-swift.sh`, `scripts/api/renew-swift.sample.json`
- `scripts/reset-ep34.sh`, `scripts/seed-ep35.sh`, `scripts/lib/common.sh`
- Planned and not in the repository yet: the `ep34-end` and `ep42-end` checkpoints in `scripts/reset-to.sh`.

## What you should see (planned)

A saved response, a renewal quote for Swift for 1 Feb 2030 to 31 Jan 2031 with 330 Connect at 30.77 and 20 Connect Plus at 41.38, and the second run stopping at the guard.

## Try it yourself

Send the same request with the record type Order if the org accepts it, compare the result with the quote, then restore the checkpoint.

All names and numbers are invented examples. Prices are in US dollars.
