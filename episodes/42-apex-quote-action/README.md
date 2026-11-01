# Episode 42: An Apex action for quotes

Status: files ready, not recorded yet; steps below may change when the episode is recorded.

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
3. Deploy and test. Nothing from this episode is in `demo_cpq` yet, so one manifest carries all of it (the object and its tab, the seven classes, the flow, the quick action, the Opportunity layout that shows the button and the permission set):

```sh
sf project deploy start --manifest manifest/ep42-quote-action.xml --target-org demo_cpq --test-level RunSpecifiedTests --tests ConnectQuoteActionTest --wait 30
```

- `--manifest` names the package file that lists what to deploy; `--test-level RunSpecifiedTests` with `--tests` runs only the named test; `--wait 30` waits up to thirty minutes.
- Expected: five tests pass (`oneClick_oneQuote`, `secondClick_sameQuote`, `lineFailsAfterHeader_retryAddsLine`, `placer_buildsGraphForNewQuoteAndForLineOnly`, `placer_turnsAResponseIntoAnOutcome`).

4. Optional: run the action once from code with `sf apex run --file scripts/anonymous/place-one-quote.apex --target-org demo_cpq`. This creates a real quote. The file looks up the opportunity `Swift Couriers - Fleet` (record `006g700000N3eenAAB`, Standard Price Book): it is the Swift opportunity that has a price book, which the action needs to find the Connect price. `Swift Couriers - Pilot` and `Swift Couriers - Depot Charging` have no price book, and there is no opportunity named `Swift Couriers - Connect`.
5. Open the flow `Create_Connect_Quote` and the quick action on the Opportunity (the button sits in the Opportunity page layout's Salesforce Mobile and Lightning Experience Actions list, which the manifest deploys). Assign the permission set `Velora_Quote_Action` to the user who will click the button (`sf org assign permset --name Velora_Quote_Action --target-org demo_cpq`).
6. On the opportunity Swift Couriers - Fleet click the button (the Pilot opportunity has no price book, so the flow would find no price). The Fleet opportunity already has older quotes without a Connect line from this action; the new quote is the one the result screen links. The result screen links one quote with one Velora Connect line, quantity 1, unit price 29. The request record (App Launcher, Quote Requests) shows Status Completed and Attempts 1. To count the line on the new quote: `sf data query --target-org demo_cpq --query "SELECT COUNT() FROM QuoteLineItem WHERE QuoteId = '<new quote id>'"` returns 1.
7. Click again: the same quote id, Attempts still 1.

## Files in this repo used by this episode

- `manifest/ep42-quote-action.xml`: everything below in one deploy.
- `force-app/main/default/objects/Quote_Request__c/` and `force-app/main/default/tabs/Quote_Request__c.tab-meta.xml` (the tab lets you open the requests from the App Launcher)
- `force-app/main/default/classes/QuotePlacer.cls`, `PstQuotePlacer.cls`, `QuoteRequestService.cls`, `QuoteInput.cls`, `QuoteOutcome.cls`, `ConnectQuoteAction.cls`, `ConnectQuoteActionTest.cls`
- `force-app/main/default/flows/Create_Connect_Quote.flow-meta.xml`
- `force-app/main/default/quickActions/Opportunity.Create_Connect_Quote.quickAction-meta.xml`
- `force-app/main/default/layouts/Opportunity-Opportunity Layout.layout-meta.xml`: the Opportunity layout with the button added to its actions
- `force-app/main/default/permissionsets/Velora_Quote_Action.permissionset-meta.xml`
- `scripts/anonymous/place-one-quote.apex`

## What you should see (planned)

One quote with one Connect line at 29 after the first click, the same quote after the second, and the test class passing in the CI run of episode 41.

## Try it yourself

Make the mock fail twice before it succeeds. After each click read Status, Attempts and the error message on the request.

All names and numbers are invented examples. Prices are in US dollars.
