# Glossary

Plain definitions of the quote-to-cash words used in this project. Where companies use a word differently, the
episode guides state the rule Velora Motors uses. All names and numbers in the project are invented examples.

## The road from enquiry to cash

- **Lead**: A person or company that has shown interest and might buy.
- **Lead conversion**: Converting a qualified lead into account and contact records, with an opportunity when the user chooses one.
- **Opportunity**: One specific chance to sell, with a stage, an amount and a close date.
- **Account, contact**: The buying company and the person who speaks for it.
- **Quote**: A priced offer to a customer. In Salesforce a quote usually hangs from an opportunity, but it does not have to.
- **CPQ (configure, price, quote)**: Choosing a product's options, working out the price, and putting the offer in a document.
- **Quote to cash (Q2C)**: From the quote to the money arriving: contract, order, delivery, invoice, payment.
- **Lead to cash (L2C)**: Quote to cash plus the steps before the quote.
- **Order to cash (O2C)**: From the customer's order: fulfil, invoice, collect.
- **Revenue Management; Agentforce Revenue Management; Revenue Cloud; Revenue Lifecycle Management (RLM); Revenue Cloud Advanced (RCA)**: One Salesforce product for the quote-to-cash road, under several names.
- **PCM (Product Catalog Management)**: The part of Revenue Management that holds products, attributes, bundles and catalogs.
- **Roles: sales rep, sales manager, deal desk, sales operations, fulfilment, billing, accounts receivable team**: Who does each step. Deal desk: the team that checks unusual deals.
- **Persona**: A typical job, used by Salesforce to recommend which permission sets to assign; assignments can be changed.
- **B2B, B2C, channel (partner, dealer)**: Selling to businesses, to private people, and through resellers.
- **CLM (contract lifecycle management)**: Creating, negotiating, signing and maintaining agreements.

## Products and the catalog

- **Product**: Anything the company sells, goods or services; some product records are not sold on their own.
- **SKU (stock keeping unit), product code**: A short code that identifies one sellable item.
- **Product family**: A broad group of products, used for reports and lists.
- **Catalog, category, subcategory**: The organised list of what the company sells, and its folders.
- **Simple product**: A product with no parent or child products.
- **Attribute**: A characteristic of a product, often chosen during the sale, sometimes fixed or hidden.
- **Product classification**: A template that gives similar products the same attributes.
- **Product variant**: Related products that share one design but differ in an attribute.
- **Bundle, static and configurable**: Products sold together as one unit; a static one is fixed, a configurable one lets the rep change it.
- **Component, component group**: A product inside a bundle; groups hold related components.
- **Required, optional, default component**: Whether a component must be in, may be added, or starts in the bundle.
- **Cardinality: group and local**: Group: how many components may be picked across a group. Local: whether one component is required or default and if its quantity can change.
- **Quantity scaling (proportional, constant)**: Whether a component's quantity grows with the bundle's quantity.
- **Included versus separately priced component**: Whether a child's charge is inside the parent's price or added.
- **Add-on**: An extra product sold with a main product.
- **Cross-sell, upsell**: Cross-sell: a related extra product. Upsell: a bigger or better version of what is bought.
- **Product recommendations**: Suggestions driven by configuration rules.
- **Guided selling (Guided Product Selection)**: Questions that narrow the catalog to matching products.
- **PSM, PSMO (product selling model, product selling model option)**: How a product is sold (once, for a term, until cancelled), and the record that offers a model on a product.
- **One-time**: Not a subscription: charged as a single sale, even if paid in parts.
- **Subscription, recurring charge**: A product charged again for each period while it runs; it can be billed in advance for many periods.
- **Term-defined**: A subscription with an end date.
- **Evergreen**: A subscription with no end date that runs until the customer cancels; it needs no renewal.
- **Pricing term versus subscription term**: The period one price covers (for example 1 month) versus how long the service runs (for example 36 months).
- **Proration policy**: Whether a customer can start partway through a pricing period and pay only for that part.
- **Usage product, usage-based pricing**: A product charged by how much is used.
- **Assetizable**: Whether a sold product becomes an asset record.
- **Commercial product, technical product**: What the customer buys versus the items operations fulfils.
- **Unit of measure (UoM)**: The unit a quantity is counted in.
- **Unit of measure class**: A group of units of the same kind (for example kWh and MWh).
- **Product usage resource**: The link between a usage product and the resource it measures.

