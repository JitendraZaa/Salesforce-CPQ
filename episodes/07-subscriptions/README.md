# Episode 7: Subscriptions

## What this episode builds

Velora Connect, the telematics service, is sold as a subscription. You give it the existing selling models Term Based -
Monthly and Evergreen - Monthly with a price of 29 per month, add it to the pilot quote for 12 months, and read the quote
lines with one query to work out MRR, ARR and TCV under Velora's rule.

## Before you start

- Starting point: end of episode 6 (tag `ep06-end`): the Volt Van is based on Electric Vehicle; Velora Connect exists with no selling model and no price.
- Fresh org: `sh scripts/reset-to.sh ep06-end`. Tag at the end: `ep07-end`.

## Click path

1. Product Catalog Management, Product Selling Models. Open Term Based - Monthly (type Term-Defined, pricing term 1,
   unit Months) and Evergreen - Monthly (type Evergreen, 1, Months). Look only; do not create models. Pricing term 1
   with unit Months means "priced monthly". How long the subscription runs comes from the quote line's dates.
2. Products, Velora Connect, Related, Product Selling Model Options, New. Open the selling model record first (the lookup
   lists recent records only). Choose Term Based - Monthly, proration policy Default Proration Policy, tick Default.
   Leave Automatically Renew Asset by Default clear. Save. Add Evergreen - Monthly the same way, not default.
3. Price Management, Price Books, Standard Price Book, Price Book Entries, New: Velora Connect, Active, selling model
   Term Based - Monthly, list price 29. Again for Evergreen - Monthly, 29.
4. Salesforce Pricing Setup, Sync Pricing Data, Sync, Confirm.
5. On the pilot quote choose Browse Catalogs, Velora Catalog, Next, Services, Velora Connect, Show buying options, choose
   Term Based - Monthly and add it.
6. In the Lines tab set the Connect line's Start Date to today and End Date twelve months later. Unit price is 29 a
   month and the term total is 12 x 29 = 348.
7. In the terminal run the query below. Why: the slide numbers should come from records, not from reading the screen.
8. Work out the three numbers (Velora's rule, shown on a slide): MRR 29, ARR 29 x 12 = 348, TCV 48,000 + 348 = 48,348.
9. Try it: change the end date to 36 months and read the total (1,044), then run the query again.

## Files in this repo used by this episode

| File | What it contains |
|---|---|
| `scripts/load-ep07.sh` | Gives Velora Connect (VC-SUB) the two options (Term Based - Monthly default, Evergreen - Monthly) and a 29 standard entry for each. It looks the models and proration policy up by name. Safe to run twice; needs `load-ep05.sh` first. |
| `queries/ep07-quote-lines.soql` | A query listing product, selling model, quantity, start and end date, net unit price and total for each line of `Swift Couriers Pilot Quote`. |
| `data/seed/22-ProductSellingModelOption.json`, `23-PricebookEntry.json` | The same options and prices as part of the full data load. |

```sh
sh scripts/load-ep07.sh
sf data query --file queries/ep07-quote-lines.soql
sf data query --target-org my_alias --query "SELECT Product2.Name, Quantity, UnitPrice, SellingModelType, SubscriptionTerm, PricingTermCount, StartDate, EndDate, TotalPrice FROM QuoteLineItem WHERE Quote.Name = 'Swift Couriers Pilot Quote'"
```

- `sf data query`: runs a read-only SOQL query. `--file` reads the query from a file; `--query` takes it inline; `--target-org` picks the org.
- `FROM QuoteLineItem WHERE Quote.Name = ...` limits the result to the pilot quote's lines.

## What you should see

Two rows: Volt Van (one-time, 48,000) and Velora Connect (term-defined, 29, term 12, total 348 over the term).

## Records and values

Velora Connect VC-SUB: 29 per vehicle per month, Term Based - Monthly, 12 months for the pilot. Pilot metrics under
Velora's rule: MRR 29, ARR 348, TCV 48,348 (recurring charges only for MRR and ARR; TCV counts every charge over the
term). The pilot van is not one of the 300 fleet vans.
