# Episode 42: An Apex action for quotes

Status: planned, not recorded yet; steps below may change when the episode is recorded.

## What this episode builds

A button on the opportunity starts a screen flow that calls an Apex action. The action sends Place Sales Transaction one quote and one quote line for a Velora Connect plan, records the request, and is safe to click twice: the second click returns the same quote and still one line.

## Before you start

Starting point: source on `main` as episode 41 left it (tag `ep41-end`). `demo_cpq` holds the Connect product, its price book entry and Swift Couriers' opportunities, with the index rebuilt and prices synced. Check:

```sh
sf data query --target-org demo_cpq --query "SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2.ProductCode = 'VC-SUB' AND IsActive = true"
```

- `--target-org` is the org alias; `--query` is the SOQL that finds the active Connect price.

## Planned steps

1. Open the custom object `Quote_Request__c` and its fields in `force-app/main/default/objects/Quote_Request__c/`. `Request_Key__c` is unique, so two clicks at once cannot create two requests; `Status__c` goes from Received to Completed.
2. Read the classes in `force-app/main/default/classes/`: `QuotePlacer` (interface), `PstQuotePlacer` (sends the request), `QuoteRequestService` (idempotency and retry), `ConnectQuoteAction` (the invocable action) and `ConnectQuoteActionTest` (a mock placer writes real quote lines).
3. Deploy and test:

```sh
sf project deploy start --source-dir force-app --target-org demo_cpq --test-level RunSpecifiedTests --tests ConnectQuoteActionTest --wait 30
```

- `--source-dir force-app` deploys the whole project; `--test-level RunSpecifiedTests` with `--tests` runs only the named test; `--wait 30` waits up to thirty minutes.

4. Optional: run the action once from code with `sf apex run --file scripts/anonymous/place-one-quote.apex --target-org demo_cpq`. This creates a real quote.
5. Open the flow `Create_Connect_Quote` and the quick action on the Opportunity. Assign the permission set `Velora_Quote_Action` to the user who will click the button (`sf org assign permset --name Velora_Quote_Action --target-org demo_cpq`).
6. On the opportunity Swift Couriers - Pilot click the button. The result screen links one quote with one Velora Connect line, quantity 1, unit price 29. The request record shows Status Completed and Attempts 1.
7. Click again: the same quote id, Attempts still 1.

## Files in this repo used by this episode

- `force-app/main/default/objects/Quote_Request__c/`
- `force-app/main/default/classes/QuotePlacer.cls`, `PstQuotePlacer.cls`, `QuoteRequestService.cls`, `QuoteInput.cls`, `QuoteOutcome.cls`, `ConnectQuoteAction.cls`, `ConnectQuoteActionTest.cls`
- `force-app/main/default/flows/Create_Connect_Quote.flow-meta.xml`
- `force-app/main/default/quickActions/Opportunity.Create_Connect_Quote.quickAction-meta.xml`
- `force-app/main/default/permissionsets/Velora_Quote_Action.permissionset-meta.xml`
- `scripts/anonymous/place-one-quote.apex`

## What you should see (planned)

One quote with one Connect line at 29 after the first click, the same quote after the second, and the test class passing in the CI run of episode 41.

## Try it yourself

Make the mock fail twice before it succeeds. After each click read Status, Attempts and the error message on the request.

All names and numbers are invented examples. Prices are in US dollars.
