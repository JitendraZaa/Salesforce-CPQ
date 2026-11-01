# Episode 39: The customer site

Status: planned, not recorded yet; steps below may change when the episode is recorded.

## What this episode builds

A self-service Experience Cloud site, Velora Customers, where an owner of a Velora Aria, Lena Fischer, signs in, adds a Velora Connect plan, and later opens the Connect invoice of 29.00 and downloads its PDF.

## Before you start

Starting point: tag `ep38-end`. The dealer site works and Swift Couriers' lifecycle, invoices and credit memos exist. The org needs Customer Community Plus licences and the Billing and Billing Advanced licences. Person Accounts are off, so Lena is a business account named Lena Fischer with one contact.

## Planned steps

1. Load Lena's account, contact and Aria order (the plan `data/ep39-lena/` is planned):

```sh
sf data import tree --plan data/ep39-lena/plan.json --target-org demo_cpq
```

- `--plan` is the plan file; `--target-org` is the org alias.

2. On the contact choose the actions menu > Enable Customer User. The account owner must have a role. Choose the Customer Community Plus User license and profile, and clear Generate new password and notify user immediately.
3. Assign the permission sets for the customer user: the quote and order permission sets for the Customer Community Plus licence, Billing Experience Cloud User, and DocGen Runtime Community User for the invoice PDF.
4. In Setup > Digital Experiences > All Sites > New choose the Self-Service Billing Portal template and name the site Velora Customers.
5. Create a sharing set so the customer profile can see invoices, invoice lines and credit memos through the account.
6. Build a catalog for private buyers that holds Velora Connect and the Aria and not the Depot Charger. Rebuild the index and run Sync Pricing Data.
7. Publish the site and sign in as Lena (Preview works). Browse the catalog, add Velora Connect (29 per vehicle per month), and create the quote and order.
8. After the order is activated and the invoice run has produced an invoice, open Home on the site, click the invoice number, review the lines and click Download.

## Files in this repo used by this episode

- Planned and not in the repository yet: `data/ep39-lena/`, the site metadata (`experiences`, `networks`, `sites`, `sharingSets`) and a permission set script for the customer user.

## What you should see (planned)

The site's catalog lists Velora Connect and no Depot Charger; an order exists with Created By Lena Fischer; the Home tab lists one posted invoice of 29.00 with no tax; Download opens the PDF.

## Try it yourself

Create a second contact on the Lena Fischer account, enable it as a second customer user, and check which invoices that user sees.

All names and numbers are invented examples. Prices are in US dollars.
