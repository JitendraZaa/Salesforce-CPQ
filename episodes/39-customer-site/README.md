# Episode 39: The customer site

All names, people, companies and numbers in this project are invented examples. Prices are in US dollars.

## What this episode builds

A self-service Experience Cloud site, Velora Customers, where Lena Fischer, an owner of a Velora Aria, signs in and reads her own invoice. You create her account, contact and customer user, build the site from the Self-Service Billing Portal template, add a sharing set, make her Connect plan (quote, order, billing schedule), post the invoice from VS Code, publish the site and sign in as Lena: Home lists invoice DOC-000000003 for 29.

## Before you start

- Starting point: the end of episode 38 and the Create Connect Quote button of episode 42 (`manifest/ep42-quote-action.xml`). Swift Couriers' billing setup exists. Person Accounts are off, so Lena is a business account named Lena Fischer with one contact. The org needs Customer Community Plus licences and the Billing licence.
- To bring a fresh org as far as it can go by loading data, run `sh scripts/reset-to.sh ep28-end <org alias>`. A git tag restores files only, never the org. (This repository has no `ep38-end` tag yet.)

## Click path

1. Sales, Accounts, New. Account Name Lena Fischer (Has Depot stays off). Save.
2. On the account add a contact, Lena Fischer, with her email address (`data/ep39-lena/Account-Contact.json` holds both records if you prefer to load them; use an address you control).
3. On the contact open the action menu and choose Enable Customer User. Leave the password email off so Lena is not emailed before the site is live, and confirm the welcome email notice. Licence Customer Community Plus; the profile is the org's custom copy of the Customer Community Plus profile.
4. Assign three permission sets to her user: Create Orders from Quotes and Price and Tax Calculations (the two quoting sets for Customer Community Plus) and Billing Experience Cloud User (opens a site built from the billing portal template).
5. Setup, Digital Experiences, All Sites, New. Choose the Self-Service Billing Portal template, name it Velora Customers, URL path customers, and create it. It starts in Preview, visible only to the people building it.
6. In the site's Administration, Members, move the custom Customer Community Plus profile to the selected side and Save. Why: a site is closed to everyone until you name who belongs.
7. Setup, Digital Experiences, Settings, Sharing Sets, New: name Customer Invoices, profile the custom Customer Community Plus profile, object Invoice, access rule User.Account = Invoice.BillingAccount, access Read Only. Why: without it Lena's invoice exists but she cannot see it.
8. Make Lena's plan at Velora's desk. On her opportunity (Lena Fischer - Velora Connect) click Create Connect Quote (episode 42): one Velora Connect line, 1 at 29 (348 a year). Mark the quote Accepted, then Create Order, Create Single Order.
9. Open the order (00000132 in the example): Bill To Contact Lena, her addresses and the legal entity, as in episode 24. Set the status to Activated. Billing starts only from an activated order: Salesforce builds a billing schedule (348 from 1 Nov 2026).
10. In VS Code open `scripts/api/ep39-generate-invoice.json`. `billingScheduleIds` lists the schedules to bill (Lena's one; replace it with your own), `action` Posted creates and posts the invoice, and `invoiceDate` and `targetDate` are both 2026-11-01.
11. Run `sh scripts/api/generate-invoice.sh scripts/api/ep39-generate-invoice.json <org alias>`. `success` is true and invoice DOC-000000003 is posted, 29, due 1 Dec 2026.
12. In the site's Administration, Emails, turn the welcome email off and save. In Settings, click Activate and confirm. Why: activating switches the site on for its members.
13. In Builder, Publish with the description "First release of the Velora customer site".
14. Sign in as Lena (from the contact, Log in to Experience as User). Home says "Hello Lena" and lists DOC-000000003: 29, dated 1 Nov 2026, due 1 Dec 2026, Not Settled. Open it: billing account Lena Fischer, one line Velora Connect 29 for 1 to 30 Nov 2026.

## Background on slides (not steps)

- Customer user, licence, profile, permission set, self-service and sharing set are explained as words.
- Velora Connect is a plan of 29 a month with no term; Lena's Aria is part of the story, not a record in this episode.
- Download (a PDF of the invoice on demand, once site users hold the document permission set) and Pay (online payment, which needs a merchant account with a payment gateway) are shown as ideas on the invoice page; this series stops at reading the invoice.

## Files in this repo used by this episode

- `scripts/api/ep39-generate-invoice.json`: the invoice request body described in step 10.
- `scripts/api/generate-invoice.sh`: sends the body to the Billing invoice-generation service. It runs `sf api request rest "/services/data/v65.0/commerce/invoicing/invoices/collection/actions/generate" --method POST --body "$(cat "$BODY")" --target-org "$ORG"`. Usage: `sh scripts/api/generate-invoice.sh [body file] [org alias]`.
- `data/ep39-lena/Account-Contact.json`: Lena's account and contact.
- `force-app/main/default/flows/Create_Connect_Quote.flow-meta.xml` and `manifest/ep42-quote-action.xml`: the Create Connect Quote button from episode 42.

## What you should see

A live Velora Customers site; signed in as Lena, Home lists one invoice, DOC-000000003, 29, Not Settled, and the invoice shows one Velora Connect line.

## Records and values

- Account and contact Lena Fischer; quote 00000049; order 00000132; invoice DOC-000000003, 29, 1 Nov 2026 to 1 Dec 2026.

## Try it yourself

Create the customer site, show the invoice list on a page, and sign in as a customer to check that only that customer's invoices show.