## Rules

- **Configuration rule**: A rule that keeps a product's choices valid: a condition and an action.
- **Rule actions**: What a rule can do: require, exclude, hide or disable a choice, or show a message.
- **BRE (Business Rules Engine), Constraint Rules Engine**: The two engines that can run configuration rules.
- **CML (Constraint Model Language), constraint model**: The language for constraint models, and the model itself.
- **Transaction Processing Type; Transaction Type field; Sales Transaction Type**: Transaction Processing Type records define the rules engine, with a default set in Revenue Settings. Sales Transaction Type is described as triggering different pricing procedures.
- **Qualification and disqualification rules; eligibility**: Rules that decide which products a customer may see or buy.
- **Decision table**: A lookup table that rules and prices read.
- **Context definition, Context Service**: The map of data (quote, lines, account) that rules and pricing read.
- **Product validation**: A runtime check that runs qualification, catalog and configuration rules on the current configuration.

## Prices and discounts

- **Price book, price book entry**: A list of products with base prices; one product's base price in one price book.
- **List price**: The published starting price before any adjustment.
- **Unit price, list price, net unit price**: Unit price: a price per unit. List price: the starting price from the price book. Net unit price: the price per unit after the procedure's adjustments.
- **Line total, subtotal, quote total**: The amount a line charges for its whole priced period after adjustments (for a subscription, per period times periods, with proration and the org's rounding); the sum of lines; the amount after header items such as tax.
- **Customer price, contract price**: The price a particular customer actually pays, often agreed in a contract.
- **Discount by percent or amount; price override**: Lowering a price by a percentage or an amount; replacing it with a set price, which can be higher or lower.
- **Manual discount**: A discount the rep enters during the deal.
- **Line discount versus header discount**: On one line, or on the whole quote.
- **Discount stacking (sequence)**: The order in which adjustments apply and which price each starts from.
- **Volume discount**: A lower unit price when more units are bought.
- **Range (all-units) versus Slab (tiered, progressive)**: Range: every unit gets the rate of the highest tier reached. Slab: each unit gets the rate of the tier it falls in. Elsewhere "tiered" can mean either; the series uses Salesforce's two names.
- **Tier bounds**: Each tier's lower bound is included and its upper bound is not.
- **Block price**: One fixed price for a whole quantity band rather than per unit.
- **Price adjustment schedule, price adjustment tier**: The record that groups adjustments of one type (volume, attribute, bundle, term, custom), and each volume tier row. "Discount schedule" is only everyday shorthand.
- **Attribute-based and bundle-based adjustment**: A price change because of a chosen option, or because products are bought together.
- **Price waterfall**: The step-by-step path from list price to net price.
- **Pricing procedure, pricing element**: The ordered steps that calculate a price, and each step.
- **Pricing recipe, pricing data sync**: The decision tables pricing reads, and the refresh that keeps them current.
- **Pricing simulation**: Testing a procedure with sample data before it goes live.
- **Derived, formula and delta pricing**: Everyday meanings: a price taken from another product's price; a price from a formula; repricing only changed lines.
- **Promotion, coupon**: A rule-based discount for eligible products, applied automatically or only with a coupon code.
- **Partner (channel) discount**: A discount that lets a reseller earn a margin.
- **Cost, cost book, cost book entry**: What a product costs the seller; the list of those costs by period.
- **Margin, markup**: Margin percent = (price - cost) / price. Markup percent = (price - cost) / cost.
- **Floor price, margin floor**: The lowest price, or lowest margin, allowed without an exception.
- **Price agreement, contract-based pricing**: A contract that captures a customer's negotiated prices for future purchases.
- **Cumulative quantity pricing**: Prices based on quantities bought over time under an agreement.

## The quote and its approval

- **Quote line (quote line item)**: One product, quantity and price on a quote.
- **STLE, TLE, TLT**: Sales Transaction Line Editor (the recommended grid); Transaction Line Editor (older, no longer enhanced); Transaction Line Table (the data structure behind lines).
- **Quote line group**: Lines collected under a heading.
- **Quote status, expiration date**: Where the quote stands, and the date the offer ends.
- **Quote version, revision**: A changed copy made when the customer asks for something different; the earlier one is kept.
- **Primary (synced) quote**: The one quote of several on an opportunity whose lines and total feed the opportunity.
- **Approval, approval workflow**: A required yes before a quote goes out.
- **Approver, approval work item**: The person who decides, and the task they get.
- **Approval chain; serial versus parallel**: The named group and order of approvers; one after another, or at once.
- **Smart approvals, auto-approval**: On resubmission, steps that need no new review are approved automatically.
- **Delegation**: An approver hands approvals to someone else for a time.
- **Quote document, template**: The customer-facing document made from the quote.
- **E-signature, acceptance**: The customer signs or accepts the offer: a business event.
- **Special term**: A contract clause added to a quote.

## Terms, multi-year deals and subscriptions over time

- **Term, start date, end date**: How long a subscription runs, and when.
- **Ramp deal**: A multi-period deal where price, quantity or discount change at set points.
- **Ramp-up pricing**: Starting small and stepping up quantity or price.
- **Segment, ramp schedule**: One period of a ramp deal, and the set of periods.
- **Uplift; escalator**: A planned price rise per period; "escalator" is a common other name.
- **Standard versus compound uplift**: Standard applies to the original list price; compound builds on the previous segment's net price.
- **CPI (Consumer Price Index) uplift**: A price rise linked to an inflation index, unlike a fixed agreed uplift.
- **Proration**: Adjusting a charge in proportion to the part of a period the service is active, under a stated rule.
- **Co-termination**: Aligning added subscriptions to end on the same date as the existing contract.
- **Period boundary: anniversary versus calendar**: Billing periods start on the start date's day, or on the first of the month.
- **Auto-renew**: A flag that marks a term subscription for automatic renewal; renewal happens only when the renewal flow is set up.
- **Evergreen versus term versus auto-renew**: No end date; a fixed end; a fixed end that is renewed automatically.
- **Effective date, backdating**: When a change takes effect, including a permitted past date.
- **Delta quantity, LIFO (last in, first out)**: The quantity change on an amendment; the rule that prices a reduction from the latest prior sales first.

## Deal and subscription metrics

- **MRR (monthly recurring revenue)**: Recurring contract value normalised to one month, on a stated date. Velora's rule: subscriptions only; one-time fees and usage excluded. Billing timing does not change it.
- **ARR (annual recurring revenue)**: MRR annualised, normally x 12: a run rate, not a forecast of next year's revenue.
- **TCV (total contract value)**: Committed amounts over the contract's defined term, one-time plus recurring; usage and anything not committed excluded (Velora's rule).
- **ACV (annual contract value)**: Velora's rule: TCV divided by contract years. Single ramp years are called "annual contracted charges" instead.
- **CMRR (committed MRR)**: Current MRR plus signed future starts, expansions and price rises, minus signed contractions and cancellations, each counted once, up to a stated date.
- **Bookings**: Accepted contractual commitments, valued under a stated policy.
- **Billings**: Amounts invoiced in a period, after credits as stated; named apart from the service month they cover.
- **Cash collections**: Money actually received.
- **Revenue (recognised revenue)**: Amounts earned under the company's accounting rules, which can differ from bookings, billings and cash.
- **Deferred revenue**: Billed or received amounts for service not yet delivered, under the accounting policy.
- **Unbilled (accrued) revenue**: Revenue earned but not yet invoiced, under the accounting policy.
- **Backlog (remaining contracted value)**: Velora's rule: contracted amounts for obligations not yet performed, whether or not billed. Delivered-but-unbilled work is unbilled revenue (G11), not backlog.
- **Customer churn**: Customers lost in a period divided by customers at its start.
- **Recurring revenue churn and contraction; expansion**: MRR lost from customers who leave (churn) or reduced by those who stay (contraction), and MRR added by existing customers (expansion), each in a period, as a share of starting MRR.
- **Renewal rate; GRR, NRR (gross and net revenue retention)**: Renewal rate: subscriptions renewed / subscriptions up for renewal in the period. GRR: (starting MRR - churn - contraction) / starting MRR, capped at 100 percent. NRR: (starting MRR - churn - contraction + expansion) / starting MRR. New customers are excluded.

