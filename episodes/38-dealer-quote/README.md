# Episode 38: A dealer's quote

All names, people, companies and numbers in this project are invented examples. Prices are in US dollars.

## What this episode builds

A dealer, Sam Okafor of Brightside Motors, signs in to the Velora Dealers site and creates a quote for a customer, Crumb & Co Bakery. You share the catalog with partner users, extend the dealer permission set from VS Code, add a Quote page with the Transaction Line Editor to the site, and create the quote as Sam. Velora's desk adds 3 Volt Vans to the same quote in the internal org (144,000), and Sam's Quotes list shows it. The partner discount (8 percent, 44,160 per van, 132,480 for 3) is explained on a slide as the rule's example.

## Before you start

- Starting point: the end of episode 37. The Velora Dealers site is live, Brightside Motors is a partner account and Sam Okafor is its partner user. The Volt Van is in the Velora Catalog at 48,000.
- Load the bakery contact and the standard price book on the bakery's opportunity: `sh scripts/load-ep38.sh`. It is safe to run twice. (Crumb & Co Bakery and its open opportunity Crumb & Co Bakery - Delivery Vans come from the seed data.)
- To bring a fresh org as far as it can go by loading data, run `sh scripts/reset-to.sh ep28-end <org alias>`. A git tag restores files only, never the org. (This repository has no `ep37-end` tag yet.)

## Click path

1. Setup, Sharing Settings. In the external column, Account and Contract are Private and so are the catalog objects. Why: Sam needs record sharing as well as permission to read.
2. In the Catalogs section choose New and create the rule Partners Read Catalogs: records owned by Roles and Internal Subordinates of Administrator; shared with Portal Roles, AUser Partner Person Account (the role Sam holds); access Read Only. Confirm the warning that this exposes data to external users.
3. Make the same rule for Product Classifications and for Attribute Definitions.
4. Accounts need no new rule: an existing rule already shares accounts owned by Velora's users with all partner users, so the bakery's account is visible to Sam.
5. Setup, Permission Sets, Velora Dealer Configurator. You change it in code so the change is saved with the project.
6. In VS Code open `force-app/main/default/permissionsets/Velora_Dealer_Configurator.permissionset-meta.xml`. Field permissions give read on Order Product Period Boundary and Subscription Term. Each object permission block names an object with `allowRead` true: Application Usage Assignment (which configuring a product needs), then Account, Opportunity, Order and Quote, then the catalog objects (Product, Catalog, Category, Category Product, Classification, Classification Attribute, Attribute Definition, Product Attribute Definition, Selling Model, Selling Model Option).
7. Deploy it: `sf project deploy start --metadata PermissionSet:Velora_Dealer_Configurator --target-org <org alias>`. The result is Succeeded.
8. Open the contact Sam Okafor and choose Log in to Experience as User, then pick Velora Dealers. Under Accounts, All Accounts, Sam sees the 20 shared accounts, Crumb & Co Bakery among them.
9. Setup, Digital Experiences, All Sites, Velora Dealers, Builder. Pages, New Page, Object Pages, object Quote, Create. Why: Sam needs quote pages on the site.
10. On the Quote Detail page, in Components, Transaction, drag the Transaction Line Editor to the top region and set objectApiName to Quote. Publish with the description "Quote page with the line editor for dealers".
11. As Sam: Home, View Quotes, New Quote. Name it Crumb & Co Bakery - Refrigerated Vans and pick the opportunity Crumb & Co Bakery - Delivery Vans. Save. The quote (00000048 in the example) shows Created By Sam Okafor and the line editor.
12. In the internal org (as you) open the same quote: one record, not two. Add Product, choose the Volt Van from the Velora Catalog (48,000), Save, set the quantity to 3. The total is 144,000.
13. Back on the site as Sam, open View Quotes: the quote shows 144,000.

## Background on slides (not steps)

- A quote line is one product row on a quote. A partner (channel) discount is the dealer's discount on it; Revenue Management stores it on the quote line as a partner discount percent with a partner unit price. The Partner Community licence supports applying partner discounts on a site; the Customer Community Plus licence does not.
- The limit is Velora's rule in this example: 8 percent standard, 10 percent at most, which a validation rule can hold.
- Example arithmetic: the van lists at 48,000; 8 percent takes 3,840 off, so the partner unit price is 44,160 and 3 vans total 132,480.
- Limits: a partner does not manage the contract lifecycle from this site, and the ramp deals and qualification rules of earlier episodes are outside what this episode uses.

## Files in this repo used by this episode

- `force-app/main/default/permissionsets/Velora_Dealer_Configurator.permissionset-meta.xml`: the permission set for dealer users, deployed in step 7.
  - `sf project deploy start`: send local metadata to the org.
  - `--metadata PermissionSet:<name>`: only that permission set.
  - `--target-org`: which org.
- `scripts/load-ep38.sh`: adds the bakery contact (Dana Whitfield) and the standard price book to the bakery's opportunity; it creates the account and contact from `data/ep38-bakery/Account-Contact.json` only if the account is missing.
- `data/ep38-bakery/Account-Contact.json` and `data/ep38-bakery/Contact.json`: the records that script loads.
- `data/ep37-dealers/Account.json`: the dealer account from episode 37.
- The Quote page is built in Experience Builder; the Velora Dealers site pages are in `force-app/main/default/experiences/Velora_Dealers1/` (retrieved in episode 37).

## What you should see

Three sharing rules, a permission set deployed as Succeeded, a Velora Dealers site that shows Sam 20 accounts, a published Quote page with the line editor, and a quote created by Sam Okafor that totals 144,000 with 3 Volt Vans.

## Records and values

- Customer: Crumb & Co Bakery; opportunity Crumb & Co Bakery - Delivery Vans; quote Crumb & Co Bakery - Refrigerated Vans.
- 3 Volt Vans at 48,000 = 144,000.

## Try it yourself

Log in to the site as a dealer user and create a quote of your own, then ask your admin what limit your company sets on the dealer's discount.
