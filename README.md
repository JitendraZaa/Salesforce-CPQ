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

## Rebuild everything in a new org

If your org expires, or you want the whole series in a fresh one, follow [docs/REBUILD.md](docs/REBUILD.md): create a
scratch org from `config/revenue-cloud-scratch-def.json`, run `sh scripts/setup-org.sh <alias>` (settings, all metadata,
permission sets, and the data in `data/seed/`), then do the few clicks the page lists.

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

Each episode has a folder `episodes/NN-name/` with a `README.md` (starting point, steps, commands, what you should see,
a task to try) and a `GLOSSARY.md` where the episode adds new terms. Episode 1 has no files. Tags `epNN-end` mark the
end of an episode's files; an episode starts from the previous episode's tag. Episodes 31 to 33 and 38 to 43 are planned
and their guides list the steps as planned.

| # | Episode and folder | What it builds |
|---|---|---|
| 1 | What CPQ and lead to cash mean | No files. The road from enquiry to cash that the rest of the series follows. |
| 2 | Our workspace, [episodes/02-our-workspace](episodes/02-our-workspace) | The DX project, `Account.Has_Depot__c`, the `Velora_Fields` permission set and the settings the series needs. |
| 3 | The first product, [episodes/03-first-product](episodes/03-first-product) | The Volt Van with its One Time price in Velora Catalog (`scripts/load-ep03.sh`). |
| 4 | From enquiry to the first quote, [episodes/04-first-quote](episodes/04-first-quote) | The Swift Couriers lead, the pilot opportunity and the first quote with the van. |
| 5 | Catalogs and categories, [episodes/05-catalogs](episodes/05-catalogs) | Five more products and the category tree (`scripts/load-ep05.sh`, `scripts/load-ep05-catalog.sh`). |
| 6 | Attributes and classifications, [episodes/06-attributes](episodes/06-attributes) | Battery and Body attributes on a classification, built on screen. |
| 7 | Subscriptions, [episodes/07-subscriptions](episodes/07-subscriptions) | Velora Connect with its monthly option at 29 per vehicle (`scripts/load-ep07.sh`). |
| 8 | Bundles, [episodes/08-bundles](episodes/08-bundles) | The Volt Van Fleet Package with van, charger and Connect as components. |
| 9 | Configuration rules, [episodes/09-configuration-rules](episodes/09-configuration-rules) | Rules that limit choices, such as Refrigerated needing Long Range. |
| 10 | Qualification rules, [episodes/10-qualification-rules](episodes/10-qualification-rules) | Depot products offered only to accounts with Has Depot. |
| 11 | The configurator flow, [episodes/11-configurator-flow](episodes/11-configurator-flow) | A cloned product configurator flow used on the quote. |
| 12 | Pricing procedures, [episodes/12-pricing-procedures](episodes/12-pricing-procedures) | The Velora Pricing procedure, cloned, read element by element and made the default. |
| 13 | Volume pricing, [episodes/13-volume-pricing](episodes/13-volume-pricing) | Volume tiers and option prices for the Volt Van, and Swift's first fleet quote V1 (`data/ep13/`, `scripts/load-ep13.sh`). |
| 14 | Promotions, [episodes/14-promotions](episodes/14-promotions) | A concept episode: what a promotion is, coupons and stacking, shown with a launch offer as an illustration. |
| 15 | Pricing from code, [episodes/15-pricing-api](episodes/15-pricing-api) | A Pricing API request from the terminal (`scripts/ep15-pricing-body.json`, `scripts/ep15-price.sh`). |
| 16 | Approvals, [episodes/16-approvals](episodes/16-approvals) | A discount approval flow: a line discount over the limit sends the quote to the sales manager. |
| 17 | The quote document, [episodes/17-quote-document](episodes/17-quote-document) | The Velora Fleet Quote template in Document Builder and the generated PDF. |
| 18 | Quote versions and the primary quote, [episodes/18-quote-versions](episodes/18-quote-versions) | Quote V2 cloned from V1 with depot charging added; the primary quote. |
| 19 | Ramp deals, [episodes/19-ramp-deals](episodes/19-ramp-deals) | Year 1 to Year 3 ramp groups on V2 and the 3 percent yearly uplift on Connect. |
| 20 | Contracts and clauses, [episodes/20-contracts](episodes/20-contracts) | Clause sets with a token, Quote Special Terms and the contract created from V2. |
| 21 | Negotiated prices that last, [episodes/21-negotiated-prices](episodes/21-negotiated-prices) | A contract price for the Volt Van and a later quote that sources it. |
| 22 | Billing setup, [episodes/22-billing-setup](episodes/22-billing-setup) | Billing policy, billing treatment and the legal entity Velora Motors Inc. |
| 23 | Quote to order, [episodes/23-quote-to-order](episodes/23-quote-to-order) | The accepted quote turned into a draft order with Create Single Order. |
| 24 | Assets and activation, [episodes/24-assets](episodes/24-assets) | The activated order, its assets and billing schedules. |
| 25 | Fulfillment orchestration, [episodes/25-fulfillment](episodes/25-fulfillment) | Dynamic Revenue Orchestrator: a plan with Build Vans and Deliver Vans. |
| 26 | The first invoice, and tax, [episodes/26-first-invoice](episodes/26-first-invoice) | The first Connect invoice from billing schedules, and where tax fits. |
| 27 | Usage setup, [episodes/27-usage-setup](episodes/27-usage-setup) | Unit of measure, usage resource, Depot Charging product and the 0.21 per kWh rate card. |
| 28 | Usage to invoice, and the monthly minimum, [episodes/28-usage-to-invoice](episodes/28-usage-to-invoice) | A September depot charging order, the usage file import, the usage flow and the usage summaries. |
| 29 | Payments, [episodes/29-payments](episodes/29-payments) | A payment of 2,552 applied to the fleet invoice, leaving a balance of 348. |
| 30 | Disputes and credits, [episodes/30-credits](episodes/30-credits) | A credit memo of 348 created and applied from an invoice line. |
| 31 | Invoice is not payment, [episodes/31-invoice-is-not-payment](episodes/31-invoice-is-not-payment) | Swift's two Connect invoices side by side in a list view and a query: 5,800 invoiced, 2,552 paid, 348 credited, 2,900 open. |
| 32 | Collections and write-offs, [episodes/32-collections](episodes/32-collections) | A collection plan for the open invoice, the reason code BD, and a flow that writes off the last 0.50 after a payment of 2,899.50. |
| 33 | Booked, billed, collected, earned, [episodes/33-booked-billed-collected-earned](episodes/33-booked-billed-collected-earned) | Booked 217,245.96, billed 2,552 and collected 2,552 read from the org with three queries; the earned figure is an example policy. |
| 34 | Amendments and proration, [episodes/34-amendments](episodes/34-amendments) | Fifty more Connect vehicles part-way through a month (Amend), and 20 vehicles moved to Connect Plus (Swap). Uses `scripts/ep34-connect-plus.sh`. |
| 35 | Renewals, [episodes/35-renewals](episodes/35-renewals) | A renewal quote and order for the Year 3 Connect asset. |
| 36 | Cancellations, [episodes/36-cancellations](episodes/36-cancellations) | Cancelling one depot's charging from a date, by quote and order. |
| 37 | The dealer site, [episodes/37-dealer-site](episodes/37-dealer-site) | An Experience Cloud site for dealers and the dealer configurator permission set. |
| 38 | A dealer's quote, [episodes/38-dealer-quote](episodes/38-dealer-quote) | A dealer signs in to the Velora Dealers site, creates a quote for Crumb & Co Bakery, and Velora's desk adds 3 Volt Vans (144,000); catalog sharing rules and the dealer permission set. |
| 39 | The customer site, [episodes/39-customer-site](episodes/39-customer-site) | The Velora Customers site: Lena Fischer's customer user, a sharing set, her Connect order and invoice DOC-000000003 (29) posted from VS Code, read on the site. |
| 40 | Deploying a pricing change, [episodes/40-deploying-pricing](episodes/40-deploying-pricing) | A new Velora Pricing version retrieved with `manifest/ep40-pricing.xml`, dry-run and deployed to a second org with `scripts/deploy-pricing.sh`, checked by pricing 100 vans (net 44,640). |
| 41 | Testing every change, [episodes/41-testing](episodes/41-testing) | `DealMetrics` and its six tests run in the test org and by `.github/workflows/ci.yml` on a push (see `docs/ci-setup.md`). |
| 42 | An Apex action for quotes, [episodes/42-apex-quote-action](episodes/42-apex-quote-action) | `Quote_Request__c`, `QuotePlacer`, `ConnectQuoteAction`, the `Create_Connect_Quote` flow and quick action: one quote and one line, safe to click twice. |
| 43 | A renewal from code, [episodes/43-renewal-from-code](episodes/43-renewal-from-code) | `scripts/api/renew-swift.sh` renews Swift's Connect Plus asset through the API and stops a second request. |

## Project layout

- `force-app/main/default`: metadata (custom object and fields, Apex classes and tests, a flow, a quick action, permission sets).
- `data/`: records to load, one folder per episode.
- `scripts/`: loaders, seed scripts and API calls; `scripts/lib/common.sh` holds the shared helpers.
- `manifest/`: package manifests for retrieving and deploying the pricing procedure.
- `docs/ci-setup.md`: how the GitHub Actions check signs in to a test org.