## Contracts

- **Contract**: The agreement that governs what was bought, for how long, on what terms.
- **MSA (master service agreement), order form, SOW (statement of work)**: Umbrella legal terms; the document for one purchase; the description of services to deliver.
- **PO (purchase order)**: The buyer's own approval document, often needed before an invoice is paid.
- **Clause, clause library, placeholder token**: Reusable contract text, the library holding it, and blanks filled per deal.
- **Redlining**: Marking changes to contract wording during negotiation.
- **Contract activation**: The contract's status set to Activated.
- **AUA (application usage assignment)**: The tag marking a contract as Revenue Management's, needed for amendments, renewals and cancellations.

## Orders and fulfilment

- **Order, order product**: The confirmed purchase, and each product on it.
- **Order status, activation**: Draft orders can change; an activated order cannot be edited. What follows activation (assets, billing schedules, fulfilment) happens only through the flows that are set up.
- **PST (Place Sales Transaction)**: The API that creates or updates a quote or order with pricing and configuration in one call.
- **Fulfilment, provisioning**: Delivering what was sold; provisioning is switching a service on.
- **Decomposition**: Mapping commercial order lines to technical fulfilment lines.
- **Orchestration plan, fulfilment step, dependency**: The ordered plan of work after decomposition, each step, and what must finish first.
- **Decomposition rule**: The rule that decides which technical product a commercial product decomposes into.
- **Fulfilment order, fulfilment order line item**: The technical order grouping the decomposed lines, and each line.
- **Fulfilment step definition, step definition group, runtime step**: The design-time step, the group that orders steps, and the step instance on a live order.
- **Fulfilment scenario**: The rule that picks which step group goes into a plan for a product and order action.
- **Fulfilment asset; orchestration submission status**: Assets made from fulfilment lines when the plan completes; the order field showing submission progress.
- **PONR (point of no return)**: A fulfilment step after which that line item can no longer be cancelled or amended.
- **Fallout, jeopardy**: A fulfilment step that fails, or is at risk of being late.
- **Supplemental order, in-flight change**: A change to an order already submitted for fulfilment.

