# Velora Motors on Agentforce Revenue Management

A Salesforce DX project that follows Velora Motors, an electric-vehicle maker, from a customer's first enquiry to the
last invoice: products and prices, configuration rules, quotes, approvals, contracts, orders, fulfillment, billing,
usage, renewals, and selling through dealer and customer sites.

It is the companion code for a video series on Agentforce Revenue Management (formerly Revenue Cloud). **Every company,
person, product, price and number in it is an invented example.** Words are explained in [GLOSSARY.md](GLOSSARY.md).

## What you need

- A Salesforce org with Revenue Management (Revenue Cloud) and these licences active: Revenue Cloud Growth or Advanced
  (every episode), Billing and Billing Advanced, Usage Management, Rate Management, Clause Management and Contract
  Lifecycle Management, Document Builder, DocGen Designer, OmniStudio, Fulfillment User (Dynamic Revenue
  Orchestrator), Revenue Management Promotions Run Time, and the Partner Community and Customer Community Plus licences
  for the two Experience Cloud sites. A Revenue Lifecycle Management demo Developer Edition has them.
- Person Accounts off: every account in the project is a business account.
- The Salesforce CLI (`sf`), Visual Studio Code with the Salesforce extensions, and Python 3 (the load scripts use it
  to read JSON).
- For the developer path, a second org for the test run, and a GitHub repository with four secrets (see
  [docs/ci-setup.md](docs/ci-setup.md)).

## Connect your org

```sh
sf org login web --alias demo_cpq --set-default
sf org display
```

Every script uses the project's default org. To aim a script at another org, set `TARGET_ORG`:

```sh
TARGET_ORG=velora_qa sh scripts/seed-second-org.sh velora_qa
```

Deploy the project's metadata with `sf project deploy start --source-dir force-app`. To check a change without saving
anything in the org:

```sh
sf project deploy validate --source-dir force-app --test-level RunSpecifiedTests \
  --tests DealMetricsTest --tests ConnectQuoteActionTest
```

## Starting from a checkpoint

Each episode starts from the previous episode's tag (`epNN-end`). A tag restores files only, not the org's records.
The `scripts/seed-epNN.sh` scripts bring an org to an episode's starting point by loading the data that can be loaded,
and print the steps that are done on screen. Every price change ends with Salesforce Pricing Setup, Sync Pricing Data;
every new product or category assignment ends with an index rebuild in Product Catalog Management. Without them,
Browse Catalogs is empty and lines price at 0.

## Learning paths

- Business: episodes 1 to 14 and 16 to 39, to understand the ideas and the terms.
- Admin: the same episodes with the builds, plus the first half of 15.
- Developer: the admin path, all of 15, and 40 to 43.

## Episodes

