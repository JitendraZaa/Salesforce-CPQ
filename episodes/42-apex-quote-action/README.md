# Episode 42: An Apex action for quotes

All names, people, companies and numbers in this project are invented examples. Prices are in US dollars.

## What this episode builds

A button on the opportunity starts a screen flow that calls an Apex action. The action sends Place Sales Transaction one quote and one quote line for a Velora Connect plan, records the request, and is safe to click twice: the second click returns the same quote, still with one line. In the example the quote is 00000046 with one Velora Connect line, 1 at 29, 11/01/2026 to 10/31/2027, total 348.

## Before you start

- Starting point: the source on `main` as episode 41 left it. `demo_cpq` holds the Connect product, its price book entry and Swift Couriers' opportunities, with the index rebuilt and prices synced. Check the price: `sf data query --target-org <org alias> --query "SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2.ProductCode = 'VC-SUB' AND IsActive = true"` (`--query` is the SOQL text).
- Deploy everything in one step (the object and its tab, the seven classes, the flow, the quick action, the Opportunity layout that shows the button and the permission set). Assign `Velora_Quote_Action` to the user who will click the button: `sf org assign permset --name Velora_Quote_Action --target-org <org alias>`.
- To bring a fresh org as far as it can go by loading data, run `sh scripts/reset-to.sh ep28-end <org alias>`. A git tag restores files only, never the org. (This repository has no `ep41-end` tag yet.)

## Click path

1. In `force-app/main/default/objects/Quote_Request__c/fields/` open `Request_Key__c` (text, required, unique, so two clicks cannot make two requests) and `Status__c` (Received, Header Saved, Completed). The other fields hold the attempts, a message, the opportunity, the quote and the tracker.
2. Open `QuotePlacer.cls`: an interface with one method, `place`. Tests swap in a stand-in with the same method.
3. Open `PstQuotePlacer.cls`: it builds a graph (a list of named records) and calls `PlaceSalesTransactionExecutor`. The quote gets its name, opportunity and price book; the line points at the quote by reference and gets its product, price book entry, quantity, unit price, start and end dates (sent as text, like 2026-11-01) and a monthly billing frequency, because Connect bills by the month. When the quote already exists, only the line is sent. The response gives a success flag, the sales transaction Id (the quote's Id), a tracker Id and a message; `toOutcome` turns them into one result.
4. Open `QuoteRequestService.cls`: the key is the opportunity Id, a colon and the product code `VC-SUB`. `createConnectQuote` finds or creates the request for that key and branches: Completed returns the quote already made, Header Saved sends only the line to the saved quote, anything else starts fresh. After the call it adds 1 to the attempts and stores the tracker and quote. The lookup locks the row, so two clicks cannot change it at once.
5. Open `ConnectQuoteAction.cls`: the invocable method that Flow sees as Create Connect Quote. It takes a list and returns one result per input (the quote, whether it is new, a message and the correlation Id), and sets the dates from today for 12 months.
6. Open `ConnectQuoteActionTest.cls`: a stand-in placer counts its calls and writes real quotes. Five tests: `oneClick_oneQuote`, `secondClick_sameQuote`, `lineFailsAfterHeader_retryAddsLine`, `placer_buildsGraphForNewQuoteAndForLineOnly`, `placer_turnsAResponseIntoAnOutcome`.
7. Open `manifest/ep42-quote-action.xml` and deploy: `sf project deploy start --manifest manifest/ep42-quote-action.xml --target-org <org alias> --test-level RunSpecifiedTests --tests ConnectQuoteActionTest --wait 30`. The table lists each component (some Unchanged if the org already holds that version); the summary shows 5 passing.
8. Setup, Flows, open Create Connect Quote in Flow Builder: three Get Records elements (the opportunity, the Connect product, its price book entry), the Apex action, then a decision on whether the action returned a message; without one the Quote Ready screen opens.
9. App Launcher, Sales, Opportunities, open Swift Couriers - Fleet (the Swift opportunity that has a price book, which the action needs to find the Connect price). Click Create Connect Quote. The screen says "Your quote is ready" with a link.
10. Open the quote (00000046): Velora Connect 11/1/2026, one Velora Connect line, quantity 1 at 29, 11/01/2026 to 10/31/2027, total 348. Click Finish.
11. Click the button again on the same opportunity: the same quote 00000046 and still one line.
12. Run `sf data query -o <org alias> --file queries/ep42-request.soql`: one row with the key, Completed, 1 attempt and quote 00000046. One attempt after two clicks, because the second click never called the API. Run `sf data query -o <org alias> --file queries/ep42-lines.soql`: one VC-SUB line, quantity 1, at 29.

## Background on slides (not steps)

- Place Sales Transaction is the API for creating a quote and its lines in one call with pricing. Salesforce's page on using it from a flow says the built-in action is for Agentforce Quoting flows only; for any other flow use a custom Apex action, which this episode builds.
- Idempotent means doing it twice has the effect of once. The API saves the quote header first and then the lines, so the request record notes Header Saved and a retry sends only the line. The key doubles as a correlation Id.
- DML is how Apex inserts and updates records: insert the request, call the API, update the request.

## Files in this repo used by this episode

- `manifest/ep42-quote-action.xml`: everything below in one deploy (`--manifest` names the package file; `--test-level RunSpecifiedTests` with `--tests` runs only the named test; `--wait 30` waits up to thirty minutes).
- `force-app/main/default/objects/Quote_Request__c/` and `force-app/main/default/tabs/Quote_Request__c.tab-meta.xml`.
- `force-app/main/default/classes/QuotePlacer.cls`, `PstQuotePlacer.cls`, `QuoteRequestService.cls`, `QuoteInput.cls`, `QuoteOutcome.cls`, `ConnectQuoteAction.cls`, `ConnectQuoteActionTest.cls`.
- `force-app/main/default/flows/Create_Connect_Quote.flow-meta.xml`.
- `force-app/main/default/quickActions/Opportunity.Create_Connect_Quote.quickAction-meta.xml`.
- `force-app/main/default/layouts/Opportunity-Opportunity Layout.layout-meta.xml`: the Opportunity layout with the button in its actions.
- `force-app/main/default/permissionsets/Velora_Quote_Action.permissionset-meta.xml`: access to the classes and request fields.
- `queries/ep42-request.soql` (key, status, attempts and quote number of the opportunity's request) and `queries/ep42-lines.soql` (the quote's lines).
- `scripts/anonymous/place-one-quote.apex`: optionally runs the action once from code on Swift Couriers - Fleet (it creates a real quote): `sf apex run --file scripts/anonymous/place-one-quote.apex --target-org <org alias>`.

## What you should see

One quote with one Connect line at 29 after the first click, the same quote after the second, a request record Completed with Attempts 1, and five tests passing.

## Try it yourself

Open the request object and the Apex class, check the flow is active, add the quick action and run it from an opportunity. Then add a test of your own and read Status and Attempts after each click.