## Assets and change over time

- **Asset, installed base**: The record of a product or service the customer has purchased; all of them together are the installed base. An asset record is not proof of legal ownership.
- **Subscription versus asset**: The subscription is what was sold over time; the asset is the record of what the customer has after the order.
- **Asset action, asset state period, assetization**: Events that change an asset, the spans between them, and creating assets from an order.
- **MAV (Managed Asset Viewer)**: The account component listing assets, where changes start.
- **Amendment, price amendment**: A mid-term change in quantity or attribute; or in price only.
- **Upgrade**: Replacing a subscription with a higher-value product. Downgrade and swap are separate operations.
- **Downgrade, swap**: Replacing with a lower-value product; replacing with a different one.
- **Renewal, renewal term**: Extending an asset for a new term.
- **Cancellation, termination**: Ending an asset's term from a chosen date.
- **Early termination fee**: A charge for ending before the agreed end.
- **Rollback**: Undoing the most recent future-dated amendment or renewal.

## Billing

- **Billing policy, billing treatment, treatment item**: Rules on a product that say how its order lines are invoiced.
- **Billing schedule**: The record, one per activated order line, that holds what is to be invoiced over the line's life.
- **Billing period item**: One billing period of a subscription, passed to an invoice line.
- **Billing schedule group**: All billing schedules from one asset, including amendments.
- **Billing frequency**: How often a line is invoiced.
- **Billing in advance versus in arrears**: Invoicing before the period, or after it.
- **Billing profile, BDOM (bill day of month)**: A customer's billing preferences: bill day, payment terms, billing address.
- **Sold-to, bill-to, ship-to**: The buying party, the party and address invoiced, and the delivery address.
- **Payment term, Net 30**: The agreed days to pay after the invoice date.
- **Legal entity**: The company in a group that issues the invoice.
- **Invoice, invoice line**: The bill sent to the customer, and each charge on it.
- **Invoice date, due date**: When the invoice is issued, and when payment is expected under the payment term.
- **Invoice batch scheduler, invoice batch run (bill run)**: The scheduler that creates invoices in bulk, and each run record.
- **Catch-up bill run**: A run that bills periods missed earlier.
- **Invoice preview**: A look at the next invoice before it is created.
- **Invoice PDF; sequential numbering**: The invoice document; invoice numbers in sequence.
- **Milestone billing, billing arrangement**: Invoicing at agreed project stages; splitting a line's invoices across billing accounts.
- **Suspend and resume billing**: Pausing a line's invoices, then restarting them.
- **Tax, tax policy, tax treatment, tax engine**: Tax added to a sale, the product's tax rule and treatment, and the engine that calculates it.
- **Tax-inclusive versus tax-exclusive price; exemption**: Tax inside the price or added to it; a sale not taxed under a rule.