| # | Episode | What it adds | Tag |
|---|---|---|---|
| 1 | What CPQ and lead to cash mean | No files. The road from enquiry to cash. | `ep01-end` |
| 2 | Our workspace | The Salesforce DX project, `Account.Has_Depot__c` and the `Velora_Fields` permission set. | `ep02-end` |
| 3 | The first product and its price | The Volt Van, its One Time price and Velora Catalog (`scripts/load-ep03.sh`). | `ep03-end` |
| 4 | From enquiry to the first quote | The Swift Couriers lead (`data/ep04/Lead.json`), the pilot opportunity and quote. | `ep04-end` |
| 5 | Catalogs and categories | Five more products (`data/ep05/Product2.json`, `scripts/load-ep05.sh`), the category tree (`scripts/load-ep05-catalog.sh`). | `ep05-end` |
| 6 | Attributes and classifications | Attributes and a classification, built on screen. | `ep06-end` |
| 7 | Subscriptions | Velora Connect options and 29 per month prices (`scripts/load-ep07.sh`). | `ep07-end` |
| 8 | Bundles | The Volt Van Fleet Package, built on screen. | `ep08-end` |
| 9 | Configuration rules | A rule that Refrigerated needs Long Range, built on screen. | `ep09-end` |
| 10 | Qualification rules | Depot products only for accounts with Has Depot. | `ep10-end` |
| 11 | The configurator flow | A cloned product configurator flow. | `ep11-end` |
| 12 | Pricing procedures | The Velora Pricing procedure. | `ep12-end` |
| 13 | Volume pricing | Volume tiers on the Volt Van (`data/ep13/`, `scripts/load-ep13.sh`). | `ep13-end` |
| 14 | Promotions | A launch promotion on the Refrigerated body. | `ep14-end` |
| 15 | Pricing from code | A Pricing API request (`scripts/ep15-pricing-body.json`, `scripts/ep15-price.sh`). | `ep15-end` |
| 16 | Approvals | A discount approval flow. | `ep16-end` |
| 17 | The quote document | A quote document template. | `ep17-end` |
| 18 | Quote versions and the primary quote | Cloned quote versions. | `ep18-end` |
| 19 | Ramp deals | Yearly ramp segments for the fleet deal. | `ep19-end` |
| 20 | Contracts and clauses | Contract with clauses. | `ep20-end` |
| 21 | Negotiated prices that last | A contract price for the Volt Van. | `ep21-end` |
| 22 | Billing setup | Billing policies, treatments and a legal entity. | `ep22-end` |
| 23 | Quote to order | An order placed from the accepted quote. | `ep23-end` |
| 24 | Assets and activation | Assets from the order. | `ep24-end` |
| 25 | Fulfillment orchestration | Build, deliver, install, activate. | `ep25-end` |
| 26 | The first invoice, and tax | The first invoice and a tax policy. | `ep26-end` |
| 27 | Usage setup | Usage resources and a rate card. | `ep27-end` |
| 28 | Usage to invoice, and the monthly minimum | Usage billed on an invoice. | `ep28-end` |
| 29 | Payments | A part payment applied to an invoice. | `ep29-end` |
| 30 | Disputes and credits | A credit memo. | `ep30-end` |
| 31 | Invoice is not payment | Reconciling invoiced, paid and open. | `ep31-end` |
| 32 | Collections and write-offs | Dunning and a write-off. | `ep32-end` |
| 33 | Booked, billed, collected, earned | Four revenue numbers side by side. | `ep33-end` |
| 34 | Amendments and proration | More vans and an upgrade mid-term. | `ep34-end` |
| 35 | Renewals | A renewal from the contract. | `ep35-end` |
| 36 | Cancellations | Cancelling one depot's charging. | `ep36-end` |
| 37 | The dealer site | An Experience Cloud site for dealers. | `ep37-end` |
| 38 | A dealer's quote | A dealer quoting for a customer. | `ep38-end` |
| 39 | The customer site | An Experience Cloud site for owners. | `ep39-end` |
| 40 | Deploying a pricing change | `manifest/ep40-pricing.xml`, `manifest/ep40-deps.xml`, `scripts/seed-second-org.sh`, `scripts/api/price-100-vans.sh`. | `ep40-end` |
| 41 | Testing every change | `DealMetrics`, `DealMetricsTest` and `.github/workflows/ci.yml` (see `docs/ci-setup.md`). | `ep41-end` |
| 42 | An Apex action for quotes | `Quote_Request__c`, `QuotePlacer`, `PstQuotePlacer`, `QuoteRequestService`, `ConnectQuoteAction` with its test, the `Create_Connect_Quote` flow and quick action, `Velora_Quote_Action`. | `ep42-end` |
| 43 | A renewal from code | `scripts/api/renew-swift.sh`, `scripts/reset-ep34.sh`. | `ep43-end` |

## Project layout

- `force-app/main/default`: metadata (custom object and fields, Apex classes and tests, a flow, a quick action, permission sets).
- `data/`: records to load, one folder per episode.
- `scripts/`: loaders, seed scripts and API calls; `scripts/lib/common.sh` holds the shared helpers.
- `manifest/`: package manifests for retrieving and deploying the pricing procedure.
- `docs/ci-setup.md`: how the GitHub Actions check signs in to a test org.