## Getting paid: invoice is not payment

- **Invoice versus payment**: An invoice asks for money; a payment is money received. They differ through payment terms, part payments, disputes, credits and late payers.
- **AR (accounts receivable, trade receivables)**: Amounts customers owe the company for goods or services already invoiced, less payments and credits applied; this lesson shows invoiced AR only.
- **Invoice balance versus account balance**: What is open on one invoice versus across all of a customer's invoices and unapplied amounts.
- **Aging, overdue**: Open invoices grouped by days past the due date (Velora's basis), in buckets 1-30, 31-60, 61-90, over 90.
- **DSO (days sales outstanding)**: Velora's rule: AR at period end / credit sales in the period x days in the period.
- **Payment**: Money received from the customer.
- **Payment application**: Linking a payment to the invoices or invoice lines it pays.
- **Unapplied payment (unapplied cash)**: The part of a received payment not yet linked to any invoice, including what is left after a partial link.
- **Partial payment, short payment, overpayment**: Paying less than the invoice; less by a small or unexplained amount; more than it.
- **Payment authorisation, capture, settlement; payment gateway; payment method; payment schedule**: Approval to charge, taking the charge, funds arriving; the service that processes cards or banks; the stored way to pay; a plan of future collections.
- **Payment reconciliation**: Matching payment records with bank or gateway evidence.
- **Credit memo; credit application**: A document that reduces what the buyer owes on an earlier invoice; applying it to that invoice, with any unused remainder kept.
- **Dispute**: A customer's formal challenge of a charge.
- **Debit memo**: A document that charges the buyer an additional amount.
- **Refund**: Money paid back to the customer.
- **Dunning**: Sending payment reminders on a schedule; one part of collections.
- **Collections, collection plan**: All work to recover overdue money, and the record that plans it.
- **Write-off**: Removing an amount from receivables because it will not be collected; it is not a refund or a legal waiver of the debt.
- **Bad debt, allowance for credit losses**: Bad debt: the expense for receivables expected not to be collected. Many companies estimate it ahead in an allowance; a later write-off then uses the allowance instead of adding a new expense.
- **GL (general ledger), chart of accounts**: The ledger of all the company's accounts, and the list of those accounts.
- **Journal entry; debit and credit**: A dated entry of balanced postings: each posting is a debit or a credit to one account, and total debits equal total credits (not the same as debit and credit memos).
- **Accounting period**: The span (often a month) that postings belong to.

## Usage

- **Usage, consumption, transaction journal**: What the customer used; the raw usage log.
- **Usage resource, anchor product, pack product**: The thing measured; the main usage subscription; an add-on granting more units.
- **Rate, rate card, rate card entry**: Price per unit of usage, and where it is held.
- **Rating**: Applying rates to usage records to price them.
- **Usage summary, aggregation**: Combining a period's usage under a policy (sum, maximum or per event) before rating.
- **Commitment, shortfall**: A promise to use or pay for a minimum over a period; the gap when use is lower.
- **Overage**: Usage above the included or committed amount.
- **Grant; entitlement**: A grant: a quantity of a usage resource with its validity and renewal and rollover policies. An entitlement: a grant assigned with a product the customer buys.
- **Prepaid; wallet, bucket; drawdown**: Prepaid: paid for before use. Wallet and bucket: balance locations that drawdown takes usage from. Drawdown: deducting consumption from an available balance.
- **Rollover**: Unused units carried to the next period.
- **True-up**: A later reconciliation under the agreement that may add a charge or a credit.
- **Usage ratable summary**: The usage summary rated with rounding rules.
- **Liable summary; usage billing period item**: Glossary label: the record of calculated overages and their charge. API object: UsageBillingPeriodItem.
- **Rating procedure, rating frequency policy**: The procedure that prices usage, and the policy that sets how often rating runs.
- **Net unit rate**: The usage price per unit after rate adjustments.

## Admin words

- **Licences: Revenue Cloud Growth, Advanced, Billing**: The three licences that decide which features an org has.
- **Revenue Settings**: The Setup page that turns features on.
- **Permission set**: Grants permissions to a user.
- **Permission set group**: Combines several permission sets for one assignment.
- **Permission set licence**: The entitlement that makes certain permissions assignable.
- **CRUD (create, read, update, delete), FLS (field-level security), sharing**: Object permissions, field permissions and record access.
- **Salesforce Go**: Salesforce's guided setup page.
- **Product Discovery, Browse Catalogs**: The screens reps use to find products.
- **Product Configurator, configurator flow**: The screen, and its flow, where options are chosen.
- **Document Builder, document generation**: The tools that make quote documents.
- **Advanced Approvals, Flow Approval Process, Flow Orchestration**: The approval feature and the Flow engine under it.
- **DRO (Dynamic Revenue Orchestrator)**: Plans and tracks fulfilment.
- **Experience Cloud site, partner user, customer user**: A portal for partners or customers, and their logins.

## Developer words

- **Salesforce DX project, sf CLI, VS Code**: The source folder, the command line and the editor.
- **Metadata versus data**: Setup stored as deployable files versus records loaded as data.
- **Metadata API types: ExpressionSetDefinition, ContextDefinition, DecisionTable, PricingRecipe, RevenueManagementSettings, BillingSettings, Flow**: The file types behind procedures, contexts, tables, recipes, settings and flows.
- **SOQL (Salesforce Object Query Language), DML (Data Manipulation Language)**: Querying records; inserting, updating and deleting them.
- **REST (Representational State Transfer), HTTP (Hypertext Transfer Protocol), JSON (JavaScript Object Notation), OAuth**: An API style over web addresses; the request and response protocol; the text format of the data; delegated authorisation that lets a tool call the org on a user's behalf (distinct from signing in).
- **Connect REST API (business APIs)**: Salesforce's REST resources for Revenue Management actions.
- **Headless Pricing API**: Prices products without saving a quote.
- **Product Configurator API**: Configures a product from code; stateless unless state is saved and reloaded.
- **Product Discovery API**: Lists catalogs, categories and products from code.
- **Asset lifecycle APIs**: Start an amendment, renewal or cancellation from code.
- **Invocable action**: An action that Flow or Apex can call.
- **Apex action wrapping PST**: Apex that calls Place Sales Transaction so a normal Flow can use it.
- **QuoteSaveEvent**: A platform event published after a quote save is processed.
- **Scratch org, scratch org features**: A short-lived org from a definition file.
- **CI (continuous integration), Apex test**: Automatic deploy and test on every change; code that proves code works.
- **Idempotency, retry, correlation ID**: A repeated call does the work only once; a failed call is tried again safely; one ID traces a request end to end.
